--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/mlg_weapons_1214787279/lua/effects/kill/init.lua <
    > Callstack:  <
]]

-- "addons\\mlg_weapons_1214787279\\lua\\effects\\kill\\init.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
function EFFECT:Init(data)
	
	self.Position = data:GetOrigin()
	self.Forward = data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	
	local AddVel = 5//self.WeaponEnt:GetOwner():GetVelocity()
//for i=0, 1 do
	local emitter = ParticleEmitter(self.Position)
	if emitter != nil then	
		local particle = emitter:Add( "hobo_gus/kill", self.Position - self.Forward * 4 )
		if particle != nil then

			particle:SetVelocity( 50 * self.Forward + 50 * VectorRand() + 5 * VectorRand() )
			particle:SetGravity( Vector( 0, 0, 150 ) )
			particle:SetAirResistance( 0 )

			particle:SetDieTime( 2 )
			
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)

			particle:SetStartSize( math.random( 35, 40 ) )
			particle:SetEndSize( 60 )

			particle:SetRoll( math.Rand( 0, 0 ) )
			//particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetBounce( 2 )
			//particle:SetCollide( true )
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
print('kill effect')
