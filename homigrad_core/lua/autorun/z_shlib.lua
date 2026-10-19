--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/autorun/z_shlib.lua <
    > Callstack:  <
]]

-- "addons\\homigrad_core\\lua\\autorun\\z_shlib.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
print("\thomigrad start.")
    IncludeDir("hgame/")
    if SERVER then
        AddCSLuaFile("hgame/tier_1/client/cl_weapon_selector.lua")
    else
        include("hgame/tier_1/client/cl_weapon_selector.lua")
    end
print("\thomigrad end")

print("\thomigrad gamemode start.")
    IncludeDir("hgamemode/")
print("\thomigrad gamemode end.")

local Run = function()
    print("\thomigrad init start.")
        IncludeDir("hinit/")
    print("\thomigrad init end.")
end

event.Add("Initialize","Homigrad Out",Run)

if Initialize then Run() end
