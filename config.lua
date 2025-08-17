Config = {}

-- Framework (for permissions/hooks if you ever expand)
Config.Framework = 'ESX' -- 'ESX' | 'QB' | 'NONE'

-- Inventory system
Config.Inventory = 'ox'   -- 'ox' | 'qs'

-- Target system
Config.Target = 'ox'      -- 'ox' | 'qb'

-- Target UI text/icon
Config.TargetLabel = 'Open Trash Bin'
Config.TargetIcon  = 'fa-solid fa-trash'  -- ox_target supports FontAwesome

-- Stash settings
Config.StashSlots  = 20              -- slots in each bin stash
Config.StashWeight = 20000           -- max weight (ox: grams; qs: their units)
Config.StashLabel  = 'Trash Bin'     -- label shown in UI

-- Auto-clean (seconds)
Config.AutoCleanSeconds = 3600        -- 5 min default

-- Restrict opening while someone is inside? (ox-only)
Config.LockWhileOpen = true

-- Prop models recognized as trash bins / dumpsters (add/remove as you like)
Config.TrashProps = {
    `prop_dumpster_01a`,
    `prop_dumpster_02a`,
    `prop_dumpster_02b`,
    `prop_dumpster_3a`,
    `prop_dumpster_4a`,
    `prop_bin_01a`,
    `prop_bin_03a`,
    `prop_bin_04a`,
    `prop_bin_05a`,
    `prop_bin_06a`,
    `prop_bin_07a`,
    `prop_bin_07b`,
    `prop_bin_08a`,
    `prop_bin_08open`,
    `prop_bin_10a`,
    `prop_bin_11a`,
    `prop_recyclebin_01a`,
    `prop_recyclebin_02_c`,
    `prop_recyclebin_02_d`,
    `prop_cs_bin_01`,
    `prop_ld_binbag_01`,
}

-- Distance for target interaction
Config.TargetDistance = 2.0

-- If using qb-target, choose an icon label since FA is not used the same way
Config.QBTargetIconText = '🗑️'

-- Advanced: stash id strategy
-- 'coords' (stable per entity position) or 'session' (always fresh id; best for QS cleanup fallback)
Config.StashIdStrategy = 'coords' -- 'coords' | 'session'
