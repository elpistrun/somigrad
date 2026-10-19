--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/food/tier_1_content/wep_food_pepsi_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\food\\tier_1_content\\wep_food_pepsi_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Reg("wep_food_pepsi","wep_food_base")
if not SWEP then return end

SWEP.PrintName = "Pepsi"

SWEP.WorldModel = "models/jorddrink/pepcan01a.mdl"

SWEP.wmVector = Vector(2.5,2,-1)
SWEP.wmAngle = Angle(0,180,0)

SWEP.HandBack = 0
SWEP.HandRight = 0

SWEP.ParticleColor = Color(75,65,65)
SWEP.SndEet = SndEatWater

SWEP.HungryAdd = 0.5

SWEP.dwsItemPos = Vector(0,0,-0.2)
SWEP.dwsItemAng = Angle(0,0,0)
SWEP.dwsItemFOV = -14
