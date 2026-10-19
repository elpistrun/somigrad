--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/weapons/tier_0_base/zconfig_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hinit/weapons/tier_0_base/tier_0_sh.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:143
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

-- "addons\\homigrad\\lua\\hinit\\weapons\\tier_0_base\\zconfig_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Get("hg_wep")
if not SWEP then return end

SWEP.itemType = "weapon"

SWEP.Slot					= 2
SWEP.SlotPos				= 0

SWEP.Primary.ClipSize		= 0
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= true
SWEP.Primary.Tracer = 1
SWEP.ChamberAuto = true

/*
	0 пусто
	1 вставлен
	2 выстрелен
*/

SWEP.Primary.Ammo			= "rifle"
SWEP.Shell = "EjectBrass_556"
SWEP.HoldType = "ar2"

SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 45
SWEP.Primary.DamageDisK = {
	{3000,1},
	{16000,0.75}
}

SWEP.Primary.Spread = 0
SWEP.Primary.Force = 0

SWEP.ScopeLerp = 0.2
SWEP.ScopeLerpOut = 0.25

SWEP.CR3 = 3
SWEP.CHandUp = 0

SWEP.CRL = 0.25
SWEP.CRL_Scope = 0.25
SWEP.CR = 3
SWEP.CR_Scope = 3

SWEP.MuzzlePos = Vector(0,0,0)
SWEP.CameraPos = Vector(-20,0,0)

SWEP.CFightVec = Vector(0,0,0)
SWEP.CFightAng = Angle(0,0,0)

--SWEP.CImersiveSetL
--SWEP.CImersiveSetL_Scope

--SWEP.CImersiveL
--SWEP.CImersiveL_Scope

SWEP.vbw = true
SWEP.vbwPos = Vector(0,0,0)
SWEP.vbwAng = Angle(0,0,0)

SWEP.EnableTransformModel = true
