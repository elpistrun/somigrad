--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/fireworks/entities/gf2_cw_catherine_w_01_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad\\lua\\hinit\\fireworks\\entities\\gf2_cw_catherine_w_01_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("gf2_cw_catherine_w_01","gf2_base_adv")
if not ENT then return end

ENT.Spawnable		= true
ENT.AdminOnly		= false

ENT.PrintName		                 =  "Eye of Sauron"
ENT.Author			                 =  "Rogue Cheney"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "G-Works 2 - Wheels"
ENT.Model                            =  "models/models/gf2/rogue_cheney/catherinewheels/catherine_wheel_01.mdl"                      
ENT.Mass                             =  50
ENT.WheelEffect                      = "gf2_wheel_01_eyeofsauron_main"
ENT.GBOWNER                          =  nil             

function ENT:SpawnFunction( ply, tr )
     if ( !tr.Hit ) then return end
	 self.GBOWNER = ply
	 ply:ChatPrint("Axis this to a wall!")
     local ent = ents.Create( self.ClassName )
	 ent:SetPhysicsAttacker(ply)
     ent:SetPos( tr.HitPos + tr.HitNormal * 16 ) 
     ent:Spawn()
     ent:Activate()

     return ent
end


function ENT:Initialize()
	self.Sound=nil
	if (SERVER) then
		self:LoadModel()
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetUseType( ONOFF_USE ) 
		local phys = self:GetPhysicsObject()
		local skincount = self:SkinCount()
		
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
			phys:Wake()
		end

		self.Armed    = false
		self.Exploded = false
		self.Used     = false
		self.Arming   = false
		self:SetSkin(0)
		self.Time = 0
		
		

	end

	self:CreateLoop()
end

function ENT:CreateLoop()
	local sound = Sound("garrys_fireworks_2/fireworks/loops/wheel_spin.wav")

	CSPatch = CreateSound(self, sound)
	CSPatch:Play()
	
	self.Sound = CSPatch
end

function ENT:UpdateSound()


	local ang_vel = self:GetPhysicsObject():GetAngleVelocity()
	
	local pitch = ang_vel.x/24.333
	pitch = math.Clamp(math.abs(pitch),0,255)
	
	local volume = 200/ang_vel.x 
	local volume = 1-math.Clamp(math.abs(volume),0,1)
	self.Sound:ChangePitch(pitch, 0)
	self.Sound:ChangeVolume(volume, 0)
	
	
	
end
if ( CLIENT ) then
	
	function ENT:Draw()
		self:DrawModel()
		
		if !(WireAddon == nil) then Wire_Render(self.Entity) end
	end
end

function ENT:TriggerInput(iname, value)
     if (!self:IsValid()) then return end 
end 

function ENT:Think()
	
	if (SERVER) then
		if !self:IsValid() then return end
		self:UpdateSound()
		if (self.IsIgnited) then self.Time = self.Time + engine.TickInterval() end
		
		self:NextThink( CurTime()+0.01 )
		return true
	end
end



function ENT:Explode()
    if !self.Exploded then return end
	ParticleEffect("gf2_misc_neighbor_hater_main_explosion", self:GetPos(), Angle(0,0,0), nil )
	self:Remove()
end

function ENT:OnTakeDamage(dmginfo)
     if self.Exploded then return end
end

function ENT:PhysicsCollide( data, physobj )
end
function ENT:GenerateUniqueID()
	local str = ""
	
	for i=0,20 do
		str = str..string.char(math.random(67,120))
	
	end
	return str
	
end
function ENT:Spin()
	local phys = self:GetPhysicsObject()

	timer.Create(self:GenerateUniqueID(), 0.01, 3400, function()
		if !phys:IsValid() then return end
		phys:AddAngleVelocity(Vector(10,0,0))	
		
	end)
	

		
			

	
end
function ENT:Arm()
	self.IsIgnited = true
	self:SetSkin(1)
	
	sound.Add( {
		name = "emitsound",
		channel = CHAN_STATIC,
		volume = 1.0,
		level = 100,
		pitch = { 100, 100 },
		sound = "garrys_fireworks_2/fireworks/catherinewheels/wheel_01.mp3"
	} )
	if self.PlayedSound==nil then 
		ParticleEffectAttach( self.WheelEffect, PATTACH_POINT_FOLLOW, self, self:LookupAttachment("attachment_nozzle") ) 
		self:EmitSound("emitsound", 100, 100) 
		self.PlayedSound=true 
		self:Spin()
		timer.Simple(34, function()
			if !self:IsValid() then return end
			self.Sound:Stop()
		end)
	
		

	end
	


end	 

ENT.DelayUse = 1

function ENT:OnRemove()
	if self.Sound==nil then return end
	self.Sound:Stop()
	self:StopSound("emitsound")
end






