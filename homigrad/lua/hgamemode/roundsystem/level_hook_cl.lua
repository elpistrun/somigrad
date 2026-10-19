--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/level_hook_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\level_hook_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local function hooked(name,nameFunc)
	hook.Add(name,"level",function(...)
		if not ActiveLevel then return end//lol

		local func = ActiveLevel[nameFunc]
		if func then return func(ActiveLevel,...) end
	end,-1)
end

local function evented(name,nameFunc,prio)
	event.Add(name,"level",function(...)
		if not ActiveLevel then return end//lol
		
		local func = ActiveLevel[nameFunc]
		if func then return func(ActiveLevel,...) end
	end,prio or -1)
end

evented("Player Spawn","PlayerSpawn")
evented("Player Death","PlayerDeath")
evented("PreCalcView","PreCalcView",-10)
evented("Move","Move")

hooked("PlayerSwitchWeapon","PlayerSwitchWeapon")
hooked("OnContextMenuOpen","OnContextMenuOpen")
hooked("OnContextMenuClose","OnContextMenuClose")
hooked("CanUseSpectateHUD","CanUseSpectateHUD")

hooked("Think","Think")

hooked("OnPhysgunFreeze","OnPhysgunFreeze")
hooked("PhysgunDrop","PhysgunDrop")
hooked("PhysgunPickup","PhysgunPickup")
hooked("PostDrawTranslucentRenderables","PostDrawTranslucentRenderables")
hooked("Paint Content Icon","PaintContentIcon")
hooked("Scoreboard DMenu","ScoreboardDMenu")

hooked("Should Draw Screenspace","DrawScreenspace")

hooked("BodyCam","BodyCam")
hooked("SetupFog","SetupFog")

event.Add("View Back Weapon","level",function(ply,list)
	if not ply.IsPlayer or not ply:IsPlayer() then return end

	local level = TableLevel()
	local func = level.VBWHide
	if func then return func(level,ply,list) end
end)

evented("Can Use Spawn","CanUseSpawnMenu",9)
evented("Can Properties","CanUseContextMenu",9)

evented("Scoreborad Inventoru UI Create","ScoreboradInventoruUICreate")
evented("Pre Draw Sphere Ring","PreDrawSphereRing")
