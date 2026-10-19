local SWEP = oop.Reg("weapon_taser","hg_wep_base",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.Base = "weapon_base"

SWEP.PrintName = L("weapon_taser")
SWEP.Author = "Homigrad"

SWEP.Slot = 2
SWEP.SlotPos = 4
SWEP.Spawnable = true
SWEP.Category = L("weapon_category_item")

SWEP.WorldModel = "models/realistic_police/taser/w_taser.mdl"

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

SWEP.dwsItemAng = Angle(0,-10,0)
SWEP.dwsItemPos = Vector(-3.5,0,-1.8)
SWEP.dwsItemFOV = -14

SWEP.dwmUp = 0.5
SWEP.dwmRight = 0
SWEP.dwmForward = 0

SWEP.dwmARight = 180
SWEP.dwmAUp = 200
SWEP.dwmAForward = 0
SWEP.HoldType = "revolver"
SWEP.HoldTypeReload = "pistol"

SWEP.itemType = "weaponSecondary"

SWEP.recoil = 0

SWEP.EnableTransformModel = true

SWEP.wmVector = Vector(0,0,0)
SWEP.wmAngle = Angle(-20,0,185)

SWEP.DeployTime = 0.3
SWEP.HolsterTime = 0.3

function SWEP:CanFight()
	local owner = self:GetOwner()
	if not IsValid(owner) then return false end
	if owner:IsNPC() then return true end
	if owner:GetNWBool("fake", false) or owner.Fake or IsValid(owner:GetNWEntity("FakeRagdoll")) then return false end
	if owner:IsSprinting() or self:IsHolstered() or self:GetNWBool("Reloading", false) then return false end
	return true
end

function SWEP:IsScope()
	local ply = self:GetOwner()
	if not IsValid(ply) then return false end
	if ply:GetNWBool("fake", false) or ply.Fake or IsValid(ply:GetNWEntity("FakeRagdoll")) then return false end

	if self:IsLocal() then
		if not self:CanFight() then return false end
		return ply:KeyDown(IN_ATTACK2) and not ply:GetNWBool("Suiciding", false)
	else
		return self:GetNWBool("IsScope", false)
	end
end

function SWEP:GetMuzzlePos(gun)
	local owner = self:GetOwner()
	if not IsValid(owner) then
		return self:GetPos(), self:GetAngles()
	end

	local isFake = owner.Fake or owner:GetNWBool("fake", false)
	local fakeRag = isFake and (owner.FakeRagdoll or owner.hgFakeRagdoll or (owner.GetNWEntity and owner:GetNWEntity("FakeRagdoll")))
	if isFake and IsValid(fakeRag) and self.GetTransformFromRagdoll then
		local gunPos, gunAng = self:GetTransformFromRagdoll(fakeRag)
		if gunPos and gunAng then
			local fwd = gunAng:Forward()
			local up = gunAng:Up()
			return gunPos + fwd * 7 + up * 1.5, gunAng
		end
	end

	if CLIENT and IsValid(self.wm) then
		gun = self.wm
	else
		gun = self
	end

	if IsValid(gun) then
		local att = gun:GetAttachment(1)
		if att and att.Pos then
			return att.Pos, att.Ang
		end
		local fwd = gun:GetForward()
		local up = gun:GetUp()
		return gun:GetPos() + fwd * 7 + up * 1.5, gun:GetAngles()
	end

	local shootPos, shootAng
	if owner.Eye then
		shootPos, shootAng = owner:Eye()
	else
		shootPos = owner:GetShootPos()
		shootAng = owner:GetAimVector():Angle()
	end
	return shootPos, shootAng
end



function SWEP:Think()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	local scope = self:IsScope()

	if SERVER then
		self:SetNWBool("IsScope", scope)
	elseif self:IsLocal() then
		if self.oldScope ~= scope then
			self.oldScope = scope
			sound.Play(scope and "homigrad/player/deploy1.wav" or "homigrad/player/holster2.wav", owner:GetPos(), 65, 120)
		end
	end
end

function SWEP:Initialize()
	self:SetClip1(self.Primary.DefaultClip)
end

function SWEP:OnDeploy()
	self:SetNWBool("Reloading", false)
end

function SWEP:OnHolstered()
	self:SetNWBool("Reloading", false)
end

local function TwitchRagdoll(rag)
	if not IsValid(rag) then return end
	local ragTimer = "TaserShock_Rag_" .. rag:EntIndex() .. "_" .. math.floor(CurTime() * 100)
	local ticks = 0
	local maxTicks = 45

	timer.Create(ragTimer, 0.1, maxTicks, function()
		ticks = ticks + 1
		if not IsValid(rag) then
			timer.Remove(ragTimer)
			return
		end

		local spark = EffectData()
		spark:SetOrigin(rag:WorldSpaceCenter())
		spark:SetNormal(VectorRand())
		spark:SetMagnitude(2)
		spark:SetScale(1)
		spark:SetRadius(4)
		util.Effect("Sparks", spark, true, true)

		if ticks % 5 == 0 then
			rag:EmitSound("ambient/energy/zap" .. math.random(1, 3) .. ".wav", 70, math.random(95, 115))
		end

		for i = 0, rag:GetPhysicsObjectCount() - 1 do
			local phys = rag:GetPhysicsObjectNum(i)
			if IsValid(phys) then
				phys:ApplyForceCenter(VectorRand() * 240)
			end
		end
	end)
end

local function ShockTarget(wep, owner, ent, hitPos, hitNormal)
	if not IsValid(ent) then
		local ed = EffectData()
		ed:SetOrigin(hitPos)
		ed:SetNormal(hitNormal)
		ed:SetMagnitude(2)
		ed:SetScale(1)
		ed:SetRadius(4)
		util.Effect("Sparks", ed, true, true)
		sound.Play("ambient/energy/zap" .. math.random(1, 3) .. ".wav", hitPos, 70, math.random(95, 115))
		return
	end

	local victim = nil
	local rag = nil

	if ent:IsPlayer() then
		victim = ent
		rag = victim.FakeRagdoll or (victim.GetDummy and victim:GetDummy())
	elseif ent:GetClass() == "prop_ragdoll" then
		rag = ent
		victim = (RagdollOwner and RagdollOwner(ent)) or (hg and hg.RagdollOwner and hg.RagdollOwner(ent)) or ent.RagdollOwner
		if not IsValid(victim) or not victim:IsPlayer() then
			victim = ent:GetNWEntity("RagdollOwner")
		end
	elseif ent:IsNPC() then
		local dmg = DamageInfo()
		dmg:SetDamage(15)
		dmg:SetAttacker(IsValid(owner) and owner or wep)
		dmg:SetInflictor(wep)
		dmg:SetDamageType(DMG_SHOCK)
		dmg:SetDamagePosition(hitPos)
		ent:TakeDamageInfo(dmg)

		local ed = EffectData()
		ed:SetOrigin(hitPos)
		ed:SetNormal(hitNormal)
		util.Effect("cball_explode", ed, true, true)
		ent:EmitSound("ambient/energy/zap1.wav", 75, 100)
		return
	else
		local ed = EffectData()
		ed:SetOrigin(hitPos)
		ed:SetNormal(hitNormal)
		ed:SetMagnitude(2)
		ed:SetScale(1)
		ed:SetRadius(4)
		util.Effect("Sparks", ed, true, true)
		sound.Play("ambient/energy/zap" .. math.random(1, 3) .. ".wav", hitPos, 70, math.random(95, 115))
		return
	end

	local ed = EffectData()
	ed:SetOrigin(hitPos)
	ed:SetNormal(hitNormal)
	util.Effect("cball_explode", ed, true, true)
	sound.Play("weapons/stunstick/stunstick_impact1.wav", hitPos, 75, 100)

	if IsValid(victim) and victim:IsPlayer() then
		if not victim:Alive() or victim.isDead or victim:GetNWBool("isDead", false) then
			if IsValid(rag) then TwitchRagdoll(rag) end
			return
		end

		if victim:HasGodMode() then return end

		if victim.DropWep then
			victim:DropWep()
		end

		local inFake = (victim.InFake and victim:InFake()) or (victim.Fake and IsValid(victim.FakeRagdoll))
		if not inFake then
			if victim.EnterFake then
				victim:EnterFake()
			elseif Faking then
				Faking(victim)
			end
		end

		rag = victim.FakeRagdoll or (victim.GetDummy and victim:GetDummy())

		victim.Otrub = true
		victim.otrub = true
		victim:SetNWBool("Otrub", true)
		victim:SetNW2Bool("Otrub", true)
		victim:SetNWBool("otrub", true)

		victim.pain = (victim.pain or 0) + 70
		victim:SetNWFloat("Pain", victim.pain)
		victim:SetNWFloat("pain", victim.pain)

		local shockTimer = "TaserShock_" .. victim:EntIndex() .. "_" .. math.floor(CurTime() * 100)
		local ticks = 0
		local maxTicks = 50

		timer.Create(shockTimer, 0.1, maxTicks, function()
			ticks = ticks + 1

			if not IsValid(victim) or not victim:Alive() or victim.isDead or victim:GetNWBool("isDead", false) then
				timer.Remove(shockTimer)
				return
			end

			local curRag = victim.FakeRagdoll or (victim.GetDummy and victim:GetDummy())
			local fxEnt = IsValid(curRag) and curRag or victim

			local spark = EffectData()
			spark:SetOrigin(fxEnt:WorldSpaceCenter())
			spark:SetNormal(VectorRand())
			spark:SetMagnitude(2)
			spark:SetScale(1)
			spark:SetRadius(4)
			util.Effect("Sparks", spark, true, true)

			if ticks % 5 == 0 then
				fxEnt:EmitSound("ambient/energy/zap" .. math.random(1, 3) .. ".wav", 75, math.random(95, 115))
			end

			if IsValid(curRag) then
				for i = 0, curRag:GetPhysicsObjectCount() - 1 do
					local phys = curRag:GetPhysicsObjectNum(i)
					if IsValid(phys) then
						phys:ApplyForceCenter(VectorRand() * 260)
					end
				end
			end

			if ticks >= maxTicks then
				if IsValid(victim) then
					victim.Otrub = false
					victim.otrub = false
					victim:SetNWBool("Otrub", false)
					victim:SetNW2Bool("Otrub", false)
					victim:SetNWBool("otrub", false)
				end
			end
		end)
	elseif IsValid(rag) then
		TwitchRagdoll(rag)
	end
end

function SWEP:PrimaryAttack()
	if self:Clip1() <= 0 then
		self:EmitSound("weapons/pistol/pistol_empty.wav", 60, 100)
		self:SetNextPrimaryFire(CurTime() + 0.5)
		return
	end

	if self:GetNWBool("Reloading", false) then return end

	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	if not self:CanFight() and not (owner.InFake and owner:InFake()) then return end
	if self.IsDeployed and not self:IsDeployed() then return end

	self:SetNextPrimaryFire(CurTime() + 1.2)
	self:SetClip1(self:Clip1() - 1)
	self:SetNWFloat("Start", CurTime() + 0.2)

	self.lastShoot = CurTime()
	self.lastShoot2 = RealTime()
	self.recoil = 0

	if IsValid(owner) and owner:IsPlayer() then
		owner:ViewPunch(Angle(-1.5, math.Rand(-0.5, 0.5), 0))
	end

	self:EmitSound("weapons/pistol/pistol_fire2.wav", 75, 160)
	self:EmitSound("ambient/energy/zap1.wav", 80, 120)

	local shootPos, shootAng = self:GetMuzzlePos()
	if not shootPos then
		if owner.Eye then
			shootPos, shootAng = owner:Eye()
		else
			shootPos = owner:GetShootPos()
			shootAng = owner:GetAimVector():Angle()
		end
	end

	local shootDir
	local inFake = (owner.InFake and owner:InFake()) or (owner.Fake and IsValid(owner.FakeRagdoll))
	if inFake then
		shootDir = shootAng:Forward()
	else
		local eyeTr = owner:EyeTrace(800)
		local targetPos = (eyeTr and eyeTr.HitPos) or (shootPos + owner:GetAimVector() * 800)
		shootDir = (targetPos - shootPos):GetNormalized()
	end

	local filter = {self, owner}
	if IsValid(owner.FakeRagdoll) then table.insert(filter, owner.FakeRagdoll) end

	local tr = util.TraceLine({
		start = shootPos,
		endpos = shootPos + shootDir * 700,
		filter = filter,
		mask = MASK_SHOT
	})

	local effectdata = EffectData()
	effectdata:SetOrigin(tr.HitPos)
	effectdata:SetStart(shootPos)
	effectdata:SetAttachment(1)
	effectdata:SetEntity(self)
	util.Effect("ToolTracer", effectdata, true, true)

	local muzzleData = EffectData()
	muzzleData:SetOrigin(shootPos)
	muzzleData:SetNormal(shootDir)
	muzzleData:SetMagnitude(1)
	muzzleData:SetScale(0.5)
	util.Effect("Sparks", muzzleData, true, true)

	if SERVER then
		ShockTarget(self, owner, tr.Entity, tr.HitPos, tr.HitNormal)
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
	if self:Clip1() >= self.Primary.ClipSize then return end
	if self:GetNWBool("Reloading", false) then return end
	if (self.NextReload or 0) > CurTime() then return end

	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	if owner.InFake and owner:InFake() then return end

	self.NextReload = CurTime() + 2.5
	self:SetNWBool("Reloading", true)
	self:SetNextPrimaryFire(CurTime() + 2.2)

	self:EmitSound("weapons/smg1/smg1_reload.wav", 65, 120)

	if SERVER then
		timer.Simple(2, function()
			if not IsValid(self) then return end
			self:SetNWBool("Reloading", false)
			self:SetClip1(self.Primary.ClipSize)
			self:EmitSound("weapons/pistol/pistol_empty.wav", 60, 120)
		end)
	end
end

function SWEP:AnimationBonesPlayer(rag,ft,time)
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	local anim = math.Clamp(self:GetNWFloat("Start",0) - CurTime() + 0.2,0,0.2) / 0.2
	if anim > 0 then
		rag:AddBoneAng("rhand",Angle(25 * anim,0,0))
	end

	if self:GetNWBool("Reloading", false) then
		rag:AddBoneAng("rforearm", Angle(15, -20, 10))
		rag:AddBoneAng("rupperarm", Angle(-10, 10, -5))
		rag:AddBoneAng("lforearm", Angle(-20, 35, 10))
		rag:AddBoneAng("lupperarm", Angle(10, 20, 0))
		return
	end

	local scope = self:IsScope()
	self.lerpScope = Lerp(0.18, self.lerpScope or 0, scope and 1 or 0)
	local kScope = self.lerpScope

	if kScope > 0.005 then
		rag:AddBoneAng("rupperarm", Angle(-3, -12, 0) * kScope)
		rag:AddBoneAng("rforearm", Angle(0, -6, 0) * kScope)
		rag:AddBoneAng("rhand", Angle(-8, 8, 0) * kScope)

		rag:AddBoneAng("lupperarm", Angle(-12, 28, 5) * kScope)
		rag:AddBoneAng("lforearm", Angle(-5, 40, -15) * kScope)
		rag:AddBoneAng("lhand", Angle(15, -10, 20) * kScope)
	end
end

if CLIENT then
	local redLaser = Material("sprites/redglow1")

	function SWEP:Render(gun)
		gun:DrawModel()

		local owner = self:GetOwner()
		if not IsValid(owner) then return end

		local shootPos, shootAng = self:GetMuzzlePos(gun)
		local tr
		if shootPos and shootAng then
			tr = util.TraceLine({
				start = shootPos,
				endpos = shootPos + shootAng:Forward() * 700,
				filter = {self, owner},
				mask = MASK_SHOT
			})
		else
			local sPos = owner:GetShootPos()
			local sAng = owner:GetAimVector():Angle()
			tr = util.TraceLine({
				start = sPos,
				endpos = sPos + sAng:Forward() * 700,
				filter = {self, owner},
				mask = MASK_SHOT
			})
		end

		if tr and tr.HitPos then
			render.SetMaterial(redLaser)
			render.DrawSprite(tr.HitPos + tr.HitNormal * 1, 3.5, 3.5, Color(255, 30, 30, 230))
		end
	end
end
