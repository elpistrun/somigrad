--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/mlg_weapons_1214787279/lua/entities/snoopnade/shared.lua <
    > Callstack:  <
]]

-- "addons\\mlg_weapons_1214787279\\lua\\entities\\snoopnade\\shared.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
ENT.Type = "anim"
ENT.PrintName			= "Snoop Dogg"
ENT.Author			= "Hobo_Gus"
ENT.Contact			= "ILLUMINATI"
ENT.Purpose			= "Smoke weed everyday"
ENT.Instructions			= "Drop it like its hot"
ENT.Spawnable			= true
ENT.Category			= "MLG"

if SERVER then

AddCSLuaFile( "shared.lua" )

function ENT:Initialize()

	self.Owner = self.Entity.Owner

	self.Entity:SetModel("models/props_junk/plasticbucket001a.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow( false )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
	phys:Wake()
	phys:SetMass(5)
	end
self.Entity:EmitSound( "snoop/NextEpisodeCut.mp3", 90, 100 )
	self.timeleft = CurTime() + 6
	self:Think()


end

 function ENT:Think()
	
	if self.timeleft < CurTime() then
		self:Explosion()	
	end

	self.Entity:NextThink( CurTime() )
	return true
end

function ENT:Explosion()
		
	local weed = EffectData()
		weed:SetOrigin(self.Entity:GetPos())
		weed:SetNormal(VectorRand(), VectorRand(), VectorRand())
		util.Effect("hg_weed", weed)
		util.Effect("hg_weed", weed)
		util.Effect("hg_weed", weed)
		
	local explode = EffectData()
		explode:SetOrigin(self.Entity:GetPos())
		explode:SetNormal(VectorRand(), VectorRand(), VectorRand())
		util.Effect("hg_jihad_boom", explode)
		
	self:EmitSound( "explosion.wav", 100, 100 )
	self:EmitSound("Smoke Weed Everyday.mp3", 100, 100)
		
	local scorchstart = self.Entity:GetPos() + ((Vector(0,0,1)) * 5)
	local scorchend = self.Entity:GetPos() + ((Vector(0,0,-1)) * 5)
	
	if ( IsValid(self.Owner) ) then
	util.BlastDamage(self.Entity, self.Owner, self.Entity:GetPos(), 350, 250)
	else
	util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 350, 250)
	end
	util.ScreenShake(self.Entity:GetPos(), 500, 500, 1.25, 500)
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
	    if ( IsValid(self.Owner) ) then
		self.Owner:EmitSound("Hitmarker Sound.wav", 100, 100)
		end
	end
	
	local impulse = -data.Speed * data.HitNormal * 1 + (data.OurOldVelocity * -4)
	phys:ApplyForceCenter(impulse)
	
end

end

//if CLIENT then
function ENT:Draw()
	//self.Entity:DrawModel()
render.SetMaterial(Material("hobo_gus/snoop_dogg"))
render.DrawSprite(self.Entity:GetPos() + ((Vector(0,0,45))),64,128,White)
end
//end
