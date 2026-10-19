--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/screen_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\screen_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
net.Receive("loadscreen",function()
	roundScreenName = net.ReadString()
	roundScreenName2 = net.ReadString()

	roundStart = true
end)

net.Receive("loadscreen_end",function()
	roundStart = false
end)

local white = Color(255,255,255)

hook.Add("PostDrawHUD","Start Round",function()
	if not roundStart then return end

	local w,h = ScrW(),ScrH()
	surface.SetDrawColor(0,0,0,225)
	surface.DrawRect(0,0,w,h)

	-- Показываем "Следующий режим: [название]"
	local text = L("hud_level_next", L(roundScreenName2 or roundScreenName))
	draw.SimpleText(text,"H.45",w / 2,h / 2,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
end)
