--[[
    Homigrad Points — Shared
    Net string registration + shared constants.
]]

HGPOINTS = HGPOINTS or {}
HGPOINTS.PLAYER = 1
HGPOINTS.LOOT   = 2

HGPOINTS.COLOR_PLAYER = Color(80, 200, 120)
HGPOINTS.COLOR_LOOT   = Color(255, 165, 30)

if SERVER then
    util.AddNetworkString("hg_points_sync")   -- sv → cl: full point list
    util.AddNetworkString("hg_points_add")    -- cl → sv: add a point
    util.AddNetworkString("hg_points_remove") -- cl → sv: remove nearest point
    util.AddNetworkString("hg_points_clear")  -- cl → sv: clear all of type
end
