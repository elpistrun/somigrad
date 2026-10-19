--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/weapons/tier_1_content/pistol-rifle/bizon_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
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

-- "addons\\homigrad\\lua\\hinit\\weapons\\tier_1_content\\pistol-rifle\\bizon_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Reg("wep_bizon","wep_mp5")
if not SWEP then return end

SWEP.PrintName 				= "Bizon"

------------------------------------------

SWEP.Primary.ClipSize		= 45
SWEP.Primary.DefaultClip	= 45
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "pistol"

SWEP.Primary.Cone = 0
SWEP.Primary.Spread = 0.075
SWEP.Primary.Damage = 25
SWEP.Primary.Force = 140
SWEP.Primary.Wait = 1 / 13

SWEP.Primary.Sound = {"arccw_go/bizon/bizon_01.wav","arccw_go/bizon/bizon_02.wav"}
SWEP.Primary.SoundFar = "arccw_go/ump45/ump45-1-distant.wav"

SWEP.HoldType = "ar2"

SWEP.Slot					= 2
SWEP.SlotPos				= 0

SWEP.WorldModel				= "models/weapons/arccw_go/v_smg_bizon.mdl"

SWEP.vbwPos = Vector(-16,2,5)
SWEP.vbwAng = Angle(0,0,0)

SWEP.dwsItemPos = Vector(-18,5,5.4)
SWEP.dwsItemFOV = -2

SWEP.wmVector = Vector(-13,6,-6)
SWEP.wmAngle = Angle(-1,7,180 + 7)

SWEP.MuzzlePos = Vector(0,-0.05,0)
SWEP.MuzzleAng = Angle(0,0,0)
SWEP.CameraPos = Vector(-20,0,2.2)
SWEP.CR_Scope = 4

SWEP.Reload1 = "arccw_go/bizon/bizon_clipout.wav"
SWEP.Reload2 = "arccw_go/bizon/bizon_clipin.wav"
SWEP.Reload3 = "arccw_go/bizon/bizon_boltback.wav"
SWEP.Reload4 = "arccw_go/bizon/bizon_boltforward.wav"

SWEP.BoltBone = "v_weapon.bizon_bolt"
SWEP.BoltMul = 2
SWEP.BoltMulX = 0

SWEP.ClipBone = "v_weapon.bizon_clip"

SWEP.FakeVec1 = Vector(4,-11,-13)
SWEP.FakeVec2 = Vector(8,-3,0)

SWEP.DeploySound = "arccw_go/bizon/bizon_draw.wav"
