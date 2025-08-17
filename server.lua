local usingOx = (Config.Inventory == 'ox')
local usingQS = (Config.Inventory == 'qs')

-- Keep track of active timers per stash
local cleanupTimers = {}  -- [stashId] = timeoutHandle/boolean

-- Helper to clear any existing cleanup for a stash
local function cancelCleanup(stashId)
    if cleanupTimers[stashId] then
        -- Citizen.SetTimeout doesn’t return a cancel handle; we use a soft flag
        cleanupTimers[stashId] = false
    end
end

-- Utility: schedule auto-clean
local function scheduleCleanup(stashId, seconds)
    cancelCleanup(stashId)
    cleanupTimers[stashId] = true
    local aliveFlag = cleanupTimers[stashId]

    SetTimeout(seconds * 1000, function()
        -- if someone cancelled/overwrote, bail
        if cleanupTimers[stashId] ~= aliveFlag then return end

        if usingOx and GetResourceState('ox_inventory') ~= 'missing' then
            -- Clear ox stash contents safely
            local ok = false
            -- Try official export if present
            if exports.ox_inventory and exports.ox_inventory.ClearInventory then
                ok = exports.ox_inventory:ClearInventory(stashId, 'stash')
            end
            -- Fallback to event (some builds expose it)
            if not ok then
                TriggerEvent('ox_inventory:clearInventory', stashId, 'stash')
            end
            -- Optionally, you could unregister, but ox handles dynamic stashes fine.
        elseif usingQS and GetResourceState('qs-inventory') ~= 'missing' then
            -- QS cleanup:
            -- Many QS versions provide a server event to clear stashes; if yours differs, replace below.
            -- Known pattern:
            TriggerEvent('qs-inventory:server:ClearStash', stashId)
            -- If your QS doesn’t have this event, the next time we re-open with a fresh stashId (session strategy) it’ll be empty.
            -- To force a real purge on older QS builds, you may need to implement a custom stash wipe in QS or switch to 'coords' id + internal clear.
        end

        cleanupTimers[stashId] = nil
    end)
end

-- Open stash request from client
RegisterNetEvent('bwrp_temptrash:openBin', function(stashId, opts)
    local src = source
    if not stashId or type(opts) ~= 'table' then return end

    local label = opts.label or 'Trash Bin'
    local slots = tonumber(opts.slots or 20)
    local weight = tonumber(opts.weight or 20000)
    local lockWhileOpen = opts.lockWhileOpen and true or false

    if usingOx and GetResourceState('ox_inventory') ~= 'missing' then
        -- Register (or re-register) a stash, then open it for the player
        -- ox_inventory will reuse same stashId and keep metadata; this is fine for bins.
        exports.ox_inventory:RegisterStash(
            stashId,
            label,
            slots,
            weight,
            nil,   -- owner
            nil,   -- groups
            { x = opts.x, y = opts.y, z = opts.z }, -- coords (optional; helps logging)
            lockWhileOpen
        )

        -- Open for the player
        exports.ox_inventory:openInventory('stash', { id = stashId }, src)

        -- Reset the cleanup timer every open (keeps it fresh while people use it)
        scheduleCleanup(stashId, Config.AutoCleanSeconds)

    elseif usingQS and GetResourceState('qs-inventory') ~= 'missing' then
        -- QS pattern: open stash via event (standard usage)
        -- Some builds use "inventory:server:OpenInventory" (QB pattern); QS often mirrors this.
        local stashData = {
            maxweight = weight,
            slots = slots,
            label = label
        }

        -- Try QS exported open, else fallback to qb-style event
        local opened = false
        if exports['qs-inventory'] and exports['qs-inventory'].OpenInventory then
            opened = exports['qs-inventory']:OpenInventory(src, 'stash', stashId, stashData)
        end
        if not opened then
            -- qb-style fallback (many QS builds listen to this too)
            TriggerClientEvent('inventory:client:OpenInventory', src, 'stash', { id = stashId, type = 'stash', title = label, slots = slots, maxweight = weight })
            TriggerClientEvent('inventory:client:SetCurrentStash', src, stashId)
            TriggerEvent('inventory:server:OpenInventory', 'stash', stashId, stashData)
        end

        -- For QS, to ensure real deletion, prefer Config.StashIdStrategy='session' (fresh id each open).
        scheduleCleanup(stashId, Config.AutoCleanSeconds)
    else
        TriggerClientEvent('chat:addMessage', src, { args = { '^3TRASH', 'No supported inventory found. Check Config.Inventory and dependencies.' } })
    end
end)
