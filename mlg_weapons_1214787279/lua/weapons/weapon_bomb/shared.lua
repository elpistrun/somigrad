--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/mlg_weapons_1214787279/lua/weapons/weapon_bomb/shared.lua <
    > Callstack:  <
]]

-- "addons\\mlg_weapons_1214787279\\lua\\weapons\\weapon_bomb\\shared.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
SWEP.base = "weapon_base"
SWEP.PrintName 		= "C4"
SWEP.Author 		= "Hobo_Gus"
SWEP.Instructions 	= ""
SWEP.Purpose 		= "Allah Akbar"
SWEP.AdminSpawnable = true
SWEP.Spawnable 		= true
SWEP.ViewModelFOV 	= 55
SWEP.UseHands = true
SWEP.ViewModel 		= Model( "models/weapons/cstrike/c_c4.mdl" )
SWEP.WorldModel 	= Model( "models/weapons/w_c4.mdl" )
SWEP.AutoSwitchTo 	= true
SWEP.AutoSwitchFrom = true
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.HoldType = "Slam"
SWEP.FiresUnderwater = false
SWEP.Weight = 5
SWEP.DrawCrosshair = false
SWEP.Category = "MLG"
SWEP.DrawAmmo = false

//PrimaryFire Settings\\ 
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 5
SWEP.Primary.ClipSize = -1
SWEP.Primary.ClipMax = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false

function SWEP:PrimaryAttack()
   self:SetNextPrimaryFire( CurTime() + 4 )
   self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

   if ( SERVER ) then
timer.Simple( 1.5, function()
	  self.Owner:EmitSound( "shout"..math.random(1,3)..".wav" )
end )
timer.Simple( 3, function()
	  
local ent = ents.Create( "env_explosion" )
   ent:SetPos( self.Owner:GetPos() )
   ent:SetOwner( self.Owner )
   ent:SetKeyValue( "iMagnitude", "200" )
   ent:Spawn()
   ent:Fire( "Explode", 0, 0 )
   ent:EmitSound( "explosion.wav", 500, 500 )
   self:Remove()
   
   local effectdata = EffectData()
   effectdata:SetOrigin( self.Owner:GetPos() )
   effectdata:SetNormal( self.Owner:GetShootPos() )
   util.Effect( "hg_jihad_boom", effectdata )
   
end )
      
   end
end

function SWEP:SecondaryAttack()
end
