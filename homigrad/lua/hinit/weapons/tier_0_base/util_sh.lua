--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/weapons/tier_0_base/util_sh.lua <
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

-- "addons\\homigrad\\lua\\hinit\\weapons\\tier_0_base\\util_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Get("hg_wep")
if not SWEP then return end

function SWEP:CanFight(ignoreClose)--cring
	local owner = self:GetOwner()

	if owner:IsNPC() then return true end
	
	if self:IsHolstered() or not self:IsDeployed() or self.reloadedStart or self.fightDelay > CurTime() then return false end
	if not owner:GetNWBool("fake") and (owner:IsSprinting() or (not ignoreClose and self.isClose)) then return false end

	return true
end

SWEP.MuzzlePos = Vector(0,0,0)
SWEP.MuzzleAng = Angle(0,0,0)

-- Which attachment the muzzle actually is.
--
-- The old call was gun:LookupBone("muzzle"), and it could never work: LookupBone matches
-- bones of the model's skeleton, while a weapon model's muzzle is an *attachment*, so the
-- result was always nil and every weapon silently fell through to attachment #1. On the
-- Valve models #1 happens to be the muzzle, but on the third-party ones it is often the
-- shell eject or the "eye". The shot takes both position and angles from whatever
-- attachment got picked, and the per-weapon MuzzleAng/MuzzlePos fudge was tuned for the
-- real muzzle, so on those models it comes out slightly off -- "the muzzle shoots a
-- little off" -- while MuzzleAng being a hand-tuned correction on top of a wrong frame
-- also tilts the shot direction a degree or two. Look the attachment up by name first,
-- then scan the model's attachment list, and only then keep the old #1 fallback so the
-- models that were fine before behave exactly as before.

local string_find,string_lower = string.find,string.lower

local function GetMuzzleAttachment(gun)
	local id = gun.LookupAttachment and gun:LookupAttachment("muzzle")

	if id and id > 0 then return id end

	local list = gun.GetAttachments and gun:GetAttachments()

	if list then
		for i = 1,#list do
			local name = string_lower(list[i].name or "")

			if string_find(name,"muzzle",1,true) then return list[i].id end
		end
	end

	return 1
end

function SWEP:GetMuzzleFromTransform(gunPos, gunAng)
	local mPos, mAng

	if CLIENT and IsValid(self.wm) then
		self.wm:SetPos(gunPos)
		self.wm:SetAngles(gunAng)
		self.wm:SetupBones()
		local attId = GetMuzzleAttachment(self.wm)
		local att = attId and self.wm:GetAttachment(attId)
		if att and att.Pos then
			mPos = att.Pos:Clone()
			mAng = att.Ang:Clone()
		end
	elseif SERVER and IsValid(self) then
		local attId = GetMuzzleAttachment(self)
		local att = attId and self:GetAttachment(attId)
		if att and att.Pos then
			local lPos = self:WorldToLocal(att.Pos)
			local lAng = self:WorldToLocalAngles(att.Ang)
			local wPos, wAng = LocalToWorld(lPos, lAng, gunPos, gunAng)
			mPos = wPos:Clone()
			mAng = wAng:Clone()
		end
	end

	if not mPos or not mAng then
		mPos = gunPos:Clone()
		mAng = gunAng:Clone()
	end

	if self.MuzzleAng then
		mAng:Rotate(self.MuzzleAng)
	end

	if self.MuzzlePos then
		mPos:Add(self.MuzzlePos:Clone():Rotate(mAng))
	end

	return mPos, mAng
end

function SWEP:GetMuzzlePos(gun)
	if not gun then
		local owner = self:GetOwner()
		local isFake = IsValid(owner) and (owner.Fake or owner:GetNWBool("fake", false))
		local fakeRag = isFake and (owner.FakeRagdoll or owner.hgFakeRagdoll or (owner.GetNWEntity and owner:GetNWEntity("FakeRagdoll")))
		if isFake and IsValid(fakeRag) and self.GetTransformFromRagdoll then
			local gunPos, gunAng = self:GetTransformFromRagdoll(fakeRag)
			if gunPos and gunAng then
				return self:GetMuzzleFromTransform(gunPos, gunAng)
			end
		end
	end

	gun = gun or self:GetGun()
	
	local pos,ang
    local att = gun:GetAttachment(GetMuzzleAttachment(gun))

	if att then
		pos,ang = att.Pos,att.Ang
	else
		pos,ang = gun:GetPos(),gun:GetAngles()
	end

	ang:Rotate(self.MuzzleAng)

    return pos:Add(self.MuzzlePos:Clone():Rotate(ang)),ang
end

function SWEP:HasFake()
	local fake = self:GetNWEntity("Fake")
    if not IsValid(fake) then return end

    fake.fake = true
    
	return fake
end

function SWEP:GetGun()
	local fake = self:HasFake()
    if fake then return fake,true end

	local wm = self.wm

	return (IsValid(wm) and wm) or self
end

function SWEP:CanFootKick() return self:GetOwner():IsSprinting() end

function SWEP:ShouldDropOnDie() return false end

function SWEP:SoundEmit(path,level,volume,pitch)
	if SERVER then
		sound.EmitNET(self:EntIndex(),path,level,volume,pitch,self:GetPos())
		if self:GetOwner():IsNPC() then net.Broadcast() else net.SendOmit(self:GetOwner()) end
	else
		sound.Emit(self:EntIndex(),path,level,volume,pitch,self:GetPos())
	end
end

function SWEP:SoundEmitSERVER(path,level,volume,pitch)
	if CLIENT then return end

	sound.Emit(self:EntIndex(),path,level,volume,pitch,self:GetPos())
end


if CLIENT then return end
