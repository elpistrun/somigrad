--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/weapons/tier_0_base/anim_sh.lua <
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

-- "addons\\homigrad\\lua\\hinit\\weapons\\tier_0_base\\anim_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Get("hg_wep")
if not SWEP then return end

local min,max = math.min,math.max

SWEP.CHandUp = 0.5
SWEP.CHandHoldUp = 0.3

function SWEP:GetCHandUp(value) return math.ease.InElastic(value) end

SWEP.CHandRight = 0
SWEP.CHandHoldRight = 0.3

function SWEP:GetCHandRight(value) return math.ease.InElastic(value) end

function SWEP:GetAngleHand()
	return Angle(
        self:GetCHandUp(max(self.lastShoot2 - RealTime() + self.CHandHoldUp,0) / self.CHandHoldUp) * self.CHandUp,
        self:GetCHandRight(max(self.lastShoot2 - RealTime() + self.CHandHoldRight,0) / self.CHandHoldRight) * self.CHandRight,
        0)
end

SWEP:Event_Add("Deploy","Smooth Hand",function(self)
	self.oldOwnerEye = self:GetOwner():EyeAngles()
	self.oldOwnerEye[1] = math.Clamp(self.oldOwnerEye[1] + (self.HoldType == "revolver" and 45 or -45),-180,180)
end)

local angSuicide = Angle(160,30,90)
local angSuicide2 = Angle(160,30,90)
local angSuicide3 = Angle(60,-30,90)

function SWEP:AnimationBonesPlayer(owner,ft,time)
    local isLocal = self:IsLocal()

	local FTK = (1 / ft) / 30

	if owner:IsPlayer() and not owner:IsSprinting() then
		local eyeangles

		if isLocal then
			eyeangles = owner:EyeTrace()

			if not eyeangles then
				eyeangles = 0
			else
				eyeangles = eyeangles.HitPos:Sub(eyeangles.StartPos):Angle()
				eyeangles:Normalize()
				eyeangles = eyeangles[1]
			end
			
			self:SetNWFloat("EyePitch",eyeangles)
		else
			eyeangles = self:GetNWFloat("EyePitch",0)
		end

		local numbr = self.FakeVec2 and 50 or 80

		if eyeangles > numbr then
			owner:AddBoneAng("rhand",Angle(-(eyeangles - numbr),0,0))
		end

		if eyeangles < -numbr then
			owner:AddBoneAng("rhand",Angle(-(eyeangles + numbr),0,0))
		end
	end

	local k = self:GetStandAnimK()
	
    self.lerpClose = Lerp(0.5 / FTK,self.lerpClose,(self.isClose and 1) or 0)

	owner:AddBoneAng("rclavicle",Angle(0,0,-45 * self.lerpClose):Mul(k))

	local scope = self:IsScope()
	self.lerpScope = Lerp((scope and self.ScopeLerp or self.ScopeLerpOut or self.ScopeLerp) / FTK,self.lerpScope,scope and 1 or 0)

	local butt = 0

	if self.FakeVec2 then
		butt = butt + self.recoil / 6 / Lerp(self.lerpScope,1,2)
	end

	butt = butt * k

	owner:AddBoneAng("rupperarm",Angle(-25,45,0):Mul(butt))
	owner:AddBoneAng("rforearm",Angle(0,-45,0):Mul(butt))
	owner:AddBoneAng("rhand",Angle(0,0,-25):Mul(butt))

	owner:AddBoneAng("rhand",Angle(self.recoil2,self.recoil2,self.recoil2 * 3 - self.recoil))

	owner:AddBoneAng("spine",Angle(0,-5,0):Mul(k))

	owner:AddBoneAng("rupperarm",Angle(-0,-15,0):Mul(self.lerpScope * k))
	owner:AddBoneAng("rhand",Angle(-10,10,0):Mul(self.lerpScope * k))

	self.recoil = Lerp(Lerp(self:IsScope() and 1 or 0,self.CRL,self.CRL_Scope) / FTK,self.recoil,0)
	self.recoil2 = Lerp(0.1 / FTK,self.recoil2,self.recoil2Set * self.randAbs)
	self.recoil2Set = Lerp(Lerp(self:IsScope() and 1 or 0,self.CRL / 12,self.CRL_Scope / 12) / FTK,self.recoil2Set,0)

	if SERVER then
		owner:AddBoneAng("rhand",self:GetAngleHand():Mul(k))
	end

	-- Draw pose. Read through GetDeployStart instead of the raw NW float: Deploy() parks it
	-- ten seconds ahead (a hack for when the correction message does not arrive), and
	-- trusting it directly held this pose -- arm at Angle(70,0,30) -- for those ten seconds
	-- while IsDeployed() stayed false and firing was blocked. Also guards DeployTime = 0,
	-- which divided by zero and pushed nan bone angles into the model.
	local deployTime = self.DeployTime
	local k

	if deployTime and deployTime > 0 then
		k = math.Clamp((self:GetDeployStart(time) + deployTime - time) / deployTime,0,1)
	else
		k = 1
	end

	if self.HoldType == "revolver" then

	else
		owner:AddBoneAng("rupperarm",Angle(50,30,30):Mul(k))
		owner:AddBoneAng("rupperarm",Angle(20,-30,0):Mul(k))
	end

	if owner:GetNWBool("Suiciding") then
		if not self.FakeVec2 then
			self:SetStandType("normal")

			owner:SetBoneAng("rforearm",angSuicide2)
			owner:SetBoneAng("rhand",angSuicide3)
		else
			self:SetStandType("normal")

			owner:SetBoneAng("rhand",angSuicide)
		end
	end

	local ang = self:GetAngleHand()
	owner:AddBoneAng("rhand",ang)
	self.applyAngleHead = ang

	local anim = self:GetNWFloat("ReloadAnim",0)
	self.reloadAnimAng = Angle(0,-25 * anim,-25 * anim)
	owner:AddBoneAng("rhand",self.reloadAnimAng)

	self:AnimationBonesPlayerPost(owner,ft,time)
end

function SWEP:AnimationBonesPlayerPost() end
