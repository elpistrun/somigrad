--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/optimization/lua/autorun/client/fontchache.lua <
    > Callstack:  <
]]

-- "addons\\optimization\\lua\\autorun\\client\\fontchache.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SetFont = surface.SetFont
local GetTextSize = surface.GetTextSize
local font = "TargetID"

local cache = setmetatable({}, {
	__mode = "k"
})

timer.Create("surface.ClearFontCache", 1800, 0, function()
	surface.ClearFontCache()
end)

function surface.ClearFontCache()
	for key in pairs(cache) do cache[key] = nil end
end

function surface.SetFont(_font)
	font = _font

	return SetFont(_font)
end

function surface.GetTextSize(text)
	if text == nil or text == "" then return 1, 1 end

	if not cache[font] then
		cache[font] = {}
	end

	if not cache[font][text] then
		local w, h = GetTextSize(text)

		cache[font][text] = {
			w = w,
			h = h
		}

		return w, h
	end

	return cache[font][text].w, cache[font][text].h
end
