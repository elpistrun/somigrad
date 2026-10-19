--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/mlg_weapons_1214787279/lua/weapons/weapon_ump45_hg/shared.lua <
    > Callstack:  <
]]

-- "addons\\mlg_weapons_1214787279\\lua\\weapons\\weapon_ump45_hg\\shared.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
//General Variables\\
SWEP.Base = "hobogus_base"

SWEP.AdminSpawnable = true

SWEP.AutoSwitchTo = false
SWEP.Slot = 2
SWEP.PrintName = "UMP45"
SWEP.Author = "Hobo_Gus"
SWEP.Spawnable = true
SWEP.AutoSwitchFrom = false
SWEP.FiresUnderwater = false
SWEP.Weight = 5
SWEP.DrawCrosshair = false
SWEP.Category = "MLG"
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.Instructions = ""
SWEP.Contact = ""
SWEP.Purpose = "From CSS for you"
SWEP.HoldType = "smg"
SWEP.ViewModelFOV = 55
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/cstrike/c_smg_ump45.mdl"
SWEP.WorldModel = "models/weapons/w_smg_ump45.mdl"
SWEP.UseHands = true
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.Hitmarker = true
SWEP.HitmarkerSound = true

SWEP.IronFOV = 70
SWEP.ViewModelBoneMods = {
}
	
SWEP.IronSightsPos = Vector(-8.75, -7, 4.199)
SWEP.IronSightsAng = Vector(-1.5, -0.301, -2)

//General Variables\\
SWEP.PrimaryReloadSound = Sound("Weapon_SMG1.Reload")
SWEP.PrimarySound = Sound("weapons/ump45/ump45-1.wav")

//Primary Fire Variables\\
SWEP.Primary.Damage = 10
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 25
SWEP.Primary.Ammo = "smg1"
SWEP.Primary.DefaultClip = 80
SWEP.Primary.Spread = 1
SWEP.Primary.Cone = 0.6
SWEP.IronCone = 0.09
SWEP.DefaultCone = 0.6
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = 0.5
SWEP.Primary.Delay = 0.08
SWEP.Primary.Force = 3
SWEP.Tracer = 6
SWEP.ShotEffect = "m9k_rg_muzzle_rifle"

print ('UMP45')
