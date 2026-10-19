local DamageTabMeta = {}
DamageTabMeta.__index = DamageTabMeta

function DamageTabMeta:AddKill(reason)
	self.kills = self.kills or {}
	table.insert(self.kills, reason)
end

function DamageTabMeta:GetKills()
	return self.kills or {}
end

function DamageTabMeta:SetDamage(val)
	self.damage = tonumber(val) or 0
end

function DamageTabMeta:GetDamage()
	return self.damage or 0
end

function DamageTabMeta:SetDamageType(val)
	self.damageType = val or DMG_GENERIC
	self.dmgType = val or DMG_GENERIC
end

function DamageTabMeta:GetDamageType()
	return self.damageType or self.dmgType or DMG_GENERIC
end

function DamageTabMeta:SetAttacker(att)
	self.attacker = att
end

function DamageTabMeta:GetAttacker()
	return self.attacker
end

function DamageTabMeta:SetInflictor(inf)
	self.inflictor = inf
end

function DamageTabMeta:GetInflictor()
	return self.inflictor
end

function DamageTabMeta:SetDamagePosition(pos)
	self.pos = pos
end

function DamageTabMeta:GetDamagePosition()
	return self.pos
end

function DamageTabMeta:SetDamageForce(force)
	self.force = force
end

function DamageTabMeta:GetDamageForce()
	return self.force
end

function CreateDamageTab(target, attacker, inflictor, damage, damageType)
	local tab = setmetatable({
		target = target,
		ent = target,
		attacker = attacker,
		inflictor = inflictor,
		damage = tonumber(damage) or 0,
		damageType = damageType or DMG_GENERIC,
		dmgType = damageType or DMG_GENERIC,
		pos = IsValid(target) and target:GetPos() or vector_origin,
		force = Vector(0, 0, 0),
		kills = {},
		pain = 0,
		bleed = 0,
	}, DamageTabMeta)
	return tab
end

local ENTITY_MT = FindMetaTable("Entity")
local PLAYER_MT = FindMetaTable("Player")

local function IsKnifeOrMelee(inflictor, attacker)
	local function check(w)
		if not IsValid(w) then return false end
		local class = string.lower(w:GetClass())
		if w.isMelee or w.isKnife or w.IsKnife or w.Base == "weapon_melee_base" then return true end
		if string.find(class, "knife") or string.find(class, "kabar") or string.find(class, "melee") or string.find(class, "gurkha") or string.find(class, "crowbar") or string.find(class, "bat") or string.find(class, "axe") or string.find(class, "shovel") or string.find(class, "sword") or string.find(class, "machete") or string.find(class, "hammer") or string.find(class, "pipe") or string.find(class, "hands") or string.find(class, "fist") then
			return true
		end
		return false
	end
	if check(inflictor) then return true end
	if IsValid(attacker) and attacker:IsPlayer() and check(attacker:GetActiveWeapon()) then
		return true
	end
	return false
end

function HG_ProcessKnifeHit(victim, attacker, weapon, hitNormal)
	if not IsValid(victim) then return end
	local targetPly = victim:IsPlayer() and victim or ((hg and hg.RagdollOwner and hg.RagdollOwner(victim)) or (RagdollOwner and RagdollOwner(victim)))
	if not IsValid(targetPly) or not targetPly:Alive() or targetPly:HasGodMode() then return end

	local wepClass = ""
	if isstring(weapon) then
		wepClass = weapon
	elseif IsValid(weapon) then
		wepClass = weapon:GetClass()
	end
	wepClass = string.lower(wepClass)

	local isHeavy = string.find(wepClass, "kabar") or string.find(wepClass, "weapon_t") or string.find(wepClass, "melee_t") or string.find(wepClass, "tomahawk")
	local isLight = string.find(wepClass, "knife") and not isHeavy

	-- Guaranteed bleeding on every hit
	local bleedAdd = isHeavy and math.random(30, 45) or (isLight and math.random(12, 18) or 25)
	local curBleed = targetPly:GetNWFloat("bleed", 0)
	targetPly.bleed = curBleed + bleedAdd
	targetPly:SetNWFloat("bleed", targetPly.bleed)

	-- Check fake drop
	local inFake = targetPly.Fake or targetPly:GetNWBool("fake", false) or (targetPly.InFake and targetPly:InFake())
	if not inFake then
		if isHeavy then
			targetPly.hgHeavyKnifeHits = (targetPly.hgHeavyKnifeHits or 0) + 1
			if not targetPly.hgHeavyKnifeLimit then
				targetPly.hgHeavyKnifeLimit = math.random(1, 3)
			end
			if targetPly.hgHeavyKnifeHits >= targetPly.hgHeavyKnifeLimit then
				targetPly.hgHeavyKnifeHits = 0
				targetPly.hgHeavyKnifeLimit = math.random(1, 3)
				local push = (isvector(hitNormal) and -hitNormal * 160) or Vector(0, 0, -100)
				if Faking then
					Faking(targetPly, push)
				elseif targetPly.EnterFake then
					targetPly:EnterFake(push)
				end
			end
		else
			targetPly.hgLightKnifeHits = (targetPly.hgLightKnifeHits or 0) + 1
			if not targetPly.hgLightKnifeLimit then
				targetPly.hgLightKnifeLimit = math.random(5, 7)
			end
			if targetPly.hgLightKnifeHits >= targetPly.hgLightKnifeLimit then
				targetPly.hgLightKnifeHits = 0
				targetPly.hgLightKnifeLimit = math.random(5, 7)
				local push = (isvector(hitNormal) and -hitNormal * 120) or Vector(0, 0, -80)
				if Faking then
					Faking(targetPly, push)
				elseif targetPly.EnterFake then
					targetPly:EnterFake(push)
				end
			end
		end
	end
end

if SERVER then
	function HG_DoHeadshotKill(ply, targetEnt, hitPos, hitNormal, attacker, inflictor)
		if IsKnifeOrMelee(inflictor, attacker) then
			-- A knife or melee weapon must NEVER pop or burst the head
			if IsValid(ply) then
				ply:TakeDamage(100, attacker, inflictor)
				if ply:Alive() then ply:Kill() end
			end
			return
		end

		if IsValid(ply) and ply.hgHeadshotInProgress then return end

		local isAlreadyExploded = (IsValid(targetEnt) and (targetEnt:GetNWBool("HeadExploded", false) or targetEnt.HeadExploded))
			or (IsValid(ply) and (ply.HeadPop or ply:GetNWBool("HeadPop", false) or ply:GetNWBool("HeadExploded", false)))
		if isAlreadyExploded then return end

		if IsValid(ply) then ply.hgHeadshotInProgress = true end

		hitPos = hitPos or (IsValid(targetEnt) and targetEnt:GetPos()) or (IsValid(ply) and ply:EyePos()) or vector_origin
		hitNormal = (isvector(hitNormal) and hitNormal ~= vector_origin) and hitNormal:GetNormalized() or Vector(0, 0, 1)

		if IsValid(ply) then
			ply.HeadPop = true
			ply.HeadExploded = true
			ply:SetNWBool("HeadPop", true)
			ply:SetNWBool("HeadExploded", true)
		end

		local rag = (IsValid(targetEnt) and targetEnt:GetClass() == "prop_ragdoll" and targetEnt)
		if not IsValid(rag) and IsValid(ply) and ply.fake then
			rag = (IsValid(ply.fakeEnt) and ply.fakeEnt)
				or (IsValid(ply.FakeRagdoll) and ply.FakeRagdoll)
				or (IsValid(ply.fakeragdoll) and ply.fakeragdoll)
				or (IsValid(ply.hgFakeRagdoll) and ply.hgFakeRagdoll)
				or (ply.GetDummy and IsValid(ply:GetDummy()) and ply:GetDummy())
				or (IsValid(ply:GetNWEntity("FakeRagdoll")) and ply:GetNWEntity("FakeRagdoll"))
				or (IsValid(ply:GetNWEntity("DeathRagdoll")) and ply:GetNWEntity("DeathRagdoll"))
		end

		if not IsValid(rag) and IsValid(ply) and ply:Alive() then
			if ply.GodDisable then ply:GodDisable() end
			if Faking then
				Faking(ply, -hitNormal * 200)
			elseif ply.EnterFake then
				ply:EnterFake(-hitNormal * 200)
			end
			rag = (IsValid(ply.fakeEnt) and ply.fakeEnt)
				or (IsValid(ply.FakeRagdoll) and ply.FakeRagdoll)
				or (IsValid(ply.fakeragdoll) and ply.fakeragdoll)
				or (IsValid(ply.hgFakeRagdoll) and ply.hgFakeRagdoll)
				or (ply.GetDummy and IsValid(ply:GetDummy()) and ply:GetDummy())
				or (IsValid(ply:GetNWEntity("FakeRagdoll")) and ply:GetNWEntity("FakeRagdoll"))
				or (IsValid(ply:GetNWEntity("DeathRagdoll")) and ply:GetNWEntity("DeathRagdoll"))
		end

		if IsValid(rag) then
			rag:SetNWBool("HeadExploded", true)
			rag.hgIsDeathCorpse = true
			rag:SetNWBool("hgDeathCorpse", true)
			if IsValid(ply) then
				rag:SetNWString("Nick", ply:Nick())
				rag:SetNWString("PlayerName", ply:Nick())
			end
			rag.pulse = 0
			rag:SetNWFloat("pulse", 0)
			rag.heartstop = true
			rag:SetNWBool("heartstop", true)
			if clearGrab then
				clearGrab(rag.ZacConsLH)
				clearGrab(rag.ZacConsRH)
				rag.ZacConsLH, rag.ZacConsRH = nil, nil
			end
		end

		if util.NetworkStringToID("bp headshoot explode") ~= 0 then
			net.Start("bp headshoot explode")
			net.WriteVector(hitPos)
			net.WriteVector(-hitNormal)
			net.Broadcast()
		end

		if util.NetworkStringToID("bp buckshoot") ~= 0 then
			net.Start("bp buckshoot")
			net.WriteVector(hitPos)
			net.WriteVector(-hitNormal)
			net.Broadcast()
		end

		sound.Play("homigrad/headshoot.wav", hitPos, 85, 100)
		sound.Play("physics/flesh/flesh_bloody_break.wav", hitPos, 85, 100)
		sound.Play("physics/flesh/flesh_squishy_impact_hard" .. math.random(1, 4) .. ".wav", hitPos, 85, 100)

		local decalFilter = {}
		if IsValid(ply) then table.insert(decalFilter, ply) end
		if IsValid(rag) then table.insert(decalFilter, rag) end
		if IsValid(targetEnt) and targetEnt ~= rag and targetEnt ~= ply then table.insert(decalFilter, targetEnt) end

		util.Decal("Blood", hitPos + hitNormal * 8, hitPos - hitNormal * 64, #decalFilter > 0 and decalFilter or (IsValid(ply) and ply or nil))

		if IsValid(ply) then
			ply.isDead = true
			ply.pulse = 0
			ply:SetNWFloat("pulse", 0)
			ply.heartstop = true
			ply:SetNWBool("heartstop", true)
			ply:SetNWBool("isDead", true)
			ply:SetNWBool("Alive", false)
			ply:SetNWBool("FakeDeath", true)
			ply.LastDmg = {
				reasons = { head = true, headExplode = true },
				target = ply,
				att = IsValid(attacker) and attacker or ply,
				weapon = IsValid(inflictor) and inflictor:GetClass() or "weapon",
				boneName = "head",
				killedBy = "headshot",
				killedTargetName = "Headshot"
			}
			if ply.GodDisable then ply:GodDisable() end
			ply:SetHealth(0)

			local lethalDmg = DamageInfo()
			lethalDmg:SetDamage(100000)
			lethalDmg:SetDamageType(DMG_BULLET)
			lethalDmg:SetAttacker(IsValid(attacker) and attacker or ply)
			lethalDmg:SetInflictor(IsValid(inflictor) and inflictor or ply)
			lethalDmg:SetDamagePosition(hitPos)
			ply:TakeDamageInfo(lethalDmg)

			if ply:Alive() then ply:Kill() end
			if ply:Alive() then ply:KillSilent() end
			ply.hgHeadshotInProgress = nil
		end
	end

	function HG_IsHeadHit(ent, hitGroup, hitPos, physBone)
		if hitGroup == HITGROUP_HEAD or hitGroup == HITGROUP_NECK then return true end
		if hitGroup and hitGroup ~= HITGROUP_GENERIC and hitGroup ~= 0 then return false end
		if not IsValid(ent) or not hitPos then return false end

		-- Living players use exact engine hitboxes; non-head hitgroup is never a headshot
		if ent:IsPlayer() then return false end

		if ent:GetClass() == "prop_ragdoll" then
			if physBone then
				local bone = ent.TranslatePhysBoneToBone and ent:TranslatePhysBoneToBone(physBone)
				if bone then
					local bName = string.lower(ent:GetBoneName(bone) or "")
					if string.find(bName, "head") or string.find(bName, "neck") then
						return true
					else
						-- Hit another specific ragdoll physics bone (spine, chest, arm, leg)
						return false
					end
				end
			end

			local headBone = ent:LookupBone("ValveBiped.Bip01_Head1") or ent:LookupBone("head")
			if headBone then
				local headPos
				local pb = ent.TranslateBoneToPhysBone and ent:TranslateBoneToPhysBone(headBone)
				local pObj = pb and ent:GetPhysicsObjectNum(pb)
				if IsValid(pObj) then headPos = pObj:GetPos() end
				if not headPos then headPos = ent:GetBonePosition(headBone) end

				if headPos and hitPos:Distance(headPos) <= 7.5 then
					local spineBone = ent:LookupBone("ValveBiped.Bip01_Spine4") or ent:LookupBone("ValveBiped.Bip01_Spine2")
					local spinePos = spineBone and ent:GetBonePosition(spineBone)
					if not spinePos or hitPos:Distance(headPos) < hitPos:Distance(spinePos) then
						return true
					end
				end
			end
		end

		return false
	end

	hook.Add("ScalePlayerDamage", "HG_HeadshotInstakill", function(ply, hitgroup, dmginfo)
		if hitgroup ~= HITGROUP_HEAD then return end
		local dmgType = dmginfo:GetDamageType()
		if bit.band(dmgType, DMG_SLASH) ~= 0 or bit.band(dmgType, DMG_CLUB) ~= 0 then return end
		local inf = dmginfo:GetInflictor()
		local att = dmginfo:GetAttacker()
		if IsKnifeOrMelee(inf, att) then return end
		if dmginfo:GetDamage() > 0 then
			local alreadyExploded = (ply.HeadPop or ply:GetNWBool("HeadPop", false) or ply:GetNWBool("HeadExploded", false))
			if not alreadyExploded then
				HG_DoHeadshotKill(ply, ply, dmginfo:GetDamagePosition(), dmginfo:GetDamageForce():GetNormalized(), dmginfo:GetAttacker(), dmginfo:GetInflictor())
			end
			dmginfo:SetDamage(math.max(dmginfo:GetDamage() * 10, 10000))
			return true
		end
	end)
end

local function ApplyDamageTab(ent, dmgTab, reasons)
	if not IsValid(ent) or not istable(dmgTab) then return end

	local damage = dmgTab.damage or (dmgTab.GetDamage and dmgTab:GetDamage()) or 0
	local dmgType = dmgTab.damageType or (dmgTab.GetDamageType and dmgTab:GetDamageType()) or DMG_GENERIC
	local attacker = dmgTab.attacker or (dmgTab.GetAttacker and dmgTab:GetAttacker()) or ent
	local inflictor = dmgTab.inflictor or (dmgTab.GetInflictor and dmgTab:GetInflictor()) or attacker
	local pos = dmgTab.pos or (dmgTab.GetDamagePosition and dmgTab:GetDamagePosition()) or ent:GetPos()
	local force = dmgTab.force or (dmgTab.GetDamageForce and dmgTab:GetDamageForce()) or vector_origin

	local isHead = dmgTab.isHead or (dmgTab.hitgroup == HITGROUP_HEAD)
	if not isHead and isfunction(HG_IsHeadHit) then
		isHead = HG_IsHeadHit(ent, dmgTab.hitgroup, pos, dmgTab.bone)
	end

	local canExplodeHead = not dmgTab.isMelee and not dmgTab.noHeadExplode and not dmgTab.isKnife and bit.band(dmgType, DMG_SLASH) == 0 and bit.band(dmgType, DMG_CLUB) == 0
	if IsKnifeOrMelee(inflictor, attacker) then
		canExplodeHead = false
	end

	if SERVER and isHead and canExplodeHead then
		local targetPly = ent:IsPlayer() and ent or ((hg and hg.RagdollOwner and hg.RagdollOwner(ent)) or (RagdollOwner and RagdollOwner(ent)))
		local alreadyExploded = (IsValid(ent) and (ent:GetNWBool("HeadExploded", false) or ent.HeadExploded))
			or (IsValid(targetPly) and (targetPly.HeadPop or targetPly:GetNWBool("HeadPop", false) or targetPly:GetNWBool("HeadExploded", false)))
		if not alreadyExploded and IsValid(targetPly) and targetPly:Alive() then
			HG_DoHeadshotKill(targetPly, ent, pos, isvector(force) and force:GetNormalized() or Vector(0,0,1), attacker, inflictor)
			return
		end
	end

	if ent:GetClass() == "prop_ragdoll" then
		local ply = (hg and hg.RagdollOwner and hg.RagdollOwner(ent)) or (RagdollOwner and RagdollOwner(ent))
		if IsValid(ply) and ply ~= ent and (ply:Alive() or ply.isDead) then
			if isvector(force) and force ~= vector_origin then
				local phys = ent:GetPhysicsObject()
				if dmgTab.bone and ent:TranslateBoneToPhysBone(dmgTab.bone) then
					phys = ent:GetPhysicsObjectNum(ent:TranslateBoneToPhysBone(dmgTab.bone)) or phys
				end
				if IsValid(phys) then
					phys:ApplyForceOffset(force * 50, pos)
				end
			end
			return ply:TakeDamageTab(dmgTab, reasons)
		end
	end

	if SERVER then
		if ent:IsPlayer() then
			if not ent:Alive() or ent:HasGodMode() then return end

			local pain = dmgTab.pain or dmgTab.dmgPain or (damage * 1.2)
			local bleed = dmgTab.bleed or dmgTab.dmgBleed or (damage > 20 and (damage * 0.1) or 0)
			if pain and pain > 0 then
				local curPain = ent:GetNWFloat("pain", 0) + pain
				ent:SetNWFloat("pain", curPain)
				if curPain > 180 and not ent:GetNWBool("Otrub", false) then
					ent:SetNWBool("Otrub", true)
				end
			end
			if bleed and bleed > 0 then
				local curBleed = ent:GetNWFloat("bleed", 0) + bleed
				ent:SetNWFloat("bleed", curBleed)
			end

			local kills = dmgTab.kills or (dmgTab.GetKills and dmgTab:GetKills())
			if (reasons and table.HasValue(reasons, "killyourself")) or (kills and table.HasValue(kills, "killyourself")) then
				ent:Kill()
				return
			end

			local newHp = math.max(0, ent:Health() - damage)
			ent:SetHealth(newHp)

			local safeForce = force
			if isvector(safeForce) and ent:IsPlayer() and not (ent.InFake and ent:InFake()) then
				safeForce = Vector(safeForce.x, safeForce.y, math.min(safeForce.z, 0))
				if safeForce:Length() > 250 then
					safeForce = safeForce:GetNormalized() * 250
				end
			end

			local dinfo = DamageInfo()
			dinfo:SetDamage(damage)
			dinfo:SetDamageType(dmgType)
			dinfo:SetAttacker(IsValid(attacker) and attacker or ent)
			dinfo:SetInflictor(IsValid(inflictor) and inflictor or ent)
			dinfo:SetDamagePosition(pos)
			dinfo:SetDamageForce(safeForce)
			ent:TakeDamageInfo(dinfo)

			if newHp <= 0 and (ent:Alive() or not ent.isDead) then
				ent.isDead = true
				ent:SetNWBool("isDead", true)
				ent:SetNWBool("Alive", false)
				ent:SetNWBool("FakeDeath", true)
				local rag = ent:GetNWEntity("FakeRagdoll") or ent.fakeEnt or ent.FakeRagdoll
				if IsValid(rag) then
					rag.hgIsDeathCorpse = true
					rag:SetNWBool("hgDeathCorpse", true)
					rag:SetNWString("Nick", ent:Nick())
					rag:SetNWString("PlayerName", ent:Nick())
				end
				ent:Kill()
			end
		else
			local dinfo = DamageInfo()
			dinfo:SetDamage(damage)
			dinfo:SetDamageType(dmgType)
			dinfo:SetAttacker(IsValid(attacker) and attacker or ent)
			dinfo:SetInflictor(IsValid(inflictor) and inflictor or ent)
			dinfo:SetDamagePosition(pos)
			dinfo:SetDamageForce(force)
			ent:TakeDamageInfo(dinfo)
		end
	end
end

ENTITY_MT.TakeDamageTab = ENTITY_MT.TakeDamageTab or ApplyDamageTab
PLAYER_MT.TakeDamageTab = PLAYER_MT.TakeDamageTab or ApplyDamageTab
