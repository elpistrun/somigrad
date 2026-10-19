--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/fireworks/entities/gf2_mortars_mortar_big_sh.lua <
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

-- "addons\\homigrad\\lua\\hinit\\fireworks\\entities\\gf2_mortars_mortar_big_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("gf2_mortars_mortar_big","gf2_base_rocket")
if not ENT then return end

ENT.Spawnable		= true
ENT.AdminOnly		= false

ENT.PrintName		                 =  "100mm Mortar Tube"
ENT.Author			                 =  "Rogue Cheney"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "G-Works 2 - Mortars + Shells"

ENT.Model                            =  "models/models/gf2/rogue_cheney/mortars/mortar_03.mdl"                      

ENT.Mass                             =  150

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

		self.IgnitionStack = 0
		self.BurningTime   = 0
		self.HasBurned     = false
		self.RequestTime   = CurTime()
		
		if !(WireAddon == nil) then self.Inputs   = Wire_CreateInputs(self, { "Launch" }) end

	end
end




if ( CLIENT ) then
	
	function ENT:Draw()
		self:DrawModel()
		local squad = self:GetNetworkedString( 12 )
		if ( LocalPlayer():GetEyeTrace().Entity == self.Entity && EyePos():Distance( self.Entity:GetPos() ) < 156 ) then
			AddWorldTip( self.Entity:EntIndex(), ( "Place one shell inside of me and press E" ), 0.5, self.Entity:GetPos(), self.Entity  )
		end	
		if !(WireAddon == nil) then Wire_Render(self.Entity) end
	end
end

function ENT:TriggerInput(iname, value)
     if (!self:IsValid()) then return end
	 if (iname == "Launch") then
         if (value >= 1) then
			self:Launch()
		 end
	 end
		 
end 



function ENT:Think()

	if (SERVER) then
		if !self:IsValid() then return end
		
	end
end

function ENT:Explode()
end

function ENT:OnTakeDamage(dmginfo)
     if self.Exploded then return end
end

function ENT:PhysicsCollide( data, physobj )
end

function ENT:Arm()


end	 

function ENT:CanLaunch()

	if (self.RequestTime+1) < CurTime()then
		self.RequestTime=CurTime()
		return true
	else
	
		return false
	end
		
	


end


function ENT:Launch()
	for k, v in pairs(ents.FindInSphere(self:GetAttachment(self:LookupAttachment("bottom")).Pos, 5)) do
		if v!=self && v:GetPhysicsObject():IsValid() && (string.StartWith(v:GetClass(), "gf2_mortars_shell_big_")==true) then
			local phys = v:GetPhysicsObject()
			phys:AddVelocity(self:GetUp()*2555)
			phys:AddAngleVelocity(phys:GetAngleVelocity()*-1)
			
			phys:AddAngleVelocity(Vector(0,0,1555))

			ParticleEffectAttach("gf2_mortar_shell_airburst",PATTACH_ABSORIGIN_FOLLOW,v,1)
			ParticleEffectAttach("gf2_mortar_shell_trail_circularsparkles_white",PATTACH_ABSORIGIN_FOLLOW,v,1)
			timer.Simple(3, function()
				if v:IsValid()==true then
					v:Explode()
				end
			end)
			
			
			local sound = table.Random({"garrys_fireworks_2/fireworks/launch/mortar_launch.mp3","garrys_fireworks_2/fireworks/launch/mortar_launch_2.mp3"})
			self:EmitSound(sound, 100, math.random(70,150))
			
			ParticleEffect( "gf2_battery_shot_effect", self:GetAttachment(self:LookupAttachment("top")).Pos, self:GetAngles(), nil )

		end
	end
	
	

end

function ENT:Use( activator, caller )
	activator:PickupObject(self)
	if not activator:KeyDown(IN_WALK) then return end

	if (SERVER) then
		if self:CanLaunch()==true then
			self:Launch()
		end
	end
end
















