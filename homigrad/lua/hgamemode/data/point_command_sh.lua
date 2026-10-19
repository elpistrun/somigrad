--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/data/point_command_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\data\\point_command_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
AdminPanel_Command_Registry("pointpagesrandom",{"bool"},"game",nil,"mapData")
AdminPanel_Command_Registry("point",{{type = "string",name = "Имя точки"},{type = "number",name = "Радиус"},{type = "string",name = "Дополнительная информация"}},"game",nil,"mapData")
AdminPanel_Command_Registry("pointremove",{{type = "string",name = "Имя точки"},{type = "number",name = "ID Точки"}},"game",nil,"mapData")
AdminPanel_Command_Registry("pointclear",{{type = "string",name = "Имя точек"}},"game",nil,"mapData")
AdminPanel_Command_Registry("pointpage",{{type = "number",name = "Номер страницы"}},"game",nil,"mapData")
AdminPanel_Command_Registry("points",{},"game",nil,"mapData")
