--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/weapons/tier_0_base/tier_0_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
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

-- "addons\\homigrad\\lua\\hinit\\weapons\\tier_0_base\\tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP,gg = oop.Reg("hg_wep","hg_wep_base",true)--пашол нахуй
if not SWEP then return INCLUDE_BREAK end

local vecZero = Vector(0,0,0)
local angZero = Angle(0,0,0)

SWEP.PrintName 				= "0oa base"
SWEP.Author 				= "0oa"
SWEP.Instructions			= ""
SWEP.WepSelectIcon			= ""

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

//

SWEP.IsFireWeapon = true

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.CSMuzzleFlashes = true

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP.HoldType = ""

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

SWEP.DisableSmoothHandFirstPerson = true
SWEP.SmoothDeployHand = true

//

local m = math.min

SWEP:Event_Add("Construct","Stupid NPC",function(self)
	self = self[1]

	local min,max,rate = 0,0,self.Primary.Wait

	local ammo = self.Primary.Ammo
	local clip = self.Primary.DefaultClip

	if ammo == "pistol" then
		min = m(clip,2)
		max = m(clip,4)
	elseif ammo == "buckshot" then
		min = m(clip,1)
		max = m(clip,2)
	elseif self.ChamberAuto then
		min = m(clip,5)
		max = m(clip,8)
	else
		min = m(clip,2)
		max = m(clip,4)
	end

	function self:GetNPCBurstSettings() return min,max,rate end	
	function self:GetNPCRestTimes() return 0.01,0.1 end
	function self:GetNPCBulletSpread() return math.Rand(10,15) end
end)

SWEP:Event_Add("Init","Main",function(self)
	self.lerpClose = 0

	self.recoil = 0
	self.recoil2 = 0
	self.recoil2Set = 0

	self.randAbs = 0 

	self.NextShot = 0
	self.lastShoot = 0
	self.lastShoot2 = 0

	self.fightDelay = 0
	self.attackDelay = 0

	self.attackHold = 0
	self.attackHoldWait = 0

	self:InsertChamber()

	local owner = self:GetOwner()

	if IsValid(owner) and owner:IsNPC() then//rubat pidoras
		self:Deploy()
	end
end)

--

function SWEP:CanFireBullet() return true end
function SWEP:CanPrimaryAttack() return true end--mdem

function SWEP:PrimaryAttack()
	if self:Event_Call("Can Primary Attack") == false or self.NextShot > CurTime() or not self:CanFight() or self.attackDelay > CurTime() then return end

	if self:GetNWInt("Chamber") ~= 1 or self:Clip1() <= 0 or not self:CanFireBullet() then
		if SERVER then sound.Emit(self:EntIndex(),self.EmptySound or "snd_jack_hmcd_click.wav",65) end

		self.NextShot = CurTime() + self.Primary.Wait
		self.Primary.Automatic = false

		self.AmmoChek = 3

		if self:GetOwner():IsNPC() then self:InsertChamber() end


		return
	end

	self.Primary.Automatic = oop.listClass[self:GetClass()][1].Primary.Automatic

	local func = self.PrimaryCustomAttack or self.Attack

	func(self)
end

function SWEP:AttackSmoke()
	if self:GetNWFloat("Smoke",0) < CurTime() then
		self:SetNWFloat("Smoke",CurTime() + 0.25)
	else
		self:SetNWFloat("Smoke",self:GetNWFloat("Smoke",0) + 0.25)
	end
end

function SWEP:GetCapabilities()
	return bit.bor(CAP_WEAPON_RANGE_ATTACK1,CAP_INNATE_RANGE_ATTACK1)
end

function SWEP:AttackShotSetupVars()
	self.lastShoot = CurTime()
	self.lastShoot2 = RealTime()

	local v = math.cos(CurTime() * 17)

	/*if v < 0 then
		v = -math.ease.OutCirc(-v)
	else
		v = math.ease.OutCirc(v)
	end*/

	self.randAbs = v

	self.recoil = math.Rand(0.9,1.1)
	self.recoil2Set = math.Rand(0.9,1.1)
end

function SWEP:Attack()
	local ply = self:GetOwner()

	self.NextShot = CurTime() + self.Primary.Wait
	self:SetNextPrimaryFire(self.NextShot)

	if self.attackHoldWait < CurTime() then
		self.attackHold = CurTime()
	end

	self.attackHoldWait = CurTime() + self.Primary.Wait + 0.05

	self:AttackShotSetupVars()

	self:FireBullet()
	self:AttackSmoke()
	if CLIENT then self:ApplySpray() end

	if ply:IsNPC() then
		ply:SetAnimation(PLAYER_ATTACK1)
		
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	end
end

//

local tr = {}
local TraceLine = util.TraceLine

local Clamp = math.Clamp

SWEP:Event_Add("Think","Main",function(self,owner,ft,time)
	local isLocal = self:IsLocal()

	if self:CanFight() then
		if self.HoldType then self:SetStandType(self.HoldType) end
	end

	if owner:IsNPC() then return end

	if not owner:IsSprinting() then
		if SERVER then
			local Time = CurTime()

			if self:IsHolstered() then
				self.isClose = true
			elseif (self.delayClose or 0) < Time then
				self.delayClose = Time + 1 / 24

				/*if not owner.fake then
					local pos,ang = self:GetTransformFromRagdoll()

					tr.start = pos:Add(Vector(-25,0,0):Rotate(owner:EyeAngles()))
					tr.endpos = tr.start:Clone():Add(Vector(25,0,0):Rotate(owner:EyeAngles()))
					tr.filter = owner

					self.isClose = TraceLine(tr).Hit
				end*/

				self.isClose = false
			end

			self:SetNWBool("isClose",self.isClose)
		else
			self.isClose = self:GetNWBool("isClose")
		end
	else
		self.isClose = true
	end
end)
