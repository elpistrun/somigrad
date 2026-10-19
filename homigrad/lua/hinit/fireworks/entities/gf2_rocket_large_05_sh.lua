--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/fireworks/entities/gf2_rocket_large_05_sh.lua <
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

-- "addons\\homigrad\\lua\\hinit\\fireworks\\entities\\gf2_rocket_large_05_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("gf2_rocket_large_05","gf2_base_rocket")
if not ENT then return end

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  false 

ENT.PrintName		                 =  "Alpha: Lrg Rocket"
ENT.Author			                 =  "Rogue"
ENT.Contact			                 =  "baldursgate3@gmail.com"
ENT.Category                         =  "G-Works 2 - Large Rockets"

ENT.Model                            =  "models/models/gf2/rogue_cheney/rockets/big/rocket_01.mdl"
ENT.RocketTrail                      =  "gf2_firework_trail_main"
ENT.RocketBurnoutTrail               =  "firework_burnout"
ENT.Effect                           =  "gf2_rocket_large_explosion_04"

ENT.ExplosionSound                   =  "garrys_fireworks_2/fireworks/explosions/fw_large_pellet_explosion.wav"         
ENT.StartSound                       =  "garrys_fireworks_2/fireworks/launch/rocket_launch_01.wav"                        
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "buttons/button14.wav"  
ENT.EngineSound                      =  "gf2_firework_engineloop"  
ENT.SmartLaunch                      =  false
ENT.Timed                            =  false 

ENT.ExplosionRadius                  =  800                                  
ENT.MaxIgnitionTime                  =  0           
ENT.Life                             =  20            
ENT.MaxDelay                         =  0           
ENT.TraceLength                      =  100             
ENT.Mass                             =  100
ENT.EnginePower                      =  150
ENT.FuelBurnoutTime                  =  4     
ENT.IgnitionDelay                    =  1            
ENT.ArmDelay                         =  0.1                      
ENT.ForceOrientation                 =  "UP"
ENT.Timer                            =  0
ENT.ExplodeDelay                     =  2
ENT.GBOWNER                          =  nil
ENT.SkinNumber                       =  4


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
