--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/melee/tier_1_content/tier_0_melee_metalbat_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\melee\\tier_1_content\\tier_0_melee_metalbat_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Reg("melee_metalbat","melee_base")
if not SWEP then return end

SWEP.PrintName = L("melee_metalbat")

SWEP.WorldModel = "models/weapons/me_bat_metal_tracer/w_me_bat_metal.mdl"

SWEP.EnableTransformModel = true
SWEP.wmVector = Vector(3.5,3,0)
SWEP.wmAngle = Angle(70,0,180)

SWEP.Primary.Damage = 35
SWEP.DamagePain = 40
SWEP.SubStamina = 10

SWEP.Primary.Ammo = "none"
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = 0.5
SWEP.Primary.Delay = 1.1
SWEP.Primary.Force = 100

SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.DrawSound = "weapons/melee/holster_in_light.wav"
SWEP.HitSound = "physics/metal/metal_canister_impact_hard3.wav"
SWEP.HitSound = {"physics/metal/metal_solid_impact_hard3.wav","physics/metal/metal_solid_impact_hard4.wav","physics/metal/metal_solid_impact_hard5.wav"}
SWEP.FlashHitSound = {"physics/flesh/flesh_strider_impact_bullet1.wav","physics/flesh/flesh_strider_impact_bullet2.wav","physics/flesh/flesh_strider_impact_bullet3.wav"}
SWEP.HoldType = "melee2"
SWEP.TwoHanded = true
SWEP.DamageType = DMG_CLUB

function SWEP:DamageTablePost(ent,dmgTab)
    if dmgTab.hitgroup == HITGROUP_HEAD then
        dmgTab.explodeHead = true

        for i = 1,3 do
            sound.Emit(nil,"physics/metal/metal_solid_impact_bullet" .. math.random(1,4) .. ".wav",95,1,100,dmgTab.pos)
        end

        ent = RagdollOwner(ent) or ent
        if IsValid(ent) and ent:IsPlayer() then FakeDown(ent) end
    end
end

SWEP.dwsItemPos = Vector(-0.5,4,0)
SWEP.dwsItemAng = Angle(90 + 45,0,90)
SWEP.dwsItemFOV = -1
