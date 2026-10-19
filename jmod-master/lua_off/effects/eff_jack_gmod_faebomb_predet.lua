--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/jmod-master/lua/effects/eff_jack_gmod_faebomb_predet.lua <
    > Callstack:  <
]]

function EFFECT:Init(data)
	local Pos = data:GetOrigin()
	local Emitter = ParticleEmitter(Pos)

	for i = 0, 100 do
		local particle = Emitter:Add("particle/smokestack", Pos)
		particle:SetVelocity(VectorRand() * 2000)
		particle:SetAirResistance(100)
		particle:SetGravity(Vector(0, 0, 0))
		particle:SetDieTime(.4)
		particle:SetStartAlpha(math.Rand(200, 255))
		particle:SetEndAlpha(0)
		local Siz = math.Rand(50, 100)
		particle:SetStartSize(Siz)
		particle:SetEndSize(Siz * 3)
		particle:SetRoll(math.Rand(-3, 3))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetLighting(false)
		local darg = math.Rand(10, 150)
		particle:SetColor(darg, darg, darg)
		particle:SetCollide(true)
	end

	Emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
	return false
end

