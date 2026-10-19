--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/dakimakuras/prop_dakimakura_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad\\lua\\hinit\\dakimakuras\\prop_dakimakura_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("prop_dakimakura","base_entity")
if not ENT then return end

ENT.PrintName = "Dakimakura"
ENT.Information = "A bodypillow"
ENT.Category = "Fun + Games"
ENT.Author = "Sera"

ENT.Spawnable = true
ENT.Base = "base_anim"
ENT.Type = "anim"

function ENT:Initialize()
	if( SERVER )then
		self:SetModel("models/dakimakura/daki.mdl")
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
	end
end

function ENT:SpawnFunction( Ply )
	net.Start("dakimakuras-net")
	net.Send( Ply )
end

function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "FrontImage" )
	self:NetworkVar( "String", 1, "BackImage" )
	self:NetworkVar( "String", 2, "Degenerate" )
	self:NetworkVar( "Bool", 3, "IsNSFW" )
	
	if( SERVER )then  return  end
	self:NetworkVarNotify( "FrontImage", self.OnVarChanged )
	self:NetworkVarNotify( "BackImage", self.OnVarChanged )
end

function ENT:OnVarChanged()
	self.NeedUpdate = CurTime() + .1
end

function ENT:ShouldRender()
	if( not GetConVar("dakimakura_nsfw"):GetBool() and self:GetIsNSFW() )then  return false  end
	if( not GetConVar("dakimakura_enable"):GetBool() )then  return false  end 
	if( Dakimakuras.Blacklist[ self:GetDegenerate() ] )then  return false  end
	return true
end

function ENT:UpdateImages()
	if( SERVER )then  return  end
	
	
	for Id, Url in pairs({ self:GetFrontImage(), self:GetBackImage() }) do	
		Dakimakuras.LoadImg( Url, function( Mat )
			if( IsValid( self ) )then				
				if( self:ShouldRender() )then
					self:SetSubMaterial( Id - 1, Mat )
				else
					self:SetSubMaterial( Id - 1, "" )
				end
			end
		end)
	end
end

function ENT:Think()
	if( CLIENT )then
		local IsDormant = self:IsDormant()
		if( IsDormant ~= self.DakiDormant )then
			self.DakiDormant = IsDormant
			
			if( not IsDormant )then
				self.NeedUpdate = CurTime() + .5
			end
		end
		
		if( self.NeedUpdate and self.NeedUpdate < CurTime() )then
			self.NeedUpdate = nil
			self:UpdateImages()
		end
	end
end

function ENT:Use( Activator )
	if( IsValid( Activator ) and Activator:IsPlayer() )then
		Activator:PickupObject( self )
	end
end

function ENT:PostEntityPaste( Player )
	if IsValid(Player) then self:SetDegenerate(Player:SteamID()) end
end
