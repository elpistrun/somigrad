--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/melee/tier_0_base/tier_0_sh.lua <
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

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\melee\\tier_0_base\\tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Reg("melee_base","hg_wep_base",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.IsMelee = true

SWEP.PrintName = "База ближнего боя"
SWEP.Category = L("weapon_category_melee")

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.WorldModel = "models/weapons/insurgency/w_marinebayonet.mdl"

SWEP.ViewModelFlip = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 1
SWEP.SlotPos = 2

SWEP.UseHands = true
SWEP.FiresUnderwater = false
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = true

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = 0
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = true

SWEP.Primary.Damage = 25
SWEP.Primary.Force = 40

SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.DrawSound = ""
SWEP.HitSound = "snd_jack_hmcd_knifehit.wav"
SWEP.FlashHitSound = "snd_jack_hmcd_knifestab.wav"
SWEP.ShouldDecal = true
SWEP.HoldType = "knife"
SWEP.DamageType = DMG_SLASH

-- Route melee through the same hold transform as every firearm.
--
-- hg_wep sets EnableTransformModel = true (hinit/weapons/tier_0_base/zconfig_sh.lua), and
-- melee_base only derives from hg_wep_base, where it defaults to false -- so melee weapons
-- were the one family that never got the hand-bone transform. The draw path takes it from
-- there: with the flag on, hg_wep_base:DrawWorldModel() calls SetupBones and returns
-- without drawing anything, and the weapon shows up only as the model SetupGun places on
-- ValveBiped.Bip01_R_Hand using wmVector/wmAngle. With it off, the raw model is drawn at
-- the entity's own transform, which is the bat standing straight up in front of you.
--
-- wmVector/wmAngle are left at the hg_wep_base defaults on purpose. That is what every
-- firearm in the pack uses and the guns sit correctly with it, so the hand bone's own
-- axes are already the "hold a weapon" axes -- the offsets are per-model fudge for models
-- whose grip is not at the origin. Copying the HL2 crowbar's numbers in here (3.5/3 units
-- to the side of the bone, 70 deg yaw, 180 roll -- a fudge for the crowbar's own model)
-- just rotated and displaced every other melee weapon.
--
-- What melee weapons do need is a rotation of their own, because their models are built
-- along their up axis instead of along a barrel. That number lives in
-- hg_wep_base/render/util_sh.lua as the hg_melee_wmangle convar (default "0 -90 0", i.e.
-- lay the model along the hand's forward axis) and it only applies to weapons that did not
-- set a wmAngle themselves -- so the crowbar, which did, keeps its tuned values.
SWEP.EnableTransformModel = true
SWEP.wmVector = Vector(3.5, 3, 0)
SWEP.wmAngle = Angle(70, 0, 180)

SWEP.SubStamina = 2
SWEP.DamagePain = 0
SWEP.DamageBleed = 0

function Circle( x, y, radius, seg )
    local cir = {}

    table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
    for i = 0, seg do
        local a = math.rad( ( i / seg ) * -360 )
        table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
    end

    local a = math.rad( 0 ) -- This is needed for non absolute segment counts
    table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

    surface.DrawPoly( cir )
end

local white = Color(200,200,200,200)
local white2 = Color(255,255,255,200)

function SWEP:DrawHUD()
	if not (GetViewEntity() == LocalPlayer()) then return end
	if LocalPlayer():InVehicle() then return end

	local tr = self:GetEyeTrace()

	if tr.Hit then
		local hitPos = tr.HitPos
		local pos = hitPos:ToScreen()

		local Size = math.Clamp(1 - ((hitPos - self.Owner:GetShootPos()):Length() / 80) ^ 2,.1,.3)

		surface.SetDrawColor(white)
		draw.NoTexture()
		Circle(pos.x,pos.y, 55 * Size, 32)

		surface.SetDrawColor(white2)
		draw.NoTexture()
		Circle(pos.x,pos.y, 40 * Size, 32)
	end
end

local size = Vector(3,3,3)

function SWEP:GetEyeTrace()
	local ply = self:GetOwner()
	
	local pos,ang = ply:Eye()

	local tr = {}
	tr.start = pos
	tr.endpos = pos + ang:Forward() * 80
	tr.filter = ply
	tr.mins = -size
	tr.maxs = size

	ply:LagCompensation(true)
	tr = util.TraceHull(tr)
	ply:LagCompensation(false)

	return tr
end

function SWEP:CanPrimaryAttack()
	if self:IsHolstered() or not self:IsDeployed() or ((self.nextAttack or 0) > CurTime()) then return false end

	return true
end

SWEP.sndTwroh = {"weapons/melee/swing_light_sharp_01.wav","weapons/melee/swing_light_sharp_02.wav","weapons/melee/swing_light_sharp_03.wav"}

if SERVER then
	util.AddNetworkString("melee delay")
else
	net.Receive("melee delay",function()
		local wep = LocalPlayer():GetActiveWeapon()
		wep.nextAttack = net.ReadFloat()
	end)
end

local TWO_HANDED_MELEE = {
	["melee_bat"] = true,
	["melee_metalbat"] = true,
	["melee_sleagehammer"] = true,
	["melee_shovel"] = true,
	["melee_crowbar"] = true,
	["melee_fireaxe"] = true,
}

local METROCOP_SWING = {
	["melee_police_bat"] = true,
	["melee_t"] = true,
	["melee_hatchet"] = true,
	["melee_pipe"] = true,
}

local KNIFE_MELEE = {
	["melee_kabar"] = true,
	["melee_kitknife"] = true,
	["melee_knife"] = true,
}

local function IsTwoHandedMelee(wep)
	if not IsValid(wep) then return false end
	local class = wep:GetClass() or ""
	if TWO_HANDED_MELEE[class] or wep.TwoHanded then return true end
	if wep.HoldType == "melee2" and not METROCOP_SWING[class] then return true end
	return false
end

local function IsMetrocopMelee(wep)
	if not IsValid(wep) then return false end
	local class = wep:GetClass() or ""
	if METROCOP_SWING[class] or wep.MetrocopSwing then return true end
	return false
end

local function IsKnifeMelee(wep)
	if not IsValid(wep) then return false end
	local class = wep:GetClass() or ""
	if KNIFE_MELEE[class] or wep.IsKnife or wep.HoldType == "knife" then return true end
	return false
end

local function GetMeleeGesture(wep)
	if IsKnifeMelee(wep) then
		return ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
	end
	if IsTwoHandedMelee(wep) then
		return ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2
	end
	if IsMetrocopMelee(wep) then
		return ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
	end
	return ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
end

function SWEP:OnDeploy()
	local snd = self.DeploySound or self.DrawSound
	if snd and snd ~= "" and SERVER then
		local owner = self:GetOwner()
		if IsValid(owner) then
			owner:EmitSound(snd, 60)
		end
	end
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	local ply = self:GetOwner()

	local isTwoHanded = IsTwoHandedMelee(self)
	local isMetrocop = IsMetrocopMelee(self)
	local isKnife = IsKnifeMelee(self)
	local animDur = isTwoHanded and 0.55 or (isMetrocop and 0.38 or (isKnife and 0.3 or 0.4))
	self:SetNWFloat("AttackAnim", CurTime())
	self:SetNWFloat("AttackAnimDuration", animDur)

	local snd = self.sndTwroh or "weapons/slam/throw.wav"
	if TypeID(snd) == TYPE_TABLE then snd = snd[math.random(1,#snd)] end

	self.nextAttack = CurTime() + self.Primary.Delay / (1 + ply:GetNWFloat("adrenaline") / 2) + 1 * math.Clamp(1 - (ply:GetNWFloat("stamina")) / 100,0,1)

	if SERVER then
		/*net.Start("melee delay")
		net.WriteFloat(self.nextAttack)
		net.Send(ply)*/

		sound.EmitNET(self:EntIndex(),snd,60,1,(self.sndTwrohPitch or 100),self:GetPos())
		net.SendOmit(ply)

		ply.stamina = math.max(ply.stamina - self.SubStamina * ply.staminamul,0)
	elseif ply == LocalPlayer() then
		ply:EmitSound(snd,60,self.sndTwrohPitch or 100)
	end

	--ply:LagCompensation(true)

	local tr = self:GetEyeTrace()

	local ent = tr.Entity

	if SERVER then
		if tr.Hit then
			if IsValid(ent) and IsValid(ent:GetPhysicsObject()) and (string.find(ent:GetPhysicsObject():GetMaterial(),"flesh") or string.find(ent:GetPhysicsObject():GetMaterial(),"player")) then
				sound.Emit(nil,TypeID(self.FlashHitSound) == TYPE_TABLE and self.FlashHitSound[math.random(1,#self.FlashHitSound)] or self.FlashHitSound,75,1,100,tr.HitPos)
			else
				sound.Emit(nil,TypeID(self.HitSound) == TYPE_TABLE and self.HitSound[math.random(1,#self.HitSound)] or self.HitSound,75,1,100,tr.HitPos)
			end
		end

		if IsValid(ent) then
			local isHead = (tr.HitGroup == HITGROUP_HEAD)
			if not isHead then
				local headBone = ent:LookupBone("ValveBiped.Bip01_Head1") or ent:LookupBone("head")
				if headBone then
					local headPos = ent:GetBonePosition(headBone)
					if headPos and tr.HitPos:Distance(headPos) <= 22 then
						isHead = true
					end
				end
			end

			local dmg = isHead and (isKnife and math.Round(self.Primary.Damage * 3) or 10000) or self.Primary.Damage
			if isKnife and not isHead and IsValid(ent) then
				local angle = ply:GetAngles().y - ent:GetAngles().y
				if angle < -180 then angle = 360 + angle end
				if angle <= 90 and angle >= -90 then
					dmg = math.Round(dmg * 1.5)
				else
					dmg = math.Round(dmg / 1.5)
				end
			end

			local dmgTab = CreateDamageTab(ent,ply,self,dmg,self.DamageType)
			dmgTab.isMelee = true
			dmgTab.isKnife = isKnife
			dmgTab.noHeadExplode = true
			dmgTab.pos = tr.HitPos
			dmgTab.hitgroup = isHead and HITGROUP_HEAD or tr.HitGroup
			dmgTab.isHead = isHead
			
			dmgTab.dmgPain = isHead and (isKnife and 100 or 1000) or self.DamagePain
			dmgTab.dmgBleed = isHead and (isKnife and 60 or 1000) or self.DamageBleed

			local norm = tr.Normal
			local pushDir = Vector(norm.x, norm.y, math.min(norm.z, 0))
			if pushDir:LengthSqr() > 0 then pushDir:Normalize() else pushDir = ply:GetForward() end
			dmgTab.force = pushDir * (isHead and (self.Primary.Force * 2) or self.Primary.Force)

			if isHead and not isKnife then
				sound.Emit(nil,"physics/flesh/flesh_bloody_break.wav",80,1,100,tr.HitPos)
				sound.Emit(nil,"physics/flesh/flesh_squishy_impact_hard" .. math.random(1,4) .. ".wav",80,1,100,tr.HitPos)
			end

			if SERVER and (ent:IsPlayer() or ent:GetClass() == "prop_ragdoll") then
				if util.NetworkStringToID("blood particle more") ~= 0 then
					net.Start("blood particle more")
					net.WriteVector(tr.HitPos)
					net.WriteVector(tr.Normal * 75 + VectorRand() * 25)
					net.Broadcast()
				end
				util.Decal("Blood", tr.HitPos + tr.HitNormal * 4, tr.HitPos - tr.HitNormal * 24)
			end

			if self.Attack then self:Attack(ent,tr,dmgTab) end

			if SERVER and isKnife and isfunction(HG_ProcessKnifeHit) then
				HG_ProcessKnifeHit(ent, ply, self, tr.Normal)
			end

			ent:TakeDamageTab(dmgTab)
		end
	end

	local gesture = GetMeleeGesture(self)
	ply:SetAnimation(PLAYER_ATTACK1)
	ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, gesture, true)

	if isKnife then
		if knifeAnim == 1 then
			ply:ViewPunch(Angle(-1.4, -2.5, -0.8))
		else
			ply:ViewPunch(Angle(-2.6, 0.4, 0.2))
		end
	else
		ply:ViewPunch(Angle(isTwoHanded and -4.5 or -3, math.Rand(-1.5, 1.5), 0))
	end

	if SERVER and tr.Hit and self.ShouldDecal then
		local pos1 = tr.HitPos + tr.HitNormal
		local pos2 = tr.HitPos - tr.HitNormal
	
		if IsValid(ent) and ent:GetClass()=="prop_ragdoll" then
			util.Decal("Impact.Flesh",pos1,pos2)
		else
			util.Decal("ManhackCut",pos1,pos2)
		end
	end

	--ply:LagCompensation(false)
end

function SWEP:SecondaryAttack()
	if not IsKnifeMelee(self) then return end
	if not self:CanPrimaryAttack() then return end

	local ply = self:GetOwner()
	if not IsValid(ply) then return end

	-- Force the heavy stab (animation 2) on right click
	self:SetNWInt("KnifeAnim", 2)
	self:SetNWFloat("AttackAnim", CurTime())
	self:SetNWFloat("AttackAnimDuration", 0.35)

	local snd = self.sndTwroh or "weapons/slam/throw.wav"
	if TypeID(snd) == TYPE_TABLE then snd = snd[math.random(1,#snd)] end

	self.nextAttack = CurTime() + (self.Primary.Delay or 0.65) * 1.15

	if SERVER then
		sound.EmitNET(self:EntIndex(),snd,60,1,(self.sndTwrohPitch or 95),self:GetPos())
		net.SendOmit(ply)
		ply.stamina = math.max(ply.stamina - (self.SubStamina or 10) * 1.3, 0)
	elseif ply == LocalPlayer() then
		ply:EmitSound(snd, 60, self.sndTwrohPitch or 95)
	end

	local tr = self:GetEyeTrace()
	local ent = tr.Entity

	if SERVER and tr.Hit then
		if IsValid(ent) and IsValid(ent:GetPhysicsObject()) and (string.find(ent:GetPhysicsObject():GetMaterial(),"flesh") or string.find(ent:GetPhysicsObject():GetMaterial(),"player")) then
			sound.Emit(nil,TypeID(self.FlashHitSound) == TYPE_TABLE and self.FlashHitSound[math.random(1,#self.FlashHitSound)] or self.FlashHitSound,75,1,100,tr.HitPos)
		else
			sound.Emit(nil,TypeID(self.HitSound) == TYPE_TABLE and self.HitSound[math.random(1,#self.HitSound)] or self.HitSound,75,1,100,tr.HitPos)
		end
	end

	if SERVER and IsValid(ent) then
		local isHead = (tr.HitGroup == HITGROUP_HEAD)
		local dmg = isHead and (isKnife and math.Round(self.Primary.Damage * 3.5) or 10000) or math.Round(self.Primary.Damage * 1.5)

		local angle = ply:GetAngles().y - ent:GetAngles().y
		if angle < -180 then angle = 360 + angle end
		if angle <= 90 and angle >= -90 then
			dmg = math.Round(dmg * 1.5) -- backstab multiplier
		end

		local dmgTab = CreateDamageTab(ent,ply,self,dmg,self.DamageType)
		dmgTab.isMelee = true
		dmgTab.isKnife = isKnife
		dmgTab.noHeadExplode = true
		dmgTab.pos = tr.HitPos
		dmgTab.hitgroup = isHead and HITGROUP_HEAD or tr.HitGroup
		dmgTab.isHead = isHead
		dmgTab.dmgPain = isHead and (isKnife and 120 or 1000) or ((self.DamagePain or 20) * 1.5)
		dmgTab.dmgBleed = isHead and (isKnife and 80 or 1000) or ((self.DamageBleed or 20) * 1.5)
		local norm = tr.Normal
		local pushDir = Vector(norm.x, norm.y, math.min(norm.z, 0))
		if pushDir:LengthSqr() > 0 then pushDir:Normalize() else pushDir = ply:GetForward() end
		dmgTab.force = pushDir * (self.Primary.Force * 1.6)

		if isHead and not isKnife then
			sound.Emit(nil,"physics/flesh/flesh_bloody_break.wav",80,1,100,tr.HitPos)
			sound.Emit(nil,"physics/flesh/flesh_squishy_impact_hard" .. math.random(1,4) .. ".wav",80,1,100,tr.HitPos)
		end

		if SERVER and (ent:IsPlayer() or ent:GetClass() == "prop_ragdoll") then
			if util.NetworkStringToID("blood particle more") ~= 0 then
				net.Start("blood particle more")
				net.WriteVector(tr.HitPos)
				net.WriteVector(tr.Normal * 85 + VectorRand() * 30)
				net.Broadcast()
			end
			util.Decal("Blood", tr.HitPos + tr.HitNormal * 4, tr.HitPos - tr.HitNormal * 24)
		end

		if self.Attack then self:Attack(ent,tr,dmgTab) end

		if SERVER and isKnife and isfunction(HG_ProcessKnifeHit) then
			HG_ProcessKnifeHit(ent, ply, self, tr.Normal)
		end

		ent:TakeDamageTab(dmgTab)
	end

	ply:SetAnimation(PLAYER_ATTACK1)
	ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE, true)
	ply:ViewPunch(Angle(-3.0, 0, 0))

	if SERVER and tr.Hit and self.ShouldDecal then
		local pos1 = tr.HitPos + tr.HitNormal
		local pos2 = tr.HitPos - tr.HitNormal
		if IsValid(ent) and ent:GetClass()=="prop_ragdoll" then
			util.Decal("Impact.Flesh",pos1,pos2)
		else
			util.Decal("ManhackCut",pos1,pos2)
		end
	end
end

function SWEP:AnimationBonesPlayer(rag, ft, time)
	if not rag or not rag.AddBoneAng then return end

	local owner = self:GetOwner()
	local inFake = IsValid(owner) and (owner.Fake or owner:GetNWBool("fake", false) or (owner.InFake and owner:InFake()))

	local start = self:GetNWFloat("AttackAnim", 0)
	local dur = self:GetNWFloat("AttackAnimDuration", 0.4)
	if dur <= 0 then dur = 0.4 end
	local remain = (start + dur) - time
	local progress = 1 - math.Clamp(remain / dur, 0, 1)

	if IsTwoHandedMelee(self) and not inFake then
		if progress > 0 and progress < 1 then
			-- Two-handed heavy swing animation (blends from hold pose into windup and full swing)
			if progress < 0.3 then
				local w = math.sin((progress / 0.3) * (math.pi / 2))
				rag:AddBoneAng("rclavicle", Angle(5 + 15 * w, -5 - 15 * w, 5 + 15 * w))
				rag:AddBoneAng("rupperarm", Angle(-30 - 30 * w, -22 - 25 * w, 15 + 15 * w))
				rag:AddBoneAng("rforearm", Angle(-50 - 25 * w, -15 - 10 * w, 10 + 5 * w))
				rag:AddBoneAng("rhand", Angle(15 + 25 * w, -15 - 15 * w, 10 + 15 * w))

				rag:AddBoneAng("lclavicle", Angle(5 + 15 * w, 10 + 10 * w, -5 - 10 * w))
				rag:AddBoneAng("lupperarm", Angle(-25 - 20 * w, 32 + 15 * w, -15 - 10 * w))
				rag:AddBoneAng("lforearm", Angle(-55 - 15 * w, 25 + 10 * w, -15 - 5 * w))
				rag:AddBoneAng("lhand", Angle(15 + 20 * w, 20 + 15 * w, -10 - 10 * w))
			else
				local s = math.sin(((progress - 0.3) / 0.7) * math.pi)
				rag:AddBoneAng("rclavicle", Angle(5 - 20 * s, -5 - 10 * s, 5 - 15 * s))
				rag:AddBoneAng("rupperarm", Angle(-30 + 75 * s, -22 - 15 * s, 15 + 10 * s))
				rag:AddBoneAng("rforearm", Angle(-50 + 20 * s, -15 - 10 * s, 10 + 5 * s))
				rag:AddBoneAng("rhand", Angle(15 - 50 * s, -15 - 10 * s, 10 + 10 * s))

				rag:AddBoneAng("lclavicle", Angle(5 - 15 * s, 10 + 10 * s, -5 - 10 * s))
				rag:AddBoneAng("lupperarm", Angle(-25 + 60 * s, 32 + 10 * s, -15 - 15 * s))
				rag:AddBoneAng("lforearm", Angle(-50 + 20 * s, 25 + 5 * s, -15 - 5 * s))
				rag:AddBoneAng("lhand", Angle(15 - 45 * s, 20 + 10 * s, -10 - 15 * s))
			end
		else
			-- Persistent two-handed ready grip (holds the bat with both hands in front of the body)
			rag:AddBoneAng("rclavicle", Angle(5, -5, 5))
			rag:AddBoneAng("rupperarm", Angle(-30, -22, 15))
			rag:AddBoneAng("rforearm", Angle(-50, -15, 10))
			rag:AddBoneAng("rhand", Angle(15, -15, 10))

			rag:AddBoneAng("lclavicle", Angle(5, 10, -5))
			rag:AddBoneAng("lupperarm", Angle(-25, 32, -15))
			rag:AddBoneAng("lforearm", Angle(-55, 25, -15))
			rag:AddBoneAng("lhand", Angle(15, 20, -10))
		end
	elseif IsMetrocopMelee(self) then
		if progress > 0 and progress < 1 then
			-- Metrocop stunstick strike: overhead right-arm downward chop, left arm free
			if progress < 0.32 then
				local w = math.sin((progress / 0.32) * (math.pi / 2))
				rag:AddBoneAng("rclavicle", Angle(18 * w, -8 * w, 20 * w))
				rag:AddBoneAng("rupperarm", Angle(-85 * w, 15 * w, -15 * w))
				rag:AddBoneAng("rforearm", Angle(-75 * w, 25 * w, -20 * w))
				rag:AddBoneAng("rhand", Angle(45 * w, -15 * w, 25 * w))
			else
				local s = math.sin(((progress - 0.32) / 0.68) * math.pi)
				rag:AddBoneAng("rclavicle", Angle(-15 * s, -5 * s, -15 * s))
				rag:AddBoneAng("rupperarm", Angle(40 * s, -20 * s, 10 * s))
				rag:AddBoneAng("rforearm", Angle(-20 * s, -10 * s, 5 * s))
				rag:AddBoneAng("rhand", Angle(-40 * s, 5 * s, -15 * s))
			end
		end
	elseif IsKnifeMelee(self) then
		if progress > 0 and progress < 1 then
			local kAnim = self:GetNWInt("KnifeAnim", 1)
			if kAnim == 1 then
				-- Animation 1: Wide horizontal forehand slash cutting from right to left
				if progress < 0.28 then
					local w = math.sin((progress / 0.28) * (math.pi / 2))
					rag:AddBoneAng("rclavicle", Angle(12 * w, -18 * w, 15 * w))
					rag:AddBoneAng("rupperarm", Angle(-30 * w, -25 * w, 40 * w))
					rag:AddBoneAng("rforearm", Angle(-50 * w, -20 * w, 20 * w))
					rag:AddBoneAng("rhand", Angle(30 * w, -25 * w, 25 * w))
				else
					local s = math.sin(((progress - 0.28) / 0.72) * math.pi)
					rag:AddBoneAng("rclavicle", Angle(12 - 30 * s, -18 + 25 * s, 15 - 30 * s))
					rag:AddBoneAng("rupperarm", Angle(-30 + 75 * s, -25 + 40 * s, 40 - 65 * s))
					rag:AddBoneAng("rforearm", Angle(-50 + 45 * s, -20 + 25 * s, 20 - 25 * s))
					rag:AddBoneAng("rhand", Angle(30 - 70 * s, -25 + 45 * s, 25 - 55 * s))
				end
			else
				-- Animation 2: Tactical forward thrust/stab directly forward towards crosshair
				if progress < 0.25 then
					local w = math.sin((progress / 0.25) * (math.pi / 2))
					rag:AddBoneAng("rclavicle", Angle(15 * w, -12 * w, 10 * w))
					rag:AddBoneAng("rupperarm", Angle(-65 * w, -18 * w, 12 * w))
					rag:AddBoneAng("rforearm", Angle(-85 * w, -22 * w, 8 * w))
					rag:AddBoneAng("rhand", Angle(35 * w, -12 * w, 18 * w))
				else
					local s = math.sin(((progress - 0.25) / 0.75) * math.pi)
					rag:AddBoneAng("rclavicle", Angle(15 - 25 * s, -12 + 18 * s, 10 - 15 * s))
					rag:AddBoneAng("rupperarm", Angle(-65 + 115 * s, -18 + 12 * s, 12 - 18 * s))
					rag:AddBoneAng("rforearm", Angle(-85 + 95 * s, -22 + 18 * s, 8 - 12 * s))
					rag:AddBoneAng("rhand", Angle(35 - 55 * s, -12 + 18 * s, 18 - 25 * s))
				end
			end
		end
	else
		if progress > 0 and progress < 1 then
			-- Generic one-handed swing fallback
			local stroke = math.sin(progress * math.pi)
			rag:AddBoneAng("rclavicle", Angle(15 * stroke, -15 * stroke, 20 * stroke))
			rag:AddBoneAng("rupperarm", Angle(-45 * stroke, -30 * stroke, 25 * stroke))
			rag:AddBoneAng("rforearm", Angle(-55 * stroke, -20 * stroke, 5 * stroke))
			rag:AddBoneAng("rhand", Angle(35 * stroke, -35 * stroke, 30 * stroke))
		end
	end
end

function SWEP:Reload() end

-- The DrawWorldModel override that used to sit here ("self:DrawModel()") is what made the
-- transform above useless: it drew the raw model at the weapon entity's own position and
-- angles and skipped hg_wep_base's version entirely. Removing it lets the inherited
-- DrawWorldModel handle EnableTransformModel, and lets PlayerDraw place the weapon on the
-- hand bone.
