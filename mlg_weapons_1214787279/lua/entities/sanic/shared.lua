--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/mlg_weapons_1214787279/lua/entities/sanic/shared.lua <
    > Callstack:  <
]]

-- "addons\\mlg_weapons_1214787279\\lua\\entities\\sanic\\shared.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
ENT.Type = "anim"
ENT.PrintName			= "Sanic"
ENT.Author			= "Hobo_Gus"
ENT.Contact			= "ILLUMINATI"
ENT.Purpose			= ""
ENT.Instructions			= ""
ENT.Spawnable			= true
ENT.Category			= "MLG"

if SERVER then

AddCSLuaFile( "shared.lua" )

function ENT:Initialize()

	self.Owner = self.Entity.Owner

	self.Entity:SetModel("models/props_c17/furnitureStove001a.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow( false )
	//self.Entity:SetCollisionGroup( COLLISION_GROUP_NPC )
	self.Entity:SetHealth( 50 )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
	phys:Wake()
	phys:SetMass(15)
	end
//self.Entity:EmitSound( "snoop/NextEpisodeCut.mp3", 90, 100 )
	self.timeleft = CurTime() + 6
	self:Think()


end

 function ENT:Think()
 //print(self.Entity:Health())<==Some debug.
 if self.Entity:Health() == 0 then
 self:Explosion()
 end
	        local target = ents.FindInSphere(self.Entity:GetPos(), 1000)
        table.RemoveByValue( target , self.Entity ) 
            for k, v in pairs(target) do
	if (v:IsPlayer() or v:IsNPC()) then
				local trace = {}
			 	trace.start = self.Entity:GetPos() + Vector(0, 0, -145)
			 	trace.endpos = (self.Entity:GetAngles((v:GetPos()+ Vector(0, 0, -140) - self.Entity:GetPos()):Angle()))
			 	trace.filter = self.Entity
		 		local tr = util.TraceLine( trace )
 //if !tr.HitWorld then
 //v:TakeDamage( 1, self.Entity, self )  
		local pos = self.Entity:GetPos()
		local ang = self.Entity:GetPos():Angle()
					self.Entity:SetAngles((v:GetPos() - self.Entity:GetPos()):Angle())
					self.Entity:GetPhysicsObject():SetVelocity(self:GetAngles():Forward() *900)
//end
if tr.HitWorld then
self:Explosion()
end
if self.Entity:GetPos() == v:GetPos() then
		self:Explosion()	
end
    end
            end

	if self.timeleft < CurTime() then
		//self:Explosion()	
	end

	self.Entity:NextThink( CurTime() )
	return true
end

function ENT:Explosion()
		
	local weed = EffectData()
		weed:SetOrigin(self.Entity:GetPos())
		weed:SetNormal(VectorRand(), VectorRand(), VectorRand())
		util.Effect("hg_mlg_hit", weed)
		util.Effect("hg_mlg_hit", weed)
		
	local explode = EffectData()
		explode:SetOrigin(self.Entity:GetPos())
		explode:SetNormal(VectorRand(), VectorRand(), VectorRand())
		util.Effect("hg_mlg_boom", explode)
		
	self:EmitSound( "explosion.wav", 100, 100 )
	    local randomsounds = {
    "mlg/mlghit1.mp3",
    "mlg/mlghit2.mp3",
	"mlg/mlghit3.mp3",
	"mlg/mlghit4.mp3"
    }
   local random = math.random(1, #randomsounds)
   self:EmitSound(randomsounds[random], 100, 100 )
	
	local scorchstart = self.Entity:GetPos() + ((Vector(0,0,1)) * 5)
	local scorchend = self.Entity:GetPos() + ((Vector(0,0,-1)) * 5)
	
	if ( IsValid(self.Owner) ) then
	util.BlastDamage(self.Entity, self.Owner, self.Entity:GetPos(), 350, 250)
	else
	util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 350, 250)
	end
	util.ScreenShake(self.Entity:GetPos(), 500, 500, 15, 600)
	self.Entity:Remove()
	-- loos like if I don't remove the entity before drawing this scorch, the scorch will draw on the entity 
	-- and disappear immediately after
	util.Decal("Scorch", scorchstart, scorchend)
end

/*---------------------------------------------------------
PhysicsCollide
---------------------------------------------------------*/
function ENT:PhysicsCollide(data,phys)
	if data.Speed > 50 then
		self:EmitSound("Hitmarker Sound.wav", 100, 100)
	end
	
	local impulse = -data.Speed * data.HitNormal * 1 + (data.OurOldVelocity * -4)
	phys:ApplyForceCenter(impulse)
	
end

function ENT:Touch(ent)
	if (ent:IsPlayer()) then
		self:Explosion()
	end
	//self:SetHealth() = (self:Health() - 5) then
end

end

//if CLIENT then
function ENT:Draw()
	//self.Entity:DrawModel()
render.SetMaterial(Material("hobo_gus/Sanic"))
render.DrawSprite(self.Entity:GetPos() + ((Vector(0,0,45))),128,128,White)
end
//end
print('sanic')
