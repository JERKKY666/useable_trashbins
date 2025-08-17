fx_version 'cerulean'
game 'gta5'

name 'bwrp_temptrash'
author 'BWRP / ChatGPT'
description 'Temporary trash-bin stashes with auto-clean for ox_inventory or qs-inventory, and ox_target or qb-target.'
version '1.0.0'

lua54 'yes'

shared_script 'config.lua'
client_scripts { 'client.lua' }
server_scripts { '@oxmysql/lib/MySQL.lua', 'server.lua' }

dependencies {
    'ox_inventory',
    'ox_target'
}
