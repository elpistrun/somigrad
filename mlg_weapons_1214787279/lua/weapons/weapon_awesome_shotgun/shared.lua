--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/mlg_weapons_1214787279/lua/weapons/weapon_awesome_shotgun/shared.lua <
    > Callstack:  <
]]

-- "addons\\mlg_weapons_1214787279\\lua\\weapons\\weapon_awesome_shotgun\\shared.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
//Shotgun
SWEP.Base = "hobogus_base"

SWEP.AdminSpawnable = true

SWEP.AutoSwitchTo = false
SWEP.Slot = 3
SWEP.PrintName = "Fuck-Off"
SWEP.Author = "Hobo_Gus"
SWEP.Spawnable = true
SWEP.AutoSwitchFrom = false
SWEP.FiresUnderwater = false
SWEP.Weight = 5
SWEP.DrawCrosshair = false
SWEP.Category = "MLG"
SWEP.SlotPos = 2
SWEP.DrawAmmo = true
SWEP.Instructions = ""
SWEP.Contact = ""
SWEP.Purpose = "Fuck them all"
SWEP.HoldType = "pistol"
SWEP.ViewModelFOV = 55
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/c_shotgun.mdl"
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"
SWEP.UseHands = true
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_L_Clavicle"] = { scale = Vector(1, 1, 1), pos = Vector(2, 8, 0), angle = Angle(45, -45, -5) },
	["ValveBiped.Bip01_L_UpperArm"] = { scale = Vector(1, 1, 1), pos = Vector(10, 0, 0), angle = Angle(-15, -15, 0) },
	["ValveBiped.Bip01_R_Forearm"] = { scale = Vector(1, 1, 1), pos = Vector(1, 0, 0), angle = Angle(0, 35, 0) },
	["ValveBiped.Bip01_L_Finger01"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 25, 0) },
	["ValveBiped.Bip01_L_Finger02"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 55, 0) },
	["ValveBiped.Bip01_L_Finger1"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -45, 0) },
	["ValveBiped.Bip01_L_Finger12"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -45, 0) },
	["ValveBiped.Bip01_L_Finger2"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 25, 0) },
	["ValveBiped.Bip01_L_Finger22"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 35, 0) },
	["ValveBiped.Bip01_L_Finger3"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(25, -15, 0) },
	["ValveBiped.Bip01_L_Finger32"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(25, -55, 0) },
	["ValveBiped.Bip01_L_Finger4"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(35, 0, -15) },
	["ValveBiped.Bip01_L_Finger42"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(25, -15, 0) },
	["ValveBiped.Bip01_L_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-6, -35, 0) }
}
	
SWEP.IronSightsPos = Vector(2, 1, 5)
SWEP.IronSightsAng = Vector(5, -30, 35)

SWEP.PrimarySound = Sound("weapons/shotgun/shotgun_fire7.wav")

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	self:ShootBulletInfo()
	local rnda = self.Primary.Recoil * 1
	local rndb = self.Primary.Recoil * math.random(-1, 1)
	self:ShootEffects()
	//self.Owner:FireBullets( bullet )
		local fx 		= EffectData()
		fx:SetEntity(self.Weapon)
		fx:SetOrigin(self.Owner:GetShootPos())
		fx:SetNormal(self.Owner:GetAimVector())
		fx:SetAttachment("1")
		util.Effect( self.ShotEffect ,fx)
self.Owner:EmitSound(self.PrimarySound)
if self.Owner:IsPlayer() then
	self.Owner:ViewPunch( Angle( rnda,rndb,rnda ) )
end
	self:TakePrimaryAmmo(self.Primary.TakeAmmo)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	//self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
end

//General Variables\\
//SWEP.PrimaryReloadSound = Sound("Weapon_SMG1.Reload")

//Primary Fire Variables\\
SWEP.Primary.Damage = 15
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 6
SWEP.Primary.Ammo = "buckshot"
SWEP.Primary.DefaultClip = 154
SWEP.Primary.Spread = 1
SWEP.Primary.Cone = 0.3
SWEP.IronCone = 0.3
SWEP.DefaultCone = 0.3
SWEP.Primary.NumberofShots = 5
SWEP.Primary.Automatic = false
SWEP.Primary.Recoil = 6.5
SWEP.Primary.Delay = 1
SWEP.Primary.Force = 3
SWEP.Tracer = 5
SWEP.ShotEffect = "m9k_rg_muzzle_smoke_hg"

SWEP.IronFOV = 0

SWEP.Secondary.Ammo = "none"

function SWEP:Deploy()
	self:SendWeaponAnim( ACT_VM_DRAW )
	self:EmitSound( "weapons/shotgun/shotgun_cock.wav", 500, 100, 1, 2 )
	self:SetNextPrimaryFire( CurTime() + self:SequenceDuration() )
	//self.Weapon:EmitSound("weapons/draw_melee.wav")

	return true
end 

local IRONSIGHT_TIME = 1

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	self:SetIronsights(false)
	self:ShootBulletInfo()
	local rnda = self.Primary.Recoil * 1
	local rndb = self.Primary.Recoil * math.random(-1, 1)
	self:ShootEffects()
	//self.Owner:FireBullets( bullet )
		local fx 		= EffectData()
		fx:SetEntity(self.Weapon)
		fx:SetOrigin(self.Owner:GetShootPos())
		fx:SetNormal(self.Owner:GetAimVector())
		fx:SetAttachment("1")
		util.Effect( self.ShotEffect ,fx)
self.Owner:EmitSound(self.PrimarySound)
if self.Owner:IsPlayer() then
	self.Owner:ViewPunch( Angle( rnda,rndb,rnda ) )
end
	self:TakePrimaryAmmo(self.Primary.TakeAmmo)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	//self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	timer.Simple(0.3, function() 
	self:SendWeaponAnim( ACT_SHOTGUN_PUMP )
	self:EmitSound( "weapons/shotgun/shotgun_cock.wav", 500, 100, 1, 2 )
	end)
end

function SWEP:Reload()
self:SetIronsights( true )
	self.Weapon:DefaultReload(ACT_SHOTGUN_PUMP)

		if (self.Weapon:Clip1() < self.Primary.ClipSize) and (self.Owner:GetAmmoCount(self.Primary.Ammo) > 0) then

		//self:SetIronsights(false)
				self.Zoomed = false
		if SERVER then
			self.Owner:SetFOV( 0, 0.3 ) -- Setting to 0 resets the FOV
		end
		
		self:EmitSound( "weapons/shotgun/shotgun_cock.wav", 500, 100, 1, 2 )
		//self:EmitSound( self.PrimaryReloadSound, 500, 100, 1, 1 )
		
		if not (CLIENT) then

			self.Owner:DrawViewModel(true)

		end
	timer.Simple(1, function() 
	self:SendWeaponAnim( ACT_SHOTGUN_PUMP )
	self:SetIronsights(false)
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.6 )
	end)
	end
end

print ('FuckOff')
