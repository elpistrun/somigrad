--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/drug_vape/lua/weapons/weapon_vape_medicinal.lua <
    > Callstack:  <
]]

-- "addons\\drug_vape\\lua\\weapons\\weapon_vape_medicinal.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
-- weapon_vape_medicinal.lua
-- Defines a vape that heals the player

-- Vape SWEP by Swamp Onions - http://steamcommunity.com/id/swamponions/

if CLIENT then
	include('weapon_vape/cl_init.lua')
else
	include('weapon_vape/shared.lua')
end

SWEP.PrintName = "Vape Medicinal"

SWEP.Instructions = "LMB: Rip Fat Clouds\n (Hold and release)\nRMB & Reload: Play Sounds\n\nThis healthy, organic juice has amazing healing abilities."

SWEP.VapeID = 3

SWEP.VapeAccentColor = Vector(0,1,0.5)
SWEP.VapeTankColor = Vector(0,0.5,0.25)

-- note: healing functionality is in weapon_vape/init.lua
