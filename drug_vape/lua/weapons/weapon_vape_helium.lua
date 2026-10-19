--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/drug_vape/lua/weapons/weapon_vape_helium.lua <
    > Callstack:  <
]]

-- "addons\\drug_vape\\lua\\weapons\\weapon_vape_helium.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
-- weapon_vape_helium.lua
-- Defines a vape which makes the player float

-- Vape SWEP by Swamp Onions - http://steamcommunity.com/id/swamponions/

if CLIENT then
	include('weapon_vape/cl_init.lua')
else
	include('weapon_vape/shared.lua')
end

SWEP.Instructions = "LMB: Rip Fat Clouds\n (Hold and release)\nRMB & Reload: Play Sounds\n\nHelium-infused juice has a levitating effect when it enters the bloodstream."

SWEP.PrintName = "Vape Helium"

SWEP.VapeID = 4

--gets overridden
SWEP.SoundPitchMod = 60

SWEP.VapeAccentColor = Vector(0.9,1,0)
SWEP.VapeTankColor = Vector(0.2,0.3,0.5)

hook.Add( "HUDPaint", "VapeHeliumBar", function()
	if vapeHelium or 0 > 0 then
		local alpha = math.min(1, vapeHelium/10)
		draw.RoundedBox( 8, (ScrW()/2)-64, ScrH()-48, 128, 32, Color( 0, 0, 0, 128*alpha ) )
		draw.RoundedBox( 0, (ScrW()/2)-58, ScrH()-42, 1.16*vapeHelium, 20, Color( 0, 100, 200, 255*alpha ) )
		draw.DrawText("He", "DermaLarge", (ScrW()/2), ScrH()-84, Color( 255, 255, 255, 255*alpha ), TEXT_ALIGN_CENTER )
	end
end )
