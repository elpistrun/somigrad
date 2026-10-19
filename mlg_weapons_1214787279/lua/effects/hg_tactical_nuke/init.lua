--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/mlg_weapons_1214787279/lua/effects/hg_tactical_nuke/init.lua <
    > Callstack:  <
]]

-- "addons\\mlg_weapons_1214787279\\lua\\effects\\hg_tactical_nuke\\init.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
function EFFECT:Init(data)
	
	//self.Position = self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)
	self.Position = data:GetOrigin()
	self.Forward = data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	
			local light = DynamicLight( 0 )
	if( light ) then
		
		light.Pos = self.Position
		light.Size = 1110000
		light.Decay = 0
		light.R = 255
		light.G = 150
		light.B = 150
		light.Brightness = 2550
		light.DieTime = CurTime() + 5

	end
			local light2 = DynamicLight( 0 )
	if( light2 ) then
		
		light2.Pos = self.Position
		light2.Size = 1000000
		light2.Decay = 0
		light2.R = 255
		light2.G = 150
		light2.B = 150
		light2.Brightness = 7
		light2.DieTime = CurTime() + 20

	end
	
	local AddVel = 5//self.WeaponEnt:GetOwner():GetVelocity()
	local emitter = ParticleEmitter(self.Position)
for i=0, 45 do
	if emitter != nil then	
				local FlameMat = {}
			FlameMat[1] = "sprites/flamelet4"
			FlameMat[2] = "sprites/flamelet5"
			FlameMat[3] = "sprites/flamelet1"
			FlameMat[4] = "sprites/flamelet3"
		local particle = emitter:Add( FlameMat[math.random(1,4)], self.Position - self.Forward * 4, (Color(255,0,0,25)) )
		if particle != nil then

			particle:SetVelocity( 700 * VectorRand() + 700 * VectorRand() + 450 * VectorRand() )
			particle:SetGravity( Vector( 0, 0, 160 ) )
			particle:SetAirResistance( 75 )
			//particle:SetColor(Color(255,0,0,25))

			particle:SetDieTime( math.Rand( 40, 45 ) )

			particle:SetStartSize( math.random( 550, 650 ) )
			particle:SetEndSize( 1 )

			particle:SetRoll( math.Rand( 180, 480 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetBounce( 2 )
			particle:SetCollide( false )
		end
	
	end
end
for i=0, 45 do
	if emitter != nil then	
				local FlameMat = {}
			FlameMat[1] = "sprites/flamelet4"
			FlameMat[2] = "sprites/flamelet5"
			FlameMat[3] = "sprites/flamelet1"
			FlameMat[4] = "sprites/flamelet3"
		local particle = emitter:Add( FlameMat[math.random(1,4)], self.Position - self.Forward * 4, (Color(255,0,0,25)) )
		if particle != nil then

			particle:SetVelocity( 100 * VectorRand() + 100 * VectorRand() + 1000 * VectorRand() )
			particle:SetGravity( Vector( 0, 0, 100 ) )
			particle:SetAirResistance( 75 )
			//particle:SetColor(Color(255,0,0,25))

			particle:SetDieTime( math.Rand( 40, 45 ) )

			particle:SetStartSize( math.random( 350, 450 ) )
			particle:SetEndSize( 1 )

			particle:SetRoll( math.Rand( 180, 480 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetBounce( 2 )
			particle:SetCollide( false )
		end
	
	end
end
for i=0, 150 do
	if emitter != nil then	
		local particle = emitter:Add( "particle/particle_smoke_dust", self.Position - self.Forward * 4, (Color(255,0,0,25)) )
		if particle != nil then

			particle:SetVelocity( 800 * self.Forward + 2000 * VectorRand() + 5 * VectorRand() )
			particle:SetGravity( Vector( 0, 0, -70 ) )
			particle:SetAirResistance( 50 )
			//particle:SetColor(Color(255,0,0,25))

			particle:SetDieTime( math.Rand( 20, 30 ) )

			particle:SetStartSize( 400 )
			particle:SetEndSize( 70 )

			particle:SetRoll( math.Rand( 180, 480 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetBounce( 1 )
			particle:SetCollide( true )
		end
	
	end
end
for i=0, 500 do
	if emitter != nil then	
		local particle = emitter:Add( "particle/particle_smoke_dust", self.Position - self.Forward * 4, (Color(255,255,255,25)) )
		if particle != nil then

			particle:SetVelocity( 100 * self.Forward + 500 * VectorRand() + 5 * VectorRand() )
			particle:SetGravity( Vector( 0, 0, -500 ) )
			particle:SetAirResistance( 0 )
			//particle:SetColor(Color(255,0,0,25))

			particle:SetDieTime( math.Rand( 20, 30 ) )

			particle:SetStartSize( 900 )
			particle:SetEndSize( 70 )

			particle:SetRoll( math.Rand( 180, 480 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetBounce( 1 )
			particle:SetCollide( true )
		end
	
	end
end
for i=0, 150 do
	if emitter != nil then	
				local FlameMat = {}
			FlameMat[1] = "sprites/flamelet4"
			FlameMat[2] = "sprites/flamelet5"
			FlameMat[3] = "sprites/flamelet1"
			FlameMat[4] = "sprites/flamelet3"
		local particle = emitter:Add( FlameMat[math.random(1,4)], self.Position - self.Forward * 4, (Color(255,0,0,25)) )
		if particle != nil then

			particle:SetVelocity( 500 * self.Forward + 500 * VectorRand() + 5 * VectorRand() )
			particle:SetGravity( Vector( 0, 0, -100 ) )
			particle:SetAirResistance( 1 )
			//particle:SetColor(Color(255,0,0,25))

			particle:SetDieTime( math.Rand( 90, 100 ) )

			particle:SetStartSize( math.random( 50, 60 ) )
			particle:SetEndSize( 1 )

			particle:SetRoll( math.Rand( 180, 480 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetBounce( 1 )
			particle:SetCollide( true )
		end
	
	end
end
for i=0, 150 do
	if emitter != nil then	
				local FlameMat = {}
			FlameMat[1] = "sprites/flamelet4"
			FlameMat[2] = "sprites/flamelet5"
			FlameMat[3] = "sprites/flamelet1"
			FlameMat[4] = "sprites/flamelet3"
		local particle = emitter:Add( FlameMat[math.random(1,4)], self.Position - self.Forward * 4, (Color(255,0,0,25)) )
		if particle != nil then

			particle:SetVelocity( 70 * self.Forward + 3000 * VectorRand() + 500 * VectorRand() )
			particle:SetGravity( Vector( 0, 0, -10 ) )
			particle:SetAirResistance( 100 )
			//particle:SetColor(Color(255,0,0,25))

			particle:SetDieTime( math.Rand( 35, 40 ) )

			particle:SetStartSize( math.random( 650, 700 ) )
			particle:SetEndSize( 1 )

			particle:SetRoll( math.Rand( 180, 480 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetBounce( 1 )
			particle:SetCollide( true )
		end
	
	end
	
end
emitter:Finish()
end
//end

function EFFECT:Think()

	return false
end


function EFFECT:Render()
end
