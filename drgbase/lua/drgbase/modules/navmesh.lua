--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/drgbase/lua/drgbase/modules/navmesh.lua <
    > Callstack: addons/drgbase/lua/autorun/drgbase.lua:93
addons/drgbase/lua/autorun/drgbase.lua:110 <
]]

if CLIENT then return end

local NAVAREAS_CENTERS = {}
function navmesh.DrG_GetAreaFromCenter(pos)
	return NAVAREAS_CENTERS[tostring(pos)]
end
for i, area in ipairs(navmesh.GetAllNavAreas()) do
	NAVAREAS_CENTERS[tostring(area:GetCenter())] = area
end

