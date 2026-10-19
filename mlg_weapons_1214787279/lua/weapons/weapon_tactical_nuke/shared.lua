--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/mlg_weapons_1214787279/lua/weapons/weapon_tactical_nuke/shared.lua <
    > Callstack:  <
]]

-- "addons\\mlg_weapons_1214787279\\lua\\weapons\\weapon_tactical_nuke\\shared.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal

SWEP.Category				= "MLG"
SWEP.Author				= "Hobo_Gus"
SWEP.Contact				= ""
SWEP.Purpose				= "REKT"
SWEP.Instructions				= ""
SWEP.PrintName				= "TACTICAL NUKE"		
SWEP.Slot				= 4			
SWEP.SlotPos				= 32		
SWEP.DrawAmmo				= true		
SWEP.DrawWeaponInfoBox			= false		
SWEP.BounceWeaponIcon   		= 	false	
SWEP.DrawCrosshair			= true		
SWEP.Weight				= 30	
SWEP.AutoSwitchTo			= true		
SWEP.AutoSwitchFrom			= true		
SWEP.HoldType 				= "rpg"		
SWEP.UseHands = true

SWEP.ViewModelFOV			= 55
SWEP.ViewModelFlip			= false
SWEP.ViewModel				= "models/weapons/c_rpg.mdl"	-- Weapon view model
SWEP.WorldModel				= "models/weapons/w_rpg.mdl"	-- Weapon world model
SWEP.ShowWorldModel			= false
SWEP.Base				= "hobogus_base"
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
SWEP.FiresUnderwater 		= false

SWEP.Primary.Sound			= Sound("")	
SWEP.Primary.ClipSize			= 1		
SWEP.Primary.DefaultClip		= 4	
SWEP.Primary.KickUp				= 1		
SWEP.Primary.KickDown			= 0		
SWEP.Primary.KickHorizontal		= 0		
SWEP.Primary.Automatic			= true		
SWEP.Primary.Ammo			= "RPG_Round"			
SWEP.Secondary.Automatic			= true	
SWEP.Laser = 1

SWEP.Primary.Round 			= ("tactical_nuke")	
//SWEP.Primary.Round 			= ("mlgeddon")	

SWEP.Primary.NumShots	= 0	
SWEP.Primary.Damage		= 0
SWEP.Primary.Spread		= 0
SWEP.Primary.IronAccuracy = 0

function SWEP:PrimaryAttack()
	if self:CanPrimaryAttack() then
		self.Weapon:EmitSound(Sound("tactical nuke.mp3"))
		self.Weapon:TakePrimaryAmmo(1)
		self.Weapon:SetNextPrimaryFire(CurTime()+50)
		timer.Simple(5.5, function()
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		self:FireR()
		end)
	end
end

function SWEP:FireR()
	local aim = self.Owner:GetAimVector()
	local side = aim:Cross(Vector(0,0,1))
	local up = side:Cross(aim)
	local pos = self.Owner:GetShootPos() + side * 12 - up * 9

	if SERVER then
	local rocket = ents.Create(self.Primary.Round)
	if !rocket:IsValid() then return false end
	rocket:SetAngles(aim:Angle()+Angle(0,0,0))
	rocket:SetPos(pos)
	rocket:SetOwner(self.Owner)
	rocket:Spawn()
	rocket:Activate()
	end
end

function SWEP:SecondaryAttack()
end	

