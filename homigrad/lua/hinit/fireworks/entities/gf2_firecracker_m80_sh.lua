--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/fireworks/entities/gf2_firecracker_m80_sh.lua <
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

-- "addons\\homigrad\\lua\\hinit\\fireworks\\entities\\gf2_firecracker_m80_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("gf2_firecracker_m80","gf2_base_adv")
if not ENT then return end

ENT.Spawnable		= true
ENT.AdminOnly		= false

if (SERVER) then
	util.AddNetworkString( "gf2_m80_effect" )
end
net.Receive( "gf2_m80_effect", function( len, pl )

		hook.Add( "RenderScreenspaceEffects", "m80_blind", function()
			if timepassed == nil then 
				timepassed=0
				
			end
			
			timepassed=timepassed+1/(1/RealFrameTime()) -- making time a constant
			
			local tab = {}
			tab[ "$pp_colour_addr" ] = 0
			tab[ "$pp_colour_addg" ] = 0
			tab[ "$pp_colour_addb" ] = 0
			tab[ "$pp_colour_brightness" ] = 0
			tab[ "$pp_colour_contrast" ] = 10/timepassed
			tab[ "$pp_colour_colour" ] = math.Clamp(10/timepassed,0,1)
			tab[ "$pp_colour_mulr" ] = 0
			tab[ "$pp_colour_mulg" ] = 0
			tab[ "$pp_colousr_mulb" ] = 0 
			DrawColorModify( tab )			
			
			DrawMotionBlur( 0.09, 1.5-(2*(timepassed/10)), 0)
			
			
			if timepassed>=10 then
				timepassed=nil
				hook.Remove("RenderScreenspaceEffects", "m80_blind")
			end
			
			
		end )
end)

ENT.PrintName		                 =  "M-80"
ENT.Author			                 =  "Rogue Cheney"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "G-Works 2 - Firecrackers"

ENT.Model                            =  "models/models/gf2/rogue_cheney/firecrackers/m80.mdl"                      
ENT.Effect                           =  ""
ENT.EffectAir                        =  ""      
ENT.EffectWater                      =  "water_small"
ENT.ExplosionSound                   =  nil


ENT.ArmSound                         =  "physics/wood/wood_box_impact_bullet1.wav"            
ENT.ActivationSound                  =  "physics/wood/wood_box_impact_hard1.wav"     

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


ENT.GBOWNER                          =  nil             

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


if ( CLIENT ) then
	function ENT:Draw()
		self:DrawModel()
		if !(WireAddon == nil) then Wire_Render(self.Entity) end
	end
end


function ENT:Explode_Sound()

	local pos = self:GetPos()
	local ent = ents.Create("gf2_shockwave_sound_lowsh")
	ent:SetPos(pos)
	ent:Spawn()
	ent:Activate()
	ent.MAX_RANGE = 50000
	ent.SHOCKWAVE_INCREMENT = 100
	ent.SOUND = table.Random({"garrys_fireworks_2/fireworks/firecrackers/m80_explosion_01.wav","garrys_fireworks_2/fireworks/firecrackers/m80_explosion_02.wav"})
	
	ent.ShakeSettings = { ["ShakeTime"] = 0.1,
						["SoundAmp"] = 5,
						["SoundFreq"] = 5
						}
						
						
						  
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
	self:ChainReaction()
	
	ParticleEffect("gf2_firecracker_m80_main", self:GetPos(), Angle(0,0,0), nil)
	self:Explode_Sound()
	
	for k, v in pairs(ents.FindInSphere(self:GetPos(), 100)) do
		if v:IsPlayer() then self:RandomEffect(v) end
	end
	
	Shockwave(self.GBOWNER, self:GetPos(), {0,25}, 155, 25)
	self:Remove()
end

function ENT:OnTakeDamage(dmginfo)
end

function ENT:PhysicsCollide( data, physobj )
end

function ENT:RandomEffect(ply)
	local rand = math.random(1,3)
	if rand==1 then -- drop active weapon cause your arm broke
		ply:DropWeapon( ply:GetActiveWeapon() ) 
		ply:EmitSound(table.Random({"vo/npc/male01/myarm01.wav","vo/npc/male01/myarm02.wav"}), math.random(80,120), 100)
		if math.random(1,2)==1 then ParticleEffectAttach("gf2_firecracker_m80_pg_bleed_hands",PATTACH_POINT_FOLLOW,ply,ply:LookupAttachment("anim_attachment_RH")) else ParticleEffectAttach("gf2_firecracker_m80_pg_bleed_hands",PATTACH_POINT_FOLLOW,ply,ply:LookupAttachment("anim_attachment_LH")) end
		

	elseif rand==2 then -- blind him
		net.Start("gf2_m80_effect")
		net.Send(ply)
		ply:EmitSound("garrys_fireworks_2/fireworks/firecrackers/myeyes.wav", math.random(80,120), 100)
		
	elseif rand==3 then -- slow him down for for some time!
		ply:EmitSound(table.Random({"vo/npc/male01/myleg01.wav","vo/npc/male01/myleg02.wav"}), math.random(80,120), 100)
		for i=1,50 do
		timer.Simple(i/10, function()
			if !ply:IsValid() then return end
			ply:SetRunSpeed(500/50*i)
			ply:SetWalkSpeed(250/50*i)
		end)
		end
	end
		
end

function ENT:ChainReaction()
	for k, v in pairs(ents.FindInSphere(self:GetPos(), 100)) do
		local phys = v:GetPhysicsObject()
		if phys:IsValid() then
			local F_dir = (v:GetPos() - self:GetPos()):GetNormal() * 200
			phys:AddVelocity(F_dir)
		end

		if v:GetClass()=="gf2_firecracker_m80" then
			timer.Simple(math.random(10,20)/10, function()
				if !v:IsValid() then return end
				v:Arm()
			end)
		end
	end
end


function ENT:Arm()
	if(!self:IsValid()) then return end
	if(self.Exploded) then return end
	if(self.Armed) then return end
	self:EmitSound(self.ArmSound)
	self.Armed=true
	 
	ParticleEffectAttach("gf2_firecracker_m80_ignition_glow_tracer", PATTACH_ABSORIGIN_FOLLOW,self,1)

	self:EmitSound("garrys_fireworks_2/fireworks/ignition/fuse.wav", 80, 100)
	timer.Simple(3, function()
		if !self:IsValid() then return end 
		self.Exploded=true
		self:Explode()
	end)

end	 

