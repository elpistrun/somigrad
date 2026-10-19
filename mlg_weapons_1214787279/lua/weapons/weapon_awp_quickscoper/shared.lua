--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/mlg_weapons_1214787279/lua/weapons/weapon_awp_quickscoper/shared.lua <
    > Callstack:  <
]]

-- "addons\\mlg_weapons_1214787279\\lua\\weapons\\weapon_awp_quickscoper\\shared.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
//General Variables\\
SWEP.Base = "hobogus_base"

SWEP.AdminSpawnable = true

SWEP.AutoSwitchTo = false
SWEP.Slot = 4
SWEP.PrintName = "AWP Quickscoper"
SWEP.Author = "Hobo_Gus"
SWEP.Spawnable = true
SWEP.AutoSwitchFrom = false
SWEP.FiresUnderwater = false
SWEP.Weight = 5
SWEP.DrawCrosshair = false
SWEP.Category = "MLG"
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.Instructions = "Bl4z3 It - M1 - Qu!ck scope, M2 - N0 Sc0p3"
SWEP.Contact = ""
SWEP.Purpose = "XxX420GetR3Kt360N0Sc0p3dXxX"
SWEP.HoldType = "rpg"
SWEP.ViewModelFOV = 55
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/cstrike/c_snip_awp.mdl"
SWEP.WorldModel = "models/weapons/w_snip_awp.mdl"
SWEP.UseHands = true
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.LaserSight = 0
SWEP.Hitmarker = true
SWEP.HitmarkerSound = true
SWEP.ViewModelBoneMods = {
}
	
SWEP.IronSightsPos = Vector(-7.481, 0, 2.079)
SWEP.IronSightsAng = Vector(0, 0, 0)

SWEP.IronFOV = 55

//General Variables\\
SWEP.PrimaryReloadSound = Sound("Weapon_SMG1.Reload")
SWEP.PrimarySound = Sound("weapons/awp/awp1.wav" )

//Primary Fire Variables\\
SWEP.Primary.Damage = 550
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 10
SWEP.Primary.Ammo = "357"
SWEP.Primary.DefaultClip = 40
SWEP.Primary.Spread = 1
SWEP.Primary.Cone = 0.001
SWEP.IronCone = 0.001
SWEP.DefaultCone = 0.001
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Recoil = 0.7
SWEP.Primary.Delay = 2
SWEP.Primary.Force = 50
SWEP.Tracer = 6


local HitSound = {
"sweps/Hitmarker Sound.wav"
}

SWEP.Secondary.Ammo = "none"

SWEP.IronsightTime = 0.2

function SWEP:PrimaryCall()//���� ���� ���-�� ��������� � ��������, �� �� ����� ���� ���
	self:SetIronsights(true)
	     self.Owner:SetNWBool("ZoomComb", false)
		 self.zoom = false
         self.Zoomed = false
		if SERVER then
			self.Owner:SetFOV( self.IronFOV, 0.3 ) 
			
		end
		timer.Simple(0.3, function() 
		self:SetIronsights(false)
		if SERVER then
			self.Owner:SetFOV( 0, 0.3 ) 
			self.Zoomed = false
		end
	end)
end

function SWEP:SecondaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	self:ShootBulletInfo()
	local rnda = self.Primary.Recoil * 1
	local rndb = self.Primary.Recoil * math.random(-1, 1)
	self:ShootEffects()
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
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )

end

function SWEP:Reload()
	self.Weapon:DefaultReload(ACT_VM_RELOAD)

if (self.Weapon:Clip1() < self.Primary.ClipSize) and (self.Owner:GetAmmoCount(self.Primary.Ammo) > 0) then
			self.Weapon:SetNWBool("Reloading", false)

end
		self:SetIronsights(false)
		self.Zoomed = false
		self.Owner:SetNWBool("ZoomComb", false)
		self.zoom = false
		if SERVER then
			self.Owner:SetFOV( 0, 0.3 ) 
		end
		
		//self:EmitSound( self.PrimaryReloadSound, 500, 100, 1, 1 )
		
		if not (CLIENT) then

			self.Owner:DrawViewModel(true)

		end
		local waitdammit = (self.Owner:GetViewModel():SequenceDuration())
	timer.Simple(waitdammit + .1, 
	function() 
		if self.Weapon == nil then return end
		self.Weapon:SetNWBool("Reloading", true)
	end)
	
end

function SWEP:CustomHitFunc(attacker, tr, dmginfo)
	
	if (tr.Entity:IsNPC()) or (tr.Entity:IsPlayer()) then
	    local randomsounds = {
    "mlg/mlghit1.mp3",
    "mlg/mlghit2.mp3",
	"mlg/mlghit3.mp3",
	"mlg/mlghit4.mp3"
    }
   local random = math.random(1, #randomsounds)
   self.Owner:EmitSound(randomsounds[random])
		local fx 		= EffectData()
		fx:SetEntity(tr.Entity)
		fx:SetOrigin(tr.HitPos)
		fx:SetNormal(tr.HitNormal)
		util.Effect( "hg_mlg_hit" ,fx)
			local fxply 		= EffectData()
		fxply:SetEntity(self.Weapon)
		fxply:SetOrigin(self.Owner:GetShootPos())
		fxply:SetNormal(self.Owner:GetAimVector())
		util.Effect( "hg_mlg_hit" ,fxply)
		util.ScreenShake(self.Owner:GetPos(), 500, 500, 5, 500)
	end

end

print ('AWPQ')
