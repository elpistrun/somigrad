--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/mlg_weapons_1214787279/lua/effects/hg_weed/init.lua <
    > Callstack:  <
]]

-- "addons\\mlg_weapons_1214787279\\lua\\effects\\hg_weed\\init.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
function EFFECT:Init(data)
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	
	self.Position = data:GetOrigin()
	self.Forward = data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	
	local AddVel = 5//self.WeaponEnt:GetOwner():GetVelocity()
for i=0, 100 do
	local emitter = ParticleEmitter(self.Position)
	if emitter != nil then	
		local particle = emitter:Add( "hobo_gus/weed", self.Position - self.Forward * 4 )
		if particle != nil then

			particle:SetVelocity( 200 * self.Forward + 200 * VectorRand() + 5 * VectorRand() )
			particle:SetGravity( Vector( 0, 0, 0 ) )
			particle:SetAirResistance( 60 )

			particle:SetDieTime( math.Rand( 3, 4 ) )

			particle:SetStartSize( math.random( 5, 10 ) )
			particle:SetEndSize( 10 )

			particle:SetRoll( math.Rand( 180, 480 ) )
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
