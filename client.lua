local usingOxTarget = (Config.Target == 'ox')
local usingQBTarget = (Config.Target == 'qb')

local trashModels = Config.TrashProps

local function makeStashIdFromEntity(ent)
    local x, y, z = table.unpack(GetEntityCoords(ent))
    -- Round coords to 2 decimals for stability
    x = math.floor(x * 100 + 0.5) / 100
    y = math.floor(y * 100 + 0.5) / 100
    z = math.floor(z * 100 + 0.5) / 100

    if Config.StashIdStrategy == 'coords' then
        return ('trash_%s_%s_%s'):format(x, y, z)
    else
        -- session based, more aggressive cleanup (generates a fresh id every open)
        return ('trash_%s_%s_%s_%d'):format(x, y, z, GetGameTimer())
    end
end

local function canUseEntity(ent)
    return DoesEntityExist(ent) and not IsEntityDead(ent)
end

local function requestOpenTrash(ent)
    if not canUseEntity(ent) then return end
    local stashId = makeStashIdFromEntity(ent)

    -- Gather a reasonable coord to store in stash metadata (nice for ox logs)
    local coords = GetEntityCoords(ent)

    TriggerServerEvent('bwrp_temptrash:openBin', stashId, {
        label = Config.StashLabel,
        slots = Config.StashSlots,
        weight = Config.StashWeight,
        lockWhileOpen = Config.LockWhileOpen,
        x = coords.x, y = coords.y, z = coords.z,
    })
end

-- Target registration
CreateThread(function()
    if usingOxTarget and GetResourceState('ox_target') ~= 'missing' then
        exports.ox_target:addModel(trashModels, {
            {
                name  = 'bwrp_open_trash',
                icon  = Config.TargetIcon,
                label = Config.TargetLabel,
                distance = Config.TargetDistance,
                onSelect = function(data)
                    if data and data.entity then
                        requestOpenTrash(data.entity)
                    end
                end
            }
        })
    elseif usingQBTarget and GetResourceState('qb-target') ~= 'missing' then
        for _, model in ipairs(trashModels) do
            exports['qb-target']:AddTargetModel(model, {
                options = {
                    {
                        icon = 'fas fa-trash',
                        label = Config.QBTargetIconText .. ' ' .. Config.TargetLabel,
                        action = function(entity)
                            requestOpenTrash(entity)
                        end
                    }
                },
                distance = Config.TargetDistance
            })
        end
    else
        print('^3[bwrp_temptrash]^0 No target system detected. Set Config.Target correctly and ensure dependency is started.')
    end
end)
