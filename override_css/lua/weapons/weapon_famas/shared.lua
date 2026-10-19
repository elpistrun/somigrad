--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/override_css/lua/weapons/weapon_famas/shared.lua <
    > Callstack:  <
]]

-- "addons\\override_css\\lua\\weapons\\weapon_famas\\shared.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
if ( CLIENT ) then

	SWEP.PrintName			= "Famas"			
	SWEP.Author				= "Counter-Strike"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 0
	SWEP.IconLetter			= "t"
	
	killicon.AddFont( "weapon_famas", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

end
SWEP.Slot				= 3

SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_cs_base"
SWEP.Category			= "Counter-Strike"



SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModelFlip      = false
SWEP.ViewModel			= "models/weapons/cstrike/c_rif_famas.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_famas.mdl"

SWEP.Weight				= 25


SWEP.Primary.Sound			= Sound( "Weapon_FAMAS.Single" )
SWEP.Primary.Recoil 		= 0.9
SWEP.Primary.Damage 		= 17
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 		= 0.001
SWEP.Primary.ClipSize 		= 25
SWEP.Primary.Delay 		= 0.075
SWEP.Primary.DefaultClip 	= 25 + 25*3
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 		= "smg1"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.IronSightsPos 		= Vector (-4.687, 2.3092, 1.3322)
SWEP.IronSightsAng 		= Vector (0.4011, -0.0735, -0.8375)
