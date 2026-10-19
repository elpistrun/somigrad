--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/mlg_weapons_1214787279/lua/effects/m0n3y_rain/init.lua <
    > Callstack:  <
]]

-- "addons\\mlg_weapons_1214787279\\lua\\effects\\m0n3y_rain\\init.lua"
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
	
	local AddVel = 5//self.WeaponEnt:GetOwner():GetVelocity()
for i=1, 1 do
	local emitter = ParticleEmitter(self.Position)
	if emitter != nil then	
		local particle = emitter:Add( "hobo_gus/hundred_dollar", self.Position - self.Forward * 4 )
		if particle != nil then

			particle:SetVelocity( 200 * self.Forward + 200 * self.Forward + 5 * self.Forward )
			particle:SetGravity( Vector( 0, 0, -600 ) )
			particle:SetAirResistance( 60 )
			
			//particle:SetLifeTime( math.Rand( 45, 50 ) )
			particle:SetDieTime( math.Rand( 45, 50 ) )

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			
			particle:SetStartSize( 8 )
			particle:SetEndSize( 8 )

			particle:SetRoll( math.Rand( 180, 480 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetBounce( 0.5 )
			particle:SetCollide( true )
		end
	emitter:Finish()
	end
	end
end
end


function EFFECT:Think()

	return false
end


function EFFECT:Render()
end
