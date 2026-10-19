--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/fireworks/entities/gf2_fountain_hellfire_sh.lua <
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

-- "addons\\homigrad\\lua\\hinit\\fireworks\\entities\\gf2_fountain_hellfire_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("gf2_fountain_hellfire","gf2_base_adv")
if not ENT then return end

ENT.Spawnable		= true
ENT.AdminOnly		= false

ENT.PrintName		                 =  "Hellfire"
ENT.Author			                 =  "Rogue Cheney"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "G-Works 2 - Fountains"

ENT.Model                            =  "models/models/gf2/rogue_cheney/fountains/fountain_01.mdl"                      

ENT.Mass                             =  50
ENT.GBOWNER                          =  nil           

sound.Add( {
	name = "fountain_01_hellfire",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = { 100, 100 },
	sound = "garrys_fireworks_2/fireworks/fountains/fountain_01_hellfire.mp3"
} )  

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
		self.IsEmitting = false
		
		self.BurningTime = 0
		
		self:Setup_Skins()
		if !(WireAddon == nil) then self.Inputs   = Wire_CreateInputs(self, { "Ignite" }) end

	end
end

function ENT:StartEmitting()
	if !(SERVER) or self.IsEmitting==true then return end
	self.IsEmitting=true
	self.IsBurning=true
	DynamicLightCheck(self)
	self:SetSkin(self:GetBurnedSkin())
	
	ParticleEffectAttach("gf2_fountain_01_hellfire_main", PATTACH_POINT_FOLLOW, self, self:LookupAttachment("nozzle_attach_02"))
	self:EmitSound("fountain_01_hellfire")
	
	self:SetModel("models/models/gf2/rogue_cheney/fountains/fountain_01_burned.mdl")
end

function ENT:GetBurnedSkin()
	local table_ent = { ["gf2_fountain_hellfire"] = 0,
						["gf2_fountain_radioburst"] = 2,
						["gf2_fountain_midnight_mj"] = 4,
						["gf2_fountain_fairy_glitter"] = 6,
						["gf2_fountain_regulus_bril"] = 8
						}	
	return table_ent[self:GetClass()]+1
end

function ENT:Setup_Skins()
	local table_ent = { ["gf2_fountain_hellfire"] = 0,
						["gf2_fountain_radioburst"] = 2,
						["gf2_fountain_midnight_mj"] = 4,
						["gf2_fountain_fairy_glitter"] = 6,
						["gf2_fountain_regulus_bril"] = 8
						}
	self:SetSkin(table_ent[self:GetClass()])
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
			if self.IsEmitting==false then 
				if self.IsEmitting==false && self.Armed==false then
					self:EmitSound("npc/roller/mine/rmine_blip3.wav")
					self.Armed=true
				end
				timer.Simple(1, function()
					if !self:IsValid() then return end
					self:StartEmitting() 
				end)
			end
		 end
	 end
		 
end  

function ENT:Think()
	if (CLIENT) then
		if self:GetNWBool("IsBurning", false) == true then			
			local dlight = DynamicLight( self:EntIndex())
			local burntime = self:GetNWFloat("BurningTime", 0)
			if ( dlight ) then
				local colour = Color(255,85,25)
				dlight.Pos = self:GetPos() + self:GetUp() * 20
				dlight.r = colour.r
				dlight.g = colour.g
				dlight.b = colour.b
				dlight.Brightness = math.random(49,50)/10
				if burntime > 40 then 
					dlight.Size = 0
				else
					dlight.Size = 200
				end
				

				dlight.Decay = 0
				dlight.DieTime = CurTime() + 0.01
				dlight.Style = 1
			end
		end
	end
	if (SERVER) then
		if !self:IsValid() then return end
		if self.IsBurning==true then
			self.BurningTime = self.BurningTime+engine.TickInterval()

			self:SetNWFloat("BurningTime", self.BurningTime)
		end
		

		if self.BurningTime > 65 then
			self:StopParticles()
			self:SetNWBool("IsBurning", false)
			self.IsBurning=false
			self.HasBurned=true
		end
			
		self:NextThink( CurTime() )
		return true

	end
end

function ENT:OnRemove()
	if (SERVER) then
		self:StopSound("fountain_01_hellfire")
		self:StopParticles()
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
end	 

function ENT:Use( activator, caller )
	activator:PickupObject(self)

	if activator:KeyDown(IN_WALK) and activator:IsValid() && self.IsEmitting==false then 

		if self.IsEmitting==false && self.Armed==false then
			self:EmitSound("npc/roller/mine/rmine_blip3.wav")
			self.Armed=true
		end
		timer.Simple(1, function()
			if !self:IsValid() then return end
			self:StartEmitting() 
		end)
	end
end

