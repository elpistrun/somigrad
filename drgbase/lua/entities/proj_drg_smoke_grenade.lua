--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/drgbase/lua/entities/proj_drg_smoke_grenade.lua <
    > Callstack:  <
]]

if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "proj_drg_grenade"

-- Misc --
ENT.PrintName = "Smoke Grenade"
ENT.Category = "DrGBase"
ENT.Models = {"models/weapons/w_eq_smokegrenade.mdl"}
ENT.Spawnable = true

-- Grenade --
ENT.Bounce = 1
ENT.OnBounceSounds = {"weapons/flashbang/grenade_hit1.wav"}

if SERVER then
	AddCSLuaFile()

	function ENT:OnDetonate()
		ParticleEffect("drg_smokescreen", self:GetPos(), self:GetAngles())
		self:EmitSound("weapons/smokegrenade/sg_explode.wav")
		self:Timer(0.1, self.Remove)
		return true
	end

end

