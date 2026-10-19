--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_donat/lua/hinit/donat/missions/items/tier_0/base/tier_0_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad_donat\\lua\\hinit\\donat\\missions\\items\\tier_0\\base\\tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Mission = MissionItem_Reg("base",nil,true)
if not Mission then return INCLUDE_BREAK end

util.tableLink(Mission,DonatItemClasses["base"][1])

function Mission:Construct()
    for steamid64,inventory in pairs(MissionList or {}) do
        MissionItem_SetupList(steamid64)
    end

    if SERVER then
        for i,ply in pairs(player.GetAll()) do
            ply.missionDataWaitSync = nil
        end
    end
end

if SERVER then return end

function Mission:StartUserCommand(cmd)
    net.Start("mission_item_cmd")
    net.WriteString(self.owner)
    net.WriteString(tostring(self.id))
    if cmd then net.WriteString(cmd) end
end

function Mission:DrawIcon(w,h,panel)
    surface.SetDrawColor(0,0,0)
    surface.DrawRect(0,0,w,h)

    draw.SimpleText(self.class,"HS.12")
end
