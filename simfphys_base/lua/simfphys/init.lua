--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/simfphys_base/lua/simfphys/init.lua <
    > Callstack: addons/simfphys_base/lua/autorun/simfphys_init.lua:4 <
]]

if SERVER then
	AddCSLuaFile("simfphys/client/fonts.lua")
	AddCSLuaFile("simfphys/client/tab.lua")
	AddCSLuaFile("simfphys/client/hud.lua")
	AddCSLuaFile("simfphys/client/seatcontrols.lua")
	AddCSLuaFile("simfphys/client/lighting.lua")
	AddCSLuaFile("simfphys/client/damage.lua")
	AddCSLuaFile("simfphys/client/poseparameter.lua")
	
	AddCSLuaFile("simfphys/anim.lua")
	AddCSLuaFile("simfphys/base_functions.lua")
	AddCSLuaFile("simfphys/base_lights.lua")
	AddCSLuaFile("simfphys/base_vehicles.lua")
	AddCSLuaFile("simfphys/view.lua")
	
	include("simfphys/base_functions.lua")

	-- The server half of this addon is missing from this copy (only the AddCSLuaFile'd
	-- client files were retrieved), so include() would throw for each absent file:
	--   [simfphys_base] Couldn't include file 'simfphys\server\...' - File not found
	-- Only include what actually exists; the real server files can be restored later.
	local missingServer = {}

	for _, file_ in ipairs({
		"simfphys/server/exitpoints.lua",
		"simfphys/server/spawner.lua",
		"simfphys/server/seatcontrols.lua",
		"simfphys/server/poseparameter.lua",
		"simfphys/server/joystick.lua",
		"simfphys/server/damage.lua"
	}) do
		if file.Exists(file_, "LUA") then
			include(file_)
		else
			missingServer[#missingServer + 1] = file_
		end
	end

	if #missingServer > 0 then
		print("[simfphys_base] server half incomplete, skipped " .. #missingServer .. " file(s); re-install the official simfphys_base to restore server features.")
	end
end
	
if CLIENT then
	killicon.Add( "gmod_sent_vehicle_fphysics_base", "HUD/killicons/simfphys_car", Color( 255, 80, 0, 255 ) )

	include("simfphys/base_functions.lua")
	include("simfphys/client/fonts.lua")
	include("simfphys/client/tab.lua")
	include("simfphys/client/hud.lua")
	include("simfphys/client/seatcontrols.lua")
	include("simfphys/client/lighting.lua")
	include("simfphys/client/damage.lua")
	include("simfphys/client/poseparameter.lua")
end

include("simfphys/anim.lua")
include("simfphys/base_lights.lua")
include("simfphys/base_vehicles.lua")
include("simfphys/view.lua")

