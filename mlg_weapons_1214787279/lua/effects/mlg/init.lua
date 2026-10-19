--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/mlg_weapons_1214787279/lua/effects/mlg/init.lua <
    > Callstack:  <
]]

-- "addons\\mlg_weapons_1214787279\\lua\\effects\\mlg\\init.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
function EFFECT:Init(data)
	
	self.Position = data:GetOrigin()
	self.Forward = data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	
//for i=0, 1 do
	local emitter = ParticleEmitter(self.Position)
	if emitter != nil then	
			local MlgMat = {}
			MlgMat[1] = "texts/mlgpro"
			MlgMat[2] = "texts/1v1"
			MlgMat[3] = "texts/getrekt"
			MlgMat[4] = "texts/fite"
			MlgMat[5] = "texts/sampletext"
		local particle = emitter:Add( MlgMat[math.random(1,5)], self.Position - self.Forward * 4 )
		if particle != nil then

			particle:SetVelocity( 100 * self.Forward + 100 * VectorRand() + 5 * VectorRand() )
			particle:SetGravity( Vector( 0, 0, 100 ) )
			particle:SetAirResistance( 90 )

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
