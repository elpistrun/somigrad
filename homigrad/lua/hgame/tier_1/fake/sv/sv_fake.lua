local cv_fake_cd = CreateConVar("hg_fake_cooldown", "2.0", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Fake cooldown in seconds")

local function IsPlayerOtrub(ply)
	if not IsValid(ply) then return false end
	if ply.Otrub == true then return true end
	if ply:GetNWBool("Otrub", false) or ply:GetNWBool("otrub", false) then return true end
	if tonumber(ply.Otrub) and tonumber(ply.Otrub) > 0 then return true end
	return false
end
local function clearGrab(cons)
	if not cons then return end
	if isentity(cons) and IsValid(cons) then
		cons:Remove()
	elseif istable(cons) then
		if IsValid(cons.cons) then cons.cons:Remove() end
		if cons.phys and IsValid(cons.phys) and cons.worldPin then
			cons.phys:EnableMotion(true)
			cons.phys:Wake()
		end
	end
end

local function resolveHeadPhys(rag)
	if not IsValid(rag) then return nil end
	local names = {
		"ValveBiped.Bip01_Head1",
		"ValveBiped.Bip01_Head",
		"bip_head",
		"Head"
	}
	for _, name in ipairs(names) do
		local b = rag:LookupBone(name)
		if b then
			local pb = rag:TranslateBoneToPhysBone(b)
			if pb and pb >= 0 and pb < rag:GetPhysicsObjectCount() then
				local obj = rag:GetPhysicsObjectNum(pb)
				if IsValid(obj) then return obj end
			end
		end
	end
	local obj = rag:GetPhysicsObjectNum(10)
	if IsValid(obj) then return obj end
	obj = rag:GetPhysicsObjectNum(3)
	if IsValid(obj) then return obj end
	return rag:GetPhysicsObjectNum(0)
end

local function resolveTorsoPhys(rag)
	if not IsValid(rag) then return nil end
	local names = {
		"ValveBiped.Bip01_Spine2",
		"ValveBiped.Bip01_Spine1",
		"ValveBiped.Bip01_Spine4",
		"ValveBiped.Bip01_Spine",
		"bip_spine_2",
		"bip_spine_1",
		"Spine2",
		"Spine"
	}
	for _, name in ipairs(names) do
		local b = rag:LookupBone(name)
		if b then
			local pb = rag:TranslateBoneToPhysBone(b)
			if pb and pb > 0 and pb < rag:GetPhysicsObjectCount() then
				local obj = rag:GetPhysicsObjectNum(pb)
				if IsValid(obj) then return obj end
			end
		end
	end
	local obj = rag:GetPhysicsObjectNum(1)
	return IsValid(obj) and obj or rag:GetPhysicsObjectNum(0)
end

local function resolveHandPhys(rag, isRight)
	if not IsValid(rag) then return nil, -1 end
	local names = isRight and {
		"ValveBiped.Bip01_R_Hand",
		"ValveBiped.Bip01_R_Forearm",
		"ValveBiped.Bip01_R_UpperArm",
		"bip_hand_R",
		"bip_forearm_R",
		"RightHand",
		"RightForeArm"
	} or {
		"ValveBiped.Bip01_L_Hand",
		"ValveBiped.Bip01_L_Forearm",
		"ValveBiped.Bip01_L_UpperArm",
		"bip_hand_L",
		"bip_forearm_L",
		"LeftHand",
		"LeftForeArm"
	}
	for _, name in ipairs(names) do
		local b = rag:LookupBone(name)
		if b then
			local pb = rag:TranslateBoneToPhysBone(b)
			if pb and pb > 0 and pb < rag:GetPhysicsObjectCount() then
				local obj = rag:GetPhysicsObjectNum(pb)
				if IsValid(obj) then return obj, pb end
			end
		end
	end
	local defaultNum = isRight and 7 or 5
	if defaultNum < rag:GetPhysicsObjectCount() then
		local obj = rag:GetPhysicsObjectNum(defaultNum)
		if IsValid(obj) then return obj, defaultNum end
	end
	return nil, -1
end

local function clampReachPos(headPos, torsoPos, fwd, lateralOffset)
	local target = headPos + fwd * 25 + (lateralOffset or Vector())
	if torsoPos then
		local diff = target - torsoPos
		local dist = diff:Length()
		if dist > 30 then
			target = torsoPos + diff:GetNormalized() * 30
		end
	end
	return target
end

local function GetPelvisPhys(rag)
	local b = rag:LookupBone("ValveBiped.Bip01_Pelvis")
	if b then
		local pb = rag:TranslateBoneToPhysBone(b)
		if pb and pb >= 0 then
			local obj = rag:GetPhysicsObjectNum(pb)
			if IsValid(obj) then return obj end
		end
	end
	local obj = rag:GetPhysicsObjectNum(0)
	return IsValid(obj) and obj or rag:GetPhysicsObjectNum(1)
end

hg = hg or {}
BleedingEntities = BleedingEntities or {}
TwoHandedOrNo = TwoHandedOrNo or {}

local hgFakeNets = {
	"fake", "fake up", "RemoveRag", "DeadBodies", "unload",
	"plankton", "ShowKot", "showiconleft", "showiconright", "hideiconleft", "hideiconright",
	"shlem", "shlem reset", "damage bol", "ragplayercolor", "bp headshoot explode",
	"blood particle explode", "bp fall", "blyed", "blood particle", "bleed artery",
	"blood particle more", "bp buckshoot", "bp hit", "GIBHEAD",
}
for i = 1, #hgFakeNets do
	util.AddNetworkString(hgFakeNets[i])
end

if not SpawnWeapon then
	function SpawnWeapon(ply) end
end
if not DespawnWeapon then
	function DespawnWeapon(ply) end
end
if not FireShot then
	function FireShot(wep) end
end
if not Reload then
	function Reload(wep) end
end
if not SpawnWeaponEnt then
	function SpawnWeaponEnt(class, pos, ply)
		local ent = ents.Create(class)
		if IsValid(ent) then
			ent:SetPos(pos)
			ent:Spawn()
			return ent
		end
	end
end
BleedingEntities = {}
local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")
Organs = {
	["brain"] = 5,
	["lungs"] = 30,
	["liver"] = 30,
	["stomach"] = 40,
	["intestines"] = 40,
	["heart"] = 10,
	["artery"] = 1,
	["spine"] = 10
}

local bonenames = {
	["ValveBiped.Bip01_Head1"] = "Head",
	["ValveBiped.Bip01_Spine"] = "Belly",
	["ValveBiped.Bip01_Spine1"] = "intestines",
	["ValveBiped.Bip01_Spine2"] = "Chest",
	["ValveBiped.Bip01_Spine4"] = "Chest",
	["ValveBiped.Bip01_Pelvis"] = "Belly",
	["ValveBiped.Bip01_R_Hand"] = "Right hand",
	["ValveBiped.Bip01_R_Forearm"] = "Head",
	["ValveBiped.Bip01_R_Foot"] = "Right leg",
	["ValveBiped.Bip01_R_Thigh"] = "Right thigh",
	["ValveBiped.Bip01_R_Calf"] = "Right calf",
	["ValveBiped.Bip01_R_Shoulder"] = "Right shoulder",
	["ValveBiped.Bip01_R_Elbow"] = "Right elbow",
	["ValveBiped.Bip01_L_Hand"] = "Left hand",
	["ValveBiped.Bip01_L_Forearm"] = "Head",
	["ValveBiped.Bip01_L_Foot"] = "Left leg",
	["ValveBiped.Bip01_L_Thigh"] = "Left thigh",
	["ValveBiped.Bip01_L_Calf"] = "Left calf",
	["ValveBiped.Bip01_L_Shoulder"] = "Left shoulder",
	["ValveBiped.Bip01_L_Elbow"] = "Left elbow"
}

--Умножения урона при попадании по регдоллу
RagdollDamageBoneMul = {
	[HITGROUP_LEFTLEG] = 0.8,
	[HITGROUP_RIGHTLEG] = 0.8,
	[HITGROUP_GENERIC] = 0.8,
	[HITGROUP_LEFTARM] = 0.8,
	[HITGROUP_RIGHTARM] = 0.8,
	[HITGROUP_CHEST] = 1.0,
	[HITGROUP_STOMACH] = 0.9,
	[HITGROUP_HEAD] = 15,
}

--Хитгруппы костей
local bonetohitgroup = {
	["ValveBiped.Bip01_Head1"] = 1,
	["ValveBiped.Bip01_Neck1"] = 1,
	["ValveBiped.Bip01_R_UpperArm"] = 5,
	["ValveBiped.Bip01_R_Forearm"] = 5,
	["ValveBiped.Bip01_R_Hand"] = 5,
	["ValveBiped.Bip01_L_UpperArm"] = 4,
	["ValveBiped.Bip01_L_Forearm"] = 4,
	["ValveBiped.Bip01_L_Hand"] = 4,
	["ValveBiped.Bip01_Pelvis"] = 3,
	["ValveBiped.Bip01_Spine2"] = 2,
	["ValveBiped.Bip01_L_Thigh"] = 6,
	["ValveBiped.Bip01_L_Calf"] = 6,
	["ValveBiped.Bip01_L_Foot"] = 6,
	["ValveBiped.Bip01_R_Thigh"] = 7,
	["ValveBiped.Bip01_R_Calf"] = 7,
	["ValveBiped.Bip01_R_Foot"] = 7
}

-- Сохранение игрока перед его падением в фейк
function SavePlyInfo(ply)
	ply.Info = ply.Info or {}
	local info = ply.Info
	info.Model = ply:GetModel()
	info.Skin = ply:GetSkin()
	info.Color = ply:GetColor()
	info.PlayerColor = ply:GetPlayerColor()
	info.BodyGroups = {}
	for _, bg in ipairs(ply:GetBodyGroups() or {}) do
		info.BodyGroups[bg.id] = ply:GetBodygroup(bg.id)
	end
	info.Hp = ply:Health()
	info.Armor = ply:Armor()
	info.HasSuit = (ply.IsSuitEquipped and ply:IsSuitEquipped()) or false
	info.SuitPower = (ply.GetSuitPower and ply:GetSuitPower()) or 0
	info.Ammo = (ply.GetAmmo and ply:GetAmmo()) or {}
	info.ActiveWeapon = IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() or nil
	info.ActiveWeapon2 = ply:GetActiveWeapon()
	GetFakeWeapon(ply)
	info.Weapons = {}
	for i, wep in pairs(ply:GetWeapons()) do
		info.Weapons[wep:GetClass()] = {
			Clip1 = wep:Clip1(),
			Clip2 = wep:Clip2(),
		}
	end

	return info
end

function GetFakeWeapon(ply)
	ply.curweapon = ply.Info and ply.Info.ActiveWeapon
end

function ClearFakeWeapon(ply)
	if ply.FakeShooting then
		DespawnWeapon(ply)
	end
end

-- Сохранение игрока перед вставанием
function SavePlyInfoPreSpawn(ply)
	ply.Info = ply.Info or {}
	local info = ply.Info
	info.Hp = ply:Health()
	info.Armor = ply:Armor()

	return info
end

-- возвращение информации игроку по его вставанию
function ReturnPlyInfo(ply)
	ClearFakeWeapon(ply)
	local info = ply.Info
	if not info then return end

	if info.Model and info.Model ~= "" then
		ply:SetModel(info.Model)
	end
	if info.Skin then
		ply:SetSkin(info.Skin)
	end
	if info.Color then
		ply:SetColor(info.Color)
	end
	if info.PlayerColor then
		ply:SetPlayerColor(info.PlayerColor)
	end
	if info.BodyGroups then
		for id, val in pairs(info.BodyGroups) do
			ply:SetBodygroup(id, val)
		end
	end

	ply:SetNoDraw(false)
	ply:SetNotSolid(false)
	ply:SetMoveType(MOVETYPE_WALK)
	ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	ply:DrawViewModel(true)
	if ply.SetupBones then ply:SetupBones() end

	ply:SetSuppressPickupNotices(true)
	ply:StripWeapons()
	ply:StripAmmo()
	for name, wepinfo in pairs(info.Weapons or {}) do
		local weapon = ply:Give(name, true)
		if IsValid(weapon) then
			weapon:SetClip1(wepinfo.Clip1)
			weapon:SetClip2(wepinfo.Clip2)
		end
	end

	for ammo, amt in pairs(info.Ammo or {}) do
		ply:GiveAmmo(amt, ammo)
	end

	if info.ActiveWeapon then
		ply:SelectWeapon(info.ActiveWeapon)
	end

	if info.HasSuit and ply.EquipSuit then
		ply:EquipSuit()
		if ply.SetSuitPower then ply:SetSuitPower(info.SuitPower or 0) end
	elseif ply.RemoveSuit then
		ply:RemoveSuit()
	end

	local curHp = ply:Health()
	local savedHp = info.Hp
	local finalHp = curHp

	if curHp <= 0 and savedHp and savedHp > 0 then
		finalHp = savedHp
	elseif savedHp and savedHp > 0 then
		finalHp = math.min(curHp, savedHp)
	end

	if not finalHp or finalHp <= 0 then
		finalHp = (curHp > 0 and curHp) or 1
	end

	ply:SetHealth(finalHp)
	info.Hp = finalHp
	ply:SetArmor(info.Armor or ply:Armor() or 0)
	ply:SetSuppressPickupNotices(false)
end

-- функция падения
function Faking(ply, force)
	if not IsValid(ply) or not ply:Alive() or ply:Health() <= 0 then return end

	local cd = math.max(0.5, cv_fake_cd and cv_fake_cd:GetFloat() or 2.0)

	-- Кулдаун на падение в фейк и вставание
	if not force then
		if timer.Exists("faketimer" .. ply:EntIndex()) then return end
		if (ply.NextFakeToggle or 0) > CurTime() then return end
	end

	local isCurrentlyInFake = ply.fake or IsValid(ply:GetNWEntity("DeathRagdoll")) or IsValid(ply:GetNWEntity("FakeRagdoll")) or IsValid(ply:GetNWEntity("Ragdoll"))

	ply.NextFakeToggle = CurTime() + cd
	ply:SetNWFloat("NextFakeToggle", ply.NextFakeToggle)
	ply:SetNWFloat("FakeCooldownMax", cd)
	timer.Create("faketimer" .. ply:EntIndex(), cd, 1, function() end)

	if not isCurrentlyInFake then
		-- Падение в фейк
		ply.fake = true
		ply.Fake = true
		ply:SetNWBool("fake", true)
		ply:SetNWBool("Fake", true)

		SavePlyInfo(ply)
		ply:DrawViewModel(false)
		ply:SetNoDraw(true)
		ply:SetNotSolid(true)

		if ply:InVehicle() then
			ply:ExitVehicle()
		end

		local rag = ply:CreateRagdoll()
		if not IsValid(rag) then rag = ply:GetNWEntity("DeathRagdoll") end
		if not IsValid(rag) then rag = ply:GetNWEntity("FakeRagdoll") end
		if not IsValid(rag) then rag = ply:GetNWEntity("Ragdoll") end

		if not IsValid(rag) then
			ply.fake = false
			ply.Fake = false
			ply:SetNWBool("fake", false)
			ply:SetNWBool("Fake", false)
			ply:SetNoDraw(false)
			ply:SetNotSolid(false)
			ply:DrawViewModel(true)
			return
		end

		ply.fakeragdoll = rag
		ply.FakeRagdoll = rag
		ply:SetNWEntity("FakeRagdoll", rag)
		ply:SetNWEntity("Ragdoll", rag)
		ply:SetNWEntity("DeathRagdoll", rag)
		rag:SetNWEntity("RagdollOwner", ply)
		rag:SetNWEntity("RagdollController", ply)
		rag.RagdollOwner = ply
		rag.hgOwner = ply
		if ply.SetDummy then ply:SetDummy(rag) end

		if isvector(force) then
			for i = 0, rag:GetPhysicsObjectCount() - 1 do
				local physobj = rag:GetPhysicsObjectNum(i)
				if IsValid(physobj) then physobj:AddVelocity(force) end
			end
		end

		ply:HuySpectate()
		ply:SetSuppressPickupNotices(false)
		ply:SetActiveWeapon(nil)
		ply:DropObject()

		net.Start("fake")
		net.WriteInt(rag:EntIndex(), 16)
		net.Send(ply)

		local guninfo = ply.curweapon and weapons.Get(ply.curweapon)
		if guninfo and guninfo.Base == "salat_base" then
			ply.FakeShooting = true
			ply:SetNWInt("FakeShooting", true)
		else
			ply.FakeShooting = false
			ply:SetNWInt("FakeShooting", false)
		end
	else
		-- Вставание из фейка
		if ply.NeckBroken then return end

		SavePlyInfoPreSpawn(ply)

		ply.fake = false
		ply.Fake = false
		ply:SetNWBool("fake", false)
		ply:SetNWBool("Fake", false)

		local rag = ply:GetNWEntity("DeathRagdoll")
		if not IsValid(rag) then rag = ply:GetNWEntity("FakeRagdoll") end
		if not IsValid(rag) then rag = ply:GetNWEntity("Ragdoll") end

		if IsValid(rag) then
			if rag.inv then
				ply.Info = ply.Info or {}
				ply.Info.Weapons = ply.Info.Weapons or {}

				for _, item in ipairs(rag.inv:GetAllItems()) do
					local class = item.spawnname
					local ent = item.ent
					if class and class ~= "weapon_hands" and class ~= "weapon_fists" and class ~= "weapon_zombie" then
						if (string.StartWith(class, "ent_jack_gmod_ezarmor_") or item.armorName) and isfunction(Armor_Equip) then
							Armor_Equip(ply, item.armorName or class, item.col)
							if IsValid(ent) then ent:Remove() end
						else
							ply.Info.Weapons[class] = {
								Clip1 = item.clip or (IsValid(ent) and ent:IsWeapon() and ent:Clip1()) or 0,
								Clip2 = 0
							}
							if IsValid(ent) then ent:Remove() end
						end
					end
				end

				for viewer in pairs(rag.inv.viewers or {}) do
					if IsValid(viewer) then
						rag.inv:Close(viewer)
					end
				end

				if Inv then
					if Inv.objects then Inv.objects[rag] = nil end
					if Inv.objectsID and rag.inv.id then Inv.objectsID[rag.inv.id] = nil end
				end
				rag.inv = nil
			end

			clearGrab(rag.ZacConsLH)
			clearGrab(rag.ZacConsRH)
			rag.ZacConsLH = nil
			rag.ZacConsRH = nil

			ply.fakeragdoll = nil
			ply.FakeRagdoll = nil

			local pos = rag:GetPos()
			local pelvis = rag:LookupBone("ValveBiped.Bip01_Pelvis")
			if pelvis and pelvis >= 0 then
				local mat = rag:GetBoneMatrix(pelvis)
				if mat then pos = mat:GetTranslation() end
			end

			local trFloor = util.TraceLine({
				start = pos + Vector(0, 0, 20),
				endpos = pos - Vector(0, 0, 60),
				filter = {ply, rag},
				mask = MASK_PLAYERSOLID
			})
			local groundZ = trFloor.Hit and trFloor.HitPos.z or pos.z
			local standPos = Vector(pos.x, pos.y, groundZ + 2)

			local trFit = util.TraceHull({
				start = standPos,
				endpos = standPos + Vector(0, 0, 10),
				mins = Vector(-16, -16, 0),
				maxs = Vector(16, 16, 72),
				filter = {ply, rag},
				mask = MASK_PLAYERSOLID
			})
			if trFit.StartSolid then
				standPos = pos + Vector(0, 0, 10)
			end

			-- Disable ragdoll collisions so it doesn't fling the player into walls
			rag:SetNotSolid(true)
			rag:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			for i = 0, rag:GetPhysicsObjectCount() - 1 do
				local phys = rag:GetPhysicsObjectNum(i)
				if IsValid(phys) then
					phys:EnableCollisions(false)
					phys:SetVelocity(vector_origin)
				end
			end

			local eyepos = ply:EyeAngles()

			ply:UnSpectate()
			ply:SetMoveType(MOVETYPE_WALK)
			ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
			ply:SetNotSolid(false)
			ply:SetNoDraw(false)
			ply:SetPos(standPos)
			ply:SetVelocity(-ply:GetVelocity())
			if ply.SetLocalVelocity then ply:SetLocalVelocity(vector_origin) end
			if ply.SetBaseVelocity then ply:SetBaseVelocity(vector_origin) end
			ply:SetEyeAngles(eyepos)
			ply:DrawViewModel(true)
			if ply.SetDummy then ply:SetDummy(nil) end

			ReturnPlyInfo(ply)

			ply.FakeShooting = false
			ply:SetNWInt("FakeShooting", false)

			net.Start("fake up")
			net.Broadcast()

			rag:Remove()
			ply:SetNWEntity("DeathRagdoll", nil)
			ply:SetNWEntity("FakeRagdoll", nil)
			ply:SetNWEntity("Ragdoll", nil)

			if rag.inv then
				if isfunction(ReturnPlayerLoot) then
					ReturnPlayerLoot(rag.inv)
				elseif isfunction(DropAllInvItems) then
					DropAllInvItems(rag.inv, rag:GetPos())
				end
			end

			-- Cancel any residual engine launch momentum on the next tick
			timer.Simple(0, function()
				if IsValid(ply) and not ply.fake then
					if ply.SetLocalVelocity then ply:SetLocalVelocity(vector_origin) end
					ply:SetVelocity(-ply:GetVelocity())
					if ply.SetBaseVelocity then ply:SetBaseVelocity(vector_origin) end
				end
			end)

			local cd = math.max(0.5, cv_fake_cd and cv_fake_cd:GetFloat() or 2.0)
			ply.NextFakeToggle = CurTime() + cd
			ply:SetNWFloat("NextFakeToggle", ply.NextFakeToggle)
			ply:SetNWFloat("FakeCooldownMax", cd)
			timer.Create("faketimer" .. ply:EntIndex(), cd, 1, function() end)
		else
			ply:UnSpectate()
			ply:SetMoveType(MOVETYPE_WALK)
			ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
			ply:SetNotSolid(false)
			ply:SetNoDraw(false)
			ply:DrawViewModel(true)
			ReturnPlyInfo(ply)
			local cd = math.max(0.5, cv_fake_cd and cv_fake_cd:GetFloat() or 2.0)
			ply.NextFakeToggle = CurTime() + cd
			ply:SetNWFloat("NextFakeToggle", ply.NextFakeToggle)
			ply:SetNWFloat("FakeCooldownMax", cd)
			timer.Create("faketimer" .. ply:EntIndex(), cd, 1, function() end)
			net.Start("fake up")
			net.Broadcast()
		end
	end
end

local function IsHeadPhysBone(rag, physObj)
	if not IsValid(rag) or not IsValid(physObj) then return false end
	local headBone = rag:LookupBone("ValveBiped.Bip01_Head1") or rag:LookupBone("ValveBiped.Bip01_Neck1")
	if headBone then
		local headPhysNum = rag:TranslateBoneToPhysBone(headBone)
		if headPhysNum and rag:GetPhysicsObjectNum(headPhysNum) == physObj then
			return true
		end
	end

	for i = 0, rag:GetPhysicsObjectCount() - 1 do
		if rag:GetPhysicsObjectNum(i) == physObj then
			local b = rag:TranslatePhysBoneToBone(i)
			local bName = string.lower(rag:GetBoneName(b) or "")
			if string.find(bName, "head") or string.find(bName, "neck") then
				return true
			end
			break
		end
	end

	return false
end

function HG_BreakNeck(ply, rag, hitPos, hitNormal, attacker, inflictor, fatal)
	return
end

function PlayerMeta:InFake()
	return self.fake or self:GetNWBool("fake", false) or self:GetNWBool("Fake", false)
end

function PlayerMeta:GetDummy()
	local rag = self:GetNWEntity("DeathRagdoll")
	if IsValid(rag) then return rag end
	rag = self:GetNWEntity("FakeRagdoll")
	if IsValid(rag) then return rag end
	rag = self:GetNWEntity("Ragdoll")
	if IsValid(rag) then return rag end
	return self
end

function PlayerMeta:EnterFake(force)
	if not self.fake then
		Faking(self, force)
	end
end

function PlayerMeta:ExitFake(force)
	if self.fake then
		Faking(self, force)
	end
end

--функция стрельбы лежа
hook.Add(
	"Think",
	"FakedShoot",
	function()
		for i, ply in ipairs(player.GetAll()) do
			if IsValid(ply:GetNWEntity("DeathRagdoll")) and ply.FakeShooting and ply:Alive() then
				SpawnWeapon(ply)
			else
				if IsValid(ply.wep) then
					DespawnWeapon(ply)
				end
			end
		end
	end
)

--функция, определяет хозяина регдолла
function RagdollOwner(rag)
	if not IsValid(rag) then return false end
	if IsValid(rag.RagdollOwner) then return rag.RagdollOwner end
	local owner = rag:GetNWEntity("RagdollOwner")
	if IsValid(owner) then return owner end
	for k, v in ipairs(player.GetAll()) do
		if v:GetNWEntity("DeathRagdoll") == rag or v:GetNWEntity("FakeRagdoll") == rag or v:GetNWEntity("Ragdoll") == rag then
			return v
		end
	end
	return false
end
hg.RagdollOwner = RagdollOwner

function PlayerMeta:DropWep(wep, target, velocity)
	local ply = self
	if not IsValid(ply) then return end

	wep = (IsValid(wep) and wep:GetOwner() == ply) and wep or ply:GetActiveWeapon()
	if not IsValid(wep) then return end

	local class = wep:GetClass()
	if class == "weapon_hands" or class == "weapon_fists" or class == "weapon_zombie" then return end

	local clip1 = wep:Clip1()
	local clip2 = wep:Clip2()
	local chamber = (wep.GetNWInt and wep:GetNWInt("Chamber", 0)) or 0
	local eyeAng = ply:EyeAngles()
	local dropPos = ply:EyePos() + eyeAng:Forward() * 32 + Vector(0, 0, -5)
	local dropVel = velocity or (eyeAng:Forward() * 220 + Vector(0, 0, 30) + ply:GetVelocity())

	local isFake = ply.Fake or ply:GetNWBool("fake", false)
	local rag = isFake and (ply.FakeRagdoll or ply.hgFakeRagdoll or (ply.GetNWEntity and ply:GetNWEntity("FakeRagdoll")))
	if isFake and IsValid(rag) then
		local hand = rag:LookupBone("ValveBiped.Bip01_R_Hand")
		if hand and hand >= 0 then
			dropPos = rag:GetBonePosition(hand) or (rag:GetPos() + Vector(0, 0, 15))
		else
			dropPos = rag:GetPos() + Vector(0, 0, 15)
		end
		dropVel = velocity or (eyeAng:Forward() * 150 + Vector(0, 0, 20))
	end

	ply:StripWeapon(class)

	local ent = ents.Create(class)
	if IsValid(ent) then
		ent.droppedBy = ply
		ent.nextPickup = CurTime() + 1.5

		if wep.WorldModel and wep.WorldModel ~= "" then
			ent:SetModel(wep.WorldModel)
		end
		ent:SetPos(dropPos)
		ent:SetAngles(eyeAng)
		ent:Spawn()
		ent:Activate()
		if (not ent:GetModel() or ent:GetModel() == "") and wep.WorldModel and wep.WorldModel ~= "" then
			ent:SetModel(wep.WorldModel)
		end
		ent.Clip = clip1
		if ent.SetClip1 then ent:SetClip1(clip1) end
		if ent.SetClip2 then ent:SetClip2(clip2) end
		if ent.SetNWInt then ent:SetNWInt("Chamber", chamber) end

		if ent.OnDrop then
			ent:OnDrop(ply)
		end

		if not IsValid(ent:GetPhysicsObject()) then
			if not ent:PhysicsInit(SOLID_VPHYSICS) or not IsValid(ent:GetPhysicsObject()) then
				if ent.PhysicsInitStandard then ent:PhysicsInitStandard() end
				if not IsValid(ent:GetPhysicsObject()) then
					ent:PhysicsInitBox(Vector(-8, -3, -3), Vector(8, 3, 3))
					ent:SetCollisionBounds(Vector(-8, -3, -3), Vector(8, 3, 3))
				end
			end
		end

		ent:SetMoveType(MOVETYPE_VPHYSICS)
		ent:SetSolid(SOLID_VPHYSICS)
		ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)

		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
			phys:EnableMotion(true)
			phys:SetVelocity(dropVel)
			phys:AddAngleVelocity(VectorRand() * 60)
		end
	end

	hook.Run("PlayerDroppedWeapon", ply, ent)
	ply:SetNWFloat("DropAnim", CurTime())

	timer.Simple(0, function()
		if IsValid(ply) and ply:Alive() and ply:HasWeapon("weapon_hands") then
			ply:SelectWeapon("weapon_hands")
		end
	end)

	return ent
end

function PlayerMeta:DropWeapon(wep, target, velocity)
	return self:DropWep(wep, target, velocity)
end

local oldGive = PlayerMeta.Give
function PlayerMeta:Give(...)
	self._isGivingWeapon = true
	local res = oldGive(self, ...)
	self._isGivingWeapon = nil
	return res
end

local oldPickupWeapon = PlayerMeta.PickupWeapon
function PlayerMeta:PickupWeapon(...)
	self._isGivingWeapon = true
	local res = oldPickupWeapon(self, ...)
	self._isGivingWeapon = nil
	return res
end

hook.Add("PlayerCanPickupWeapon", "Homigrad_WeaponPickupDelay", function(ply, wep)
	if not IsValid(ply) or not IsValid(wep) then return end

	-- Programmatic give (round start, loadout, hands, commands) must always be allowed!
	if ply._isGivingWeapon or ply.AllowWeaponPickup or ply.spawningFromRoundStart then
		return true
	end

	local class = wep:GetClass()

	-- If the player already has this weapon, do NOT pick it up as ammo!
	if ply:HasWeapon(class) and not ply.AllowDuplicatePickup then
		return false
	end

	-- Delay after dropping
	if wep.droppedBy == ply and (wep.nextPickup or 0) > CurTime() then
		return false
	end

	-- Prevent automatic walking-over pickup:
	-- Loose weapons on the ground should only be picked up intentionally with +USE (E key) or via inventory
	if not ply:KeyDown(IN_USE) and not wep.canpickup then
		return false
	end

	return true
end)


function PlayerMeta:PickupEnt()
	local ply = self
	local rag = ply:GetNWEntity("DeathRagdoll")
	local phys = rag:GetPhysicsObjectNum(7)
	local offset = phys:GetAngles():Right() * 5
	local traceinfo = {
		start = phys:GetPos(),
		endpos = phys:GetPos() + offset,
		filter = rag,
		output = trace,
	}

	local trace = util.TraceLine(traceinfo)
	if trace.Entity == Entity(0) or trace.Entity == NULL or not trace.Entity.canpickup then return end
	if trace.Entity:GetClass() == "wep" then
		ply:Give(trace.Entity.curweapon, true):SetClip1(trace.Entity.Clip)
		--SavePlyInfo(ply)
		ply.wep.Clip = trace.Entity.Clip
		trace.Entity:Remove()
	end
end

--обнуление регдолла после вставания
hook.Add(
	"PlayerDeath",
	"resetfakes",
	function(ply, inflictor, attacker)
		if ply.fake then
			ply.fake = false
			ply.Fake = false
			ply:SetNWBool("fake", false)
			ply:SetNWBool("Fake", false)
			ply:SetNWBool("FakeDeath", true)
			ply.isDead = true
			ply:SetNWBool("isDead", true)
			ply:SetNWBool("Alive", false)
			ply.NextFakeToggle = 0
			ply:SetNWFloat("NextFakeToggle", 0)
			timer.Remove("faketimer" .. ply:EntIndex())
			ply:SetParent()
			ply:UnSpectate()
			ply:Spectate(OBS_MODE_ROAMING)
			ply:SetMoveType(MOVETYPE_NOCLIP)
			ply:SetNoDraw(true)
			ply:SetNotSolid(true)
		else
			ply.NextFakeToggle = 0
			ply:SetNWFloat("NextFakeToggle", 0)
			timer.Remove("faketimer" .. ply:EntIndex())
		end

		-- Death messages removed as requested
	end
)

hook.Add(
	"PhysgunDrop",
	"DropPlayer",
	function(ply, ent)
		if IsValid(ent) then ent.isheld = false end
	end
)

hook.Add(
	"PhysgunPickup",
	"DropPlayer2",
	function(ply, ent)
		if not IsValid(ent) then return end
		ent.isheld = true
		if ent:IsPlayer() and ent:Alive() and not ent.fake then
			Faking(ent)
			timer.Simple(0, function()
				if IsValid(ply) and IsValid(ent) then
					local rag = ent:GetNWEntity("DeathRagdoll") or ent:GetNWEntity("FakeRagdoll") or ent.fakeEnt
					if IsValid(rag) and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "weapon_physgun" then
						ply:PhysgunPickup(rag)
					end
				end
			end)
			return true
		end
	end
)

--обнуление регдолла после вставания
hook.Add(
	"DoPlayerDeath",
	"resetfakes3232",
	function(ply)
		if ply.fake or IsValid(ply:GetNWEntity("DeathRagdoll")) or IsValid(ply:GetNWEntity("FakeRagdoll")) or IsValid(ply.fakeragdoll) then
			local rag = ply:GetNWEntity("DeathRagdoll")
			if not IsValid(rag) then rag = ply:GetNWEntity("FakeRagdoll") end
			if not IsValid(rag) then rag = ply.fakeragdoll end
			if IsValid(rag) then
				rag.deadbody = true
				rag.hgIsDeathCorpse = true
				rag:SetNWBool("hgDeathCorpse", true)
				rag:SetNWString("Nick", ply:Nick())
				rag:SetNWString("PlayerName", ply:Nick())
				if ply.IsBleeding then
					rag.IsBleeding = true
				end
				table.insert(BleedingEntities, rag)
				rag:SetEyeTarget(vector_origin)
				ply.hgDeathRagdollCreated = rag
			end
			ply.wasFakeOnDeath = true
			ply.fake = false
			ply.Fake = false
			ply:SetNWBool("fake", false)
			ply:SetNWBool("Fake", false)
			ply:SetNWBool("FakeDeath", true)
			ply.isDead = true
			ply:SetNWBool("isDead", true)
			ply:SetNWBool("Alive", false)
			ply:UnSpectate()
			ply:Spectate(OBS_MODE_ROAMING)
			ply:SetMoveType(MOVETYPE_NOCLIP)
			ply:SetNoDraw(true)
			ply:SetNotSolid(true)
		end
	end
)

--ply:GetNWEntity("DeathRagdoll").index=table.MemberValuesFromKey(BleedingEntities,ply:GetNWEntity("DeathRagdoll"))
hook.Add(
	"Think",
	"BodyDespawn",
	function()
		for i, ent in pairs(ents.FindByClass("prop_ragdoll")) do
			if ent.deadbody and engine.ActiveGamemode() == "sandbox" then
				if IsValid(ent.ZacConsLH) then
					ent.ZacConsLH:Remove()
					ent.ZacConsLH = nil
				end

				if IsValid(ent.ZacConsRH) then
					ent.ZacConsRH:Remove()
					ent.ZacConsRH = nil
				end

				if not timer.Exists("DecayTimer" .. ent:EntIndex()) then
					timer.Create(
						"DecayTimer" .. ent:EntIndex(),
						60,
						1,
						function()
							if IsValid(ent) then
								ent:Remove()
								table.RemoveByValue(BleedingEntities, ent)
							end
						end
					)
				end
			end
		end
	end
)

util.AddNetworkString("ragplayercolor")
function EntityMeta:BetterSetPlayerColor(col)
	if not (col or self) then return end
	timer.Simple(
		.1,
		function()
			if not IsValid(self) then return end
			net.Start("ragplayercolor")
			net.WriteEntity(self)
			net.WriteVector(col)
			net.Broadcast()
		end
	)
end

--обнуление регдолла после вставания
--обнуление регдолла после вставания/возрождения
hook.Add(
	"PlayerSpawn",
	"resetfakebody",
	function(ply)
		local oldRag = ply:GetNWEntity("DeathRagdoll")
		if not IsValid(oldRag) then oldRag = ply:GetNWEntity("FakeRagdoll") end
		if not IsValid(oldRag) then oldRag = ply:GetNWEntity("Ragdoll") end
		if not IsValid(oldRag) then oldRag = ply.fakeragdoll end
		if not IsValid(oldRag) then oldRag = ply.fakeEnt end

		if IsValid(oldRag) and not oldRag:IsPlayer() then
			if not oldRag.deadbody or ply.fake then
				if oldRag.inv then
					if isfunction(DropAllInvItems) then
						DropAllInvItems(oldRag.inv, oldRag:GetPos())
					end
				end
				oldRag:Remove()
			end
		end

		ply.fake = false
		ply.Fake = false
		ply:SetNWBool("fake", false)
		ply:SetNWBool("Fake", false)
		ply:SetNWEntity("DeathRagdoll", NULL)
		ply:SetNWEntity("FakeRagdoll", NULL)
		ply:SetNWEntity("Ragdoll", NULL)
		ply.fakeragdoll = nil
		ply.FakeRagdoll = nil
		ply.fakeEnt = nil
		ply.FakeShooting = false
		ply:SetNWInt("FakeShooting", false)
		ply.NextFakeToggle = 0
		ply:SetNWFloat("NextFakeToggle", 0)
		timer.Remove("faketimer" .. ply:EntIndex())
		ply.NeckBroken = false
		ply:SetNWBool("NeckBroken", false)
		ply.LastNeckCheck = nil
		ply.wasFakeOnDeath = nil
		ply.hgDeathRagdollCreated = nil

		ply:UnSpectate()
		ply:SetMoveType(MOVETYPE_WALK)
		ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
		ply:SetNotSolid(false)
		ply:SetNoDraw(false)
		ply:DrawViewModel(true)
		if ply.SetupBones then ply:SetupBones() end

		ply.LeftArm = 1
		ply.RightArm = 1
		ply.LeftLeg = 1
		ply.RightLeg = 1
		ply.Otrub = false
		ply.stamina = ply.stamina or 100
		ply.suiciding = false

		ply.Organs = {
			["brain"] = 20,
			["lungs"] = 30,
			["liver"] = 30,
			["stomach"] = 40,
			["intestines"] = 40,
			["heart"] = 10,
			["artery"] = 1,
			["spine"] = 10
		}

		ply.InternalBleeding = nil
		ply.InternalBleeding2 = nil
		ply.InternalBleeding3 = nil
		ply.InternalBleeding4 = nil
		ply.InternalBleeding5 = nil
		ply.arterybleeding = false
		ply.brokenspine = false

		net.Start("fake up")
		net.Broadcast()
	end
)

--урон по разным костям регдолла
hook.Add(
	"EntityTakeDamage",
	"ragdamage",
	function(ent, dmginfo)
		if ent.deadbody and not ent.IsBleeding and dmginfo:IsDamageType(DMG_BULLET + DMG_SLASH + DMG_BLAST + DMG_ENERGYBEAM + DMG_NEVERGIB + DMG_ALWAYSGIB + DMG_PLASMA + DMG_AIRBOAT + DMG_SNIPER + DMG_BUCKSHOT) then
			ent.IsBleeding = true
		end

		-- Защита от смертельного урона при скольжении, падении или столкновении с игроками/пропами
		local isCrush = dmginfo:IsDamageType(DMG_CRUSH) or dmginfo:GetDamageType() == 1 or dmginfo:IsDamageType(DMG_FALL)
		if isCrush and IsValid(RagdollOwner(ent)) then
			local att = dmginfo:GetAttacker()
			local inf = dmginfo:GetInflictor()
			local isVehicle = IsValid(att) and att:IsVehicle()
			local isProp = (IsValid(att) and not att:IsWorld() and not att:IsPlayer() and not att:IsRagdoll())
				or (IsValid(inf) and not inf:IsWorld() and not inf:IsPlayer() and not inf:IsRagdoll())
			local propVel = (IsValid(att) and att:GetVelocity():Length()) or (IsValid(inf) and inf:GetVelocity():Length()) or 0

			if isProp and propVel > 160 then
				local owner = RagdollOwner(ent)
				local headBone = ent:LookupBone("ValveBiped.Bip01_Head1") or ent:LookupBone("ValveBiped.Bip01_Neck1")
				local headPos = headBone and ent:GetBonePosition(headBone)
				local hitPos = dmginfo:GetDamagePosition()
				if headPos and hitPos:Distance(headPos) < 28 then
					HG_BreakNeck(owner, ent, hitPos, dmginfo:GetDamageForce():GetNormalized(), att, inf, propVel > 320 or dmginfo:GetDamage() > 25)
				end
			elseif not isVehicle then
				local speed = ent:GetVelocity():Length()
				if speed < 520 then
					dmginfo:SetDamage(0)
					return true
				else
					local fallDmg = math.Clamp((speed - 480) * 0.12, 0, 40)
					dmginfo:SetDamage(fallDmg)
				end
			end
		end

		local trace = util.QuickTrace(dmginfo:GetDamagePosition(), dmginfo:GetDamageForce():GetNormalized() * 100)
		local bone = trace.PhysicsBone
		local hitgroup
		local isfall
		local bonename = ent:GetBoneName(bone)
		if bonetohitgroup[bonename] ~= nil then
			hitgroup = bonetohitgroup[bonename]
		end

		if RagdollDamageBoneMul[hitgroup] then
			local owner = RagdollOwner(ent)
			if IsValid(owner) then
				dmginfo:ScaleDamage(0.3)
				local timerName = "faketimer" .. owner:EntIndex()
				local curLeft = timer.TimeLeft(timerName) or 0
				local stunTime = math.max(curLeft, dmginfo:GetDamage() / 30)
				if stunTime > 0 then
					timer.Create(timerName, stunTime, 1, function() end)
					owner.NextFakeToggle = math.max(owner.NextFakeToggle or 0, CurTime() + stunTime)
					owner:SetNWFloat("NextFakeToggle", owner.NextFakeToggle)
				end
				if hitgroup == HITGROUP_HEAD then
					if dmginfo:GetAttacker():IsRagdoll() then return end
					dmginfo:ScaleDamage(2)
					if dmginfo:GetDamageType() == 2 then
						dmginfo:ScaleDamage(2)
					end

					if dmginfo:GetDamageType() == 1 and dmginfo:GetDamage() > 5 and ent:GetVelocity():Length() > 520 and RagdollOwner(ent).Otrub == 0 then
						RagdollOwner(ent).pain = math.Clamp(RagdollOwner(ent).pain + (ent:GetVelocity():Length() - 480) * 0.3, 0, 300)
					end

					-- Classic Homigrad Headshot Explosion!
					local inf = dmginfo:GetInflictor()
					local att = dmginfo:GetAttacker()
					local isMelee = (isfunction(IsKnifeOrMelee) and IsKnifeOrMelee(inf, att)) or dmginfo:IsDamageType(DMG_SLASH + DMG_CLUB)
					local isFirearm = dmginfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT + DMG_SNIPER + DMG_AIRBOAT + DMG_BLAST)
					if not isFirearm and IsValid(inf) then
						local c = string.lower(inf:GetClass())
						if (string.find(c, "wep_") or string.find(c, "weapon_")) and not isMelee then
							isFirearm = true
						end
					end
					if not isFirearm and IsValid(att) and att:IsPlayer() then
						local w = att:GetActiveWeapon()
						if IsValid(w) then
							local c = string.lower(w:GetClass())
							if (string.find(c, "wep_") or string.find(c, "weapon_")) and not isMelee then
								isFirearm = true
							end
						end
					end

					if not isMelee and isFirearm and not ent:GetNWBool("HeadExploded", false) then
						if isfunction(HG_DoHeadshotKill) then
							local hitPos = dmginfo:GetDamagePosition()
							local hitForce = dmginfo:GetDamageForce()
							local hitNormal = (isvector(hitForce) and hitForce:LengthSqr() > 0) and -hitForce:GetNormalized() or Vector(0, 0, 1)
							HG_DoHeadshotKill(RagdollOwner(ent), ent, hitPos, hitNormal, att, inf)
						end
					end
				end

				if hitgroup == HITGROUP_LEFTARM then
					if dmginfo:GetAttacker():IsRagdoll() then return end
					dmginfo:ScaleDamage(0.3)
				end

				if hitgroup == HITGROUP_LEFTLEG then
					if dmginfo:GetAttacker():IsRagdoll() then return end
					dmginfo:ScaleDamage(0.3)
				end

				if hitgroup == HITGROUP_RIGHTLEG then
					if dmginfo:GetAttacker():IsRagdoll() then return end
					dmginfo:ScaleDamage(0.3)
				end

				if hitgroup == HITGROUP_RIGHTARM then
					if dmginfo:GetAttacker():IsRagdoll() then return end
					dmginfo:ScaleDamage(0.3)
				end

				if hitgroup == HITGROUP_CHEST then
					if dmginfo:GetAttacker():IsRagdoll() then return end
					dmginfo:ScaleDamage(0.8)
				end

				if hitgroup == HITGROUP_STOMACH then
					if dmginfo:GetAttacker():IsRagdoll() then return end
					dmginfo:ScaleDamage(0.5)
				end
			end

			local ply
			local penetration
			if IsValid(RagdollOwner(ent)) then
				ply = RagdollOwner(ent)
			elseif ent:IsPlayer() then
				ply = ent
			end

			if dmginfo:IsDamageType(DMG_BULLET + DMG_SLASH) then
				penetration = dmginfo:GetDamageForce() * 0.008
			else
				penetration = dmginfo:GetDamageForce() * 0.004
			end

			if not dmginfo:IsDamageType(DMG_CRUSH + DMG_GENERIC) then
				if hitgroup == 1 and ent:IsPlayer() and ent.fake == false and ent:Alive() then
					Faking(ent)
				end

				--and ent:LookupBone(bonename)==3 then
				if ent:IsPlayer() or IsValid(RagdollOwner(ent)) then
					local matrix = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Spine2"))
					local ang = matrix:GetAngles()
					local pos = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Spine2"))
					local huy = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(), penetration, pos, ang, Vector(-1, 0, -6), Vector(10, 6, 6))
					--ply:ChatPrint("You were hit in the lungs.")
					if huy ~= nil then
						if ply.Organs["lungs"] ~= 0 then
							ply.Organs["lungs"] = math.Clamp(ply.Organs["lungs"] - dmginfo:GetDamage(), 0, 30)
							--if ply.Organs["lungs"]==0 then ply:ChatPrint("Твои легкие были уничтожены.") end
						end
					end
				end

				--lungs
				--and ent:LookupBone(bonename)==6 then
				if ent:IsPlayer() or IsValid(RagdollOwner(ent)) then
					local matrix = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Head1"))
					local ang = matrix:GetAngles()
					local pos = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Head1"))
					local huy = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(), penetration, pos, ang, Vector(2, -4, -3), Vector(7, 4, 3))
					--[[if huy then
					if IsValid(RagdollOwner(ent)) then
						RagdollOwner(ent):Kill()
					elseif ent:IsPlayer() then
						ent:Kill()
					end
				end--]]
					--fuck simplicity
					--ply:ChatPrint("You were hit in the brain.")
					if huy then
						if ply.Organs["brain"] ~= 0 then
							ply.Organs["brain"] = math.Clamp(ply.Organs["brain"] - dmginfo:GetDamage(), 0, 20)
						end
					end
				end

				--brain
				--and ent:LookupBone(bonename)==2 then
				if ent:IsPlayer() or IsValid(RagdollOwner(ent)) then
					local matrix = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Spine1"))
					local ang = matrix:GetAngles()
					local pos = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Spine1"))
					local huy = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(), penetration, pos, ang, Vector(-4, -1, -6), Vector(2, 5, -1))
					--ply:ChatPrint("You were hit in the liver.")
					if huy then
						if ply.Organs["liver"] ~= 0 then
							ply.Organs["liver"] = math.Clamp(ply.Organs["liver"] - dmginfo:GetDamage(), 0, 30)
							--if ply.Organs["liver"]==0 then ply:ChatPrint("Твоя печень была уничтожена.") end
						end
					end
				end

				--liver
				--and ent:LookupBone(bonename)==2 then
				if ent:IsPlayer() or IsValid(RagdollOwner(ent)) then
					local matrix = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Spine1"))
					local ang = matrix:GetAngles()
					local pos = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Spine1"))
					local huy = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(), penetration, pos, ang, Vector(-4, -1, -1), Vector(2, 5, 6))
					--ply:ChatPrint("You were hit in the stomach.")
					if huy then
						if ply.Organs["stomach"] ~= 0 then
							ply.Organs["stomach"] = math.Clamp(ply.Organs["stomach"] - dmginfo:GetDamage(), 0, 40)
							--if ply.Organs["stomach"]==0 then ply:ChatPrint("Твой желудок был уничтожен.") end
						end
					end
				end

				--stomach
				--and ent:LookupBone(bonename)==2 then
				if ent:IsPlayer() or IsValid(RagdollOwner(ent)) then
					local matrix = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Spine"))
					local ang = matrix:GetAngles()
					local pos = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Spine"))
					local huy = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(), penetration, pos, ang, Vector(-4, -1, -6), Vector(1, 5, 6))
					--ply:ChatPrint("You were hit in the intestines.")
					if huy then
						if ply.Organs["intestines"] ~= 0 then
							ply.Organs["intestines"] = math.Clamp(ply.Organs["intestines"] - dmginfo:GetDamage(), 0, 40)
							--if ply.Organs["intestines"]==0 then ply:ChatPrint("Твои кишечник был уничтожен.")end
						end
					end
				end

				--and ent:LookupBone(bonename)==2 then
				if ent:IsPlayer() or IsValid(RagdollOwner(ent)) then
					local matrix = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Spine2"))
					local ang = matrix:GetAngles()
					local pos = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Spine2"))
					local huy = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(), penetration, pos, ang, Vector(1, 0, -1), Vector(5, 4, 3))
					--ply:ChatPrint("You were hit in the heart.")
					if huy then
						if ply.Organs["heart"] ~= 0 then
							ply.Organs["heart"] = math.Clamp(ply.Organs["heart"] - dmginfo:GetDamage(), 0, 10)
							--if ply.Organs["heart"]==0 then ply:ChatPrint("Твое сердце уничтожено.") end
						end
					end
				end

				--heart
				--and ent:LookupBone(bonename)==2 then
				if ent:IsPlayer() or IsValid(RagdollOwner(ent)) and dmginfo:IsDamageType(DMG_BULLET + DMG_SLASH + DMG_BLAST + DMG_ENERGYBEAM + DMG_NEVERGIB + DMG_ALWAYSGIB + DMG_PLASMA + DMG_AIRBOAT + DMG_SNIPER + DMG_BUCKSHOT) then
					local matrix = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Head1"))
					local ang = matrix:GetAngles()
					local pos = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Head1"))
					local huy = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(), penetration, pos, ang, Vector(-3, -2, -2), Vector(0, -1, -1))
					local huy2 = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(), penetration, pos, ang, Vector(-3, -2, 1), Vector(0, -1, 2))
					--ply:ChatPrint("You were hit in the artery.")
					if huy or huy2 then
						if ply.Organs["artery"] ~= 0 then
							ply.Organs["artery"] = math.Clamp(ply.Organs["artery"] - dmginfo:GetDamage(), 0, 1)
							if ply.Organs["artery"] == 0 then
								if not ply.fake then
									Faking(ply)
								end
							end
						end
					end
				end

				--coronary artery
				--and ent:LookupBone(bonename)==2 then
				if ent:IsPlayer() or IsValid(RagdollOwner(ent)) then
					local matrix = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Spine4"))
					local ang = matrix:GetAngles()
					local pos = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Spine4"))
					local huy = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(), penetration, pos, ang, Vector(-8, -1, -1), Vector(2, 0, 1))
					local matrix = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Spine1"))
					local ang = matrix:GetAngles()
					local pos = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Spine1"))
					local huy2 = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(), penetration, pos, ang, Vector(-8, -3, -1), Vector(2, -2, 1))
					--ply:ChatPrint("You were hit in the spine.")
					if huy or huy2 then
						if ply.Organs["spine"] ~= 0 then
							ply.Organs["spine"] = math.Clamp(ply.Organs["spine"] - dmginfo:GetDamage(), 0, 1)
						end
					end
				end
				--spine
			end

			--print(dmginfo:GetDamage())
			--print(hitgroup)
			if IsValid(RagdollOwner(ent)) then
				RagdollOwner(ent).LastHit = bonename
			elseif ent:IsPlayer() then
				ent.LastHit = bonename
			end
		end

		if IsValid(RagdollOwner(ent)) then
			if dmginfo:GetDamageType() == 1 or dmginfo:IsDamageType(DMG_CRUSH + DMG_FALL) then
				local att = dmginfo:GetAttacker()
				local isVehicle = IsValid(att) and att:IsVehicle()
				if not isVehicle then
					local speed = ent:GetVelocity():Length()
					if speed < 520 then
						dmginfo:SetDamage(0)
						return true
					else
						local fallDmg = math.Clamp((speed - 480) * 0.12, 0, 40)
						dmginfo:SetDamage(fallDmg)
					end
				end
			end

			if dmginfo:GetDamage() > 0 then
				RagdollOwner(ent):TakeDamageInfo(dmginfo)
				if RagdollOwner(ent):Health() <= 0 and RagdollOwner(ent):Alive() then
					RagdollOwner(ent):Kill()
				end
			end
		end
	end
)

local function ToggleFake(ply)
	if not IsValid(ply) or not ply:Alive() or ply:Health() <= 0 then return end
	if timer.Exists("faketimer" .. ply:EntIndex()) then return end
	if (ply.NextFakeToggle or 0) > CurTime() then return end
	local rag = ply:GetNWEntity("DeathRagdoll")
	if not IsValid(rag) then rag = ply:GetNWEntity("FakeRagdoll") end
	if not IsValid(rag) then rag = ply:GetNWEntity("Ragdoll") end

	if IsValid(rag) and rag.isheld == true then return end
	if IsPlayerOtrub(ply) and (ply.fake or IsValid(rag)) then return end
	if IsValid(rag) and table.Count(constraint.FindConstraints(rag, "Rope")) > 0 then return end

	Faking(ply)
end

net.Receive("fake", function(len, ply)
	ToggleFake(ply)
end)

concommand.Add("fake", function(ply)
	ToggleFake(ply)
end)

--все игроки встают после очистки карты
hook.Add(
	"PreCleanupMap",
	"cleannoobs",
	function()
		for i, v in ipairs(player.GetAll()) do
			if v.fake then
				Faking(v)
			end
		end

		BleedingEntities = {}
	end
)

--изменение функции регдолла
function PlayerMeta:CreateRagdoll(attacker, dmginfo)
	local oldrag = self:GetNWEntity("DeathRagdoll")
	if not IsValid(oldrag) then oldrag = self:GetNWEntity("FakeRagdoll") end
	if not IsValid(oldrag) then oldrag = self:GetNWEntity("Ragdoll") end
	if not IsValid(oldrag) then oldrag = self.fakeragdoll end
	if not IsValid(oldrag) then oldrag = self.FakeRagdoll end

	-- Защита от создания второго регдолла при смерти
	if not self:Alive() and (self.fake or self.wasFakeOnDeath or IsValid(self.hgDeathRagdollCreated) or IsValid(oldrag)) then
		local existing = (IsValid(self.hgDeathRagdollCreated) and self.hgDeathRagdollCreated) or oldrag
		if IsValid(existing) then
			if IsValid(existing.ZacConsLH) then
				existing.ZacConsLH:Remove()
				existing.ZacConsLH = nil
			end
			if IsValid(existing.ZacConsRH) then
				existing.ZacConsRH:Remove()
				existing.ZacConsRH = nil
			end
			existing.deadbody = true
			existing.hgIsDeathCorpse = true
			existing:SetNWBool("hgDeathCorpse", true)
			existing:SetNWString("Nick", self:Nick())
			existing:SetNWString("PlayerName", self:Nick())
			if self.IsBleeding then
				existing.IsBleeding = true
			end
			existing:SetEyeTarget(vector_origin)
			self:Spectate(OBS_MODE_ROAMING)
			self:SetMoveType(MOVETYPE_OBSERVER)
			self.hgDeathRagdollCreated = existing
			return existing
		end
		return nil
	end

	if IsValid(oldrag) then
		if IsValid(oldrag.ZacConsLH) then
			oldrag.ZacConsLH:Remove()
			oldrag.ZacConsLH = nil
		end
		if IsValid(oldrag.ZacConsRH) then
			oldrag.ZacConsRH:Remove()
			oldrag.ZacConsRH = nil
		end
	end

	local Data = duplicator.CopyEntTable(self)
	local rag = ents.Create("prop_ragdoll")
	duplicator.DoGeneric(rag, Data)
	rag:SetModel(self:GetModel())
	rag:SetColor(self:GetColor())
	rag:SetSkin(self:GetSkin())
	rag:BetterSetPlayerColor(self:GetPlayerColor())
	rag:Spawn()
	rag:Activate()
	rag:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	rag:SetNWEntity("RagdollOwner", self)
	local vel = self:GetVelocity() / 1
	for i = 0, rag:GetPhysicsObjectCount() - 1 do
		local physobj = rag:GetPhysicsObjectNum(i)
		local ragbonename = rag:GetBoneName(rag:TranslatePhysBoneToBone(i))
		local bone = self:LookupBone(ragbonename)
		if bone then
			local bonemat = self:GetBoneMatrix(bone)
			if bonemat then
				local bonepos = bonemat:GetTranslation()
				local boneang = bonemat:GetAngles()
				physobj:SetPos(bonepos, true)
				physobj:SetAngles(boneang)
				--УБРАТЬ ГОВНЕЦО ПОТОМ
				if not self:Alive() then
					vel = vel / 2
				end

				physobj:AddVelocity(vel)
			end
		end
	end

	if self:Alive() then
		self:SetNWEntity("DeathRagdoll", rag)
		self:SetNWEntity("FakeRagdoll", rag)
		self:SetNWEntity("Ragdoll", rag)
		self.FakeRagdoll = rag
		self.fakeragdoll = rag
	else
		self:SetNWEntity("DeathRagdoll", rag)
		self:SetNWEntity("FakeRagdoll", rag)
		self:SetNWEntity("Ragdoll", rag)
		self.FakeRagdoll = rag
		self.fakeragdoll = rag
		self.hgDeathRagdollCreated = rag
		self.curweapon = IsValid(self:GetActiveWeapon()) and self:GetActiveWeapon():GetClass() or nil
		local guninfo = self.curweapon and weapons.Get(self.curweapon)
		if guninfo and guninfo.Base == "salat_base" and SpawnWeapon then
			SpawnWeapon(self)
		end

		self:Spectate(OBS_MODE_ROAMING)
		self:SetMoveType(MOVETYPE_OBSERVER)
		rag:SetEyeTarget(vector_origin)
		if self.IsBleeding then
			rag.IsBleeding = true
		end

		rag.deadbody = true
		rag.hgIsDeathCorpse = true
		rag:SetNWBool("hgDeathCorpse", true)
		rag:SetNWString("Nick", self:Nick())
		rag:SetNWString("PlayerName", self:Nick())
	end

	rag:AddCallback("PhysicsCollide", function(ent, data)
		hook.Run("Homigrad_RagdollCollide", ent, data)
	end)

	return rag
end

hook.Add("Homigrad_RagdollCollide", "Homigrad_NeckBreak", function(rag, data)
	if not IsValid(rag) then return end
	local ply = RagdollOwner(rag)
	if not IsValid(ply) or not ply:Alive() or ply.NeckBroken then return end
	if (ply.LastNeckCheck or 0) > CurTime() then return end

	if not IsHeadPhysBone(rag, data.PhysObj) then return end

	local hitEnt = data.HitEntity
	local speed = data.Speed or 0
	local isWorld = not IsValid(hitEnt) or hitEnt:IsWorld()
	local isProp = IsValid(hitEnt) and not hitEnt:IsPlayer() and not hitEnt:IsRagdoll() and not isWorld

	local shouldBreak = false
	local fatal = false

	if isWorld then
		-- Удар головой об стенку, пол или потолок
		if speed >= 430 then
			shouldBreak = true
			fatal = true
		elseif speed >= 320 then
			shouldBreak = true
			fatal = false
		end
	elseif isProp then
		-- Проп влетел в голову
		local propPhys = data.HitObject or hitEnt:GetPhysicsObject()
		local propMass = IsValid(propPhys) and propPhys:GetMass() or 10
		local propVel = (data.TheirOldVelocity and data.TheirOldVelocity:Length()) or hitEnt:GetVelocity():Length()

		if (propVel >= 180 and propMass >= 5) or speed >= 300 then
			shouldBreak = true
			if (propVel >= 340 and propMass >= 10) or speed >= 430 or (propMass >= 35 and propVel >= 160) then
				fatal = true
			end
		end
	end

	if shouldBreak then
		ply.LastNeckCheck = CurTime() + 1
		HG_BreakNeck(ply, rag, data.HitPos, data.HitNormal, hitEnt, hitEnt, fatal)
	end
end)

--проверка на скорость в фейке (для сбивания с ног других игроков)
hook.Add(
	"Think",
	"VelocityFakeHitPlyCheck",
	function()
		for i, rag in pairs(ents.FindByClass("prop_ragdoll")) do
			local ply = RagdollOwner(rag)
			if IsValid(ply) or rag.deadbody then
				if rag:GetVelocity():Length() > 250 then
					rag:SetCollisionGroup(COLLISION_GROUP_NONE)
					local trace = {
						start = rag:GetPos(),
						endpos = rag:GetPos() + rag:GetVelocity() / 4,
						filter = rag
					}

					local tr = util.TraceLine(trace)
					if tr.Entity == NULL or tr.Entity == rag or tr.Entity == Entity(0) then return nil end
					if tr.Entity:IsPlayer() and tr.Entity ~= RagdollOwner(rag) and tr.Entity.fake == false then
						Faking(tr.Entity)
					end
				else
					rag:SetCollisionGroup(COLLISION_GROUP_WEAPON)
				end
			end
		end
	end
)

--проверка на скорость в фейке (для сбивания с ног других игроков)
hook.Add(
	"Think",
	"VelocityFakeHitPlyCheck",
	function()
		for i, rag in pairs(ents.FindByClass("prop_ragdoll")) do
			if IsValid(rag) then
				if rag:GetVelocity():Length() > 200 then
					rag:SetCollisionGroup(COLLISION_GROUP_NONE)
				else
					rag:SetCollisionGroup(COLLISION_GROUP_WEAPON)
				end
			end
		end
	end
)

hook.Add(
	"PlayerInitialSpawn",
	"homigrad-addcallback",
	function(ply)
		ply:AddCallback(
			"PhysicsCollide",
			function(phys, data)
				hook.Run("Player Collide", ply, data.HitEntity, data)
			end
		)
	end
)

local gg = CreateConVar("hg_oldcollidefake", "0")
hook.Add(
	"Player Collide",
	"homigrad-fake",
	function(ply, hitEnt, data)
		if not IsValid(ply) or ply.fake or ply:HasGodMode() then return end

		-- Приземление на пол/землю после обычного прыжка никогда не сбивает в фейк
		local isFloor = data.HitNormal and data.HitNormal.z > 0.65
		if isFloor and (not data.OurOldVelocity or data.OurOldVelocity.z > -450) then
			return
		end

		local entVel = IsValid(hitEnt) and hitEnt:GetVelocity():Length() or 0
		local isMovingProp = IsValid(hitEnt) and not hitEnt:IsWorld() and not hitEnt:IsPlayerHolding() and entVel > 150
		local isExtremeSlam = data.Speed > 450 and not isFloor
		local isHardFall = data.Speed > 480 and (data.OurOldVelocity and data.OurOldVelocity.z < -450)

		local hitPos = data.HitPos
		local headPos = ply:EyePos()
		local isNearHead = (hitPos and hitPos:Distance(headPos) < 28) or (hitPos and hitPos.z > ply:GetPos().z + 46)

		if isNearHead and not ply.NeckBroken then
			if isMovingProp and entVel > 180 then
				HG_BreakNeck(ply, nil, hitPos, data.HitNormal, hitEnt, hitEnt, entVel > 320 or data.Speed > 400)
				return
			elseif isExtremeSlam and data.Speed > 440 then
				HG_BreakNeck(ply, nil, hitPos, data.HitNormal, hitEnt, hitEnt, true)
				return
			elseif isHardFall and data.Speed > 480 and data.HitNormal and data.HitNormal.z < -0.3 then
				HG_BreakNeck(ply, nil, hitPos, data.HitNormal, hitEnt, hitEnt, true)
				return
			end
		end

		if isMovingProp or isExtremeSlam or isHardFall then
			timer.Simple(
				0,
				function()
					if not IsValid(ply) or ply.fake then return end
					if hook.Run("Should Fake Collide", ply, hitEnt, data) == false then return end
					Faking(ply)
				end
			)
		end
	end
)


local function tryGrab(rag, ply, phys, physBone)
	if not IsValid(phys) or physBone == nil or physBone < 0 then return nil end

	local origin = phys:GetPos()
	local eye = ply:EyeAngles()
	local fwd = eye:Forward()
	local up = eye:Up()
	local right = eye:Right()
	local physAng = phys:GetAngles()

	local dirs = {
		fwd * 30,
		fwd * 25 + up * 15,
		fwd * 25 - up * 15,
		fwd * 25 + right * 15,
		fwd * 25 - right * 15,
		physAng:Forward() * 25,
		physAng:Up() * 20,
		physAng:Up() * -20,
		physAng:Right() * 20,
		physAng:Right() * -20,
	}

	local filterList = {rag, ply}
	if IsValid(ply.wep) then table.insert(filterList, ply.wep) end

	for i = 1, #dirs do
		local dir = dirs[i]
		local dirNorm = dir:GetNormalized()
		local startPos = origin + dirNorm * 5
		local endPos = origin + dir

		local tr = util.TraceLine({
			start = startPos,
			endpos = endPos,
			filter = filterList,
			mask = MASK_SOLID,
		})

		if tr.Hit and not tr.HitSky and not tr.StartSolid and not tr.AllSolid and (tr.Fraction or 0) > 0 then
			local hitEnt = tr.Entity
			if hitEnt == rag or hitEnt == ply then continue end
			if IsValid(hitEnt) then
				if hitEnt:GetParent() == rag or hitEnt:GetParent() == ply then continue end
				if hitEnt:IsPlayer() or hitEnt:IsWeapon() then continue end
			end

			local cons
			if tr.HitWorld then
				cons = constraint.Weld(rag, game.GetWorld(), physBone, 0, 3500, false, false)
			elseif IsValid(hitEnt) and not hitEnt:IsWorld() then
				if hitEnt:GetSolid() ~= SOLID_NONE then
					cons = constraint.Weld(rag, hitEnt, physBone, tr.PhysicsBone or 0, 3500, false, false)
				end
			end

			if IsValid(cons) then
				return cons
			end
		end
	end
	return nil
end

--управление в фейке
local dvec = Vector(0, 0, -64)
hook.Add(
	"Think",
	"FakeControl",
	function()
		for i, ply in ipairs(player.GetAll()) do
			ply.holdingartery = false
			if not ply:Alive() or not ply.fake then continue end
			local rag = ply:GetNWEntity("DeathRagdoll")
			if not IsValid(rag) then rag = ply:GetNWEntity("FakeRagdoll") end
			if not IsValid(rag) then rag = ply.fakeragdoll end
			if IsValid(rag) then
				ply:SetNWBool("fake", ply.fake)
				local deltatime = CurTime() - (rag.ZacLastCallTime or CurTime())
				rag.ZacLastCallTime = CurTime()
				local eyeangs = ply:EyeAngles()
				local head = resolveHeadPhys(rag)
				local torsoPhys = resolveTorsoPhys(rag)
				local physL, boneL = resolveHandPhys(rag, false)
				local physR, boneR = resolveHandPhys(rag, true)
				rag:SetFlexWeight(9, 0)
				local eyeAttachId = rag:LookupAttachment("eyes")
				local attachment = (eyeAttachId and eyeAttachId > 0) and rag:GetAttachment(eyeAttachId)
				if not attachment then
					local headBone = rag:LookupBone("ValveBiped.Bip01_Head1")
					local headPos, headAng
					if headBone then
						headPos, headAng = rag:GetBonePosition(headBone)
					else
						headPos, headAng = rag:GetPos() + Vector(0,0,50), rag:GetAngles()
					end
					attachment = { Pos = headPos, Ang = headAng or angle_zero }
				end
				local eyeForward = (attachment and attachment.Ang) and attachment.Ang:Forward() or ply:GetAimVector()
				local dist = (eyeForward * 10000):Distance(ply:GetAimVector() * 10000)
				local distmod = math.Clamp(1 - (dist / 20000), 0.1, 1)
				local lookat = LerpVector(distmod, eyeForward * 100000, ply:GetAimVector() * 100000)
				local LocalPos, LocalAng = WorldToLocal(lookat, angle_zero, attachment.Pos, attachment.Ang)
				local bone = rag:LookupBone("ValveBiped.Bip01_Head1")
				local headPos = (bone and rag:GetBonePosition(bone)) or rag:GetPos()
				local head1 = headPos + dvec
				ply:SetPos(head1)
				if not IsPlayerOtrub(RagdollOwner(rag)) then
					rag:SetEyeTarget(LocalPos)
				else
					rag:SetEyeTarget(vector_origin)
				end

				if RagdollOwner(rag):Alive() then
					if not IsPlayerOtrub(RagdollOwner(rag)) then
						if ply:KeyPressed(IN_JUMP) and table.Count(constraint.FindConstraints(ply:GetNWEntity("DeathRagdoll"), "Rope")) > 0 and ply.stamina > 45 then
							local RopeCount = table.Count(constraint.FindConstraints(ply:GetNWEntity("DeathRagdoll"), "Rope"))
							Ropes = constraint.FindConstraints(ply:GetNWEntity("DeathRagdoll"), "Rope")
							Try = math.random(1, 10 * RopeCount)
							ply.stamina = ply.stamina - 4 * (RopeCount / 6)
							local phys = rag:GetPhysicsObjectNum(1)
							local speed = 200
							local shadowparams = {
								secondstoarrive = 0.05,
								pos = phys:GetPos() + phys:GetAngles():Forward() * 20,
								angle = phys:GetAngles(),
								maxangulardamp = 30,
								maxspeeddamp = 30,
								maxangular = 90,
								maxspeed = speed,
								teleportdistance = 0,
								deltatime = 0.01,
							}

							phys:Wake()
							phys:ComputeShadowControl(shadowparams)
							if Try > (7 * RopeCount) then
								Ropes[1].Constraint:Remove()
								rag:EmitSound("snd_jack_hmcd_ducttape.wav", 90, 50, 0.5, CHAN_AUTO)
							end
						end

						if ply:KeyPressed(IN_RELOAD) then
							Reload(ply.wep)
						end

						if ply:KeyDown(IN_ATTACK) then
							if not ply.FakeShooting and not ply.arterybleeding then
								if IsValid(physL) then
									local targetPos = clampReachPos(head:GetPos(), torsoPhys and torsoPhys:GetPos(), eyeangs:Forward(), eyeangs:Right() * -10 + eyeangs:Up() * 4)
									physL:Wake()
									physL:ComputeShadowControl({
										secondstoarrive = 0.2,
										pos = targetPos,
										angle = eyeangs,
										maxangulardamp = 20,
										maxspeeddamp = 20,
										maxangular = 160,
										maxspeed = 85,
										teleportdistance = 0,
										deltatime = deltatime,
									})
								end
							end
						end

						local guninfo = weapons.Get(ply.curweapon)
						if guninfo and guninfo.Primary.Automatic then
							--KeyDown if an automatic gun
							if ply:KeyDown(IN_ATTACK) then
								if ply.FakeShooting then
									FireShot(ply.wep)
								end
							end
						else
							if ply:KeyPressed(IN_ATTACK) then
								if ply.FakeShooting then
									FireShot(ply.wep)
								end
							end
						end

						if ply:KeyDown(IN_ATTACK2) then
							local ang = ply:EyeAngles()
							if ply.FakeShooting then
								ang:RotateAroundAxis(eyeangs:Forward(), 180)
							end

							if not ply.suiciding or (guninfo and guninfo.TwoHands) then
								if guninfo and guninfo.TwoHands and IsValid(ply.wep) then
									local targetPos = clampReachPos(head:GetPos(), torsoPhys and torsoPhys:GetPos(), eyeangs:Forward(), eyeangs:Right() * 8 + eyeangs:Up() * 4)
									local shadowparams = {
										secondstoarrive = 0.2,
										pos = targetPos,
										angle = ang,
										maxangular = 200,
										maxangulardamp = 20,
										maxspeeddamp = 20,
										maxspeed = 90,
										teleportdistance = 0,
										deltatime = deltatime,
									}
									if IsValid(physR) then
										physR:Wake()
										physR:ComputeShadowControl(shadowparams)
									end
									if IsValid(physL) then
										physL:Wake()
										physL:ComputeShadowControl(shadowparams)
									end
									local wepPhys = ply.wep:GetPhysicsObject()
									if IsValid(wepPhys) then
										wepPhys:Wake()
										wepPhys:ComputeShadowControl(shadowparams)
									end
								else
									if IsValid(physR) then
										local targetPos = clampReachPos(head:GetPos(), torsoPhys and torsoPhys:GetPos(), eyeangs:Forward(), eyeangs:Right() * 10 + eyeangs:Up() * 4)
										physR:Wake()
										physR:ComputeShadowControl({
											secondstoarrive = 0.2,
											pos = targetPos,
											angle = ang,
											maxangular = 160,
											maxangulardamp = 20,
											maxspeeddamp = 20,
											maxspeed = 85,
											teleportdistance = 0,
											deltatime = deltatime,
										})
									end
								end
							else
								if ply.FakeShooting and IsValid(ply.wep) then
									local shadowparams = {
										secondstoarrive = 0.2,
										pos = head:GetPos() - ply.wep:GetAngles():Forward() * 12,
										angle = ang,
										maxspeed = 250,
										maxangular = 250,
										maxangulardamp = 20,
										maxspeeddamp = 20,
										teleportdistance = 0,
										deltatime = deltatime,
									}
									local wepPhys = ply.wep:GetPhysicsObject()
									if IsValid(wepPhys) then
										wepPhys:Wake()
										wepPhys:ComputeShadowControl(shadowparams)
									end
								elseif IsValid(physR) and IsValid(ply.wep) and IsValid(ply.wep:GetPhysicsObject()) then
									local shadowparams = {
										secondstoarrive = 0.2,
										pos = head:GetPos(),
										angle = ply.wep:GetPhysicsObject():GetAngles(),
										maxspeed = 100,
										maxangular = 160,
										maxangulardamp = 20,
										maxspeeddamp = 20,
										teleportdistance = 0,
										deltatime = deltatime,
									}
									ply.wep:GetPhysicsObject():ComputeShadowControl(shadowparams)
									physR:ComputeShadowControl(shadowparams)
								end
							end
						end

						if ply:KeyDown(IN_USE) then
							local angs = ply:EyeAngles()
							angs:RotateAroundAxis(angs:Forward(), 90)
							angs:RotateAroundAxis(angs:Up(), 90)
							local shadowparams = {
								secondstoarrive = 0.5,
								pos = head:GetPos() + vector_up * 20,
								angle = angs,
								maxangulardamp = 10,
								maxspeeddamp = 10,
								maxangular = 370,
								maxspeed = 40,
								teleportdistance = 0,
								deltatime = deltatime,
							}

							head:Wake()
							head:ComputeShadowControl(shadowparams)
						end
					end

					-- Зацепы руками на Shift (левая) и Alt (правая)
					if ply:KeyDown(IN_SPEED) and not IsPlayerOtrub(RagdollOwner(rag)) then
						if IsValid(physL) then
							local targetPos = clampReachPos(head:GetPos(), torsoPhys and torsoPhys:GetPos(), eyeangs:Forward(), eyeangs:Right() * -10 + eyeangs:Up() * 4)
							physL:Wake()
							physL:ComputeShadowControl({
								secondstoarrive = 0.2,
								pos = targetPos,
								angle = eyeangs,
								maxangular = 155,
								maxangulardamp = 15,
								maxspeeddamp = 15,
								maxspeed = 85,
								teleportdistance = 0,
								deltatime = deltatime,
							})

							if not rag.ZacConsLH and (not rag.ZacNextGrLH or rag.ZacNextGrLH <= CurTime()) then
								rag.ZacNextGrLH = CurTime() + 0.1
								local cons = tryGrab(rag, ply, physL, boneL)
								if cons then
									rag.ZacConsLH = cons
									rag:EmitSound("physics/flesh/flesh_impact_hard" .. math.random(1,4) .. ".wav", 65, 100, 0.4)
								end
							end
						end
					else
						if rag.ZacConsLH then
							clearGrab(rag.ZacConsLH)
							rag.ZacConsLH = nil
						end
					end

					if ply:KeyDown(IN_WALK) and not IsPlayerOtrub(RagdollOwner(rag)) then
						if IsValid(physR) then
							local targetPos = clampReachPos(head:GetPos(), torsoPhys and torsoPhys:GetPos(), eyeangs:Forward(), eyeangs:Right() * 10 + eyeangs:Up() * 4)
							physR:Wake()
							physR:ComputeShadowControl({
								secondstoarrive = 0.2,
								pos = targetPos,
								angle = eyeangs,
								maxangular = 155,
								maxangulardamp = 15,
								maxspeeddamp = 15,
								maxspeed = 85,
								teleportdistance = 0,
								deltatime = deltatime,
							})

							if not rag.ZacConsRH and (not rag.ZacNextGrRH or rag.ZacNextGrRH <= CurTime()) then
								rag.ZacNextGrRH = CurTime() + 0.1
								local cons = tryGrab(rag, ply, physR, boneR)
								if cons then
									rag.ZacConsRH = cons
									rag:EmitSound("physics/flesh/flesh_impact_hard" .. math.random(1,4) .. ".wav", 65, 100, 0.4)
								end
							end
						end
					else
						if rag.ZacConsRH then
							clearGrab(rag.ZacConsRH)
							rag.ZacConsRH = nil
						end
					end

					-- Автоматический разрыв хвата при чрезмерном растяжении руки (защита от вытягивания)
					local torsoPos = (IsValid(torsoPhys) and torsoPhys:GetPos()) or head:GetPos()
					if rag.ZacConsLH then
						local handPos = IsValid(physL) and physL:GetPos()
						if not handPos or handPos:Distance(torsoPos) > 42 then
							clearGrab(rag.ZacConsLH)
							rag.ZacConsLH = nil
						end
					end
					if rag.ZacConsRH then
						local handPos = IsValid(physR) and physR:GetPos()
						if not handPos or handPos:Distance(torsoPos) > 42 then
							clearGrab(rag.ZacConsRH)
							rag.ZacConsRH = nil
						end
					end

					ply:SetNWBool("LeftArm", rag.ZacConsLH ~= nil)
					ply:SetNWBool("RightArm", rag.ZacConsRH ~= nil)

					-- Оригинальное плавное подтягивание через ComputeShadowControl (без диких сил)
					local spinePhys = torsoPhys or rag:GetPhysicsObjectNum(1)
					if IsValid(spinePhys) and not IsPlayerOtrub(RagdollOwner(rag)) then
						if ply:KeyDown(IN_FORWARD) and (rag.ZacConsLH or rag.ZacConsRH) then
							local targetHandPos = (rag.ZacConsLH and IsValid(physL) and physL:GetPos()) or (rag.ZacConsRH and IsValid(physR) and physR:GetPos()) or spinePhys:GetPos()
							spinePhys:Wake()
							spinePhys:ComputeShadowControl({
								secondstoarrive = 0.5,
								pos = targetHandPos,
								angle = spinePhys:GetAngles(),
								maxangulardamp = 10,
								maxspeeddamp = 10,
								maxangular = 50,
								maxspeed = 45,
								teleportdistance = 0,
								deltatime = deltatime,
							})
						elseif ply:KeyDown(IN_BACK) and (rag.ZacConsLH or rag.ZacConsRH) then
							local chst = rag:GetPhysicsObjectNum(0)
							local targetPos = IsValid(chst) and chst:GetPos() or spinePhys:GetPos()
							spinePhys:Wake()
							spinePhys:ComputeShadowControl({
								secondstoarrive = 0.5,
								pos = targetPos,
								angle = spinePhys:GetAngles(),
								maxangulardamp = 10,
								maxspeeddamp = 10,
								maxangular = 50,
								maxspeed = 45,
								teleportdistance = 0,
								deltatime = deltatime,
							})
						end
					end
				end
			end
		end
end)

hook.Add(
	"Think",
	"VelocityPlayerFallOnPlayerCheck",
	function()
		for _, ply in ipairs(player.GetAll()) do
			if ply:GetVelocity():Length() > 600 and ply:Alive() and not ply.fake and not ply:HasGodMode() and ply:GetMoveType() ~= MOVETYPE_NOCLIP then
				Faking(ply)
			end
		end
	end
)

physenv.SetPerformanceSettings(
	{
		MaxVelocity = 99999
	}
)

physenv.SetAirDensity(2)
hook.Add(
	"EntityTakeDamage",
	"LastAttacker",
	function(ent, dmginfo)
		local attacker = dmginfo:GetAttacker()
		local ply = RagdollOwner(ent)
		if ent:IsPlayer() and attacker:IsPlayer() then
			ent.Attacker = attacker:Nick()
			ent.AttackerEnt = attacker
		elseif IsValid(ply) and attacker:IsPlayer() then
			ply.Attacker = attacker:Nick()
			ply.AttackerEnt = attacker
		elseif IsValid(ply) and attacker == ply.wep then
			-- сделать по-другому (тут только если ты себя убиваешь)
			ply.Attacker = ply:Nick()
			ply.AttackerEnt = attacker
		end
	end
)

concommand.Add(
	"suicide",
	function(ply)
		if not ply:Alive() then return nil end
		ply.suiciding = not ply.suiciding
	end
)

hook.Add(
	"PlayerSwitchWeapon",
	"fakewep",
	function(ply, oldwep, newwep)
		if IsPlayerOtrub(ply) then return true end
		if ply.fake then
			if IsValid(ply.Info.ActiveWeapon2) and IsValid(ply.wep) then
				ply.Info.ActiveWeapon2:SetClip1(ply.wep.Clip)
				ply:SetAmmo(ply.wep.Amt, ply.wep.AmmoType)
			end

			local guninfo = IsValid(newwep) and weapons.Get(newwep:GetClass())
			if guninfo.Base == "salat_base" then
				if IsValid(ply.wep) then
					DespawnWeapon(ply)
				end

				ply:SetActiveWeapon(newwep)
				ply.Info.ActiveWeapon = newwep
				ply.curweapon = newwep
				SavePlyInfo(ply)
				ply:SetActiveWeapon(nil)
				SpawnWeapon(ply)
				ply.FakeShooting = true
			else
				if IsValid(ply.wep) then
					DespawnWeapon(ply)
				end

				ply:SetActiveWeapon(nil)
				ply.curweapon = newwep
				ply.FakeShooting = false
			end

			return true
		end
	end
)

function PlayerMeta:HuySpectate()
	local ply = self
	ply:SetNoDraw(true)
	ply:SetNotSolid(true)
	ply:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	ply:SetMoveType(MOVETYPE_NONE)
end

OrgansNextThink = 0
InternalBleeding = 10
hook.Add(
	"Think",
	"InternalBleeding",
	function()
		for i, ply in ipairs(player.GetAll()) do
			ply.OrgansNextThink = ply.OrgansNextThink or OrgansNextThink
			if not (ply.OrgansNextThink > CurTime()) then
				ply.OrgansNextThink = CurTime() + 0.2
				--print(ply) PrintTable(ply.Organs)
				if ply.Organs and ply:Alive() then
					if ply.Organs["brain"] == 0 then
						ply:Kill()
					end

					if ply.Organs["liver"] == 0 then
						ply.InternalBleeding = ply.InternalBleeding or InternalBleeding
						ply.InternalBleeding = math.Clamp(ply.InternalBleeding - 0.1, 0, 10)
						--print(ply.InternalBleeding, ply.Blood)
						ply.Blood = ply.Blood - ply.InternalBleeding
					end

					if ply.Organs["stomach"] == 0 then
						ply.InternalBleeding2 = ply.InternalBleeding2 or InternalBleeding
						ply.InternalBleeding2 = math.Clamp(ply.InternalBleeding2 - 0.1, 0, 10)
						--print(ply.InternalBleeding, ply.Blood)
						ply.Blood = ply.Blood - ply.InternalBleeding2
					end

					if ply.Organs["intestines"] == 0 then
						ply.InternalBleeding3 = ply.InternalBleeding3 or InternalBleeding
						ply.InternalBleeding3 = math.Clamp(ply.InternalBleeding3 - 0.1, 0, 10)
						--print(ply.InternalBleeding, ply.Blood)
						ply.Blood = ply.Blood - ply.InternalBleeding3
					end

					if ply.Organs["heart"] == 0 then
						ply.InternalBleeding4 = ply.InternalBleeding4 or InternalBleeding
						--print(ply.InternalBleeding4)
						ply.InternalBleeding4 = math.Clamp(ply.InternalBleeding4 * 10 - 0.1, 0, 10)
						--print(ply.InternalBleeding, ply.Blood)
						ply.Blood = ply.Blood - ply.InternalBleeding4 * 3
					end

					if ply.Organs["lungs"] == 0 then
						ply.InternalBleeding5 = ply.InternalBleeding5 or InternalBleeding
						ply.InternalBleeding5 = math.Clamp(ply.InternalBleeding5 - 0.1, 0, 10)
						--print(ply.InternalBleeding, ply.Blood)
						ply.Blood = ply.Blood - ply.InternalBleeding5
					end


					if ply.Organs["artery"] == 0 then
						ply.arterybleeding = true
					else
						ply.arterybleeding = false
					end

					--print(ply.Blood)
					if ply.Blood and ply.Blood <= 2000 and ply:Alive() or ply.pain and ply.pain > 950 and ply:Alive() then
						ply:ExitVehicle()
						ply:Kill()
						ply.Bloodlosing = 0
						ply:SetNWInt("BloodLosing", 0)
					end
				end
			end
		end
	end
)

hook.Add(
	"PlayerUse",
	"nouseinfake",
	function(ply)
		if ply.fake then return false end
	end
)

hook.Add(
	"PlayerSay",
	"dropweaponhuy",
	function(ply, text)
		if string.lower(text) == "*drop" then
			if not ply.fake then
				ply:DropWeapon()

				return ""
			else
				if IsValid(ply.wep) then
					if IsValid(ply.WepCons) then
						ply.WepCons:Remove()
						ply.WepCons = nil
					end

					if IsValid(ply.WepCons2) then
						ply.WepCons2:Remove()
						ply.WepCons2 = nil
					end

					ply.wep.canpickup = true
					ply.wep:SetOwner()
					ply.wep.curweapon = ply.curweapon
					ply.Info.Weapons[ply.Info.ActiveWeapon].Clip1 = ply.wep.Clip
					ply:StripWeapon(ply.Info.ActiveWeapon)
					ply.Info.Weapons[ply.Info.ActiveWeapon] = nil
					ply.wep = nil
					ply.Info.ActiveWeapon = nil
					ply.Info.ActiveWeapon2 = nil
					ply:SetActiveWeapon(nil)
					ply.FakeShooting = false
				else
					ply:PickupEnt()
				end

				return ""
			end
		end
	end
)

-- Реалистичный расчет урона от падения и защита от случайного подскальзывания / падения с малой высоты
hook.Add("GetFallDamage", "Homigrad_RealisticFallDamage", function(ply, speed)
	if speed < 520 then
		return 0
	end
	return math.Clamp((speed - 480) * 0.15, 0, 85)
end)

hook.Add("EntityTakeDamage", "Homigrad_PlayerSlipProtection", function(ent, dmginfo)
	if not IsValid(ent) or not ent:IsPlayer() then return end

	local isCrush = dmginfo:IsDamageType(DMG_FALL) or dmginfo:IsDamageType(DMG_CRUSH) or dmginfo:GetDamageType() == 1
	if isCrush then
		local att = dmginfo:GetAttacker()
		local inf = dmginfo:GetInflictor()
		local isVehicle = IsValid(att) and att:IsVehicle()
		local isProp = (IsValid(att) and not att:IsWorld() and not att:IsPlayer() and not att:IsRagdoll())
			or (IsValid(inf) and not inf:IsWorld() and not inf:IsPlayer() and not inf:IsRagdoll())
		local propVel = (IsValid(att) and att:GetVelocity():Length()) or (IsValid(inf) and inf:GetVelocity():Length()) or 0

		if isProp and propVel > 160 then
			local hitPos = dmginfo:GetDamagePosition()
			local headPos = ent:EyePos()
			if (hitPos and hitPos:Distance(headPos) < 28) or (hitPos and hitPos.z > ent:GetPos().z + 46) then
				HG_BreakNeck(ent, nil, hitPos, dmginfo:GetDamageForce():GetNormalized(), att, inf, propVel > 320 or dmginfo:GetDamage() > 25)
				return
			end
			return
		end

		if not isVehicle then
			local spd = ent:GetVelocity():Length()
			if spd < 520 then
				dmginfo:SetDamage(0)
				return true
			else
				local scaled = math.Clamp((spd - 480) * 0.12, 0, 40)
				dmginfo:SetDamage(scaled)
			end
		end
	end
end)