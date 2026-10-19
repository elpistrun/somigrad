--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/med/tier_0_med_kit/tier_0_sh.lua <
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

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\med\\tier_0_med_kit\\tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Reg("med_kit","hg_wep_base",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName = "weapon_medkit"
SWEP.Author = "0oa"
SWEP.Instructions = L("weapon_medkit_desc")

SWEP.Spawnable = true
SWEP.Category = L("weapon_category_medical")

SWEP.Slot = 3
SWEP.SlotPos = 3

SWEP.WorldModel = "models/w_models/weapons/w_eq_medkit.mdl"

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

SWEP.dwsItemPos = Vector(0,0,-4)
SWEP.dwsItemAng = Angle(0,-90,0)
SWEP.dwsItemFOV = -12

SWEP.vbw = false
SWEP.vbwPos = Vector(0,-1,-7)
SWEP.vbwAng = Angle(-90,90,180)
SWEP.vbwModelScale = Vector(0.8,0.8,0.8)

SWEP.InvMoveSnd = InvMoveSndBody
SWEP.InvCount = 1
SWEP.itemType = "medical"

SWEP.HoldType = "pistol"

SWEP.EnableTransformModel = true


SWEP.wmVector = Vector(5,7,-2)
SWEP.wmAngle = Angle(0,0,-90)

SWEP.SmoothDeployHand = true

SWEP.Primary.Delay = 1.0
SWEP.Primary.Automatic = true
SWEP.Secondary.Delay = 1.0
SWEP.Secondary.Automatic = true

SWEP.HealSound = "items/smallmedkit1.wav"
SWEP.HealDistance = 110
SWEP.Charges = 1

function SWEP:OnInit()
    self.Charges = self.Charges or self.InvCount or 1
end

function SWEP:GetHealTarget()
    local owner = self:GetOwner()
    if not IsValid(owner) then return nil end

    local dis = self.HealDistance or 110
    local eyePos = owner:EyePos()
    local eyeAng = owner:EyeAngles()
    local forward = eyeAng:Forward()

    -- 1. Try eye trace from player view / camera
    local tr = owner.EyeTrace and owner:EyeTrace(dis)
    if not tr or not tr.Hit then
        tr = owner:GetEyeTrace()
    end

    local ent = (tr and tr.Hit and tr.Entity) or nil
    if not IsValid(ent) or (not ent:IsPlayer() and ent:GetClass() ~= "prop_ragdoll") then
        -- 2. Try box hull trace along crosshair for easy targeting of bodies on the ground
        local trHull = util.TraceHull({
            start = eyePos,
            endpos = eyePos + forward * dis,
            mins = Vector(-14, -14, -14),
            maxs = Vector(14, 14, 14),
            filter = owner,
            mask = MASK_SHOT
        })
        if IsValid(trHull.Entity) and (trHull.Entity:IsPlayer() or trHull.Entity:GetClass() == "prop_ragdoll") then
            ent = trHull.Entity
            tr = trHull
        end
    end

    if not IsValid(ent) then return nil end

    -- Direct player
    if ent:IsPlayer() then
        if ent:Alive() and not ent.isDead and not ent:GetNWBool("isDead", false) then
            return ent, ent, tr
        end
    -- Player in fake (ragdoll)
    elseif ent:GetClass() == "prop_ragdoll" then
        local ply = (hg and hg.RagdollOwner and hg.RagdollOwner(ent)) or (RagdollOwner and RagdollOwner(ent))
        if not IsValid(ply) then ply = ent:GetNWEntity("RagdollOwner") end
        if not IsValid(ply) then ply = ent:GetNWEntity("RagdollController") end
        if not IsValid(ply) and ent.GetController then ply = ent:GetController() end
        if not IsValid(ply) and ent.Player then ply = ent.Player end
        if not IsValid(ply) then
            for _, p in ipairs(player.GetAll()) do
                if p.FakeRagdoll == ent or p.hgFakeRagdoll == ent or (p.GetDummy and p:GetDummy() == ent) or (p.GetNWEntity and p:GetNWEntity("FakeRagdoll") == ent) then
                    ply = p
                    break
                end
            end
        end

        if IsValid(ply) and ply:Alive() and not ply.isDead and not ply:GetNWBool("isDead", false) then
            return ply, ent, tr
        end
    end

    return nil
end

function SWEP:ApplyEffect(target, isSelf, entHit)
    -- Stops / heavily reduces bleeding
    local curBleed = target:GetNWFloat("bleed", 0)
    local newBleed = math.max(0, curBleed - 80)
    target.bleed = newBleed
    target:SetNWFloat("bleed", newBleed)

    -- Restores Health
    local curHp = target:Health()
    local maxHp = target:GetMaxHealth()
    target:SetHealth(math.min(maxHp, curHp + 45))

    -- Restores Blood
    local curBlood = target.blood or target:GetNWFloat("blood", 5000)
    local newBlood = math.min(5000, curBlood + 600)
    target.blood = newBlood
    target:SetNWFloat("blood", newBlood)

    -- Reduces Pain
    local curPain = target:GetNWFloat("pain", 0)
    local newPain = math.max(0, curPain - 60)
    target.pain = newPain
    target:SetNWFloat("pain", newPain)

    -- Wake up from Otrub if stable
    if (target.Otrub or target:GetNWBool("Otrub", false)) and newBlood > 2500 and newPain < 180 then
        target.Otrub = false
        target:SetNWBool("Otrub", false)
        target:SetNW2Bool("Otrub", false)
    end
end

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:Alive() then return end

    self:SetNextPrimaryFire(CurTime() + (self.Primary.Delay or 1.0))
    self:SetNextSecondaryFire(CurTime() + (self.Secondary.Delay or 1.0))

    if CLIENT then
        owner:ViewPunch(Angle(-1.5, 0, 0))
        return
    end

    self:ApplyEffect(owner, true, owner)

    local snd = self.HealSound or "snd_jack_bandage.ogg"
    sound.Emit(self:EntIndex(), snd, 65, 1, math.random(95, 105))

    owner:ViewPunch(Angle(-2, 0, 0))

    self.Charges = (self.Charges or self.InvCount or 1) - 1
    if self.Charges <= 0 then
        self:Remove()
    end
end

function SWEP:SecondaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:Alive() then return end

    self:SetNextPrimaryFire(CurTime() + (self.Primary.Delay or 1.0))
    self:SetNextSecondaryFire(CurTime() + (self.Secondary.Delay or 1.0))

    local targetPly, hitEnt, tr = self:GetHealTarget()
    if not IsValid(targetPly) then
        if SERVER and (self.nextMsg or 0) < CurTime() then
            self.nextMsg = CurTime() + 1.2
            owner:ChatPrint("Рядом нет раненого игрока или тела для лечения!")
        end
        return
    end

    if CLIENT then
        owner:ViewPunch(Angle(-1.5, 0, 0))
        return
    end

    self:ApplyEffect(targetPly, false, hitEnt)

    local snd = self.HealSound or "snd_jack_bandage.ogg"
    sound.Emit(self:EntIndex(), snd, 65, 1, math.random(95, 105))

    owner:ViewPunch(Angle(-2, 0, 0))

    self.Charges = (self.Charges or self.InvCount or 1) - 1
    if self.Charges <= 0 then
        self:Remove()
    end
end
