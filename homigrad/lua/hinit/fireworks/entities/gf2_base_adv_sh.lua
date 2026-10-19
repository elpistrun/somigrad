--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/fireworks/entities/gf2_base_adv_sh.lua <
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

-- "addons\\homigrad\\lua\\hinit\\fireworks\\entities\\gf2_base_adv_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("gf2_base_adv","base_entity")
if not ENT then return end

local Models = {}
Models[1]                            =  "testmodel"

local ExploSnds = {}
ExploSnds[1]                         =  "BaseExplosionEffect.Sound"

local damagesound                    =  "weapons/rpg/shotdown.wav"

ENT.Spawnable		            	 =  false         
ENT.AdminSpawnable		             =  false       

ENT.PrintName		                 =  "Name"        
ENT.Author			                 =  "Rogue Cheney"      
ENT.Contact			                 =  "Rogue Cheney" 
ENT.Category                         =  ""            

ENT.Model                            =  ""            
ENT.Effect                           =  ""                       
ENT.ExplosionSound                   =  ""            
ENT.ArmSound                         =  ""            
ENT.ActivationSound                  =  ""    

ENT.ShouldUnweld                     =  false         
ENT.ShouldIgnite                     =  false         
ENT.ShouldExplodeOnImpact            =  false         
ENT.Flamable                         =  false                     
ENT.Timed                            =  false    

ENT.ExplosionDamage                  =  0             
ENT.PhysForce                        =  0             
ENT.ExplosionRadius                  =  0            
ENT.SpecialRadius                    =  0             
ENT.MaxIgnitionTime                  =  5             
ENT.Life                             =  20           
ENT.MaxDelay                         =  2             
ENT.TraceLength                      =  500           
ENT.ImpactSpeed                      =  500          
ENT.Mass                             =  0                     
ENT.ArmDelay                         =  2                      
ENT.Timer                            =  0

ENT.GBOWNER                          =  nil            


function ENT:Initialize()
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
	 if (skincount > 0) then
	     self:SetSkin(math.random(0,skincount))
	 end
	 self.Armed    = false
	 self.Exploded = false
	 self.Used     = false
	 self.Arming   = false

	  if !(WireAddon == nil) then self.Inputs   = Wire_CreateInputs(self, { "Arm", "Detonate" }) end
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
end 

function ENT:LoadModel()
     if self.UseRandomModels then
	     self:SetModel(table.Random(Models))
	 else
	     self:SetModel(self.Model)
	 end
end
	 

function ENT:Explode_Sound()
	if self.PlayedExploSound!=nil then return end
	if self.PlayedExploSound==nil then self.PlayedExploSound=true end
	local pos = self:GetPos()
	local ent = ents.Create("gf2_shockwave_sound_lowsh")
	ent:SetPos(pos)
	ent:Spawn()
	ent:Activate()
	ent.SOUND = self.ExplosionSound
	ent.MAX_RANGE = 50000
	ent.SHOCKWAVE_INCREMENT = 100
	ent.ShakeSettings = { ["ShakeTime"] = 1,
						["SoundAmp"] = 2,
						["SoundFreq"] = 2}
						  
end



function ENT:Explode()
     if !self.Exploded then return end
	 local pos = self:GetPos()
     self:Explode_Sound()
	 
	 
	
	ParticleEffect(self.Effect,pos,Angle(0,0,0),nil)
	self:Remove()
end

function ENT:OnTakeDamage(dmginfo)
     if self.Exploded then return end
     self:TakePhysicsDamage(dmginfo)
	 
	 local phys = self:GetPhysicsObject()
	 
     if (self.Life <= 0) then return end
	 if(GetConVar("gf2_fragility"):GetInt() >= 1) then
	     if(!self.Armed and !self.Arming) then
			self.Attacker = dmginfo:GetAttacker()
	         self:Arm()
	     end
	 end
	 
     if(!self.Armed) then return end

	 if self:IsValid() then
	     self.Life = self.Life - dmginfo:GetDamage()
		 if (self.Life <= self.Life/2) and !self.Exploded and self.Flamable then
		     self:Ignite(self.MaxDelay,0)
		 end
		 if (self.Life <= 0) then 
		     timer.Simple(math.Rand(0,self.MaxDelay),function()
			     if !self:IsValid() then return end 
			     self.Exploded = true
			     self:Explode()
			 end)
	     end
	end
end

function ENT:PhysicsCollide( data, physobj )
     if(self.Exploded) then return end
     if(!self:IsValid()) then return end
	 if(self.Life <= 0) then return end
	 if(GetConVar("gf2_fragility"):GetInt() >= 1) then
	     if(data.Speed > self.ImpactSpeed) then
	 	     if(!self.Armed and !self.Arming) then
		         self:EmitSound(damagesound)
	             self:Arm()
	         end
		 end
	 end
	 if(!self.Armed) then return end
     if self.ShouldExplodeOnImpact then
	     if (data.Speed > self.ImpactSpeed ) then
			 self.Exploded = true
			 self:Explode()
		 end
	 end
end

function ENT:Arm()
     if(!self:IsValid()) then return end
	 if(self.Exploded) then return end
	 if(self.Armed) then return end
	 self.Arming = true
	 self.Used = true
	 timer.Simple(self.ArmDelay, function()
	     if !self:IsValid() then return end 
	     self.Armed = true
		 self.Arming = false
		 self:EmitSound(self.ArmSound)
		 if(self.Timed) then
	         timer.Simple(self.Timer, function()
	             if !self:IsValid() then return end 
				 timer.Simple(math.Rand(0,self.MaxDelay),function()
			         if !self:IsValid() then return end 
			         self.Exploded = true
			         self:Explode()
				 end)
	         end)
	     end
	 end)
end	 

function ENT:Use( activator, caller )
	activator:PickupObject(self)

     if(self.Exploded) then return end
     if activator:KeyDown(IN_WALK) then
	     if(GetConVar("gf2_easyuse"):GetInt() >= 1) then
	         if(!self.Armed) then
		         if(!self.Exploded) and (!self.Used) then
		             if(activator:IsPlayer()) then
						self.Attacker = activator
                         self:EmitSound(self.ActivationSound)
                         self:Arm()
		             end
	             end
             end
         end
	 end
end

function ENT:OnRemove()
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
    return WireLib and WireLib.BuildDupeInfo(self.Entity)
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
    if WireLib then WireLib.ApplyDupeInfo( ply, ent, info, GetEntByID ) end
end

function ENT:PreEntityCopy()
     local DupeInfo = self:BuildDupeInfo()
     if(DupeInfo) then
         duplicator.StoreEntityModifier(self,"WireDupeInfo",DupeInfo)
     end
end

function ENT:PostEntityPaste(Player,Ent,CreatedEntities)
     if(Ent.EntityMods and Ent.EntityMods.WireDupeInfo) then
         Ent:ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
     end
end

