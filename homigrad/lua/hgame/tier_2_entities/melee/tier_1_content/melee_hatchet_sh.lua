--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/melee/tier_1_content/melee_hatchet_sh.lua <
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

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\melee\\tier_1_content\\melee_hatchet_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Reg("melee_hatchet","melee_metalbat")
if not SWEP then return end

SWEP.PrintName = L("melee_hatchet")

SWEP.WorldModel = "models/weapons/me_hatchet/w_me_hatchet.mdl"

SWEP.EnableTransformModel = true
SWEP.wmVector = Vector(3.5,3,0)
SWEP.wmAngle = Angle(70,0,180)

SWEP.Primary.Damage = 25
SWEP.Primary.Ammo = "none"
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = 0.5
SWEP.Primary.Delay = 0.9
SWEP.Primary.Force = 120

SWEP.DrawSound = "weapons/melee/holster_in_light.wav"
SWEP.HitSound = "snd_jack_hmcd_knifehit.wav"
SWEP.FlashHitSound = "snd_jack_hmcd_axehit.wav"
SWEP.HoldType = "melee"
SWEP.MetrocopSwing = true
SWEP.DamageType = DMG_SLASH

SWEP.sndTwrohPitch = 125

SWEP.dwsItemPos = Vector(0,1,0)
SWEP.dwsItemAng = Angle(90 + 45,0,90)
SWEP.dwsItemFOV = -7
