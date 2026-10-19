--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/mlg_weapons_1214787279/lua/weapons/weapon_illuminati_cannon/shared.lua <
    > Callstack:  <
]]

-- "addons\\mlg_weapons_1214787279\\lua\\weapons\\weapon_illuminati_cannon\\shared.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
//General Variables\\
SWEP.Base = "hobogus_base"

SWEP.AdminSpawnable = true

SWEP.AutoSwitchTo = false
SWEP.Slot = 2
SWEP.PrintName = "ILLUMINATI GUN"
SWEP.Author = "Hobo_Gus"
SWEP.Spawnable = false
SWEP.AutoSwitchFrom = false
SWEP.FiresUnderwater = false
SWEP.Weight = 5
SWEP.DrawCrosshair = false
SWEP.Category = "MLG"
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.Instructions = "Shoot"
SWEP.Contact = ""
SWEP.Purpose = "BFG"
SWEP.HoldType = "physgun"
SWEP.ViewModelFOV = 55
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/c_physcannon.mdl"
SWEP.WorldModel = "models/weapons/w_physics.mdl"
SWEP.UseHands = true
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
	
SWEP.IronSightsPos = Vector(0.639, 0, -8.12)
SWEP.IronSightsAng = Vector(0, 0, 0)

//General Variables\\
SWEP.PrimaryReloadSound = Sound("Weapon_SMG1.Reload")
SWEP.PrimarySound = Sound("beams/beamstart5.wav")

//Primary Fire Variables\\
SWEP.Primary.Damage = 11
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 3
SWEP.Primary.Ammo = "ar2"
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Spread = 1
SWEP.Primary.Cone = 0.3
SWEP.IronCone = 0.3
SWEP.DefaultCone = 0.3
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Recoil = 55
SWEP.Primary.Delay = 1.5
SWEP.Primary.Force = 3
SWEP.Tracer = 2
SWEP.ShotEffect = "hg_mlg_hit"
SWEP.IronFOV = 0
SWEP.Laser = 1
function SWEP:Think()
end

SWEP.Secondary.Ammo = "none"

local IRONSIGHT_TIME = 0.17

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	//self:ShootBulletInfo()
local ent = ents.Create("illuminati_shot")
local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector():Angle()
	pos = pos +ang:Forward() *0 +ang:Right() *15 +ang:Up() *-5
	ent:SetPos(pos)
	ent:SetAngles(self.Owner:GetAimVector():Angle())
	ent:SetOwner(self.Weapon:GetOwner())
	ent:Spawn()
//ent:Activate()
	local rnda = self.Primary.Recoil * 1
	local rndb = self.Primary.Recoil * math.random(-1, 1)
	self:ShootEffects()
		local fx 		= EffectData()
		fx:SetEntity(self.Weapon)
		fx:SetOrigin(self.Owner:GetShootPos())
		fx:SetNormal(self.Owner:GetAimVector())
		fx:SetAttachment("1")
		util.Effect( self.ShotEffect ,fx)
		util.ScreenShake(self.Owner:GetPos(), 500, 500, 5, 500)
self.Owner:EmitSound(self.PrimarySound)
if self.Owner:IsPlayer() then
	self.Owner:ViewPunch( Angle( rnda,rndb,rnda ) )
end
	self:TakePrimaryAmmo(self.Primary.TakeAmmo)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
end

function SWEP:Reload()
         self.NextReload = self.NextReload or 0
         if ( self.NextReload > CurTime() ) then return end
         if ( self:Clip1() ~= self.Primary.ClipSize and self:Ammo1() ~= 0 ) then
		      self:SendWeaponAnim( ACT_VM_HOLSTER )
			  self:SetNetworkedInt( "Spin",0 )
			  self:SetNextPrimaryFire( CurTime() + 1.25 )
			  self:SetNextSecondaryFire( CurTime() + 1.25 )
			  self.NextReload = CurTime() + 1.25
			  self.Reloading = true
			  self:EmitSound( "TriggerSuperArmor.DoneCharging", 500, 100, 1, -1)
			  self:EmitSound( "WeaponDissolve.Dissolve", 500, 100, 1, -1)
			  self:EmitSound( "TriggerSuperArmor.DoneCharging", 500, 100, 1, -1)
			  self:EmitSound( "WeaponDissolve.Dissolve", 500, 100, 1, -1)
			  timer.Simple( 2.3,function()
			        if ( IsValid( self ) ) then
                         self:DefaultReload( ACT_VM_DRAW )
						 self.Reloading = false
						self:EmitSound( "PropJeep.FireCannon", 100, 80, 1, -1) 
							//self:SetIronsights(false)
					end
			  end )
		 end
end

SWEP.VElements = {
	["som+"] = { type = "Model", model = "models/props_combine/combine_fence01a.mdl", bone = "Base", rel = "", pos = Vector(4, 4.5, 11), angle = Angle(180, -120, 180), size = Vector(0.3, 0.3, 0.3), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["som++"] = { type = "Model", model = "models/props_combine/combine_fence01a.mdl", bone = "Base", rel = "", pos = Vector(-4, 4.5, 11), angle = Angle(180, 120, 180), size = Vector(0.3, 0.3, 0.3), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["light"] = { type = "Model", model = "models/props_combine/combine_light002a.mdl", bone = "Base", rel = "", pos = Vector(9, 2, -4), angle = Angle(0, -110, 90), size = Vector(0.3, 0.3, 0.3), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["bat+"] = { type = "Model", model = "models/Items/battery.mdl", bone = "Base", rel = "", pos = Vector(-3.5, 1, 3), angle = Angle(0, 130, 0), size = Vector(1.5, 1.5, 1.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["som"] = { type = "Model", model = "models/props_combine/combine_fence01a.mdl", bone = "Base", rel = "", pos = Vector(-0.5, -1, 11), angle = Angle(180, 0, 180), size = Vector(0.3, 0.3, 0.3), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["bat"] = { type = "Model", model = "models/Items/battery.mdl", bone = "Base", rel = "", pos = Vector(3.5, 1, 3), angle = Angle(0, 30, 0), size = Vector(1.5, 1.5, 1.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["con"] = { type = "Model", model = "models/props_combine/combine_interface001.mdl", bone = "Base", rel = "", pos = Vector(0, 6, -8), angle = Angle(-90, -90, 180), size = Vector(0.15, 0.15, 0.15), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["som+"] = { type = "Model", model = "models/props_combine/combine_fence01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(15, -3, -8), angle = Angle(0, 100, 90), size = Vector(0.2, 0.2, 0.2), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["con"] = { type = "Model", model = "models/props_combine/combine_interface001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4, 1, -2), angle = Angle(180, 15, -15), size = Vector(0.15, 0.15, 0.15), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["light"] = { type = "Model", model = "models/props_combine/combine_light002a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(8, -7, -9), angle = Angle(90, 0, 90), size = Vector(0.3, 0.3, 0.3), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["som+++"] = { type = "Model", model = "models/props_combine/combine_fence01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(15, 2, -3), angle = Angle(-130, 100, 90), size = Vector(0.2, 0.2, 0.2), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["bat"] = { type = "Model", model = "models/Items/battery.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(22, -1, -9), angle = Angle(-60, -80, 90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["som++"] = { type = "Model", model = "models/props_combine/combine_fence01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(15, -4, -3), angle = Angle(130, 100, 90), size = Vector(0.2, 0.2, 0.2), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["bat+"] = { type = "Model", model = "models/Items/battery.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(20, -6, -7), angle = Angle(-160, -80, 90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

function SWEP:SecondaryAttack()
//render.DrawSprite(self.Entity:GetPos(),math.Rand(300,100),40,White)
end

print ('ILLUMINATI')
