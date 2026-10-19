--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/mlg_weapons_1214787279/lua/weapons/weapon_shahid/shared.lua <
    > Callstack:  <
]]

-- "addons\\mlg_weapons_1214787279\\lua\\weapons\\weapon_shahid\\shared.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
SWEP.Base = "hobogus_base"
SWEP.PrintName 		= "Shahid"
SWEP.Author 		= "Hobo_Gus"
SWEP.Instructions 	= ""
SWEP.Purpose 		= "Allah Akbar"
SWEP.AdminSpawnable = true
SWEP.Spawnable 		= true
SWEP.ViewModelFOV 	= 55
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_slam.mdl"
SWEP.WorldModel = "models/weapons/w_slam.mdl"
SWEP.AutoSwitchTo 	= true
SWEP.AutoSwitchFrom = true
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.HoldType = "Slam"
SWEP.FiresUnderwater = false
SWEP.Weight = 5
SWEP.DrawCrosshair = false
SWEP.Category = "MLG"
SWEP.DrawAmmo = false

SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_R_Finger41"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -23.924, 0) },
	["ValveBiped.Bip01_R_Finger1"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(14.81, -42.153, -5.697) },
	["ValveBiped.Bip01_R_Finger21"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 44.43, 0) },
	["ValveBiped.Bip01_R_Finger11"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -64.937, 0) },
	["ValveBiped.Bip01_R_Finger4"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-14.811, -5.697, -19.368) },
	["ValveBiped.Bip01_R_Forearm"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -10.254, 33.037) },
	["ValveBiped.Bip01_R_Finger31"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -35.317, 0) },
	["ValveBiped.Bip01_R_Finger3"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-3.418, -17.09, -14.811) },
	["ValveBiped.Bip01_R_Finger42"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -39.874, 0) },
	["ValveBiped.Bip01_R_Finger2"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 5.696, 0) },
	["ValveBiped.Bip01_R_Finger12"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -48.987, 0) },
	["Slam_base"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_R_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(21.645, -23.924, 5.696) }
}

SWEP.WElements = {
	["tnt++"] = { type = "Model", model = "models/dav0r/tnt/tnt.mdl", bone = "ValveBiped.Bip01_Spine", rel = "", pos = Vector(3, -6, 8), angle = Angle(90, 0, 0), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["tnt+"] = { type = "Model", model = "models/dav0r/tnt/tnt.mdl", bone = "ValveBiped.Bip01_Spine", rel = "", pos = Vector(3, -8, 4), angle = Angle(90, 0, 0), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["tnt"] = { type = "Model", model = "models/dav0r/tnt/tnt.mdl", bone = "ValveBiped.Bip01_Spine", rel = "", pos = Vector(3, -9, 0), angle = Angle(90, 0, 0), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["tnt+++"] = { type = "Model", model = "models/dav0r/tnt/tnt.mdl", bone = "ValveBiped.Bip01_Spine", rel = "", pos = Vector(3, -8, -4), angle = Angle(90, 0, 0), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

//PrimaryFire Settings\\ 
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 5
SWEP.Primary.ClipSize = -1
SWEP.Primary.ClipMax = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DEPLOY)
	//self:SetNextPrimaryFire( CurTime() + self:SequenceDuration() )
	self:SetHoldType( self.HoldType )	
	self:SetIronsights(false)
	self.Zoomed = false
	self.Weapon:SetNWBool("Reloading", true)
	return true
	
end

function SWEP:PrimaryAttack()
   self:SetNextPrimaryFire( CurTime() + 4 )
   self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)

   if ( SERVER ) then
local ent = ents.Create( "env_explosion" )
   ent:SetPos( self.Owner:GetPos() )
   ent:SetOwner( self.Owner )
   ent:SetKeyValue( "iMagnitude", "200" )
   ent:Spawn()
   ent:Fire( "Explode", 0, 0 )
   ent:EmitSound( "explosion.wav", 500, 500 )
   self:Remove()
   
   local effectdata = EffectData()
   effectdata:SetOrigin( self.Owner:GetPos() )
   effectdata:SetNormal( self.Owner:GetShootPos() )
   util.Effect( "hg_jihad_boom", effectdata )
      
   end
end

function SWEP:SecondaryAttack()
end
