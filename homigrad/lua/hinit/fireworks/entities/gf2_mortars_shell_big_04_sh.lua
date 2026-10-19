--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/fireworks/entities/gf2_mortars_shell_big_04_sh.lua <
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

-- "addons\\homigrad\\lua\\hinit\\fireworks\\entities\\gf2_mortars_shell_big_04_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("gf2_mortars_shell_big_04","gf2_base_rocket")
if not ENT then return end
ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  false

ENT.PrintName		                 =  "100mm Shell 04"
ENT.Author			                 =  "Rogue"
ENT.Contact			                 =  "baldursgate3@gmail.com"
ENT.Category                         =  "G-Works 2 - Mortars + Shells"

ENT.Model                            =  "models/models/gf2/rogue_cheney/mortars/mortarshell_03.mdl"
ENT.RocketTrail                      =  ""
ENT.RocketBurnoutTrail               =  "firework_burnout"
ENT.Effect                           =  "gf2_mortar_shell_big_03_explosion_main_green"

ENT.ExplosionSound                   =  "garrys_fireworks_2/fireworks/explosions/mortar_explosion_02.mp3"        
ENT.StartSound                       =  "garrys_fireworks_2/fireworks/launch/rocket_launch_01.wav"                        
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "buttons/button14.wav"  
ENT.EngineSound                      =  "gf2_firework_engineloop"  
ENT.SmartLaunch                      =  false
ENT.Timed                            =  false 

ENT.ExplosionRadius                  =  800                                  
ENT.MaxIgnitionTime                  =  0           
ENT.Life                             =  20            
ENT.MaxDelay                         =  0           
ENT.TraceLength                      =  100             
ENT.Mass                             =  100
ENT.EnginePower                      =  50
ENT.FuelBurnoutTime                  =  1     
ENT.IgnitionDelay                    =  0           
ENT.ArmDelay                         =  0.1                      
ENT.ForceOrientation                 =  "UP"
ENT.Timer                            =  0
ENT.ExplodeDelay                     =  4
ENT.GBOWNER                          =  nil
ENT.SkinNumber                       =  0


function ENT:SpawnFunction( ply, tr )
     if ( !tr.Hit ) then return end
	 self.GBOWNER = ply
     local ent = ents.Create( self.ClassName )
	 ent:SetPhysicsAttacker(ply)
     ent:SetPos( tr.HitPos + tr.HitNormal * 16 ) 
     ent:Spawn()
     ent:Activate()
	
     return ent
end


function ENT:OnRemove()
	if (SERVER) then

		self:StopParticles()
		
	
	end
end


function ENT:Explode()
	if (SERVER) then
		if !self:IsValid() then return end
		ExplodeSPos(self:GetPos(), self.ExplosionSound)
		ParticleEffect(self.Effect,self:GetPos(),Angle(0,0,0),nil)
		
		
		self:Remove()
	end
end

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

function ENT:OnTakeDamage(dmginfo)
end

function ENT:PhysicsCollide( data, physobj )
end

function ENT:Launch()
end

function ENT:EnginePowerMod()
end

function ENT:Think()
	if (SERVER) then
		if(!self:IsValid()) then return end -- if we aren't good then something fucked up
		self:NextThink(CurTime() + 0.01)
		return true
	end
end

function ENT:Arm()
end	 

function ENT:Use( activator, caller )

end









