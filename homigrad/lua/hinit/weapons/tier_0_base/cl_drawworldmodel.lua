--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/weapons/tier_0_base/cl_drawworldmodel.lua <
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

-- "addons\\homigrad\\lua\\hinit\\weapons\\tier_0_base\\cl_drawworldmodel.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Get("hg_wep")
if not SWEP then return end

function SWEP:DrawSetupSkin(gun)
    gun:SetSubMaterial(0,self:GetNWString("skin"))
	gun:SetSubMaterial(1,self:GetNWString("skin"))

    self:DrawSetupSkinPost(gun)
end

function SWEP:DrawSetupSkinPost() end

function SWEP:DrawModelGun(gun)
	gun:DrawModel()
end

function SWEP:Render(gun)
    self:DrawSetupSkin(gun)
	self:DrawModelGun(gun)

    if IsValid(self) and EyePos():Distance(gun:GetPos()) <= 500 then self:DrawSmoke(gun) end

    self:DrawWorldModelPost(gun)
end

function SWEP:DrawWorldModelPost(gun) end
function SWEP:SetupGunPost(gun) end

local white = Color(255,255,160)
local mat = Material("homigrad/shine")
local random,Rand = math.random,math.Rand

local cos = math.cos

function SWEP:DrawSmoke(gun)
	local Time = RealTime()
	if (self.delaySmoke or 0) > Time then return end
	self.delaySmoke = Time + 1 / 24

	local smoke = math.Clamp(self:GetNWFloat("Smoke",0) - CurTime(),0,3) / 3
	local k = math.max((self.lastShoot + 1 - CurTime()),0)

	smoke = smoke * (1 - k)
	if smoke <= 0 then return end

	local pos,ang = self:GetMuzzlePos(gun)
	local dir = Vector(1,0,0):Rotate(ang)

	local emitter = ParticleEmitterLight(pos)

	local part = emitter:Add(mat,pos:Add(Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1))))
	if part then
		part:SetDieTime(Rand(1,2))

		local p = random(200,255)
		part:SetColor(p,p,p)

		part:SetStartAlpha(Rand(15,25) * smoke)
		part:SetEndAlpha(0)

		part:SetStartSize(Rand(3,4))
		part:SetStartLength(Rand(4,8))
		part:SetEndLength(Rand(12,15))
		part:SetEndSize(Rand(8,14))

		part:SetVelocity(Vector(0.01,0,Rand(12,22)):Rotate(Angle(0,cos(Time * 3 + self:EntIndex()) * 7,0)):Add(Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1))))
	end

	emitter:Finish()
end
