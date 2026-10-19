--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/fireworks/entities/gf2_flares_red_flare_sh.lua <
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

-- "addons\\homigrad\\lua\\hinit\\fireworks\\entities\\gf2_flares_red_flare_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("gf2_flares_red_flare","gf2_base_adv")
if not ENT then return end

sound.Add( {
	name = "flare_sound",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 70,
	pitch = { 100, 100 },
	sound = "garrys_fireworks_2/fireworks/flares/flare_sound.mp3"
} )

ENT.Spawnable		= true
ENT.AdminOnly		= false


ENT.PrintName		                 =  "Red Flare"
ENT.Author			                 =  "Rogue Cheney"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "G-Works 2 - Flares"
ENT.Type                             = "anim"
ENT.Model                            =  "models/models/gf2/rogue_cheney/flares/flare_p_01/flare_01.mdl"       
ENT.AutomaticFrameAdvance = true
ENT.RenderGroup = RENDERGROUP_BOTH


ENT.ArmSound                         =  ""            
ENT.ActivationSound                  =  ""          
ENT.Life                             =  25                                 

ENT.ImpactSpeed                      =  9000
ENT.Mass                             =  50
ENT.ArmDelay                         =  1

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

local material = "particle/lens_flares/particle_flare_whited_001.vmt"

function ENT:GetType(get_type)
	local class_types = { ["gf2_flares_red_flare"   ] = {["Particle Effect"]="gf2_flare_01_red_main",
														 ["Flare Colour"]   = Color(255,45,45,255),
														 ["Skin"]          = 1,
														 ["Burned Skin"]    = 6
														},
														 
						  ["gf2_flares_green_flare"   ] = {["Particle Effect"]="gf2_flare_02_green_main",
														 ["Flare Colour"]   = Color(45,255,45,255),
														 ["Skin"]          = 0,
														 ["Burned Skin"]    = 5														  
														 },
						  ["gf2_flares_blue_flare"   ] = {["Particle Effect"]="gf2_flare_03_blue_main",
														 ["Flare Colour"]   = Color(44,45,255,255),
														 ["Skin"]          = 2,
														 ["Burned Skin"]    = 7														 		 
														 },
						  ["gf2_flares_yellow_flare"   ] = {["Particle Effect"]="gf2_flare_04_yellow_main",
														 ["Flare Colour"]   = Color(255,164,45,255),
														 ["Skin"]          = 3,
														 ["Burned Skin"]    = 8														 	 								 
														 },	
						  ["gf2_flares_white_flare"   ] = {["Particle Effect"]="gf2_flare_05_white_main",
														 ["Flare Colour"]   = Color(255,255,255,255),					 
														 ["Skin"]          = 4,
														 ["Burned Skin"]    = 9																	 
														 }
		
	
	
	}
				
	if get_type == "Particle Effect" then
		return class_types[self:GetClass()]["Particle Effect"]
	elseif get_type == "Flare Colour" then
		return class_types[self:GetClass()]["Flare Colour"]
	elseif get_type == "Skin" then
		return class_types[self:GetClass()]["Skin"]
	elseif get_type == "Burned Skin" then
		return class_types[self:GetClass()]["Burned Skin"]
	else 
		print("WTF just happened?")
	end

end

function ENT:Initialize()
	
	self:RenderFlares()
	if (CLIENT) then
		self.BurnTime = 0
	end
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
		self.BurnTime = 0
		
		self:SetSkin(self:GetType("Skin"))


		if !(WireAddon == nil) then self.Inputs   = Wire_CreateInputs(self, { "Ignite"}) end
	end
end





if ( CLIENT ) then
	
	function ENT:Draw()
		self:DrawModel()

		if !(WireAddon == nil) then Wire_Render(self.Entity) end
	end
end

function ENT:TriggerInput(iname, value)
     if (!self:IsValid()) then return end
	 if (iname == "Ignite") then
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
		
		self.HasIgnited = true

		self:EmitSound("flare_sound")													
		ParticleEffectAttach( self:GetType("Particle Effect"), PATTACH_POINT_FOLLOW, self, self:LookupAttachment( "attachment_nozzle" ) )
		self:SetSkin( self:GetType("Burned Skin"))

		self:ResetSequence(self:LookupSequence("FLARE_BURN"))


		
		

		
	end)

end	 


function ENT:FlareDamage(entity)
	if (GetConVar("gf2_flare_damage"):GetInt() >= 1) then
		if entity:IsPlayer() then 
			entity:Ignite(5, 0) 
		elseif entity:GetPhysicsObject():IsValid() then
			if entity.DamagedAmountbyFlares == nil then entity.DamagedAmountbyFlares = 0 end
			entity.DamagedAmountbyFlares = entity.DamagedAmountbyFlares + math.random(1,5)
			
			if entity.DamagedAmountbyFlares >= 100 and entity.DamagedAmountbyFlares <= 300 then entity:Ignite(1,0) -- ignite props :D
			elseif entity.DamagedAmountbyFlares > 300 and entity.DamagedAmountbyFlares <= 1000 then 
				local color = math.Clamp(255-(255/1000*(entity.DamagedAmountbyFlares-200)), 0, 255)
				entity:SetColor(Color(color,color,color))
				entity:Ignite(5,0)
				ParticleEffectAttach( "gf2_flare_universal_welding_damage", PATTACH_POINT_FOLLOW, entity, 0 )
			elseif entity.DamagedAmountbyFlares >= 500 then

				ParticleEffectAttach( "gf2_flare_universal_welding_damage_permenant", PATTACH_POINT_FOLLOW, entity, 0 )

				timer.Simple(0.1, function()
					if !entity:IsValid() then return end
					entity:EmitSound("physics/glass/glass_sheet_break3.wav")
					entity:Remove()
					
				end)
			end
		end
	end
end

function ENT:FlameBurn()
	if !self:IsBurning() then return end
	local pos_mod = self:GetAttachment(self:LookupAttachment("attachment_nozzle")).Pos + 0.1 * self:GetUp()
	
	local tr = util.TraceLine( {
		start = pos_mod,
		endpos = pos_mod + (8 * self:GetUp()),

	} )

	if tr.Entity:IsValid() or tr.Entity:IsWorld() then 
		ParticleEffect( "gf2_flare_universal_welding_effect", tr.HitPos, Angle(0,0,0), nil )
		self:FlareDamage(tr.Entity)
	end

end

function ENT:RecordBurnTime()
	if !self:IsBurning() then return end
	
	local t = engine.TickInterval() * 10
	self.BurnTime = self.BurnTime + t 
	

end


function ENT:IsBurning()
	if self.HasIgnited && self.BurnTime < 140 then 
		if GetConVarNumber("gf2_dynamic_light")==1 then 
			self:SetNWBool("IsBurning", true) 
		end 
		return true 
	else 
		self:SetNWBool("IsBurning", false) 
		return false
	end
end

function ENT:OnRemove()
	if (SERVER) then
		self:StopSound("flare_sound")
	end
end

function ENT:Think()
	if (CLIENT) then
		if self:GetNWBool("IsBurning", false) == true then	
			self.BurnTime=self.BurnTime+(engine.TickInterval()*10)
			
			local dlight = DynamicLight( self:EntIndex())
			
			if ( dlight ) then
				local colour = ReturnFlares(self)["Colour"]
				dlight.Pos = self:GetAttachment(1).Pos
				dlight.r = colour.r
				dlight.g = colour.g
				dlight.b = colour.b
				dlight.Brightness = math.Clamp((((6.2+(math.random(-10,10)/100))/8)*self.BurnTime), 0, 7)
				dlight.Size = math.Clamp(561/8*self.BurnTime, 0, 561)
				dlight.Decay = 0
				dlight.DieTime = CurTime() + 0.01
				dlight.Style = 1
			end
		end
	end
	if (SERVER) then 
		if !self:IsValid() then return end
		self:FlameBurn()
		self:RecordBurnTime()
		
	end
	self:NextThink( CurTime() + 0.1 )
	return true
end



function ENT:Draw()
	self:DrawModel()
	return true
end

function IsFlare(entity)
	local IsFlare = {["gf2_flares_red_flare"   ] = true, ["gf2_flares_green_flare"   ] = true,["gf2_flares_blue_flare"   ] = true,["gf2_flares_yellow_flare"   ] = true,["gf2_flares_white_flare"   ] = true }
	
	return IsFlare[entity:GetClass()]
	
end

function ReturnFlares(ent) 
	local data = {}

	
	if ent!=nil then
		if ent:IsValid() then
			for k, v in pairs(ents.GetAll()) do
				
				if IsFlare(v)==true then
					if ent == v then 
						
						return {["Entity"] = ent, ["Colour"] = ent:GetType("Flare Colour")}
						
						
					end
					
					
					
				end
			end
		end
		
	else
		
		for k, v in pairs(ents.GetAll()) do
			
			if IsFlare(v)==true then
				if v:GetNWBool("IsBurning", false)==true then
					table.insert( data, {["Entity"] = v, ["Colour"] = v:GetType("Flare Colour")})
					
				end
			end
		end
		return data
	end
end


local  material = Material( "effects/lensflare/bar_2" )


function ENT:RenderFlares()
	
	hook.Add( "RenderScreenspaceEffects", "Render Flare", function()

		for k, v in pairs(ReturnFlares()) do

			local sizedist = math.Clamp(LocalPlayer():GetPos():Distance(v["Entity"]:GetPos()), 0, 2000)
			
			local alphadist = math.Clamp((155/500)*sizedist+math.random(-255,255), 50, 2055)
			local sizedratio = math.Clamp((200/500)*sizedist, 85, 5000) 

			cam.Start3D( EyePos(), EyeAngles() ) -- Start the 3D function so we can draw onto the screen.
				render.SetMaterial( material ) -- Tell render what material we want, in this case the flash from the gravgun
				if LocalPlayer():IsLineOfSightClear( v["Entity"]:GetPos() ) then
					render.DrawSprite( v["Entity"]:GetAttachment(1).Pos, alphadist, sizedratio,v["Colour"] ) -- Draw the sprite in the middle of the map, at 16x16 in it's original colour with full alpha.
				end
			cam.End3D()
			
		
		end
	end )

end


