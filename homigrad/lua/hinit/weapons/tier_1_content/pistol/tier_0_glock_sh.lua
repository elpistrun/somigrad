--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/weapons/tier_1_content/pistol/tier_0_glock_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
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

-- "addons\\homigrad\\lua\\hinit\\weapons\\tier_1_content\\pistol\\tier_0_glock_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Reg("wep_glock","hg_wep")
if not SWEP then return end

SWEP.PrintName 				= "Glock"
SWEP.Category 				= L("weapon_category_pistol")

------------------------------------------

SWEP.ReloadTime = 1.5

SWEP.itemType = "weaponSecondary"

SWEP.Primary.ClipSize		= 17
SWEP.Primary.DefaultClip	= 17
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "pistol"
SWEP.Shell = "EjectBrass_556"

SWEP.Primary.Cone = 0
SWEP.Primary.Spread = 0.01
SWEP.Primary.Damage = 33
SWEP.Primary.Force = 140
SWEP.Primary.Wait = 1 / 7

SWEP.Primary.Sound = "arccw_go/glock18/glock18-1.wav"
SWEP.Primary.SoundFar = "arccw_go/glock18/glock18-1-distant.wav"

SWEP.HoldType = "revolver"
SWEP.HoldTypeReload = "pistol"

SWEP.Slot					= 2
SWEP.SlotPos				= 1

SWEP.WorldModel				= "models/weapons/arccw_go/v_pist_glock.mdl"

SWEP.vbwPos = Vector(-5,12,2)
SWEP.vbwAng = Angle(-90,0,0)

SWEP.dwsItemPos = Vector(-17.5,4,3)
SWEP.dwsItemFOV = -14.5

SWEP.wmVector = Vector(-13.5,5.5,-5)
SWEP.wmAngle = Angle(-5,2.4,180 + 3)

SWEP.MuzzlePos = Vector(2,-0.02,0)
SWEP.CameraPos = Vector(-20,0,0.5)
SWEP.CR_Scope = 4

SWEP.Reload1 = "arccw_go/glock18/glock_clipout.wav"
SWEP.Reload2 = "arccw_go/glock18/glock_clipin.wav"
SWEP.Reload3 = "arccw_go/glock18/glock_slideback.wav"
SWEP.Reload4 = "arccw_go/glock18/glock_sliderelease.wav"

SWEP.BoltBone = "v_weapon.glock_slide"
SWEP.BoltMul = 2
SWEP.BoltEmpty = true

SWEP.ClipBone = "v_weapon.glock_magazine"

SWEP.FakeVec1 = Vector(5,-7.5,-11)

SWEP.DeploySound = "arccw_go/glock18/glock_draw.wav"

SWEP.CFightVec = Vector(2,4,-1)

SWEP.CHandUp = 8
SWEP.CHandHoldUp = 0.2

SWEP.eyeSprayH = 2
SWEP.eyeSprayLSet = 0.7
SWEP.eyeSprayLReset = 0.3

function SWEP:GetCHandUp(value) return math.ease.InCubic(value) end
function SWEP:GetCHandRight(value) return math.ease.InCubic(value) end


