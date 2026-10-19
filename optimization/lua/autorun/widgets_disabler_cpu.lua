--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/optimization/lua/autorun/widgets_disabler_cpu.lua <
    > Callstack:  <
]]

-- "addons\\optimization\\lua\\autorun\\widgets_disabler_cpu.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
hook.Add( "PreGamemodeLoaded", "widgets_disabler_cpu", function()
	function widgets.PlayerTick()
		-- empty
	end

	if timer.Exists("HostnameThink") then timer.Remove("HostnameThink") end
	if timer.Exists("CheckHookTimes") then timer.Remove("CheckHookTimes") end

	hook.Remove( "PlayerTick", "TickWidgets" )

	if SERVER then
		hook.Add("MouthMoveAnimation", "Optimization", function() return nil end)
		hook.Add("GrabEarAnimation", "Optimization", function() return nil end)
	end
end )
