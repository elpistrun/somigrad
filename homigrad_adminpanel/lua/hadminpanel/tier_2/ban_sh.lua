--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_adminpanel/lua/hadminpanel/tier_2/ban_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:11 <
]]

-- "addons\\homigrad_adminpanel\\lua\\hadminpanel\\tier_2\\ban_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
if CLIENT then
    manager_BanList = Create_SyncDataManager("AdminPanelBanList","AP Ban List Sync","adminpanel","adminpanel_ban_sync")
    manager_BanMessage = Create_SyncDataManager("AdminPanelBanMessage","AP Ban Message Sync","adminpanel","adminpanel_ban_message_sync")
end

AdminPanelSuccessReg("ban_list",nil,"rights")
AdminPanel_Command_Registry("ban_message",{"string"},nil,"project")

local cmd,success = AdminPanel_Command_Registry("ban",{{type = "steamid",isRequired = true},{type = "string",name = "Время",desc = "Можно указать в конце (h,d,w,m,y) для умножения времени",isRequired = true},{type = "string",name = "Причина",isRequired = true}},"async",nil,"admin")
success.parametrs = {
    {name = "min",type = "string",canParse = function(value)
        if tonumber(value) and tonumber(value) < 0 then return false,"value < 0" end
    end},
    {name = "max",type = "string",canParse = function(value)
        if tonumber(value) and tonumber(value) < 0 then return false,"value < 0" end
    end},
}

AdminPanel_Command_Registry("unban",{{type = "steamid",isRequired = true}},"async",nil,"admin")
AdminPanel_Command_Registry("kick",{{type = "player",isRequired = true},{type = "string",name = "Причина",isRequired = true}},"async",nil,"admin")

