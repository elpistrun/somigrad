--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/fireworks/entities/gf2_shockwave_sound_lowsh_sh.lua <
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

-- "addons\\homigrad\\lua\\hinit\\fireworks\\entities\\gf2_shockwave_sound_lowsh_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("gf2_shockwave_sound_lowsh","base_entity")
if not ENT then return end

if (SERVER) then
	util.AddNetworkString( "gf2_net_sound" )
end

ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false     

ENT.PrintName		                 =  ""        
ENT.Author			                 =  ""      
ENT.Contact			                 =  ""      

ENT.GBOWNER                          =  nil            
ENT.MAX_RANGE                        = 0
ENT.SHOCKWAVE_INCREMENT              = 0
ENT.DELAY                            = 0
ENT.SOUND                            = ""

net.Receive( "gf2_net_sound", function( len, pl )
	local sound = net.ReadString()
	

	LocalPlayer():EmitSound(sound, 100, math.random(80,120))
	
end );

function ENT:Initialize()
     if (SERVER) then
		 self.FILTER                           = {}
         self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
	     self:SetSolid( SOLID_NONE )
	     self:SetMoveType( MOVETYPE_NONE )
	     self:SetUseType( ONOFF_USE ) 
		 self.Bursts = 0
		 self.CURRENTRANGE = 0
		 self.FILTER = {}
		 self:SetNoDraw(true)
     end
end
	

function ENT:ProcessInRange()
	local pos = self:GetPos()
	
	if(GetConVar("gf2_realistic_sound"):GetInt() >= 1) then
		
		for k, v in pairs(ents.FindInSphere(pos,self.CURRENTRANGE)) do
			if v:IsPlayer() then
				
				if !(table.HasValue(self.FILTER,v)) then
				
					net.Start("gf2_net_sound")
						net.WriteString(self.SOUND)
						
					net.Send(v)
					
					
					if GetConVar("gf2_sound_shake"):GetInt()== 1 then
						util.ScreenShake( v:GetPos(), self.ShakeSettings["SoundAmp"], self.ShakeSettings["SoundFreq"], self.ShakeSettings["ShakeTime"], 500 )
					end
					table.insert(self.FILTER, v)

				end
			end
		end
	else
		for k, v in pairs(player.GetAll()) do
			net.Start("gf2_net_sound")
				net.WriteString(self.SOUND)
			net.Send(v)
			v:SetNWString("sound", self.SOUND)
			if self:GetVar("Shocktime") == nil then
				self.shocktime = 1
			else
				self.shocktime = self:GetVar("Shocktime")
			end
			if GetConVar("gf2_sound_shake"):GetInt()== 1 then
				util.ScreenShake( v:GetPos(), 5555, 555, self.shocktime, 500 )
			end
			self:Remove()
			
		 end	 
	 end
end

function ENT:Think()		
     if (SERVER) then
     if !self:IsValid() then return end
	 self:ProcessInRange()
	 local pos = self:GetPos()
	 self.CURRENTRANGE = self.CURRENTRANGE+(self.SHOCKWAVE_INCREMENT*10) 
	 self.Bursts = self.Bursts + 1
	 if (self.CURRENTRANGE >= self.MAX_RANGE) then
	     self:Remove()
	 end

	 self:NextThink(CurTime() + 0.1)
	 return true
	 end
end

function ENT:Draw()
     return false
end
