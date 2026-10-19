--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/override_css/lua/weapons/weapon_smokegrenade/shared.lua <
    > Callstack:  <
]]

-- "addons\\override_css\\lua\\weapons\\weapon_smokegrenade\\shared.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
if (SERVER) then
        SWEP.Weight                     = 5
        SWEP.AutoSwitchTo               = false
        SWEP.AutoSwitchFrom             = false
end

if (CLIENT) then

        SWEP.PrintName                  = "Smoke Grenade"
        SWEP.Slot                               = 2
        SWEP.SlotPos                    = 0
        SWEP.DrawAmmo                   = false
        SWEP.DrawCrosshair              = false
        SWEP.ViewModelFOV                       = 65
        SWEP.ViewModelFlip              = false
        SWEP.CSMuzzleFlashes            = false

        SWEP.IconLetter                         = "P"
        killicon.AddFont("weapon_smokegrenade", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ))
end

SWEP.Slot                               = 2

SWEP.Base                                       = "weapon_grenade_base"

SWEP.Author                             = "kna_rus"
SWEP.Contact                            = ""
SWEP.Purpose                            = ""

SWEP.Spawnable                          = true
SWEP.AdminSpawnable                     = true

SWEP.ViewModel                          = "models/weapons/cstrike/c_eq_smokegrenade.mdl"
SWEP.WorldModel                                 = "models/weapons/w_eq_smokegrenade.mdl"

SWEP.Primary.ClipSize                   = -1
SWEP.Primary.DefaultClip                = -1
SWEP.Primary.Automatic                  = true
SWEP.Primary.Ammo                       = "none"

SWEP.Secondary.ClipSize                 = -1
SWEP.Secondary.DefaultClip              = -1
SWEP.Secondary.Automatic                = true
SWEP.Secondary.Ammo                     = "none"

SWEP.NadeClass = "ent_smokegrenade"
