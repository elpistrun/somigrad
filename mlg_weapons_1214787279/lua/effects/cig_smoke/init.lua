--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/mlg_weapons_1214787279/lua/effects/cig_smoke/init.lua <
    > Callstack:  <
]]

-- "addons\\mlg_weapons_1214787279\\lua\\effects\\cig_smoke\\init.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
function EFFECT:Init(data)
	
	//if not IsValid(data:GetEntity()) then return end
	//if not IsValid(data:GetEntity():GetOwner()) then return end
	//self.WeaponEnt = data:GetEntity()

	self.Position = data:GetOrigin()
	self.Forward = data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	
	local AddVel = data:GetNormal()
	
	local emitter = ParticleEmitter(self.Position)
	if emitter != nil then	
		for i = 1,10 do
			local particle = emitter:Add( "particle/particle_smokegrenade", self.Position )

				particle:SetVelocity( 36 * i * self.Forward + 2 * VectorRand() + AddVel )
				particle:SetAirResistance( 90 )
				particle:SetGravity( Vector(0, 0, math.Rand(50, 100) ) )

				particle:SetDieTime( math.Rand( 15, 20 ) )

				particle:SetStartAlpha( math.Rand( 15, 50 ) )
				particle:SetEndAlpha( 0 )

				particle:SetStartSize( math.Rand( 40, 50 ) )
				particle:SetEndSize( math.Rand( 50, 60 ) )

				particle:SetRoll( math.Rand( -25, 25 ) )
				particle:SetRollDelta( math.Rand( -0.05, 0.05 ) )

				particle:SetColor( 120, 120, 120 )
		end
	end
	emitter:Finish()
	end


function EFFECT:Think()

	return false
end


function EFFECT:Render()
end

print ('SMOKEWEEDSMALL')
