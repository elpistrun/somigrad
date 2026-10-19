--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/level_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\level_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
cvars.CreateOption("hg_sound_round","1")

showRoundInfo = 0

net.Receive("roundActiveName",function()
	showRoundInfo = RealTime() + 10
	roundActiveName = net.ReadString()

	ActiveLevel = Levels[roundActiveName]
end)

net.Receive("levelNextName",function()
	showRoundInfo = RealTime() + 10
	levelNextName = net.ReadString()
end)

net.Receive("roundActive",function()
	showRoundInfo = RealTime() + 10
	roundActive = net.ReadBool()
end)

local white = Color(255,255,255)
showRoundInfoColor = Color(255,255,255)
local yellow = Color(255,255,0)

hook.Add("HUDPaint","Level",function()
	if not InitNET then return end//иди нахуй
	
	local k = showRoundInfo - RealTime()

	k = math.max(k,0)

	showRoundInfoColor.a = k * 255
	yellow.a = showRoundInfoColor.a

	local w,h = ScrW(),ScrH()

	if roundActive then
		local func = ActiveLevel and ActiveLevel.HUDPaint

		if func then
			func(ActiveLevel,k)
		elseif roundTimeStart and roundTime then
			local time = math.Round(roundTimeStart + roundTime - CurTime())
			local acurcetime = string.FormattedTime(time,"%02i:%02i")
			if time < 0 then acurcetime = "акедумадекосай;3" end

			draw.SimpleText(acurcetime,"HS.18",w / 2,h - 25,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
	else
		draw.SimpleText(L("round_end"),"HS.18",w / 2,h - 25,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

	surface.SetFont("HS.18")

	local corner = 15 * ScreenSize

	local name,nextName = L("hud_level_active",L(roundActiveName)),L("hud_level_next",L(levelNextName or roundActiveName))

	local tw,th = surface.GetTextSize(#name > #nextName and name or nextName)

	tw = tw + corner * 2

	surface.SetDrawColor(0,0,0,255 * k)
	
	draw.GradientRight(w - tw,0,tw,th * 2 + corner * 2)

	draw.SimpleText(name,"HS.18",w - corner,corner,showRoundInfoColor,TEXT_ALIGN_RIGHT)
	draw.SimpleText(nextName,"HS.18",w - corner,corner + th,roundActiveName ~= levelNextName and yellow or showRoundInfoColor,TEXT_ALIGN_RIGHT)

	local err = GetGlobalString("Game Error") or ""
	if err == "" then return end

	if err == "stop_game" and LocalPlayer():Alive() then return end

	surface.SetDrawColor(255,0,0,125)

	local text = L(err)
	local tw,th = surface.GetTextSize(text)
	
	th = th * 2
	
	corner = corner * 2

	draw.GradientRight(w / 2 - tw,corner - th / 4,tw,th)
	draw.GradientLeft(w / 2,corner - th / 4,tw,th)

	draw.SimpleText(text,"HS.18",w / 2,corner,nil,TEXT_ALIGN_CENTER)
end)
