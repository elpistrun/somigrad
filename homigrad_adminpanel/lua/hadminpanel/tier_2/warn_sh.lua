--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_adminpanel/lua/hadminpanel/tier_2/warn_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:11 <
]]

-- "addons\\homigrad_adminpanel\\lua\\hadminpanel\\tier_2\\warn_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
if CLIENT then
    manager_WarnList = Create_SyncDataManager("AdminPanelWarnList","AP Warn List Sync","adminpanel","adminpanel_warn_sync")
end

AdminPanelSuccessReg("warn_list",nil,"rights")

AdminPanel_Command_Registry("warn",{{type = "steamid",required = true},{type = "number",name = "Количество",required = true},{type = "string",name = "Причина",required = true}},"async",nil,"admin")
AdminPanel_Command_Registry("unwarn",{{type = "steamid",required = true},{type = "number",name = "Количество",required = true},{type = "string",name = "Причина",required = true}},"async",nil,"admin")
AdminPanel_Command_Registry("clearwarn",{{type = "steamid",required = true},{type = "string",name = "Причина",required = true}},"async",nil,"admin")
AdminPanel_Command_Registry("getwarn",{{type = "steamid",required = true}},"async",nil,"admin")
