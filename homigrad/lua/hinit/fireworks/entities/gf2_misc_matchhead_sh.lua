--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/fireworks/entities/gf2_misc_matchhead_sh.lua <
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

-- "addons\\homigrad\\lua\\hinit\\fireworks\\entities\\gf2_misc_matchhead_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("gf2_misc_matchhead","gf2_base_adv")
if not ENT then return end

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Match"
ENT.Author			                 =  "Rogue"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "G-Works 2 - Misc"

ENT.Model                            =  "models/models/gf2/rogue_cheney/misc/matchhead.mdl"           
ENT.Effect                           =  ""                  
ENT.EffectAir                        =  ""   
ENT.EffectWater                      =  "" 
ENT.ExplosionSound                   =  ""                   
ENT.ParticleTrail                    =  ""

ENT.ShouldUnweld                     =  false
ENT.ShouldIgnite                     =  false      
ENT.ShouldExplodeOnImpact            =  false         

ENT.Flamable                         =  false        
ENT.UseRandomSounds                  =  false       
ENT.UseRandomModels                  =  false

ENT.ExplosionDamage                  =  1          
ENT.PhysForce                        =  2           
ENT.ExplosionRadius                  =  3           
ENT.SpecialRadius                    =  4            
ENT.MaxIgnitionTime                  =  1           
ENT.Life                             =  500000          
ENT.MaxDelay                         =  0          
ENT.TraceLength                      =  0        
ENT.ImpactSpeed                      =  0           
ENT.Mass                             =  5

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

function ENT:SpawnFunction( ply, tr )
     if ( !tr.Hit ) then return end
	 self.GBOWNER = ply
     local ent = ents.Create( self.ClassName )
	 ent:SetPhysicsAttacker(ply)
     ent:SetPos( tr.HitPos + tr.HitNormal * 106 ) 
     ent:Spawn()
     ent:Activate()

     return ent
end

function ENT:Initialize()
 if (SERVER) then
     self:LoadModel()
	 self:PhysicsInit( SOLID_VPHYSICS )
	 self:SetSolid( SOLID_VPHYSICS )
	 self:SetMoveType( MOVETYPE_VPHYSICS )
	 self:SetUseType( ONOFF_USE ) -- doesen't fucking work
	 local phys = self:GetPhysicsObject()
	 local skincount = self:SkinCount()
	 if (phys:IsValid()) then
		 phys:SetMass(self.Mass)
		 phys:Wake()
     end
	 if (skincount > 0) then
	     self:SetSkin(math.random(0,skincount))
	 end
	 self.Ignition_Stack = 0
	 self.Ignited=false
	 self.Ignition_Time=0
	 self.MatchHeadPos={0,0,0}
	 self.HasBurned=false
	 self.mod=self:GetPos()
	end
end

function ENT:PhysicsCollide( data, physobj )
	if SERVER then
		if self.Ignited==false then
			local toucher = data.HitEntity
			if self.speed!=nil then
			if (toucher:IsWorld() or toucher:GetPhysicsObject():IsValid()) and self.speed > 20 then
				self:EmitSound("garrys_fireworks_2/fireworks/misc/strike.wav", 50, 100)
				self.Ignition_Stack = self.Ignition_Stack + 0.1
			end
			end
		end
	end
end

function ENT:MatchIgnite()
	if SERVER then
		ParticleEffectAttach( "matchhead_ignition", PATTACH_POINT_FOLLOW, self, 0 )
	end
end
function ENT:Use()
end


function ENT:UpdateFlamePos()

	if SERVER then
		if self.IsBurning==true and self.HasBurned==false then
			self:CheckSurrounding()
			local flame_pos = 23-(self.Ignition_Time*(2.5/4))
			local mod = self:GetPos() - 18 * self:GetUp() + -3.5 * self:GetForward() + flame_pos * self:GetUp()
			self.mod = mod
			for k, v in pairs(ents.FindInSphere(mod, 6)) do
				if v:GetClass()=="gf2_matchhead" then
					local distance = self:GetPos():Distance( v:GetPos() )
					if math.random(1,math.Round(distance/2))==1 then
						v.Ignition_Stack=v.Ignition_Stack+0.2
					end
					
				elseif v:IsPlayer() or v:IsNPC() then
					v:Ignite(2, 0)
				end
			end
		end
	end
end

function ENT:CheckSurrounding()
	--[[
	for k, v in pairs(ents.FindInSphere(self.mod, 8)) do
		if v:GetClass()=="gf2_matchhead" or string.StartWith(tostring(v:GetClass()), "gf2_") or v:GetClass()=="gf2_ent_fire" and (v:IsPlayer() or v:IsNPC()) then
		
		else
			
			
		
			if v.EntFired==nil and v:GetClass()!="gf2_ent_fire" and self:CountFires()<150 then
				

				if (v:IsValid() and v:GetPhysicsObject():IsValid() and v:GetClass()!="gf2_matchhead") and (v.EntFired!=true and v:GetClass()!="gf2_ent_fire" and v:GetClass()!="entityflame")  then 
	
					v:Ignite(10, 0)
					print(v)
					v.EntFired=true
					
					local fire = ents.Create("gf2_ent_fire")
					fire:SetPos( v:GetPos() ) 
					fire:Spawn()
					fire:Activate()
					fire.ParentEntity=v
				end
			end
		end


		
	end]]
end
function ENT:CountFires()
	local items = 0
	for k, v in pairs(ents.GetAll()) do
		if v:GetClass()=="gf2_ent_fire" then
			items = items + 1
		end
	end
	return items
end

function ENT:Think()
	if CLIENT then
		if self:GetNWBool("IsBurning", false)==true and  self:GetNWBool("HasBurned", true)==false then
			local dlight = DynamicLight( self:EntIndex() )
			if ( dlight ) then
				dlight.pos = self:GetPos()
				dlight.r = 255
				dlight.g = 55
				dlight.b = 0
				dlight.brightness = 0.5
				dlight.Decay = 1000
				dlight.Size = 156
				dlight.Style = 6
				dlight.DieTime = CurTime() + 0.1
			end
		end
	end
	if SERVER then
		if !self:IsValid() then return end
		self:UpdateFlamePos()
		self:SetNWBool("IsBurning", self.IsBurning)
		self:SetNWBool("HasBurned", self.HasBurned)
		if (self.Ignited==true) then
			if self.IsBurning==nil then
				self.IsBurning=true
				self:EmitSound("garrys_fireworks_2/fireworks/misc/flameup.wav", 100, 100)
				self:MatchIgnite()
				self:SetMaterial("models/rogue_cheney/cannon/cannon_match_burned")
			end
			if (self.Ignition_Time*1.4)>=22 then
				self.HasBurned=true

			end
			
			self.Ignition_Time=self.Ignition_Time+0.01
			self:NextThink(CurTime() + 0.01)
			return true
		else
			if self.Ignition_Stack >= 0.2 then
				self.Ignited=true
			end

			self.speed = (self:GetVelocity():Length() * 6.25) * 3600 * 0.0000254 * 0.75
			
			if self.Ignition_Stack >= 0.1 then
				self.Ignition_Stack = math.Round(self.Ignition_Stack, 2) - 0.1
			end
			self:NextThink(CurTime() + 0.01)
			return true
		end
	end
end

