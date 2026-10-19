--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/mlg_weapons_1214787279/lua/effects/hg_mlg_boom/init.lua <
    > Callstack:  <
]]

-- "addons\\mlg_weapons_1214787279\\lua\\effects\\hg_mlg_boom\\init.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
function EFFECT:Init(data)
	
	self.Position = data:GetOrigin()
	self.Forward = data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	
for i=0, 100 do
	local emitter = ParticleEmitter(self.Position)
	if emitter != nil then	
			local MlgMat = {}
			MlgMat[1] = "hobo_gus/weed"
			MlgMat[2] = "hobo_gus/dew"
			MlgMat[3] = "hobo_gus/doritos"
			MlgMat[4] = "hobo_gus/illuminati"
		local particle = emitter:Add( MlgMat[math.random(1,4)], self.Position - self.Forward * 4 )
		if particle != nil then

			particle:SetVelocity( 100 * self.Forward + 100 * VectorRand() + 5 * VectorRand() )
			particle:SetGravity( Vector( 0, 0, -100 ) )
			particle:SetAirResistance( 160 )

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			
			particle:SetDieTime( math.Rand( 1, 2 ) )

			particle:SetStartSize( math.random( 100, 150 ) )
			particle:SetEndSize( 10 )

			particle:SetRoll( math.Rand( 360, 960 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetBounce( 2 )
			particle:SetCollide( true )
		end
	emitter:Finish()
	end
	end
for i=0, 25 do
	local emitter = ParticleEmitter(self.Position)
	if emitter != nil then	
			local MlgMat = {}
			MlgMat[1] = "hobo_gus/weed"
			MlgMat[2] = "hobo_gus/dew"
			MlgMat[3] = "hobo_gus/doritos"
			MlgMat[4] = "hobo_gus/illuminati"
		local particle = emitter:Add( MlgMat[math.random(1,4)], self.Position - self.Forward * 4 )
		if particle != nil then

			particle:SetVelocity( 400 * self.Forward + 400 * VectorRand() + 5 * VectorRand() )
			particle:SetGravity( Vector( 0, 0, 0 ) )
			particle:SetAirResistance( 10 )

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			
			particle:SetDieTime( math.Rand( 5, 6 ) )

			particle:SetStartSize( math.random( 35, 55 ) )
			particle:SetEndSize( 70 )

			particle:SetRoll( math.Rand( 360, 960 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetBounce( 1 )
			particle:SetCollide( true )
		end
	emitter:Finish()
	end
end
for i=0, 25 do
	local emitter = ParticleEmitter(self.Position)
	if emitter != nil then	
		local particle = emitter:Add( "hobo_gus/illuminati", self.Position - self.Forward * 4 )
		if particle != nil then

			particle:SetVelocity( 400 * VectorRand() + 400 * VectorRand() + 400 * VectorRand() )
			particle:SetGravity( Vector( 0, 0, 0 ) )
			particle:SetAirResistance( 35 )

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			
			particle:SetDieTime( math.Rand( 5, 6 ) )

			particle:SetStartSize( math.random( 20, 25 ) )
			particle:SetEndSize( 30 )

			particle:SetRoll( math.Rand( 360, 960 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetBounce( 2 )
			particle:SetCollide( true )
		end
	emitter:Finish()
	end
end
end


function EFFECT:Think()

	return false
end


function EFFECT:Render()

end
print('mlgboom')
