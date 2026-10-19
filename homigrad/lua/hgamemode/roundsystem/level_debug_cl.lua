--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/level_debug_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\level_debug_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
concommand.Add("hg_dataround",function()
	PrintTable(roundData or {})
end)

concommand.Add("hg_enddataround",function()
	PrintTable(roundDataEnd or {})
end)

concommand.Add("hg_roundinfo",function()
	print("roundActive	" .. tostring(roundActive))
	print("roundActiveName	" .. tostring(roundActiveName))
	print("levelNextName	" .. tostring(levelNextName))

	print("roundTimeStart	" .. tostring(roundTimeStart))
	print("roundTime	" .. tostring(roundTime))

	if roundTimeStart and roundTime then
		print("time left	" .. tostring(math.Round(roundTimeStart + roundTime - CurTime())))
	end
end)
