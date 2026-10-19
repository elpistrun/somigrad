--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/fireworks/entities/gf2_cake_01_sh.lua <
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

-- "addons\\homigrad\\lua\\hinit\\fireworks\\entities\\gf2_cake_01_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("gf2_cake_01","gf2_base_adv")
if not ENT then return end

ENT.Spawnable		= true
ENT.AdminOnly		= false

ENT.PrintName		                 =  "Dancing Dragon"
ENT.Author			                 =  "Rogue Cheney"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "G-Works 2 - Cakes"

ENT.Model                            =  "models/models/gf2/rogue_cheney/cakes/cake_01.mdl"                      
ENT.Effect                           =  ""
ENT.EffectAir                        =  ""      
ENT.EffectWater                      =  "water_small"
ENT.ExplosionSound                   =  "physics/wood/wood_crate_break1.wav"
ENT.ArmSound                         =  "physics/wood/wood_box_impact_bullet1.wav"            
ENT.ActivationSound                  =  "physics/wood/wood_box_impact_hard1.wav"     
ENT.Bomblet                          =  "gf_cracker"

ENT.ShouldUnweld                     =  false
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false    
ENT.UseRandomSounds                  =  false
ENT.UseRandomModels                  =  false
ENT.Timed                            =  false
ENT.RandomAngles                     =  false         -- If this is false, the bomblets will spawn facing the general bomb direction.

ENT.ExplosionDamage                  =  100            
ENT.PhysForce                        =  100           
ENT.ExplosionRadius                  =  25          
ENT.SpecialRadius                    =  2                   
ENT.Life                             =  25                                 
ENT.MaxDelay                         =  0                                 
ENT.TraceLength                      =  500
ENT.ImpactSpeed                      =  9000
ENT.Mass                             =  150
ENT.ArmDelay                         =  1
ENT.Timer                            =  0
ENT.NumBomblets                      =  16
ENT.Magnitude                        =  155
ENT.Shape                            =  "RANDOM"

ENT.GBOWNER                          =  nil             

function ENT:CreatePositions()
	local pos_table = {}

	
	for x=1,2 do
		for y=1,8 do
			local angle = ((360/8)*y)*math.pi/180
			local xy     = math.cos(angle)*self:GetRight()*(x*4)
			local yy     = math.sin(angle)*self:GetForward()*(x*4)
			local pos = (self:GetPos()+self:GetUp()*9)+xy+yy
			table.insert(pos_table, pos)
		end
	end
	table.insert(pos_table,self:GetPos()+self:GetUp()*9	)
	return pos_table
end
	
	
function ENT:Start_Launching()
	
	local pos_tbl = self:CreatePositions()
	local kmod = 1 
	for k, v in pairs(pos_tbl) do
		if k<=8 then kmod=4 else kmod = 1 end
		timer.Simple(k/kmod+math.random(1,100)/1000, function()
			if !self:IsValid() then return end
			
			
			
			self:GetPhysicsObject():AddVelocity(self:GetUp()*-100+Vector(math.random(-155,155),math.random(-155,155),0))
			local pos_tbl = self:CreatePositions()
			local v = pos_tbl[k]
			self:EmitSound("garrys_fireworks_2/fireworks/battery/battery_shot.wav", 100, math.random(70,120))
			
			local sparky = ents.Create("gf2_battery_pellet")
			sparky:SetPos(v)
			sparky:Spawn()
			sparky:Activate()
			sparky.Info = {["Effect"]         = {"gf2_cake_01_explosion_01","gf2_cake_01_explosion_02", "gf2_cake_01_explosion_03","gf2_cake_01_explosion_04"},
						  ["ExplosionSound"] = {"", ""},
						  ["Trail"]  = table.Random({"gf2_firework_idle_white_trail_2","gf2_firework_idle_golden_trail_2"}),
						  ["ExplosionDelay"] = math.random(6,10)/10,
						  ["MatchSoundwithEffect"] = true,
						  ["Trail_as_Firework"] = k<=8,
						  ["Trail_Firework"]    = table.Random({"gf2_cake_01_trail_01"}),
						  ["Trail_Sound"]          = {["gf2_cake_01_trail_01"] = ""},
						  
						  ["Effect_Sound"]         = {["gf2_cake_01_explosion_01"] = "garrys_fireworks_2/fireworks/battery/battery_explode_01.wav",
													  ["gf2_cake_01_explosion_02"] = "garrys_fireworks_2/fireworks/battery/battery_explode_01.wav",
													  ["gf2_cake_01_explosion_03"] = "garrys_fireworks_2/fireworks/battery/battery_explode_01.wav",
													  ["gf2_cake_01_explosion_04"] = "garrys_fireworks_2/fireworks/battery/battery_explode_01.wav"}
													  
						  }
			sparky:GetPhysicsObject():AddVelocity(Vector(math.random(-550, 550), math.random(-550,550),0)+(3000*self:GetUp()))
			sparky:SetCollisionGroup(COLLISION_GROUP_WORLD)
			
			if sparky.Info["Trail_as_Firework"]==true then 
				sparky:EmitSound("garrys_fireworks_2/fireworks/battery/battery_pellet_whistle.wav", 100,math.random(80,120)) 
				sparky.Trail = sparky.Info["Trail_Firework"] 			
				ParticleEffectAttach(sparky.Trail, PATTACH_ABSORIGIN_FOLLOW,sparky,1) 
				sparky.Info["Effect"] = {""} 

			end
			ParticleEffect( "gf2_battery_shot_effect", v, self:GetAngles(), self )
		end)
	end
end


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

		self.Armed    = false
		self.Exploded = false
		self.Used     = false
		self.Arming   = false
		
		self:SetSkin(0)
		if !(WireAddon == nil) then self.Inputs   = Wire_CreateInputs(self, { "Arm", "Detonate" }) end
	end
end

local material = Material("brick/brick_model", "nocull")



if ( CLIENT ) then
	
	function ENT:Draw()
		self:DrawModel()
	
		if !(WireAddon == nil) then Wire_Render(self.Entity) end
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



function ENT:Explode()
     if !self.Exploded then return end
	self:Remove()
end

function ENT:OnTakeDamage(dmginfo)
     if self.Exploded then return end
end

function ENT:PhysicsCollide( data, physobj )
end

function ENT:Arm()
	if(!self:IsValid()) then return end
	if(self.Exploded) then return end
	if(self.Armed) then return end
	self:EmitSound(self.ArmSound)
	self.Armed=true
	 
	
	timer.Simple(1, function()
		if !self:IsValid() then return end 

		if !self:IsValid() then return end 
		self.HasIgnited = true
		self.HasCalledLaunching = false
		self:Start_Launching()
		self:SetSkin(1)
	end)

end	 
