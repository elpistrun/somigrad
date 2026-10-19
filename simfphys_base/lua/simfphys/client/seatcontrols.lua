--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/simfphys_base/lua/simfphys/client/seatcontrols.lua <
    > Callstack: addons/simfphys_base/lua/simfphys/init.lua:32
[C]:-1
addons/simfphys_base/lua/autorun/simfphys_init.lua:4 <
]]

local pressedkeys = {}
local chatopen = false
local spawnmenuopen = false
local contextmenuopen = false

local function lockControls( bLock )
	-- The server that owns this addon is responsible for pooling "simfphys_blockcontrols".
	-- If it's absent (mismatched/removed addon, or we have no netchannel after a disconnect),
	-- net.Start would throw "Calling net.Start with unpooled message name!" every time a menu opens.
	if util.NetworkStringToID( "simfphys_blockcontrols" ) == 0 then return end

	net.Start("simfphys_blockcontrols")
		net.WriteBool( bLock )
	net.SendToServer()
end

hook.Add( "OnContextMenuOpen", "simfphys_seatswitching_cmenuopen", function()
	contextmenuopen = true
	lockControls( true )
end)

hook.Add( "OnContextMenuClose", "simfphys_seatswitching_cmenuclose", function()
	contextmenuopen = false
	lockControls( false )
end)

hook.Add( "OnSpawnMenuOpen", "simfphys_seatswitching_menuopen", function()
	spawnmenuopen = true
	lockControls( true )
end)

hook.Add( "OnSpawnMenuClose", "simfphys_seatswitching_menuclose", function()
	spawnmenuopen = false
	lockControls( false )
end)

hook.Add( "FinishChat", "simfphys_seatswitching_chatend", function()
	chatopen = false
	lockControls( false )
end)

hook.Add( "StartChat", "simfphys_seatswitching_chatstart", function()
	chatopen = true
	lockControls( true )
end)

