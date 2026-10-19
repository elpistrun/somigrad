--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/mlg_weapons_1214787279/lua/effects/hg_jihad_boom/init.lua <
    > Callstack:  <
]]

-- "addons\\mlg_weapons_1214787279\\lua\\effects\\hg_jihad_boom\\init.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
function EFFECT:Init(data)
	
	//self.Position = self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)
	self.Position = data:GetOrigin()
	self.Forward = data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	
for i=0, 15 do
	local emitter = ParticleEmitter(self.Position)
	if emitter != nil then	
		local particle = emitter:Add( "particle/particle_smoke_dust", self.Position - self.Forward * 4, (Color(255,0,0,25)) )
		if particle != nil then

			particle:SetVelocity( 250 * self.Forward + 250 * VectorRand() + 5 * VectorRand() )
			particle:SetGravity( Vector( 0, 0, 0 ) )
			particle:SetAirResistance( 50 )
			//particle:SetColor(Color(255,0,0,25))

			particle:SetDieTime( math.Rand( 8, 10 ) )

			particle:SetStartSize( 40 )
			particle:SetEndSize( 70 )

			particle:SetRoll( math.Rand( 180, 480 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetBounce( 1 )
			particle:SetCollide( true )
		end
	
	end
	emitter:Finish()
end
for i=0, 50 do
	local emitter = ParticleEmitter(self.Position)
	if emitter != nil then	
				local FlameMat = {}
			FlameMat[1] = "sprites/flamelet4"
			FlameMat[2] = "sprites/flamelet5"
			FlameMat[3] = "sprites/flamelet1"
			FlameMat[4] = "sprites/flamelet3"
		local particle = emitter:Add( FlameMat[math.random(1,4)], self.Position - self.Forward * 4, (Color(255,0,0,25)) )
		if particle != nil then

			particle:SetVelocity( 100 * VectorRand() + 100 * VectorRand() + 100 * VectorRand() )
			particle:SetGravity( Vector( 0, 0, 0 ) )
			particle:SetAirResistance( 65 )
			//particle:SetColor(Color(255,0,0,25))

			particle:SetDieTime( math.Rand( 1, 2 ) )

			particle:SetStartSize( math.random( 50, 60 ) )
			particle:SetEndSize( 40 )

			particle:SetRoll( math.Rand( 180, 480 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetBounce( 2 )
			particle:SetCollide( true )
		end
	
	end
	emitter:Finish()
end
for i=0, 45 do
	local emitter = ParticleEmitter(self.Position)
	if emitter != nil then	
				local FlameMat = {}
			FlameMat[1] = "sprites/flamelet4"
			FlameMat[2] = "sprites/flamelet5"
			FlameMat[3] = "sprites/flamelet1"
			FlameMat[4] = "sprites/flamelet3"
		local particle = emitter:Add( FlameMat[math.random(1,4)], self.Position - self.Forward * 4, (Color(255,0,0,25)) )
		if particle != nil then

			particle:SetVelocity( math.random(50, 200) * VectorRand() + math.random(50, 200) * VectorRand() + math.random(50, 200) * VectorRand() )
			particle:SetGravity( Vector( 0, 0, 0 ) )
			particle:SetAirResistance( 25 )
			//particle:SetColor(Color(255,0,0,25))

			particle:SetDieTime( math.Rand( 10, 12 ) )

			particle:SetStartSize( math.random( 2, 3 ) )
			particle:SetEndSize( 1 )

			particle:SetRoll( math.Rand( 180, 480 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetBounce( 1 )
			particle:SetCollide( true )
		end
	
	end
	emitter:Finish()
end
end
//end

function EFFECT:Think()

	return false
end


function EFFECT:Render()
end
