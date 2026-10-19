--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_adminpanel/lua/hadminpanel/tier_1/command_game_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:11 <
]]

-- "addons\\homigrad_adminpanel\\lua\\hadminpanel\\tier_1\\command_game_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
AdminPanel_Command_Registry("help",{{type = "string",name = "Имя команды"}})
AdminPanel_Command_Registry("noclip",{"players^"},"game",nil,"admin_operator")
AdminPanel_Command_Registry("tp",{"players"},"game",nil,"admin_operator")
AdminPanel_Command_Registry("goto",{"players"},"game",nil,"admin_operator")
AdminPanel_Command_Registry("bring",{"players"},"game",nil,"admin_operator")
AdminPanel_Command_Registry("god",{"players^"},"game",nil,"admin_operator")
AdminPanel_Command_Registry("ungod",{"players^"},"game",nil,"admin_operator")

AdminPanel_Command_Registry("slay",{"players"},"game",nil,"admin_operator")
AdminPanel_Command_Registry("hp",{"players","number"},"game",nil,"admin_operator")

AdminPanel_Command_Registry("respawn",{"players^"},"game",nil,"admin_operator")
AdminPanel_Command_Registry("setmodel",{"players","string"},"game",nil,"admin_operator")
AdminPanel_Command_Registry("give",{"players","string"},"game",nil,"admin_operator")
AdminPanel_Command_Registry("setmaterial",{"players","string"},"game",nil,"admin_operator")
AdminPanel_Command_Registry("setcolor",{"players","number","number","number"},"game",nil,"admin_operator")

if SERVER then return end

local SuppressEngineLighting
AdminPanel_Command_Create("SuppressEngineLighting",{"bool"},function(args)
    SuppressEngineLighting = tonumber(args[1])

    if TypeID(SuppressEngineLighting) == TYPE_NUMBER and SuppressEngineLighting <= 0 then SuppressEngineLighting = nil end
end)

event.Add("PreRenderScene","SuppressEngineLighting",function()
    if SuppressEngineLighting then
        render.SuppressEngineLighting(true)
        render.SetLightingMode(SuppressEngineLighting)
    end
end,20)

event.Add("PreRenderHUD","SuppressEngineLighting",function()
    if SuppressEngineLighting then
        render.SuppressEngineLighting(false)
        render.SetLightingMode(0)
    end
end,20)


