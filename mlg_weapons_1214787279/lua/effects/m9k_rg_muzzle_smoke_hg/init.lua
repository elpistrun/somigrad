--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/mlg_weapons_1214787279/lua/effects/m9k_rg_muzzle_smoke_hg/init.lua <
    > Callstack:  <
]]

-- "addons\\mlg_weapons_1214787279\\lua\\effects\\m9k_rg_muzzle_smoke_hg\\init.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
function EFFECT:Init(data)
	
	if not IsValid(data:GetEntity()) then return end
	if not IsValid(data:GetEntity():GetOwner()) then return end
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	
	if self.WeaponEnt == nil or self.WeaponEnt:GetOwner() == nil or self.WeaponEnt:GetOwner():GetVelocity() == nil then 
		return
	else
	
	self.Position = self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)
	self.Forward = data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	
	local AddVel = self.WeaponEnt:GetOwner():GetVelocity()
	
	local emitter = ParticleEmitter(self.Position)
	if emitter != nil then	
		local particle = emitter:Add( "sprites/heatwave", self.Position - self.Forward * 4 )
		if particle != nil then
	
			particle:SetVelocity( 80 * self.Forward + 20 * VectorRand() + 1.05 * AddVel )
			particle:SetGravity( Vector( 0, 0, 100 ) )
			particle:SetAirResistance( 160 )

			particle:SetDieTime( math.Rand( 0.2, 0.25 ) )

			particle:SetStartSize( math.random( 25, 40 ) )
			particle:SetEndSize( 10 )

			particle:SetRoll( math.Rand( 180, 480 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
		
		for i = 1,4 do
			local particle = emitter:Add( "particle/particle_smokegrenade", self.Position )

				particle:SetVelocity( 36 * i * self.Forward + 2 * VectorRand() + AddVel )
				particle:SetAirResistance( 150 )
				particle:SetGravity( Vector(0, 0, math.Rand(50, 100) ) )

				particle:SetDieTime( math.Rand( 50, 80 ) )

				particle:SetStartAlpha( math.Rand( 15, 50 ) )
				particle:SetEndAlpha( 0 )

				particle:SetStartSize( math.Rand( 25, 55 ) )
				particle:SetEndSize( math.Rand( 45, 70 ) )

				particle:SetRoll( math.Rand( -25, 25 ) )
				particle:SetRollDelta( math.Rand( -0.05, 0.05 ) )

				particle:SetColor( 120, 120, 120 )
		end
		
		if math.random( 1, 2 ) == 1 then

			for j = 4,5 do

				for i = -1,4,7 do 

					local particle = emitter:Add( "effects/muzzleflash"..math.random( 1, 4 ), self.Position - 3 * self.Forward + 2 * j * i * self.Right)

						particle:SetVelocity( 60 * j * i * self.Right + AddVel )
						particle:SetGravity( AddVel )

						particle:SetDieTime( 0.1 )

						particle:SetStartAlpha( 150 )

						particle:SetStartSize( j )
						particle:SetEndSize( 4 * j )

						particle:SetRoll( math.Rand( 180, 480 ) )
						particle:SetRollDelta( math.Rand( -1, 1 ) )

						particle:SetColor( 255, 255, 255 )	
				end
			end

			for i = 4,8 do 

				local particle = emitter:Add( "effects/muzzleflash"..math.random( 1, 4 ), self.Position + 8 * self.Forward )

					particle:SetVelocity( 350 * self.Forward + 1.1 * AddVel )
					particle:SetAirResistance( 160 )

					particle:SetDieTime( 0.1 )

					particle:SetStartAlpha( 160 )
					particle:SetEndAlpha( 0 )

					particle:SetStartSize( 6 * i )
					particle:SetEndSize( 5 * i )

					particle:SetRoll( math.Rand( 180, 480 ) )
					particle:SetRollDelta( math.Rand( -1, 1) )

					particle:SetColor( 255, 255, 255 )	
			end
		end
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

print ('P LOADED')
