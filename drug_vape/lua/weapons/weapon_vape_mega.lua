--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/drug_vape/lua/weapons/weapon_vape_mega.lua <
    > Callstack:  <
]]

-- "addons\\drug_vape\\lua\\weapons\\weapon_vape_mega.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
-- weapon_vape_mega.lua
-- Defines a big vape that makes massive clouds (admin only recommended)

-- Vape SWEP by Swamp Onions - http://steamcommunity.com/id/swamponions/

if CLIENT then
	include('weapon_vape/cl_init.lua')
else
	include('weapon_vape/shared.lua')
end

SWEP.PrintName = "Vape Mega"

SWEP.Instructions = "LMB: Rip MASSIVE Clouds\n (Hold and release)\nRMB & Reload: Play Sounds\n\nOriginally developed for military use, this powerful vape quickly creates a large vape-screen ideal for concealment."

SWEP.AdminOnly = true

SWEP.VapeID = 2

SWEP.SoundPitchMod = -30

SWEP.VapeScale = 2.5

SWEP.VapeVMPos1 = Vector(15,-3,-1.5)

SWEP.VapeVMPos2 = Vector(18,-6,-9)

--HOT ROD VAPE
SWEP.VapeAccentColor = Vector(1,0,0.3)
SWEP.VapeTankColor = Vector(0.1,0.1,0.1)

function SWEP:PrimaryAttack()
	if SERVER then
		VapeUpdate(self.Owner, self.VapeID)
	end
	--Takes slightly longer to breathe
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.15)
end
