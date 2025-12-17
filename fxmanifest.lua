fx_version 'cerulean'
game 'gta5'
lua54 "yes"

author 'zqmvo'
description 'Enhanced Discord Rich Presence with customizable buttons and detailed info'
version '2.0.0'

shared_script '@ox_lib/init.lua'

client_scripts {
    'discordpr_cl.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', 
    'discordpr_sv.lua'
}

-- Export functions for other resources
server_export 'updateQueue'
server_export 'getPlayerCount' 
server_export 'getMaxPlayers'

dependency 'ox_lib'

dependencies {
    'oxmysql' 
}