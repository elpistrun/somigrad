--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/fumos/yuyuko_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\fumos\\yuyuko_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Reg("fumos_yuyuko",{"fumos_fumo"})
if not SWEP then return end

SWEP.PrintName = "Yuyuko"
SWEP.NextBotClass = "npc_yuyuko"
SWEP.WorldModel = "models/tadano/fumo/pack/yuyu.mdl"

SWEP.dwsItemPos = Vector(10,30,-10)
SWEP.dwsItemAng = Angle(0,0,0)

SWEP.wmVector1 = Vector(5,15,5)
SWEP.wmVector2 = Vector(10,-10,0)

SWEP.wmAngle1 = Angle(-40,190,-20)
SWEP.wmAngle2 = Angle(150,190,-20)
