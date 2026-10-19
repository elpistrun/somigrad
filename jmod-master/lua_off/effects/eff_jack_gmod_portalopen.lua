--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/jmod-master/lua/effects/eff_jack_gmod_portalopen.lua <
    > Callstack:  <
]]

function EFFECT:Init(data)
	self.Position = data:GetOrigin()
	local emitter = ParticleEmitter(self.Position)

	for i = 0, 25 do
		local particle = emitter:Add("sprites/mat_jack_gravipinch", self.Position)
		particle:SetVelocity(Vector(0, 0, 0))
		particle:SetDieTime(.76)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(0)
		particle:SetEndSize(150)
		particle:SetRoll(0)
		particle:SetRollDelta(0)
		particle:SetColor(0, 0, 0)
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end

