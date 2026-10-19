--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_adminpanel/lua/hadminpanel/tier_2/gag_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:11 <
]]

-- "addons\\homigrad_adminpanel\\lua\\hadminpanel\\tier_2\\gag_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
if CLIENT then
    manager_GagList = Create_SyncDataManager("AdminPanelGagList","AP Gag List Sync","adminpanel","adminpanel_gag_sync")
end

local cmd,success = AdminPanel_Command_Registry("gag",{{type = "steamid",isRequired = true},{type = "string",name = "Время",isRequired = true},{type = "string",name = "Причина",isRequired = true}},"async",nil,"admin")
success.parametrs = {
    {name = "min",type = "string",canParse = function(value)
        if tonumber(value) and tonumber(value) < 0 then return false,"value < 0" end
    end},
    {name = "max",type = "string",canParse = function(value)
        if tonumber(value) and tonumber(value) < 0 then return false,"value < 0" end
    end},
}

AdminPanel_Command_Registry("ungag",{{type = "steamid",isRequired = true}},"async",nil,"admin")

