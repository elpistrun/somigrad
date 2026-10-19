--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/mlg_weapons_1214787279/lua/weapons/weapon_357_hg/shared.lua <
    > Callstack:  <
]]

-- "addons\\mlg_weapons_1214787279\\lua\\weapons\\weapon_357_hg\\shared.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
//General Variables\\
SWEP.Base = "hobogus_base"

SWEP.AdminSpawnable = true

SWEP.AutoSwitchTo = false
SWEP.Slot = 2
SWEP.PrintName = "357"
SWEP.Author = "Hobo_Gus"
SWEP.Spawnable = true
SWEP.AutoSwitchFrom = false
SWEP.FiresUnderwater = false
SWEP.Weight = 5
SWEP.DrawCrosshair = true
SWEP.Category = "MLG"
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.Instructions = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.HoldType = "revolver"
SWEP.ViewModelFOV = 55
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/c_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"
SWEP.UseHands = true
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true

SWEP.IronFOV = 0
SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_L_UpperArm"] = { scale = Vector(1, 1, 1), pos = Vector(5.202, -11.098, 16.301), angle = Angle(-27, -58.266, 48) },
	["ValveBiped.Bip01_L_Finger0"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-11.94, -28.469, 13.776) },
	["ValveBiped.Bip01_L_Forearm"] = { scale = Vector(1, 1, 1), pos = Vector(-1.607, 1.684, 2.9), angle = Angle(0, 0.917, -2.756) },
	["ValveBiped.Bip01_L_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-16.647, -35.376, 64.509) }
}
	
SWEP.IronSightsPos = Vector(7.599, 0, -5.04)
SWEP.IronSightsAng = Vector(8.675, 15.854, -2.095)

//General Variables\\
SWEP.PrimaryReloadSound = Sound("Weapon_SMG1.Reload")
SWEP.PrimarySound = Sound("weapons/357/357_fire3.wav")

//Primary Fire Variables\\
SWEP.Primary.Damage = 45
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 6
SWEP.Primary.Ammo = "357"
SWEP.Primary.DefaultClip = 16
SWEP.Primary.Spread = 1
SWEP.Primary.Cone = 0.4
SWEP.IronCone = 0.3
SWEP.DefaultCone = 0.4
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = 3
SWEP.Primary.Delay = 0.1
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

print ('357')
