--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/nextbots/nav_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad\\lua\\hinit\\nextbots\\nav_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
AdminPanel_Command_Registry("navgenerate",{},nil,nil,"rcon")

surface.CreateFont("alternateHUD", {
	font = "Arial",
	size = 56
})

surface.CreateFont("alternateHUDSmall", {
	font = "Arial",
	size = 24
})

local function string_ToHMS(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds / 60) % 60)
	local seconds = math.floor(seconds % 60)

	if hours > 0 then
		return string.format("%02d:%02d:%02d", hours, minutes, seconds)
	else
		return string.format("%02d:%02d", minutes, seconds)
	end
end

local flavourTexts = {
	{
		"Gotta learn fast!",
		"Learning this'll be a piece of cake!",
		"This is too easy."
	}, {
		"This must be a big map.",
		"This map is a bit bigger than I thought.",
	}, {
		"Just how big is this place?",
		"This place is pretty big."
	}, {
		"This place is enormous!",
		"A guy could get lost around here."
	}, {
		"Surely I'm almost done...",
		"There can't be too much more...",
		"This isn't gm_bigcity, is it?",
		"Is it over yet?",
		"You never told me the map was this big!"
	}
}

local SECONDS_PER_BRACKET = 300 -- 5 minutes
local color_yellow = Color(255, 255, 80)
local flavourText = ""
local lastBracket = 0
local generateStart = 0
local function navGenerateHUDOverlay()
	draw.SimpleTextOutlined("nextbot is studying this map.", "alternateHUD",
		ScrW() / 2, ScrH() / 2, color_white,
		TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, color_black)
	draw.SimpleTextOutlined("Please wait...", "alternateHUD",
		ScrW() / 2, ScrH() / 2, color_white,
		TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, color_black)

	local elapsed = SysTime() - generateStart
	local elapsedStr = string_ToHMS(elapsed)
	draw.SimpleTextOutlined("Time Elapsed:", "alternateHUDSmall",
		ScrW() / 2, ScrH() * 3/4, color_white,
		TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
	draw.SimpleTextOutlined(elapsedStr, "alternateHUDSmall",
		ScrW() / 2, ScrH() * 3/4, color_white,
		TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)

	-- It's taking a while.
	local textBracket = math.floor(elapsed / SECONDS_PER_BRACKET) + 1
	if textBracket ~= lastBracket then
		flavourText = table.Random(flavourTexts[math.min(5, textBracket)])
		lastBracket = textBracket
	end
	draw.SimpleTextOutlined(flavourText, "alternateHUDSmall",
		ScrW() / 2, ScrH() * 4/5, color_yellow,
		TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
end

net.Receive("nextbot_navgen", function()
	local startSuccess = net.ReadBool()
	if startSuccess then
		generateStart = SysTime()
		lastBracket = 0
		hook.Add("HUDPaint", "alternateNavGenOverlay", navGenerateHUDOverlay)
	else
		Derma_Message("Oh no. alternate doesn't even know where to start with \z
		this map.\n\z
		If you're not running the Sandbox gamemode, switch to that and try \z
		again.", "Error!")
	end
end)

local nagMe = true

local function requestNavGenerate()
	RunConsoleCommand("nextbot_navgenerate")
end

local function stopNagging()
	nagMe = false
end

local function navWarning()
	Derma_Query("It will take a while (possibly hours) for alternate to figure \z
		this map out.\n\z
		While he's studying it, you won't be able to play,\n\z
		and the game will appear to have frozen/crashed.\n\z
		\n\z
		Also note that THE MAP WILL BE RESTARTED.\n\z
		Anything that has been built will be deleted.", "Warning!",
		"Go ahead!", requestNavGenerate,
		"Not right now.", nil)
end

net.Receive("nextbot_nav", function()
	if not nagMe then return end

	if game.SinglePlayer() then
		Derma_Query("Uh oh! alternate doesn't know this map.\n\z
			Would you like him to learn it?",
			"This map is not yet alternate-compatible!",
			"Yes", navWarning,
			"No", nil,
			"No. Don't ask again.", stopNagging)
	else
		Derma_Query("Uh oh! alternate doesn't know this map. \z
			He won't be able to move!\n\z
			Because you're not in a single-player game, he isn't able to \z
			learn it.\n\z
			\n\z
			Ask the server host about teaching this map to alternate.\n\z
			\n\z
			If you ARE the server host, you can run npc_alternate_learn over \z
			rcon.\n\z
			Keep in mind that it may take hours during which you will be \z
			unable\n\z
			to play, and THE MAP WILL BE RESTARTED.",
			"This map is currently not alternate-compatible!",
			"Ok", nil,
			"Ok. Don't say this again.", stopNagging)
	end
end)
