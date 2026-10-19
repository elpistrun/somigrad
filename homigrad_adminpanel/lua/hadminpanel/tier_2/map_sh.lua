--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_adminpanel/lua/hadminpanel/tier_2/map_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:11 <
]]

-- "addons\\homigrad_adminpanel\\lua\\hadminpanel\\tier_2\\map_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
AdminPanel_Command_Registry("map",{{type = "string",name = "Имя карты"}},nil,"rcon")
AdminPanel_Command_Registry("map_block",{{type = "string",name = "Имя карты"},{type = "bool",name = "Запретить"}},nil,"rcon")

net.ReceiveMediaToken("map_list.txt",function(body)
    MapList = util.JSONToTable(body,true)
end)

net.ReceiveMediaToken("map_block.txt",function(body)
    MapsBlocked = util.JSONToTable(body,true) or {}

    event.Call("Map Blocked Sync")
end)

