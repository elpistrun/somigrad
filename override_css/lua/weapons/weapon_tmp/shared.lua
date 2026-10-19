--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/override_css/lua/weapons/weapon_tmp/shared.lua <
    > Callstack:  <
]]

-- "addons\\override_css\\lua\\weapons\\weapon_tmp\\shared.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
if ( SERVER ) then
        SWEP.Knockback                  = 0.8
end

if ( CLIENT ) then

        SWEP.PrintName                  = "TMP"                 
        SWEP.Author                             = "Counter-Strike"
        SWEP.Slot                               = 0
        SWEP.SlotPos                    = 0
        SWEP.IconLetter                 = "d"
        
        killicon.AddFont( "weapon_tmp", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
        
end

SWEP.Slot				= 3

SWEP.HoldType                   = "ar2"

SWEP.Base                               = "weapon_cs_base"
SWEP.Category                   = "Counter-Strike"

SWEP.Spawnable                  = true
SWEP.AdminSpawnable             = true

SWEP.ViewModel                  = "models/weapons/cstrike/c_smg_tmp.mdl"
SWEP.WorldModel                 = "models/weapons/w_smg_tmp.mdl"

SWEP.Weight                             = 5
SWEP.AutoSwitchTo               = false
SWEP.AutoSwitchFrom             = false

SWEP.Primary.Sound                      = Sound( "Weapon_tmp.Single" )
SWEP.Primary.Recoil                     = 0.7
SWEP.Primary.Damage                     = 20
SWEP.Primary.NumShots           = 1
SWEP.Primary.Cone                       = 0.022
SWEP.Primary.ClipSize           = 25
SWEP.Primary.Delay                      = 0.075
SWEP.Primary.DefaultClip        = 50
SWEP.Primary.Automatic          = true
SWEP.Primary.Ammo                       = "smg1"

SWEP.Secondary.ClipSize         = -1
SWEP.Secondary.DefaultClip      = -1
SWEP.Secondary.Automatic        = false
SWEP.Secondary.Ammo                     = "none"

SWEP.IronSightsPos              = Vector( 5.3, -3, 2.6 )
