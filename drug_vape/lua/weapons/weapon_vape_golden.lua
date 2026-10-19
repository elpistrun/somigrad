--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/drug_vape/lua/weapons/weapon_vape_golden.lua <
    > Callstack:  <
]]

-- "addons\\drug_vape\\lua\\weapons\\weapon_vape_golden.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
-- weapon_vape_golden.lua
-- Defines a vape with gold accent and shaded tank

-- Vape SWEP by Swamp Onions - http://steamcommunity.com/id/swamponions/

if CLIENT then
	include('weapon_vape/cl_init.lua')
else
	include('weapon_vape/shared.lua')
end

SWEP.PrintName = "Vape Golden"

SWEP.Instructions = "LMB: Rip Fat Clouds\n (Hold and release)\nRMB & Reload: Play Sounds\n\nAn elegant, golden vape for the classy cloud chaser."

SWEP.VapeAccentColor = Vector(1,0.8,0)
SWEP.VapeTankColor = Vector(0.1,0.1,0.1)
