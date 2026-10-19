--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/mlg_weapons_1214787279/lua/weapons/weapon_deagle_hg/shared.lua <
    > Callstack:  <
]]

-- "addons\\mlg_weapons_1214787279\\lua\\weapons\\weapon_deagle_hg\\shared.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
//General Variables\\
SWEP.Base = "hobogus_base"

SWEP.AdminSpawnable = true

SWEP.AutoSwitchTo = false
SWEP.Slot = 2
SWEP.PrintName = "Desert Eagle"
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
SWEP.HoldType = "revolver"
SWEP.ViewModelFOV = 65
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"
SWEP.UseHands = true
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.Hitmarker = true
SWEP.HitmarkerSound = true

SWEP.IronFOV = 70
SWEP.ViewModelBoneMods = {
}
	
SWEP.IronSightsPos = Vector(-6.361, 0, 2.119)
SWEP.IronSightsAng = Vector(0, 0, 0)

//General Variables\\
SWEP.PrimaryReloadSound = Sound("Weapon_SMG1.Reload")
SWEP.PrimarySound = Sound("weapons/deagle/deagle-1.wav")

//Primary Fire Variables\\
SWEP.Primary.Damage = 45
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 8
SWEP.Primary.Ammo = "357"
SWEP.Primary.DefaultClip = 16
SWEP.Primary.Spread = 1
SWEP.Primary.Cone = 0.8
SWEP.IronCone = 0.3
SWEP.DefaultCone = 0.8
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Recoil = 3
SWEP.Primary.Delay = 0.08
SWEP.Primary.Force = 6
SWEP.Tracer = 6
SWEP.ShotEffect = "m9k_rg_muzzle_rifle"

function SWEP:Deploy()
	self:SendWeaponAnim( ACT_VM_DRAW )
	self:SetNextPrimaryFire( CurTime() + self:SequenceDuration() )
	self:SetHoldType( self.HoldType )	
	self.Weapon:SetNWBool("Reloading", true)
	return true
	
end

print ('DEagle')
