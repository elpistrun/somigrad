--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/weapons/tier_1_content/rifle_tier_0/neg_sh.lua <
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

-- "addons\\homigrad\\lua\\hinit\\weapons\\tier_1_content\\rifle_tier_0\\neg_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Reg("wep_neg","hg_wep")
if not SWEP then return end

SWEP.PrintName 				= "Negev"
SWEP.Category 				= L("weapon_category_rifle")

SWEP.Author                 = "akurse"
------------------------------------------

SWEP.CR3 = 4
SWEP.CHandHold = 0.1
SWEP.CHandUp = 0.01

SWEP.Primary.ClipSize		= 100
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "rifle"
SWEP.Primary.AmmoDWR        = "ar2"
SWEP.Shell = "EjectBrass_556"

SWEP.Primary.Cone = 0
SWEP.Primary.Spread = 0.0015
SWEP.Primary.Damage = 25
SWEP.Primary.Force = 140
SWEP.Primary.Wait = 1 / 12

SWEP.Primary.Sound = "arccw_go/m4a1/m4a1_us_04.wav"
SWEP.Primary.SoundPitch = 95
SWEP.Primary.SoundFar = "arccw_go/m4a1/m4a1_us_distant_03.wav"

SWEP.HoldType = "ar2"

SWEP.Slot					= 2
SWEP.SlotPos				= 0

SWEP.WorldModel				= "models/weapons/arccw_go/v_mach_negev.mdl"

SWEP.vbwPos = Vector(-25,2,5)
SWEP.vbwAng = Angle(0,0,0)

SWEP.dwsItemPos = Vector(-26.5,6,6.4)

SWEP.dwsItemFOV = 4

SWEP.wmVector = Vector(-19,9.7,-7)
SWEP.wmAngle = Angle(-1,8,180 - 3)
SWEP.wmScale = 1.1

SWEP.MuzzlePos = Vector(0,0,0)
SWEP.MuzzleAng = Angle(0.1,0.2,0)
SWEP.CameraPos = Vector(-37.5,0.04,2.3)
SWEP.CR_Scope = 2

SWEP.ReloadTime = 3

SWEP.Reload1 = "homigrad/france/ineedabullets2.wav"
SWEP.Reload2 = "arccw_go/m249/m249_coverdown.wav"
SWEP.Reload3 = "arccw_go/m249/m249_coverup.wav"
SWEP.Reload4 = false



SWEP.BoltBone = "v_weapon.chargehandle"
SWEP.BoltMul = 5.5

SWEP.ClipBone = false

SWEP.FakeVec1 = Vector(10,-16,-15)
SWEP.FakeVec2 = Vector(8,-4,0)

SWEP.DeploySound = "arccw_go/m249/m249_draw.wav"

SWEP.MoveSpeed = 0

function SWEP:ShootEffect(pos,dir)
    local color = Color(255,225,125)

    self:ShootLight(pos,dir,color)
    self:ShootEffect_Manual(pos,dir,color,{
        flashScale = 3,
        gasTimeScale = 2.5,
        gasSideScale = 2.75,
        gasForwardScale = 5
    })
end

SWEP.MoveMul = 0.5
