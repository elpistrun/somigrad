--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/roundsystem_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\roundsystem_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
net.Receive("roundData",function()
	showRoundInfo = RealTime() + 10

	roundData = net.ReadTable()
	roundTimeStart = net.ReadFloat()
	roundTime = net.ReadFloat()

	LevelCall("Sync",roundData)
end)

net.Receive("roundDataEnd",function()
	showRoundInfo = RealTime() + 10

	roundDataEnd = net.ReadTable()
end)

net.Receive("roundEmit",function()
	showRoundInfo = RealTime() + 10
	
	system.FlashWindow()
	
	if roundActive then
		StartRound()
	else
		EndRound()
	end
end)

function StartRound()
	RunConsoleCommand("stopsound")

	event.Run("Start Round")

	LevelCall("Start")
end

function EndRound()
	event.Run("End Round")

	LevelCall("End")
end
