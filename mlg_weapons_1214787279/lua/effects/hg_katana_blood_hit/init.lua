--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/mlg_weapons_1214787279/lua/effects/hg_katana_blood_hit/init.lua <
    > Callstack:  <
]]

-- "addons\\mlg_weapons_1214787279\\lua\\effects\\hg_katana_blood_hit\\init.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
function EFFECT:Init(data)
	
	//if not IsValid(data:GetEntity()) then return end
	//if not IsValid(data:GetEntity():GetOwner()) then return end
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	
	//if self.WeaponEnt == nil or self.WeaponEnt:GetOwner() == nil or self.WeaponEnt:GetOwner():GetVelocity() == nil then 
		//return
	//else
	
	//self.Position = self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)
	self.Position = data:GetOrigin()
	self.Forward = data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	
	local AddVel = 5//self.WeaponEnt:GetOwner():GetVelocity()
	local emitter = ParticleEmitter(data:GetOrigin())
	
for i=0, 25 do
			local Blood = {}
			Blood[1] = "decals/blood2"
			Blood[2] = "decals/blood7"
			Blood[3] = "decals/blood3"
			Blood[4] = "decals/blood1"
			local particle = emitter:Add( Blood[math.random(1,4)], self.Position - self.Forward * 4, (Color(255,0,0,25)) )
			particle:SetVelocity( 100 * self.Forward + 100 * VectorRand() + 5 * VectorRand() )
			particle:SetGravity( Vector( 0, 0, 0 ) )
			particle:SetAirResistance( 60 )
			//particle:SetColor(Color(255,0,0,25))

			particle:SetDieTime( math.Rand( 0.1, 0.2 ) )

			particle:SetStartSize( math.random( 3, 8 ) )
			particle:SetEndSize( 10 )

			particle:SetRoll( math.Rand( 180, 480 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			//particle:SetBounce( 1 )
			particle:SetCollide( true )

end
for i=0, 66 do
			local Blood = {}
			Blood[1] = "decals/blood2"
			Blood[2] = "decals/blood7"
			Blood[3] = "decals/blood3"
			Blood[4] = "decals/blood1"
			local particle = emitter:Add( Blood[math.random(1,4)], self.Position - self.Forward * 4, (Color(255,0,0,25)) )
			particle:SetVelocity( 100 * self.Forward + 100 * VectorRand() + 5 * VectorRand() )
			particle:SetGravity( Vector( 0, 0, -200 ) )
			particle:SetAirResistance( 60 )
			//particle:SetColor(Color(255,0,0,25))

			particle:SetDieTime( math.Rand( 6, 9 ) )

			particle:SetStartSize( math.random( 3, 8 ) )
			particle:SetEndSize( 10 )

			particle:SetRoll( math.Rand( 180, 480 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			//particle:SetBounce( 1 )
			particle:SetCollide( true )

end
for i=0, 2 do
			local Blood = {}
			Blood[1] = "decals/blood2"
			Blood[2] = "decals/blood7"
			Blood[3] = "decals/blood3"
			Blood[4] = "decals/blood1"
			local particle = emitter:Add( Blood[math.random(1,4)], self.Position - self.Forward * 4, (Color(255,0,0,25)) )
			particle:SetVelocity( 100 * self.Forward + 200 * VectorRand() + 5 * VectorRand() )
			particle:SetGravity( Vector( 0, 0, 0 ) )
			particle:SetAirResistance( 60 )
			//particle:SetColor(Color(255,0,0,25))

			particle:SetDieTime( math.Rand( 0.1, 0.2 ) )

			particle:SetStartSize( math.random( 30, 35 ) )
			particle:SetEndSize( 10 )

			particle:SetRoll( math.Rand( 180, 480 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			//particle:SetBounce( 1 )
			particle:SetCollide( true )


end
emitter:Finish()
end
//end

function EFFECT:Think()

	return false
end


function EFFECT:Render()
end
