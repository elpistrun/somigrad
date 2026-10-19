--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/weapons/tier_0_base/bullet_sh.lua <
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

-- "addons\\homigrad\\lua\\hinit\\weapons\\tier_0_base\\bullet_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Get("hg_wep")
if not SWEP then return end

local buckshot = {}
buckshot["12/70 gauge"] = true
buckshot["buckshot"] = true

local HullBullet = 1

local bullet = {}

if CLIENT then
	local last = 0

	net.Receive("weapon shoot point",function()
		if not InitNET then return end
		
		local wep = weapons.Get(net.ReadString())
		local pos = net.ReadVector()
		local dir = net.ReadVector()
		local entIndex = net.ReadInt(14)

		wep:ShootSound(pos,dir,entIndex)

		local ent = Entity(entIndex)
		
		if IsEntity(ent) and ent.AttackShotSetupVars then
			ent:FireBulletOutPerson(pos,dir,entIndex)

			ent:AttackShotSetupVars()
			ent:ShootEffect(pos,dir)
		else
			wep:FireBulletOutPerson(pos,dir,entIndex)
		end
	end)

	function SWEP:FireBulletOutPerson(pos,dir)
		local primary = self.Primary

		local cone = primary.Cone

		local ply = self.GetOwner and self:GetOwner()

		bullet.Num 			= (self.NumBullet or 1)
		bullet.Src 			= pos
		bullet.Dir 			= dir
		bullet.Spread 		= Vector()
		bullet.Force		= primary.Force / 40 / (self.NumBullet or 1)
		bullet.Damage		= primary.Damage
		bullet.AmmoType     = primary.Ammo
		bullet.Attacker 	= ply
		bullet.Tracer       = primary.Tracer
		bullet.HullSize 	= HullBullet
		bullet.TracerName   = "Tracer"
		bullet.IgnoreEntity = ply
	
		bullet.Callback = function() return {false,false} end

		local gun = (IsEntity(wep) and wep:GetGun())

		if not gun then
			gun = ClientsideModel("models/hunter/plates/plate.mdl")
			gun:SetNoDraw(true)
			gun:SetPos(pos)

			timer.Simple(0,function() gun:Remove() end)
		end

		gun:FireBullets(bullet)
	end
local function GetEntityHeadPos(ent)
	if not IsValid(ent) then return end
	if ent:IsPlayer() then
		local b = ent:LookupBone("ValveBiped.Bip01_Head1")
		if b then
			local pos = ent:GetBonePosition(b)
			if pos and pos ~= vector_origin then return pos end
		end
		return ent:EyePos()
	elseif ent:GetClass() == "prop_ragdoll" then
		local b = ent:LookupBone("ValveBiped.Bip01_Head1") or ent:LookupBone("head")
		if b then
			local pb = ent:TranslateBoneToPhysBone(b)
			local po = pb and ent:GetPhysicsObjectNum(pb)
			if IsValid(po) then return po:GetPos() end
			local pos = ent:GetBonePosition(b)
			if pos and pos ~= vector_origin then return pos end
		end
		return ent:GetPos() + Vector(0,0,10)
	end
end

function HG_FindHeadNearRay(startPos, endPos, radius, ignorePly)
	local ray = endPos - startPos
	local rayLen = ray:Length()
	if rayLen <= 0.01 then return end
	local rayDir = ray / rayLen

	local candidates = {}
	for _, p in ipairs(player.GetAll()) do
		if IsValid(p) and p ~= ignorePly and (p:Alive() or not p.isDead) then
			table.insert(candidates, {ply = p, ent = p})
		end
	end
	for _, rag in ipairs(ents.FindByClass("prop_ragdoll")) do
		if IsValid(rag) then
			local owner = (hg and hg.RagdollOwner and hg.RagdollOwner(rag)) or (RagdollOwner and RagdollOwner(rag)) or rag:GetNWEntity("RagdollController")
			if IsValid(owner) and owner ~= ignorePly and (owner:Alive() or not owner.isDead) then
				table.insert(candidates, {ply = owner, ent = rag})
			end
		end
	end

	local bestTarget, bestDist, bestPos = nil, radius, nil
	for _, cand in ipairs(candidates) do
		local headPos = GetEntityHeadPos(cand.ent)
		if headPos then
			local v = headPos - startPos
			local d = v:Dot(rayDir)
			if d >= 0 and d <= rayLen + 12 then
				local proj = startPos + rayDir * d
				local dist = headPos:Distance(proj)
				if dist <= bestDist then
					local trWall = util.TraceLine({
						start = startPos,
						endpos = proj,
						mask = MASK_SOLID_BRUSHONLY
					})
					if not trWall.Hit or (trWall.Fraction * rayLen >= d - 4) then
						bestDist = dist
						bestTarget = cand
						bestPos = headPos
					end
				end
			end
		end
	end

	return bestTarget, bestPos
end

else
    util.AddNetworkString("weapon shoot point")
end

function SWEP:GetShootMatrix() return self:GetMuzzlePos() end

function SWEP:FireBullet()
	local ply = self:GetOwner()

	local gun,isFake = self:GetGun()
	gun.forceAtt = self
	
	local pos, ang
	local isFake = IsValid(ply) and (ply.Fake or ply:GetNWBool("fake", false))
	local fakeRag = isFake and (ply.FakeRagdoll or ply.hgFakeRagdoll or (ply.GetNWEntity and ply:GetNWEntity("FakeRagdoll")))

	local shootDir
	local scoped = false

	if isFake and IsValid(fakeRag) then
		pos,ang = self:GetMuzzlePos()

		if not pos or not ang then
			if self.GetTransformFromRagdoll then
				local gunPos, gunAng = self:GetTransformFromRagdoll(fakeRag)
				if gunPos and gunAng and self.GetMuzzleFromTransform then
					pos,ang = self:GetMuzzleFromTransform(gunPos, gunAng)
				end
			end
		end

		if not pos or not ang then
			local handBone = fakeRag:LookupBone("ValveBiped.Bip01_R_Hand")
			local handPos = (handBone and handBone >= 0 and fakeRag:GetBonePosition(handBone)) or (fakeRag:GetPos() + Vector(0, 0, 12))
			pos = handPos
			ang = ply:EyeAngles()
		end

		shootDir = (ang and ang:Forward()) or ply:GetAimVector()
	else
		if ply:IsPlayer() then
			if CLIENT then
				pos,ang = self:GetShootMatrix()
			end
			if not pos then pos = ply:GetShootPos() end
			if not ang then ang = ply:EyeAngles() end

			if CLIENT and self.IsScope then scoped = self:IsScope() end
			if not scoped then scoped = self.GetNWBool and self:GetNWBool("IsScope") end

			if scoped then
				shootDir = (ang and ang:Forward()) or ply:GetAimVector()
			else
				shootDir = ply:GetAimVector()
			end

			if SERVER then
				pos = ply:GetShootPos()
			else
				local trCross = util.TraceLine({
					start = ply:GetShootPos(),
					endpos = ply:GetShootPos() + shootDir * 56756,
					filter = {ply, self, gun}
				})
				if trCross and trCross.HitPos and pos:DistToSqr(trCross.HitPos) > 64 then
					shootDir = (trCross.HitPos - pos):GetNormalized()
				end
			end
		else
			pos = ply:GetShootPos()
			shootDir = ply:GetAimVector()
		end
	end

	local cone = self.Primary.Cone or self.Primary.Spread or 0
	if scoped then
		cone = cone * 0.2
	elseif isFake then
		cone = cone + 0.035
	end

	local bullet = {}
	bullet.Num 			= (self.NumBullet or 1)
	bullet.Src 			= pos + shootDir * (isFake and 4 or 2)
	bullet.Dir 			= shootDir
	bullet.Spread 		= Vector(cone,cone,0)
	bullet.Force		= (self.Primary.Force or 100) / 40 / (self.NumBullet or 1)
	bullet.Damage		= self.Primary.Damage
	bullet.AmmoType     = self.Primary.Ammo
	bullet.Attacker 	= ply
	bullet.Tracer       = 0
	bullet.HullSize 	= HullBullet or 1.5
	bullet.TracerName   = self.Tracer or "Tracer"
	bullet.IgnoreEntity = isFake and fakeRag or ply

	if isFake and SERVER and IsValid(fakeRag) then
		local handBone = fakeRag:LookupBone("ValveBiped.Bip01_R_Hand")
		local handPhys = handBone and fakeRag:GetPhysicsObjectNum(fakeRag:TranslateBoneToPhysBone(handBone))
		if IsValid(handPhys) then
			handPhys:ApplyForceCenter(-shootDir * (self.Primary.Force or 80) * 10 + Vector(0,0,40))
		end
	end

	if SERVER then
		bullet.Callback = function(ply,tr,dmgInfo)
			if tr.Entity == self or tr.Entity == gun or tr.Entity == ply or (isFake and tr.Entity == fakeRag) then
				return {false, false}
			end

			dmgInfo:ScaleDamage(1 / (self.NumBullet or 1))

			local dis = tr.StartPos:Distance(tr.HitPos)
			local disK = 1
			local disTable = self.Primary.DamageDisK
			if istable(disTable) and #disTable > 0 then
				if dis <= disTable[1][1] then
					disK = disTable[1][2]
				elseif dis >= disTable[#disTable][1] then
					disK = disTable[#disTable][2]
				else
					for idx = 1, #disTable - 1 do
						local p1 = disTable[idx]
						local p2 = disTable[idx + 1]
						if dis >= p1[1] and dis <= p2[1] then
							local diff = p2[1] - p1[1]
							local frac = (diff > 0) and math.Clamp((dis - p1[1]) / diff, 0, 1) or 0
							disK = Lerp(frac, p1[2], p2[2])
							break
						end
					end
				end
			end
			if disK and disK > 0 and not (disK ~= disK) then
				dmgInfo:ScaleDamage(disK)
			end

			if self.Tracer == "none" then
				dmgInfo:SetDamageType(DMG_BLAST)
			end

			local wepClass = string.lower(self:GetClass() or "")
			local isR8 = (wepClass == "wep_r8") or (wepClass == "weapon_r8") or (self.IsRevolver) or (string.find(wepClass, "r8") ~= nil) or (self.PrintName == "R8")

			local isHead = tr.HitGroup == HITGROUP_HEAD or tr.HitGroup == HITGROUP_NECK
			local isBodyHit = tr.HitGroup == HITGROUP_CHEST or tr.HitGroup == HITGROUP_STOMACH or tr.HitGroup == HITGROUP_LEFTARM or tr.HitGroup == HITGROUP_RIGHTARM or tr.HitGroup == HITGROUP_LEFTLEG or tr.HitGroup == HITGROUP_RIGHTLEG or tr.HitGroup == HITGROUP_GEAR
			local headTargetPly, headTargetEnt, headShotPos

			if not isHead and not isBodyHit and IsValid(tr.Entity) and isfunction(HG_IsHeadHit) then
				isHead = HG_IsHeadHit(tr.Entity, tr.HitGroup, tr.HitPos, tr.PhysicsBone)
			end

			-- R8 huge kinetic impact: even nearby hits to neck/upper chest or close to head on ragdoll count as head hits!
			if isR8 and IsValid(tr.Entity) and not isHead then
				if tr.HitGroup == HITGROUP_NECK or (tr.HitGroup == HITGROUP_CHEST and math.random(1, 10) <= 6) then
					isHead = true
				elseif tr.Entity:GetClass() == "prop_ragdoll" then
					local headBone = tr.Entity:LookupBone("ValveBiped.Bip01_Head1") or tr.Entity:LookupBone("head")
					if headBone then
						local headPos = tr.Entity:GetBonePosition(headBone)
						if headPos and tr.HitPos:Distance(headPos) <= 18 then
							isHead = true
							headShotPos = tr.HitPos
						end
					end
				end
			end

			if isHead and IsValid(tr.Entity) then
				headTargetEnt = tr.Entity
				headTargetPly = tr.Entity:IsPlayer() and tr.Entity or ((hg and hg.RagdollOwner and hg.RagdollOwner(tr.Entity)) or (RagdollOwner and RagdollOwner(tr.Entity)) or tr.Entity:GetNWEntity("RagdollController") or tr.Entity:GetNWEntity("RagdollOwner") or tr.Entity.Player)
				headShotPos = headShotPos or tr.HitPos
			end

			-- Head explosion calculation (works on living players AND dead ragdolls/corpses)
			local canHeadPop = isHead and (IsValid(headTargetPly) or (IsValid(tr.Entity) and tr.Entity:GetClass() == "prop_ragdoll"))
			local alreadyExploded = (IsValid(tr.Entity) and (tr.Entity:GetNWBool("HeadExploded", false) or tr.Entity.HeadExploded))
				or (IsValid(headTargetPly) and (headTargetPly.HeadPop or headTargetPly:GetNWBool("HeadPop", false) or headTargetPly:GetNWBool("HeadExploded", false)))

			if canHeadPop and not alreadyExploded then
				if isfunction(HG_DoHeadshotKill) then
					HG_DoHeadshotKill(headTargetPly, headTargetEnt or tr.Entity, headShotPos or tr.HitPos, -tr.Normal, ply, self)
				end
				dmgInfo:SetDamage(10000)
			else
				local hitEnt = tr.Entity
				local targetPly = IsValid(hitEnt) and (hitEnt:IsPlayer() and hitEnt or ((hg and hg.RagdollOwner and hg.RagdollOwner(hitEnt)) or (RagdollOwner and RagdollOwner(hitEnt))))
				if IsValid(targetPly) and (targetPly:Alive() or not targetPly.isDead) and not targetPly:HasGodMode() then
					local dmg = dmgInfo:GetDamage()
					if dmg > 0 then
						local pain = dmg * 1.2
						local bleed = dmg > 12 and (dmg * 0.15) or 0
						if pain > 0 then
							local curPain = targetPly:GetNWFloat("pain", 0) + pain
							targetPly:SetNWFloat("pain", curPain)
							if curPain > 160 and not targetPly:GetNWBool("Otrub", false) then
								targetPly:SetNWBool("Otrub", true)
							end
						end
						if bleed > 0 then
							targetPly:SetNWFloat("bleed", targetPly:GetNWFloat("bleed", 0) + bleed)
						end

						if util.NetworkStringToID("blood particle more") ~= 0 then
							net.Start("blood particle more")
							net.WriteVector(tr.HitPos)
							net.WriteVector(tr.Normal * 120 + VectorRand() * 30)
							net.Broadcast()
						end
						util.Decal("Blood", tr.HitPos + tr.HitNormal * 4, tr.HitPos - tr.HitNormal * 32)
						sound.Play("physics/flesh/flesh_squishy_impact_hard" .. math.random(1, 4) .. ".wav", tr.HitPos, 75, math.random(95, 105))

						if (dmg >= 25 or targetPly:GetNWFloat("pain", 0) > 90) and not targetPly.Fake then
							if Faking then
								Faking(targetPly, -tr.Normal * math.min(dmg * 8, 300))
							elseif targetPly.EnterFake then
								targetPly:EnterFake(-tr.Normal * math.min(dmg * 8, 300))
							end
						end

						local newHp = math.max(0, targetPly:Health() - dmg)
						targetPly:SetHealth(newHp)
						if newHp <= 0 and (targetPly:Alive() or not targetPly.isDead) then
							targetPly.isDead = true
							targetPly:SetNWBool("isDead", true)
							targetPly:SetNWBool("Alive", false)
							targetPly:SetNWBool("FakeDeath", true)
							targetPly:Kill()
						end
					end
				end
			end
		end
	end

	self:SetClip1(self:Clip1() - 1)

	if not ply.fake and ply:GetNWBool("Suiciding") then
		if SERVER then
			local head = ply:LookupBone("ValveBiped.Bip01_Head1")
			head = head and ply:GetBoneMatrix(head)

			dmgTab = CreateDamageTab(ply,ply,self,100,DMG_BULLET)
			dmgTab:AddKill("killyourself")
			dmgTab.hitgroup = HITGROUP_HEAD
			dmgTab.isBullet = true
			dmgTab.bone = ply:LookupBone("ValveBiped.Bip01_Head1")
			dmgTab.pos = head and head:GetTranslation() or self:EyePos()
			dmgTab.force = Vector(0,0,1)
			
			timer.Simple(0,function()
				if not IsValid(ply) then return end

				ply:TakeDamageTab(dmgTab,{"killyourself"})
			end)
		end
	else
		if ply:IsNPC() then
			local target = ply:GetEnemy()

			bullet.Damage = bullet.Damage * 0.75
			
			if SERVER then
				if IsValid(target) then
					if target:IsPlayer() and target.fake then ply:SetEnemy(target.fakeEnt.bull) end
	
					target = ply:GetEnemy()

					if target:GetClass() == "npc_bullseye" then
						//bullet.Dir = Vector(1,0,0):Rotate((bullet.Src - (bullet.Src + target:GetPos())):Angle())

						//bullet.Dir:Rotate(Angle(math.Rand(-3,3),math.Rand(-3,3),0))
					end
				end

				bullet.Damage = bullet.Damage / 2

				bullet.Src = ply:GetShootPos()
				bullet.Dir = ply:GetAimVector()

				gun:FireBullets(bullet)
			end
		else
			ply:LagCompensation(true)

			if CLIENT then
				bullet.Tracer = 1
				
				gun:FireBullets(bullet)
			else
				self:FireBullets(bullet)
			end

			ply:LagCompensation(false)
		end

		self:SetLastShootTime()
	end
	
	/*local effectdata = EffectData()
	effectdata:SetOrigin(pos)
	effectdata:SetAngles(ang)
	effectdata:SetScale(self:IsScope() and 0.1 or 1)
	effectdata:SetNormal(shootDir)
	util.Effect(self.Efect or "MuzzleEffect",effectdata)*/

	if SERVER then
		net.Start("weapon shoot point",true)
		net.WriteString(self:GetClass())
		net.WriteVector(bullet.Src)
		net.WriteVector(bullet.Dir)
		net.WriteInt(self:EntIndex(),14)
		if ply:IsNPC() then net.Broadcast() else net.SendOmit(ply) end
	else
		self:ShootSound(bullet.Src,bullet.Dir,self:EntIndex())
	end

	self:SetNWInt("Chamber",2)

	if self.ChamberAuto then self:InsertChamber() end

	if CLIENT then
		self:ShootEffect(pos,shootDir)
	end
end

function SWEP:dmgTabPre(target,dmgTab) dmgTab.noBlood = self.Primary.NoBlood end
