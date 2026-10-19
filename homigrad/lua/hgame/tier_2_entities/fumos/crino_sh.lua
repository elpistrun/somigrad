--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/fumos/crino_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\fumos\\crino_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Reg("fumos_crino",{"fumos_fumo"})
if not SWEP then return end

SWEP.PrintName = "Crino"
SWEP.NextBotClass = "npc_komeiji_fumo_enemy"
SWEP.WorldModel = "models/tadano/fumo/pack/cirno.mdl"

SWEP.dwsItemPos = Vector(45,0,-1)
SWEP.dwsItemAng = Angle(0,90,0)

SWEP.wmVector1 = Vector(3,2,-4)
SWEP.wmVector2 = Vector(3,2,-4)

SWEP.wmAngle1 = Angle(20,190,-20)
SWEP.wmAngle2 = Angle(-120,190,-20)
