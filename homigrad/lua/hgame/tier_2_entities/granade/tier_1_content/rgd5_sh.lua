--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/granade/tier_1_content/rgd5_sh.lua <
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

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\granade\\tier_1_content\\rgd5_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Reg("wep_gnade_rgd5","wep_gnade_base")
if not SWEP then return end

SWEP.PrintName = "RGD-5"
SWEP.Instructions = L("wep_gnade_rgd5_desc")

SWEP.WorldModel = "models/pwb/weapons/w_rgd5.mdl"

SWEP.Granade = "ent_gnade_rgd5"

SWEP.dwsItemPos = Vector(9.2,0,-5)
SWEP.dwsItemAng = Angle(32,0,0)
SWEP.dwsItemFOV = -15

SWEP.ExplosiveClass = "explosive_rgd5"
SWEP.TimeDetonate = 3.5
