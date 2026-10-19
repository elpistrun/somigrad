--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/weapons/tier_1_content/rifle_tier_0/m4a1_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad\\lua\\hinit\\weapons\\tier_1_content\\rifle_tier_0\\m4a1_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Reg("wep_m4a1","wep_ak47")
if not SWEP then return end

SWEP.PrintName 				= "M4A1"

------------------------------------------

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "rifle"

SWEP.Primary.Cone = 0
SWEP.Primary.Spread = 0.001
SWEP.Primary.Damage = 42
SWEP.Primary.Force = 140
SWEP.Primary.Wait = 1 / 11

SWEP.Primary.Sound = {"pwb2/weapons/m4a1/ru-556 fire unsilenced.wav"}
SWEP.Primary.SoundFar = {"arccw_go/m4a1/m4a1_us_distant.wav","arccw_go/m4a1/m4a1_us_distant_02.wav","arccw_go/m4a1/m4a1_us_distant_03.wav"}

SWEP.HoldType = "ar2"

SWEP.Slot					= 2
SWEP.SlotPos				= 0

SWEP.WorldModel				= "models/weapons/arccw_go/v_rif_m4a1.mdl"

SWEP.vbwPos = Vector(-10,2,5)
SWEP.vbwAng = Angle(0,0,0)

SWEP.dwsItemPos = Vector(-16.5,6,5)

SWEP.wmVector = Vector(-12,6,-4)
SWEP.wmAngle = Angle(-1,8,180 - 2)

SWEP.MuzzlePos = Vector(0,0,0)
SWEP.MuzzleAng = Angle(0,0,0)
SWEP.CameraPos = Vector(-26,-0.045,2.8)
SWEP.CR_Scope = 2

SWEP.Reload1 = "arccw_go/m4a1/m4a1_clipout.wav"
SWEP.Reload2 = "pwb2/weapons/m4a1/ru-556 clip in 2.wav"
SWEP.Reload3 = "pwb2/weapons/m4a1/ru-556 bolt back.wav"
SWEP.Reload4 = "pwb2/weapons/m4a1/ru-556 bolt release.wav"

SWEP.BoltBone = "v_weapon.M4A1_bolt"
SWEP.BoltMul = 2

SWEP.ClipBone = "v_weapon.M4A1_Clip"

SWEP.FakeVec1 = Vector(0,-12,-12)
SWEP.FakeVec2 = Vector(8,-3,0)

SWEP.DeploySound = "arccw_go/m4a1/m4a1_draw.wav"

SWEP.eyeSprayH = 0.75

SWEP.eyeSpraySinAddW = -2
