--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/fireworks/entities/gf2_base_rocket_sh.lua <
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

-- "addons\\homigrad\\lua\\hinit\\fireworks\\entities\\gf2_base_rocket_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("gf2_base_rocket","base_entity")
if not ENT then return end

-- Rocket sounds are defined here
sound.Add( {
	name = "gf2_firework_engineloop",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = {90, 110},
	sound = "garrys_fireworks_2/fireworks/loops/rocket_engine.wav"
} )


ENT.Spawnable		            	 =  false     
ENT.AdminSpawnable		             =  false       

ENT.PrintName		                 =  ""            
ENT.Author			                 =  ""       
ENT.Contact			                 =  "" 
ENT.Category                         =  ""   

ENT.Model                            =  ""            
ENT.RocketTrail                      =  ""            
ENT.RocketBurnoutTrail               =  ""            
ENT.Effect                           =  ""                     
ENT.ExplosionSound                   =  ""            
ENT.StartSound                       =  ""            
ENT.ArmSound                         =  ""            
ENT.ActivationSound                  =  ""      
ENT.EngineSound                      =  "Missile.Ignite"  

ENT.SmartLaunch                      =  true     
ENT.Timed                            =  false 


ENT.ExplosionDamage                  =  0            
ENT.ExplosionRadius                  =  0                    
ENT.SpecialRadius                    =  0             
ENT.MaxIgnitionTime                  =  5             
ENT.Life                             =  20            
ENT.MaxDelay                         =  2                 
ENT.ImpactSpeed                      =  500           
ENT.Mass                             =  0   
ENT.EnginePower                      =  0             
ENT.FuelBurnoutTime                  =  0             
ENT.IgnitionDelay                    =  0                        
ENT.ArmDelay                         =  2             
ENT.ForceOrientation                 =  "NORMAL"     
ENT.DamageSound                      = "npc/roller/mine/rmine_blip3.wav"
ENT.ExplodeDelay                     =  6 
ENT.GBOWNER                          =  nil    
ENT.SkinNumber                       =  nil     
ENT.ShakeSettings = { ["ShakeTime"] = 1,
					  ["SoundAmp"] = 0.5,
					  ["SoundFreq"] = 25}


function ENT:Initialize()
	if (SERVER) then
		self:SetModel(self.Model)  
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType( ONOFF_USE )
		local phys = self:GetPhysicsObject() 
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
			phys:Wake()
		end

		self.Armed    = false
		self.Exploded = false
		self.Fired    = false
		self.Burnt    = false
		self.Ignition = false
		self.Arming   = false
		self.EnginePower_Mod = 0

		
		if self.SkinNumber != nil then
			self:SetSkin(self.SkinNumber)
		end
		if !(WireAddon == nil) then self.Inputs = Wire_CreateInputs(self, { "Arm", "Detonate", "Launch" }) end

	end
end

function ENT:TriggerInput(iname, value)
     if (!self:IsValid()) then return end
	 if (iname == "Detonate") then
         if (value >= 1) then
		     if (!self.Exploded and self.Armed) then
			     timer.Simple(math.Rand(0,self.MaxDelay),function()
				     if !self:IsValid() then return end
	                 self.Exploded = true
					 
			         self:Explode()
				 end)
		     end
		 end
	 end
	 if (iname == "Arm") then
         if (value >= 1) then
             if (!self.Exploded and !self.Armed and !self.Arming) then
			     self:EmitSound(self.ActivationSound)
                 self:Arm()
             end 
         end
     end		 
	 if (iname == "Launch") then 
	     if (value >= 1) then
		     if (!self.Exploded and !self.Burnt and !self.Ignition and !self.Fired) then
			     self:Launch()
				 
		     end
	     end
     end
end          

function ExplodeSPos(pos, soundfile)
	
	local ent = ents.Create("gf2_shockwave_sound_lowsh")
	ent:SetPos(pos)
	ent:Spawn()
	ent:Activate()
	ent.SOUND = soundfile
	ent.MAX_RANGE = 50000
	ent.SHOCKWAVE_INCREMENT = 100
	ent.ShakeSettings = { ["ShakeTime"] = 1,
						["SoundAmp"] = 0.8,
						["SoundFreq"] = 25}
						  
end

function ENT:Explode_Sound()
	if self.PlayedExploSound!=nil then return end
	if self.PlayedExploSound==nil then self.PlayedExploSound=true end
	local pos = self:GetPos()
	local ent = ents.Create("gf2_shockwave_sound_lowsh")
	ent:SetPos(pos)
	ent:Spawn()
	ent.Attacker = self.Attacker
	ent:Activate()
	ent.SOUND = self.ExplosionSound
	ent.MAX_RANGE = 50000
	ent.SHOCKWAVE_INCREMENT = 100
	ent.ShakeSettings = { ["ShakeTime"] = self.ShakeSettings["ShakeTime"],
						["SoundAmp"] = self.ShakeSettings["SoundAmp"],
						["SoundFreq"] = self.ShakeSettings["SoundFreq"]}
						  
end

function ENT:Explode_Shockwave()
end

function ENT:Explode()
	if not self.Exploded then return end
	local pos = self:LocalToWorld(self:OBBCenter())
	self:Explode_Sound()
	self:Explode_Shockwave()
	ParticleEffect(self.Effect,self:GetPos(),Angle(0,0,0),nil)
	self:Remove()
end

function ENT:OnTakeDamage(dmginfo)
	if !self:IsValid() then return end
	if self.Exploded then return end
	if (self.Life <= 0) then return end
	self:TakePhysicsDamage(dmginfo)
	
	if(GetConVar("gf2_fragility"):GetInt() >= 1) then  
		if(!self.Fired and !self.Burnt and !self.Arming and !self.Armed) then
			if(math.random(0,9) == 1) then
				self:Launch()
			else
				self:Arm()
			end
		end
	end
	if(self.Fired and !self.Burnt and self.Armed) then
		if (dmginfo:GetDamage() >= 2) then
			local phys = self:GetPhysicsObject()
			self:EmitSound(self.DamageSound)

		end
	end
	if(!self.Armed) then return end
	self.Life = self.Life - dmginfo:GetDamage()
	if (self.Life <= 0) then 
	timer.Simple(math.Rand(0,self.MaxDelay),function()
		if !self:IsValid() then return end 
		self.Exploded = true
		self:Explode()

	end)
	end
end

function ENT:PhysicsCollide( data, physobj )
     if(self.Exploded) then return end
     if(!self:IsValid()) then return end
	 if(self.Life <= 0) then return end
	 
	 if(!self.Armed) then return end
		
	 if (data.Speed > self.ImpactSpeed )then
		 self.Exploded = true
		 self:Explode()
	 end
	 if (self.Ignition) then
		self.Exploded = true
		self:Explode()
	 end
end

function ENT:Launch()
	if(self.Exploded) then return end
	if(self.Burned) then return end
	if(self.Fired) then return end

	local phys = self:GetPhysicsObject()
	if !phys:IsValid() then return end

	self.Fired = true
	if(self.SmartLaunch) then
		constraint.RemoveAll(self)
	end
	timer.Simple(self.ExplodeDelay, function()
		if !self:IsValid() then return end
		self.Exploded=true
		self:Explode()
	end)
	timer.Simple(0.01,function()
		if not self:IsValid() then return end
		if(phys:IsValid()) then
			phys:Wake()
			phys:EnableMotion(true)
			self.Ignition = true
			self:EmitSound(self.StartSound, 100, 100)
			
			ParticleEffectAttach(self.RocketTrail,PATTACH_ABSORIGIN_FOLLOW,self,1)
			timer.Simple(0.4, function()
				if !self:IsValid() then return end
				self:EmitSound(self.EngineSound, 100, 100)
			end)
			timer.Simple(1, function()
				if !self:IsValid() then return end
				self.Armed    = true
				
				
			end)
		end
	end) 
	timer.Simple(self.FuelBurnoutTime, function()
		if !self:IsValid() then return end
		self.Burnt=true
		self:StopParticles()
		self:StopSound(self.EngineSound)
	end)
end

function ENT:EnginePowerMod()
	if !self:IsValid() then return end
	
	self.EnginePower_Mod = math.Clamp(self.EnginePower_Mod + 0.01, 0, 1)
end

function ENT:Think()
	if (SERVER) then
		if(self.Burnt) then return end
		if(!self.Ignition) then return end -- if there wasn't ignition, we won't fly
		if(self.Exploded) then return end -- if we exploded then what the fuck are we doing here
		if(!self:IsValid()) then return end -- if we aren't good then something fucked up
		self:EnginePowerMod()
		
		
		local phys = self:GetPhysicsObject()  
		local thrustpos = self:GetPos()
		if(self.ForceOrientation == "RIGHT") then
			phys:AddVelocity(self:GetRight() * self.EnginePower) -- Continuous engine impulse
		elseif(self.ForceOrientation == "LEFT") then
			phys:AddVelocity(self:GetRight() * -self.EnginePower) -- Continuous engine impulse
		elseif(self.ForceOrientation == "UP") then
			phys:AddVelocity(self:GetUp() * self.EnginePower) -- Continuous engine impulse
		elseif(self.ForceOrientation == "DOWN") then 
			phys:AddVelocity(self:GetUp() * -self.EnginePower) -- Continuous engine impulse
		elseif(self.ForceOrientation == "INV") then
			phys:AddVelocity(self:GetForward() * -self.EnginePower) -- Continuous engine impulse
		else
			phys:AddVelocity(self:GetForward() * (self.EnginePower*self.EnginePower_Mod)) -- Continuous engine impulse
		end


		self:NextThink(CurTime() + 0.01)
		return true
	end
end

function ENT:Arm()
     if(!self:IsValid()) then return end
	 if(self.Armed) then return end
	 self.Arming = true
	 
	 timer.Simple(self.ArmDelay, function()
	     if not self:IsValid() then return end 
	     self.Armed = true
		 self.Arming = false
		 self:EmitSound(self.ArmSound)
		 if(self.Timed) then
	         timer.Simple(self.Timer, function()
	             if !self:IsValid() then return end 
			     self.Exploded = true
			     self:Explode()
	         end)
		 end
	 end)
end	 

function ENT:Use( activator, caller )
	activator:PickupObject(self)

     if(self.Exploded) then return end
	 if(self.Dumb) then return end
	 if activator:KeyDown(IN_WALK) then
         if(self:IsValid()) then
             if (!self.Exploded) and (!self.Burnt) and (!self.Fired) then
	             if (activator:IsPlayer()) then
					activator:DropObject()

					self.Attacker = activator
                    self:EmitSound(self.ActivationSound)
                    self:Launch(ac)
		         end
	         end
         end
	 end
end

function ENT:OnRemove()
     self:StopSound(self.EngineSound)
	 self:StopParticles()
end

if ( CLIENT ) then
     function ENT:Draw()
         self:DrawModel()
		 if !(WireAddon == nil) then Wire_Render(self.Entity) end
     end
end

function ENT:OnRestore()
     Wire_Restored(self.Entity)
end

function ENT:BuildDupeInfo()
     return WireLib.BuildDupeInfo(self.Entity)
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
     WireLib.ApplyDupeInfo( ply, ent, info, GetEntByID )
end

function ENT:PreEntityCopy()
     local DupeInfo = self:BuildDupeInfo()
     if(DupeInfo) then
         duplicator.StoreEntityModifier(self.Entity,"WireDupeInfo",DupeInfo)
     end
end

function ENT:PostEntityPaste(Player,Ent,CreatedEntities)
     if(Ent.EntityMods and Ent.EntityMods.WireDupeInfo) then
         Ent:ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
     end
end
