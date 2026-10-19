--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/weapons/tier_1_content/pistol-rifle/mp7_sh.lua <
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

-- "addons\\homigrad\\lua\\hinit\\weapons\\tier_1_content\\pistol-rifle\\mp7_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Reg("wep_mp7","wep_mp5")
if not SWEP then return end

SWEP.PrintName 				= "MP7"

------------------------------------------

SWEP.Primary.ClipSize		= 24
SWEP.Primary.DefaultClip	= 24
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "pistol"

SWEP.Primary.Cone = 0
SWEP.Primary.Spread = 0.03
SWEP.Primary.Damage = 35
SWEP.Primary.Force = 140
SWEP.Primary.Wait = 1 / 17

SWEP.Primary.Sound = {"pwb2/weapons/usptactical/usp_unsil-1.wav"}
SWEP.Primary.SoundPitch = 100

SWEP.Primary.SoundFar = "arccw_go/mp7/mp7-1-distant.wav"

SWEP.HoldType = "smg"

SWEP.Slot					= 2
SWEP.SlotPos				= 0

SWEP.WorldModel				= "models/weapons/arccw_go/v_smg_mp7.mdl"

SWEP.vbwPos = Vector(-16,2,5)
SWEP.vbwAng = Angle(0,0,0)

SWEP.dwsItemPos = Vector(-19,5,5.5)
SWEP.dwsItemFOV = -3

SWEP.wmVector = Vector(-10,7,-7)
SWEP.wmAngle = Angle(-1,7,180 + 2.5)

SWEP.MuzzlePos = Vector(2.5,0,0.2)
SWEP.MuzzleAng = Angle(0,0,0)
SWEP.CameraPos = Vector(-20,0,2.8)
SWEP.CR_Scope = 2

SWEP.Reload1 = "pwb2/weapons/p90/magin.wav"
SWEP.Reload2 = "pwb2/weapons/mp5a3/kry_mp5_magin2.wav"
SWEP.Reload3 = "pwb2/weapons/p90/bolt.wav"
SWEP.Reload4 = false

SWEP.BoltBone = "v_weapon.Bolt"
SWEP.BoltMul = 2
SWEP.BoltMulX = 0

SWEP.ClipBone = "v_weapon.Clip"

SWEP.FakeVec1 = Vector(4,-11,-13)
SWEP.FakeVec2 = Vector(8,-3,0)

SWEP.DeploySound = "arccw_go/mp7/mp7_draw.wav"

SWEP.eyeSprayH = 4
SWEP.eyeSprayW = 0.2
SWEP.eyeSpraySinW = 0.2
SWEP.eyeSprayRandW = 0.1

SWEP.eyeSprayLSet = 0.9
SWEP.eyeSprayLReset = 0.85

SWEP.eyeSprayHoldK = 0.25

function SWEP:ShootEffect(pos,dir)
    local color = Color(255,225,125)

    self:ShootLight(pos,dir,color)
    self:ShootEffect_Manual(pos,dir,color,{
        gasTimeScale = 2.5,
        gasSideScale = 2.75,
        gasForwardScale = 3
    })
end

