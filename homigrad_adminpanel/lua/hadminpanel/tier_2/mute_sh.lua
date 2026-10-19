--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_adminpanel/lua/hadminpanel/tier_2/mute_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:11 <
]]

-- "addons\\homigrad_adminpanel\\lua\\hadminpanel\\tier_2\\mute_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
if CLIENT then
    manager_MuteList = Create_SyncDataManager("AdminPanelMuteList","AP Mute List Sync","adminpanel","adminpanel_mute_sync")
end

local cmd,success = AdminPanel_Command_Registry("mute",{{type = "steamid"},{type = "string",name = "Время"},{type = "string",name = "Причина"}},"async",nil,"admin")
success.parametrs = {
    {name = "min",type = "string",canParse = function(value)
        if tonumber(value) and tonumber(value) < 0 then return false,"value < 0" end
    end},
    {name = "max",type = "string",canParse = function(value)
        if tonumber(value) and tonumber(value) < 0 then return false,"value < 0" end
    end},
}

AdminPanel_Command_Registry("unmute",{{type = "steamid"}},"async",nil,"admin")

