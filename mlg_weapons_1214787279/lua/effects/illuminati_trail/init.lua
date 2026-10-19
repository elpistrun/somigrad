--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/mlg_weapons_1214787279/lua/effects/illuminati_trail/init.lua <
    > Callstack:  <
]]

-- "addons\\mlg_weapons_1214787279\\lua\\effects\\illuminati_trail\\init.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
function EFFECT:Init(data)
	
	self.Position = data:GetOrigin()
	self.Forward = data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	
	local light = DynamicLight( 0 )
	if( light ) then
		
		light.Pos = self.Position
		light.Size = 300
		light.Decay = 100
		light.R = 0
		light.G = 255
		light.B = 150
		light.Brightness = 255
		light.DieTime = CurTime() + 5

	end
	
	local AddVel = 5//self.WeaponEnt:GetOwner():GetVelocity()
for i=0, 3 do
	local emitter = ParticleEmitter(self.Position)
	if emitter != nil then	
		local particle = emitter:Add( "hobo_gus/illuminati", self.Position - self.Forward * 4 )
		if particle != nil then

			particle:SetVelocity( 35 * self.Forward + 35 * VectorRand() + 5 * VectorRand() )
			particle:SetGravity( Vector( 0, 0, 0 ) )
			particle:SetAirResistance( 50 )

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			
			particle:SetDieTime( math.Rand( 2, 3 ) )

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
end

function EFFECT:Think()

	return false
end


function EFFECT:Render()
end
print('illuminati trail')
