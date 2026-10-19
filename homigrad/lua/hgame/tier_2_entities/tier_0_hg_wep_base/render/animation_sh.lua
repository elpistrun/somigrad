--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/tier_0_hg_wep_base/render/animation_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hgame/tier_2_entities/tier_0_hg_wep_base/tier_0_sh.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\tier_0_hg_wep_base\\render\\animation_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Get("hg_wep_base")
if not SWEP then return end

if SERVER then return end

SWEP:Event_Add("Init","Smooth Hand",function(self)
	self.ownerDiffEyePitchSet = 0
	self.ownerDiffEyeYawSet = 0

	self.ownerDiffHand = Angle()
	self.oldOwnerEye = Angle()
end)

function SWEP:DoAnimation(rag,ft,time,hg_bones_framerate)
	self:SmoothHand(ft,hg_bones_framerate)
    self:AnimationBonesPlayer(rag,ft,CurTime())
end

function SWEP:SmoothHand(ft,hg_bones_framerate)
	local owner = self:GetOwner()
	if self:GetPos():Distance(EyePos()) > 512 or (self.DisableSmoothHandFirstPerson and owner == LocalPlayer() and GetViewEntity() == LocalPlayer()) then return end
	
	if self.SmoothDeployHand then
		-- Easing functions only make sense on [0,1]. DeployStart could still be the ten
		-- second placeholder Deploy() parks there, which made this 10.5 / 0.5 = 21, and
		-- InCubic turned 21 into 21^3 = 9261 -- times -75 degrees applied to rhand, the very
		-- bone the weapon rides on. That is the hand, and the gun with it, spinning on its
		-- axis for as long as the placeholder lasts, then settling.
		local deployAnim = math.max(self:GetDeployStart(CurTime()) - CurTime() + 0.5,0) / 0.5
		deployAnim = math.ease.InCubic(math.Clamp(deployAnim,0,1))
		owner:AddBoneAng("rhand",Angle(-75 * deployAnim,0,0))
	end

	local ang = owner:EyeAngles()

	if not self.oldOwnerEye then
		self.oldOwnerEye = ang
	elseif self.oldOwnerEye ~= ang then
		local diff = self.oldOwnerEye - ang
		diff:Normalize()

		local mul = 3

		self.ownerDiffEyePitchSet = -diff[1] * mul
		self.ownerDiffEyeYawSet = -diff[2] * mul

		self.oldOwnerEye = ang
	end

	if hg_bones_framerate != 0 then return end

	self.ownerDiffEyePitch = Lerp(0.2,self.ownerDiffEyePitch or 0,self.ownerDiffEyePitchSet)
	self.ownerDiffEyeYaw = Lerp(0.2,self.ownerDiffEyeYaw or 0,self.ownerDiffEyeYawSet)

	self.ownerDiffHand = Angle(self.ownerDiffEyePitch,self.ownerDiffEyeYaw,0):Mul(7)

	owner:AddBoneAng("rhand",self.ownerDiffHand)

	self.ownerDiffEyePitchSet = LerpLess(0.1,self.ownerDiffEyePitchSet,0,0.01)
	self.ownerDiffEyeYawSet = LerpLess(0.1,self.ownerDiffEyeYawSet,0,0.01)
end

event.Add("Bones","Player",function(ply,link,ft,hg_bones_framerate)
	if not link.GetActiveWeapon then return end
	
	local wep = link:GetActiveWeapon()
	if IsValid(wep) and wep.DoAnimation then wep:DoAnimation(ply,ft,CurTime(),hg_bones_framerate) end
end)
