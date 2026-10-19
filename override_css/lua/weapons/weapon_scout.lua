--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/override_css/lua/weapons/weapon_scout.lua <
    > Callstack:  <
]]

-- "addons\\override_css\\lua\\weapons\\weapon_scout.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
if ( CLIENT ) then

	SWEP.PrintName			= "Scout"			
	SWEP.Author				= "Counter-Strike"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 0
	SWEP.IconLetter			= "n"
	
	killicon.AddFont( "weapon_scout", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
	
end
SWEP.Slot				= 3

SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_cs_base"
SWEP.Category			= "Counter-Strike"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/cstrike/c_snip_scout.mdl"
SWEP.WorldModel			= "models/weapons/w_snip_scout.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound( "Weapon_scout.Single" )
SWEP.Primary.Recoil			= 4
SWEP.Primary.Damage			= 70
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.0005
SWEP.Primary.ClipSize		= 15
SWEP.Primary.Delay			= 1.56
SWEP.Primary.DefaultClip	= 45
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "smg1"

SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos 		= Vector( 6.1, -7, 2.5 )
SWEP.IronSightsAng 		= Vector( 2.8, 0, 0 )

SWEP.Scope = true
SWEP.ScopedFOV = 25

function SWEP:PrimaryAttack2() -- secondary primary attack so we don't override the default base one
	timer.Simple( self.Primary.Delay*0.9, function() 
			if self.Weapon then
				self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
			end
		end )
	if self:GetIronsights() then
		timer.Simple(self.Primary.Delay/1.5, function()
			if IsValid(self) then
				self:SetIronsights( true, true )
			end
		end)
	end
	self:SetIronsights( false, true )
end
function SWEP:SecondaryAttack2()
	if self then
		self:SetIronsights( not self:GetIronsights() )
	end
end

