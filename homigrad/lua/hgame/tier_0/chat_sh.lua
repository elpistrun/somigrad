--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_0/chat_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_0\\chat_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
AdminPanel_Command_Registry("closedev",{"bool"}):SetCategory("rcon")
AdminPanel_Command_Registry("setmaxplayers",{"number"}):SetCategory("rcon")
AdminPanel_Command_Registry("setworkshopid_formap",{"number"}):SetCategory("rcon")
AdminPanel_Command_Registry("getlistentities",{}):SetCategory("rcon")

AdminPanelSuccessReg("CanEmbedCustomChat",nil,"rights")
AdminPanelSuccessReg("free_slot",nil,"rights")

AdminPanelSuccessReg("CanChangePlayerModel",nil,"rights")

hook.Add("CanChangePlayerModel","!Homigrad",function(ply)
    if ply:HasSuccess("CanChangePlayerModel") then return true end
end)

