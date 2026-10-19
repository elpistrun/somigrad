--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/weapon_hands/tier_0_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad\\lua\\hinit\\weapon_hands\\tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Reg("weapon_hands","base_weapon",true)
if not SWEP then return INCLUDE_BREAK end

if not CreateDamageTab then
	local DamageTabMeta = {}
	DamageTabMeta.__index = DamageTabMeta
	function DamageTabMeta:AddKill(reason) self.kills = self.kills or {} table.insert(self.kills, reason) end
	function DamageTabMeta:GetKills() return self.kills or {} end
	function DamageTabMeta:SetDamage(val) self.damage = tonumber(val) or 0 end
	function DamageTabMeta:GetDamage() return self.damage or 0 end
	function DamageTabMeta:SetDamageType(val) self.damageType = val or DMG_GENERIC self.dmgType = val or DMG_GENERIC end
	function DamageTabMeta:GetDamageType() return self.damageType or self.dmgType or DMG_GENERIC end
	function DamageTabMeta:SetAttacker(att) self.attacker = att end
	function DamageTabMeta:GetAttacker() return self.attacker end
	function DamageTabMeta:SetInflictor(inf) self.inflictor = inf end
	function DamageTabMeta:GetInflictor() return self.inflictor end
	function DamageTabMeta:SetDamagePosition(pos) self.pos = pos end
	function DamageTabMeta:GetDamagePosition() return self.pos end
	function DamageTabMeta:SetDamageForce(force) self.force = force end
	function DamageTabMeta:GetDamageForce() return self.force end

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
end

local ENTITY_MT = FindMetaTable("Entity")
local PLAYER_MT = FindMetaTable("Player")
if not ENTITY_MT.TakeDamageTab then
	local function ApplyDamageTab(ent, dmgTab, reasons)
		if not IsValid(ent) or not istable(dmgTab) then return end
		local damage = dmgTab.damage or (dmgTab.GetDamage and dmgTab:GetDamage()) or 0
		local dmgType = dmgTab.damageType or (dmgTab.GetDamageType and dmgTab:GetDamageType()) or DMG_GENERIC
		local attacker = dmgTab.attacker or (dmgTab.GetAttacker and dmgTab:GetAttacker()) or ent
		local inflictor = dmgTab.inflictor or (dmgTab.GetInflictor and dmgTab:GetInflictor()) or attacker
		local pos = dmgTab.pos or (dmgTab.GetDamagePosition and dmgTab:GetDamagePosition()) or ent:GetPos()
		local force = dmgTab.force or (dmgTab.GetDamageForce and dmgTab:GetDamageForce()) or vector_origin

		if ent:GetClass() == "prop_ragdoll" then
			local ply = (hg and hg.RagdollOwner and hg.RagdollOwner(ent)) or (RagdollOwner and RagdollOwner(ent))
			if IsValid(ply) and ply ~= ent and ply:Alive() then
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
					ent:SetNWFloat("bleed", ent:GetNWFloat("bleed", 0) + bleed)
				end
				local newHp = math.max(0, ent:Health() - damage)
				ent:SetHealth(newHp)

				local dinfo = DamageInfo()
				dinfo:SetDamage(damage)
				dinfo:SetDamageType(dmgType)
				dinfo:SetAttacker(IsValid(attacker) and attacker or ent)
				dinfo:SetInflictor(IsValid(inflictor) and inflictor or ent)
				dinfo:SetDamagePosition(pos)
				dinfo:SetDamageForce(force)
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
	ENTITY_MT.TakeDamageTab = ApplyDamageTab
	PLAYER_MT.TakeDamageTab = ApplyDamageTab
end

-- While the fake/ragdoll system owns the body the hands must do nothing at all: the
-- grab keys belong to the fake control (main_sv's Think + sv_glide_fake), and anything
-- left carried from before the possession would keep being pulled by ApplyForce from a
-- player that is no longer standing anywhere near it. Declared up here because
-- SecondaryAttack is one of the first methods in the file to use it.
local function InFakeNoHands(self)
	local owner = self:GetOwner()

	if not IsValid(owner) or not owner.InFake or not owner:InFake() then return false end

	-- Never keep a carry the player cannot control -- drop it on the way in.
	if self.CarryEnt then self:SetCarrying() end

	return true
end

if SERVER then
	SWEP.Weight = 5
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false
else
	SWEP.PrintName = L("weapon_hands")
	SWEP.Slot = 0
	SWEP.SlotPos = -100
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.BounceWeaponIcon = false
	SWEP.WepSelectIcon = surface.GetTextureID( "vgui/wep_jack_hmcd_hands" )
	SWEP.IconWeaponSelection = Material("homigrad/weapon_icon/hand.png")

	local HandTex, ClosedTex = surface.GetTextureID("vgui/hud/gmod_hand"), surface.GetTextureID("vgui/hud/gmod_closedhand")

	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		surface.SetDrawColor( 255, 255, 255, alpha )
		surface.SetMaterial(Material("homigrad/weapon_icon/hand.png") )

		local size = math.min(wide,tall)
		size = size - tall * 0.05
		
		surface.DrawTexturedRect(x + wide/2-size/2,y,size,size)
	end

	local white = Color(255,255,255)

	function SWEP:DrawHUD()
		if not (GetViewEntity() == LocalPlayer()) then return end
		if LocalPlayer():InVehicle() then return end

		local ply = self.Owner

		local Tr = ply:EyeTraceShoot(PlayerDisUse)
		if not Tr then return end

		local fraction = Tr.Fraction * 80000

		local pos = Tr.HitPos:ToScreen()
		local ent = Tr.Entity

		local Size = math.max(1 - fraction,0.25)

		if Tr.Hit then
			if not self.Owner:KeyDown(IN_ATTACK2) and IsValid(ent) and ent.HUDTarget then return end

			surface.SetDrawColor(255,255,255,255 * Size)
			
			local s = 64 * Size

			if self:CanPickup(ent) then
				s = 128 * Size
				
				if self.Owner:KeyDown(IN_ATTACK2) then
					surface.SetTexture(ClosedTex)
				else
					surface.SetTexture(HandTex)
				end

				surface.DrawTexturedRect(pos.x - s / 2,pos.y - s / 2,s,s)
			else
				draw.RoundedBox(s,pos.x - s / 2,pos.y - s / 2,s,s,white)
			end
			
			if IsValid(ent) then
				if ent:GetNoDraw() then return end

				local col

				if ent.GetPlayerColor then
					col = ent:GetPlayerColor():ToColor()
				else
					col = ent:GetColor()
				end

				col.a = 255 * Size * 2 * (1 - InvOpenK)

				draw.DrawText(ent:IsPlayer() and ent:Name() or ent:GetNWString("Nickname") or "","H.45",pos.x,pos.y - 30,col,TEXT_ALIGN_CENTER)
			end
		end
	end
end

SWEP.SwayScale = 3
SWEP.BobScale = 3
SWEP.InstantPickup = true -- FF compat
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = L("weapon_hands_desc")

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.HoldType = "normal"

SWEP.ViewModel = ""
SWEP.WorldModel = ""

SWEP.UseHands = true
SWEP.AttackSlowDown = .5
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.ReachDistance = 140
SWEP.HomicideSWEP = true

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "NextIdle")
	self:NetworkVar("Bool", 2, "Fists")
	self:NetworkVar("Float", 1, "NextDown")
	self:NetworkVar("Bool", 3, "Blocking")
	self:NetworkVar("Bool", 4, "IsCarrying")
end

function SWEP:Initialize()
	self:SetNextIdle(CurTime() + 5)
	self:SetNextDown(CurTime() + 5)
	self:SetHoldType(self.HoldType)
	self:SetFists(false)
	self:SetBlocking(false)

	self:DrawShadow(false)
end

function SWEP:Deploy()
	-- In fake the hands are a placeholder slot and nothing else: the body holds nothing,
	-- so they never deploy (their punch/grab keys are dead too, see InFakeNoHands).
	if InFakeNoHands(self) then return false end

	if not IsFirstTimePredicted() then
		return
	end

	self:SetNextPrimaryFire(CurTime() + .5)
	self:SetFists(false)
	self:SetNextDown(CurTime())

	return true
end

function SWEP:Holster() return true end
function SWEP:CanPrimaryAttack() return true end

local pickupWhiteList = {
	["prop_ragdoll"] = true,
	["prop_physics"] = true,
	["prop_physics_multiplayer"] = true
}

function SWEP:CanPickup(ent)
	if not IsValid(ent) then return end

	if ent:IsNPC() then return false end
	if ent:IsPlayer() then return false end
	if ent:IsWorld() then return false end

	local class = ent:GetClass()

	local phys = ent:GetPhysicsObject()

	if pickupWhiteList[class] then return true end
	if IsValid(phys) and phys:IsMotionEnabled() then return true end

	return false
end

function SWEP:CanCarryEnt(ent)
	if  IsValid(ent) and self:CanPickup(ent) and not ent:IsPlayer() then
		return true
	end

	return false
end

function SWEP:SecondaryAttack()
	if not IsFirstTimePredicted() then return end
	if self:GetFists() then return end
	if InFakeNoHands(self) then return end

	if SERVER then
		if IsValid(self.CarryEnt) then return end

		local ply = self.Owner
		local reach = self.ReachDistance or 140
		local tr = ply:EyeTrace(reach)

		if not tr then return end
		
		local ent = tr.Entity

		if self:CanCarryEnt(ent) then
			local Dist = (tr.StartPos - tr.HitPos):Length()

			if Dist < self.ReachDistance then
				sound.Play("Flesh.ImpactSoft", self.Owner:GetShootPos(), 65, math.random(90, 110))

				self:SetCarrying(ent,tr.PhysicsBone,tr.HitPos,Dist)

				tr.Entity.Touched = true

				self:ApplyForce()
			end
		elseif IsValid(ent) and ent:IsPlayer() then
			local Dist = (self.Owner:GetShootPos() - tr.HitPos):Length()

			if Dist < self.ReachDistance then
				sound.Play("Flesh.ImpactSoft", self.Owner:GetShootPos(), 65, math.random(90, 110))
				local horizPush = self.Owner:GetAimVector()
				horizPush.z = 0
				if horizPush:LengthSqr() > 0 then
					horizPush:Normalize()
				else
					horizPush = self.Owner:GetForward()
				end
				self.Owner:SetVelocity(horizPush * 15)
				ent:SetVelocity(horizPush * 40)
				self:SetNextSecondaryFire(CurTime() + .25)
			end
		end
	end
end

function SWEP:FreezeMovement()
	/*if self.Owner:KeyDown(IN_USE) and self.Owner:KeyDown(IN_ATTACK2) and self:GetNWBool( "Pickup" ) then
		return true
	end

	return false*/
end

if SERVER then
	util.AddNetworkString("get pulse")
else
	net.Receive("get pulse",function()
		chat.AddText(L("pulse_" .. net.ReadString()))
	end)
end

function SWEP:OnRemove()

end

function SWEP:GetCarrying()
	return self.CarryEnt
end

function SWEP:SetCarrying(ent, bone, pos, dist)
	if IsValid(ent) then
		self:SetNWBool( "Pickup", true )
		self.CarryEnt = ent
		self.CarryBone = bone
		self.CarryDist = dist

		if not (ent:GetClass() == "prop_ragdoll") then
			self.CarryPos = ent:WorldToLocal(pos)
		else
			self.CarryPos = nil
		end
	else
		self:SetNWBool( "Pickup", false )
		self.CarryEnt = nil
		self.CarryBone = nil
		self.CarryPos = nil
		self.CarryDist = nil
	end
end

-- The pack's copy of this SWEP lost ApplyForce, yet every grab path calls it
-- (SecondaryAttack after SetCarrying, and Think every frame while a carry is held), so
-- holding RMB on anything threw "attempt to call method 'ApplyForce' (a nil value)".
-- The sibling addon jmodhands ships the same weapon_hands with the method intact
-- (jmodhands/lua/weapons/weapon_hands.lua:299) and it fits this file exactly: same
-- CarryEnt/CarryBone/CarryPos/CarryDist fields, same ReachDistance, same physics model.
-- Two bits are homigrad's, not jmodhands': the pulse comes from the player's "pulse" NW
-- float (metabolism/stamina_sh.lua writes seconds-per-beat) and is reported through this
-- file's own "get pulse" receiver, whose keys are the localized pulse_0..pulse_4 strings.
function SWEP:ApplyForce()
	local owner = self:GetOwner()
	local ent = self.CarryEnt

	if not IsValid(owner) or not IsValid(ent) then return end

	local bone = self.CarryBone or 0
	local phys = ent:GetPhysicsObjectNum(bone)

	if not IsValid(phys) then return end

	local target = owner:GetAimVector() * (self.CarryDist or self.ReachDistance) + owner:GetShootPos()
	local targetPos = self.CarryPos and ent:LocalToWorld(self.CarryPos) or phys:GetPos()

	local vec = target - targetPos
	local len = vec:Length()
	local mul = ent:GetPhysicsObject():GetMass()

	-- Out of reach: let go instead of yanking it across the map.
	if len > self.ReachDistance then
		self:SetCarrying()

		return
	end

	local ragOwner
	local isRagdoll = ent:GetClass() == "prop_ragdoll"

	if isRagdoll then
		mul = mul * 3
		ragOwner = RagdollOwner(ent)

		-- Reload while holding a body = take its pulse.
		if owner:KeyPressed(IN_RELOAD) then
			local key = 0

			local isDead = false
			if ent:GetNWBool("HeadExploded", false) then isDead = true end
			if ent.hgIsDeathCorpse or ent:GetNWBool("hgDeathCorpse", false) then isDead = true end
			if not IsValid(ragOwner) or not ragOwner:Alive() or ragOwner.isDead or ragOwner:GetNWBool("isDead", false) then isDead = true end
			if IsValid(ragOwner) and (ragOwner.HeadPop or ragOwner:GetNWBool("HeadPop", false) or ragOwner.heartstop or ragOwner:GetNWBool("heartstop", false)) then isDead = true end

			if not isDead and IsValid(ragOwner) then
				local pulse = ragOwner:GetNWFloat("pulse", 0)
				if pulse > 0 then
					local bpm = 1 / pulse
					if bpm >= 115 then
						key = 1 -- Сильный пульс (тахикардия / адреналин / бег)
					elseif bpm >= 75 then
						key = 2 -- Нормальный пульс
					elseif bpm >= 50 then
						key = 3 -- Слабый пульс
					else
						key = 4 -- Очень слабый пульс
					end
				end
			end

			if SERVER then
				net.Start("get pulse")
					net.WriteString(tostring(key))
				net.Send(owner)
			end
		end

		-- CPR: LMB while holding a body whose heart is not beating (ownerless corpse or a
		-- stopped pump). The client page for this lives in the same "get pulse" contract.
		if SERVER then
			if owner:KeyDown(IN_ATTACK) then
				local headBlown = ent:GetNWBool("HeadExploded", false) or (IsValid(ragOwner) and (ragOwner.HeadPop or ragOwner:GetNWBool("HeadPop", false)))
				if headBlown then
					if self.firstTimePrint then
						owner:ChatPrint("У этого тела нет головы, СЛР невозможно!")
					end
					self.firstTimePrint = false
				elseif not (ragOwner and ragOwner:Alive() and not ragOwner.heartstop and not ragOwner:GetNWBool("heartstop", false)) then
					if self.firstTimePrint then
						owner:ChatPrint("Вы начинаете проводить СЛР... (держите ЛКМ зажатым до появления пульса)")
					end

					self.firstTimePrint = false

					if (self.CPRThink or 0) < CurTime() then
						self.CPRThink = CurTime() + 1

						if ragOwner then
							ragOwner.CPR = math.max((ragOwner.CPR or 0) + 50,0)
							ragOwner.o2 = math.min((ragOwner.o2 or 0) + 0.5,1)
						end

						ent:EmitSound("physics/body/body_medium_impact_soft" .. tostring(math.random(7)) .. ".wav")
					end
				end
			else
				self.firstTimePrint = true
			end
		end
	end

	vec:Normalize()

	local avec, velo = vec * len, phys:GetVelocity() - owner:GetVelocity()
	local force = (avec - velo / 2) * (bone > 3 and mul / 10 or mul)

	if force:Length() > 6000 then
		self:SetCarrying()

		return
	end

	if self.CarryPos then
		phys:ApplyForceOffset(force,ent:LocalToWorld(self.CarryPos))
	else
		phys:ApplyForceCenter(force)
	end

	if owner:KeyDown(IN_USE) then
		local cmd = owner:GetCurrentCommand()

		if cmd then
			local x,y = cmd:GetMouseX(),cmd:GetMouseY()
			local rotate = Vector(x,y,0) / (isRagdoll and 6 or 4)

			phys:AddAngleVelocity(rotate)
		end
	end

	phys:ApplyForceCenter(Vector(0,0,mul))
	phys:AddAngleVelocity(-phys:GetAngleVelocity() / 10)
end

function SWEP:Think()
	if InFakeNoHands(self) then return end

	local owner = self:GetOwner()

	local fists = self:GetFists()

	if owner:KeyDown(IN_ATTACK2) and not fists then
		if IsValid(self.CarryEnt) then self:ApplyForce() end
	elseif self.CarryEnt then
		self:SetCarrying()
	end

	if fists and owner:KeyDown(IN_ATTACK2) then
		self:SetNextPrimaryFire(CurTime() + .5)
		self:SetBlocking(true)
	else
		self:SetBlocking(false)
	end

	local HoldType = "fist"

	if fists then
		HoldType = "fist"
		local Time = CurTime()

		if self:GetBlocking() then
			self:SetNextDown(Time + 1)
			HoldType = "camera"
		end

		if (self:GetNextDown() < Time) or owner:KeyDown(IN_SPEED) then
			self:SetNextDown(Time + 1)
			self:SetFists(false)
			self:SetBlocking(false)
		end
	else
		HoldType = "normal"
	end

	if IsValid(self.CarryEnt) or self.CarryEnt then
		HoldType = "magic"
	end

	if self.Owner:KeyDown(IN_SPEED) then
		HoldType = "normal"
	end

	if SERVER then
		self:SetHoldType(HoldType)
	end
end

function SWEP:PrimaryAttack()
	-- In fake LMB is the fake grab, never a punch.
	if InFakeNoHands(self) then return end

	-- Rate limit before any branch: this function has several early returns and the cooldown
	-- used to be set only at the very bottom, so any of them -- or an error thrown further
	-- down -- left the weapon ungated and a held attack ran every frame.
	self:SetNextPrimaryFire(CurTime() + 0.22)
	self:SetNextSecondaryFire(CurTime() + 0.22)

	local owner = self:GetOwner()

	local side = "fists_left"

	if math.random(1, 2) == 1 then
		side = "fists_right"
	end

	if owner:KeyDown(IN_ATTACK2) then return end
	
	self:SetNextDown(CurTime() + 7)

	if not self:GetFists() then
		self:SetFists(true)
		self:SetNextPrimaryFire(CurTime() + 0.15)

		return
	end

	if self:GetBlocking() then return end
	if owner:KeyDown(IN_SPEED) then return end

	if not IsFirstTimePredicted() then return end

	owner:ViewPunch(Angle(0,0,math.random(-2,2)))
	owner:SetAnimation(PLAYER_ATTACK1)

	if SERVER then
		sound.Emit(self:EntIndex(),"weapons/slam/throw.wav",65,math.random(90,110))
		owner:ViewPunch(Angle(0,0,math.random(-2,2)))

		timer.Simple(0.02,function()
			if IsValid(self) then self:AttackFront() end
		end)
	end

	self:SetNextPrimaryFire(CurTime() + 0.22)
	self:SetNextSecondaryFire(CurTime() + 0.22)
end

function SWEP:AttackFront()
	if CLIENT then return end

	local owner = self:GetOwner()

	local reach = math.max(self.ReachDistance or 100, 95)
	local tr = owner:EyeTrace(reach)
	if not tr then return end

	local ent,hitPos = tr.Entity,tr.HitPos

	local dir = tr.Normal

	if IsValid(ent) or (ent and ent.IsWorld and ent:IsWorld()) then
		local SelfForce, Mul = -150, 1
		
		if self:IsEntSoft(ent) then
			SelfForce = 25

			if ent:IsPlayer() and IsValid(ent:GetActiveWeapon()) and ent:GetActiveWeapon().GetBlocking and ent:GetActiveWeapon():GetBlocking() and not RagdollOwner(ent) then
				sound.Play("Flesh.ImpactSoft", hitPos, 65, math.random(90, 110))
			else
				sound.Play("Flesh.ImpactHard", hitPos, 65, math.random(90, 110))
			end
		else
			sound.Play("Flesh.ImpactSoft", hitPos, 65, math.random(90, 110))
		end

		local isHead = (tr.HitGroup == HITGROUP_HEAD)
		if not isHead and isfunction(HG_IsHeadHit) then
			isHead = HG_IsHeadHit(ent, tr.HitGroup, hitPos, tr.PhysicsBone)
		end

		local dmg = isHead and 15 or 5
		local dmgTab = CreateDamageTab(ent,owner,self,dmg,DMG_CLUB)
		dmgTab.isFists = true
		dmgTab.isHead = isHead
		dmgTab.hitgroup = isHead and HITGROUP_HEAD or tr.HitGroup
		dmgTab.bone = tr.PhysicsBone and ent.TranslatePhysBoneToBone and ent:TranslatePhysBoneToBone(tr.PhysicsBone)

		local horizDir = Vector(dir.x, dir.y, 0)
		if horizDir:LengthSqr() > 0 then
			horizDir:Normalize()
		else
			horizDir = owner:GetForward()
		end

		dmgTab.force = horizDir * (isHead and 10 or 5)
		dmgTab.pos = hitPos

		ent:TakeDamageTab(dmgTab)

		if ent:IsPlayer() and ent:Alive() and not (ent.InFake and ent:InFake()) then
			if isHead and (ent:Health() < 35 or math.random(1, 4) == 1) then
				if Faking then
					Faking(ent, horizDir * 160)
				elseif ent.EnterFake then
					ent:EnterFake(horizDir * 160)
				end
			else
				ent:SetVelocity(horizDir * 50)
			end
		elseif ent:IsRagdoll() or (ent.InFake and ent:InFake()) then
			local phys = ent:GetPhysicsObjectNum(tr.PhysicsBone or 0) or ent:GetPhysicsObject()
			if IsValid(phys) then
				phys:ApplyForceOffset(horizDir * 2000, hitPos)
			end
		else
			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				phys:ApplyForceOffset(dir * 3000, hitPos)
			end
		end

		/*if ent:GetClass() == "func_breakable_surf" then
			if math.random(1,20) == 10 then ent:Fire("break","",0) end
		end

		if ent:GetClass() == "func_breakable" then
			if math.random(7,11) == 10 then ent:Fire("break","",0) end
		end*/
	end
end

--self.CarryDist
--self.CarryPos
--self.CarryBone

function SWEP:Reload()
	if not IsFirstTimePredicted() then return end
	if InFakeNoHands(self) then return end

	self:SetFists(false)
	self:SetBlocking(false)
end

function SWEP:DrawWorldModel() end

function SWEP:IsEntSoft(ent)
	return ent:IsNPC() or ent:IsPlayer() or RagdollOwner(ent)
end

