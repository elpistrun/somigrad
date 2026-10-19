--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/jmod-master/lua/effects/eff_jack_gmod_ezhealpoof.lua <
    > Callstack:  <
]]

-- Jackarunda 2021
local Sprites = {"particle/smokestack"}

function EFFECT:Init(data)
	local Pos, Scale = data:GetOrigin(), 1
	local Emitter = ParticleEmitter(Pos)

	for i = 1, 2 do
		local Sprite = table.Random(Sprites)
		local Particle = Emitter:Add(Sprite, Pos)

		if Particle then
			Particle:SetVelocity(10 * VectorRand() * Scale)
			Particle:SetAirResistance(1000)
			Particle:SetDieTime(math.Rand(5, 10) * Scale)
			Particle:SetStartAlpha(255)
			Particle:SetEndAlpha(0)
			local Size = math.Rand(10, 20) * Scale
			Particle:SetStartSize(Size)
			Particle:SetEndSize(Size)
			Particle:SetRoll(math.Rand(-3, 3))
			Particle:SetRollDelta(math.Rand(-2, 2))
			Particle:SetGravity(Vector(0, 0, 0))
			Particle:SetLighting(false)
			local darg = math.Rand(200, 255)
			Particle:SetColor(darg, darg, darg)
			Particle:SetCollide(false)
		end
	end

	Emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
-- no u

