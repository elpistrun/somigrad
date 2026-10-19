--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/mlg_weapons_1214787279/lua/effects/hg_mlg_hit/init.lua <
    > Callstack:  <
]]

-- "addons\\mlg_weapons_1214787279\\lua\\effects\\hg_mlg_hit\\init.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
function EFFECT:Init(data)
	
	self.Position = data:GetOrigin()
	self.Forward = data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	
	local AddVel = 5//self.WeaponEnt:GetOwner():GetVelocity()
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

			particle:SetVelocity( 200 * self.Forward + 200 * VectorRand() + 5 * VectorRand() )
			particle:SetGravity( Vector( 0, 0, -100 ) )
			particle:SetAirResistance( 60 )

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			
			particle:SetDieTime( math.Rand( 3, 4 ) )

			particle:SetStartSize( math.random( 5, 10 ) )
			particle:SetEndSize( 10 )

			particle:SetRoll( math.Rand( 80, 360 ) )
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
		local particle = emitter:Add( "hobo_gus/rainbow_frog", self.Position - self.Forward * 4 )
		if particle != nil then

			particle:SetVelocity( 200 * self.Forward + 200 * VectorRand() + 5 * VectorRand() )
			particle:SetGravity( Vector( 0, 0, -100 ) )
			particle:SetAirResistance( 60 )

			particle:SetDieTime( math.Rand( 3, 4 ) )
			
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)

			particle:SetStartSize( math.random( 5, 10 ) )
			particle:SetEndSize( 10 )

			particle:SetRoll( math.Rand( 0, 0 ) )
			//particle:SetRollDelta( math.Rand( -1, 1 ) )
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
print('mlghit')
