--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/override_css/lua/weapons/weapon_ump45/shared.lua <
    > Callstack:  <
]]

-- "addons\\override_css\\lua\\weapons\\weapon_ump45\\shared.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
if ( CLIENT ) then

	SWEP.PrintName			= "UMP 45"			
	SWEP.Author				= "Counter-Strike"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 0
	SWEP.IconLetter			= "x"
	
	killicon.AddFont( "weapon_ump45", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
	
end

SWEP.Slot				= 3

SWEP.HoldType			= "smg"
SWEP.Base				= "weapon_cs_base"
SWEP.Category			= "Counter-Strike"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.ViewModel 			= "models/weapons/cstrike/c_smg_ump45.mdl"
SWEP.WorldModel 			= "models/weapons/w_smg_ump45.mdl"

SWEP.Primary.Sound 		= Sound("Weapon_UMP45.Single")
SWEP.Primary.Recoil 		= 0.7
SWEP.Primary.Damage 		= 22
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 		= 0.012
SWEP.Primary.ClipSize 		= 25
SWEP.Primary.Delay 		= 0.09
SWEP.Primary.DefaultClip 	= 25
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 		= "pistol"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.IronSightsPos 		= Vector(7.31,-2,3.285)
SWEP.IronSightsAng 		= Vector(-1.4,.245,2)

