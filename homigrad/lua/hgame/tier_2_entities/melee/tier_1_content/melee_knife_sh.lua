--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/melee/tier_1_content/melee_knife_sh.lua <
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

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\melee\\tier_1_content\\melee_knife_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Reg("melee_knife","melee_base")
if not SWEP then return end

SWEP.PrintName = L("melee_knife")

SWEP.WorldModel = "models/pwb/weapons/w_knife.mdl"

SWEP.HoldType = "knife"
SWEP.IsKnife = true
SWEP.UseHandAttachment = true
SWEP.wmVector = Vector(0, 0, 0)
SWEP.wmAngle = Angle(0, 0, 0)

SWEP.Primary.Sound = Sound( "Weapon_Knife.Single" )
SWEP.Primary.Damage = 12
SWEP.DamageBleed = 10

SWEP.Primary.Ammo = "none"
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = 0.5
SWEP.Primary.Delay = 0.4
SWEP.Primary.Force = 150

SWEP.DeploySound = "snd_jack_hmcd_knifedraw.wav"
SWEP.DrawSound = "snd_jack_hmcd_knifedraw.wav"
SWEP.HitSound = "snd_jack_hmcd_knifehit.wav"
SWEP.FlashHitSound = "snd_jack_hmcd_knifestab.wav"

function SWEP:Attack(ent,obj,tr,dmginfo)
    if ent.Blooded then ent.Blooded = ent.Blooded + 5 end
end

SWEP.sndTwroh = {"weapons/slam/throw.wav"}
SWEP.sndTwrohPitch = 120

SWEP.dwsItemPos = Vector(9.5,0,-5)
SWEP.dwsItemAng = Angle(35 - 45,0,0)
SWEP.dwsItemFOV = -13
