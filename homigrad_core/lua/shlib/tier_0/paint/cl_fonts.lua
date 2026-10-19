--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_0/paint/cl_fonts.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_0\\paint\\cl_fonts.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local hg_screensize = CreateClientConVar("hg_screensize","1",true,false,"",0.25,4)

ScreenSize = hg_screensize:GetFloat()

cvars.AddChangeCallback("hg_screensize",function(_,_,new)
	ScreenSize = tonumber(new or 1) or 1

    event.Run("Screen Size",ScreenSize)
end,"main")

event.Add("Screen Size","Fonts",function(mul)
	surface.CreateFont("H.12",{
		font = "Arial",
		size = math.ceil(12 * mul),
		weight = 3000,
		bold = true,
	})

	surface.CreateFont("H.18",{
		font = "Arial",
		size = math.ceil(18 * mul),
		weight = 3000
	})

	surface.CreateFont("HO.18",{
		font = "Arial",
		size = math.ceil(18 * mul),
		weight = 3000
	})

	surface.CreateFont("H.25",{
		font = "Arial",
		size = math.ceil(25 * mul),
		weight = 3000
	})

	surface.CreateFont("H.45",{
		font = "Arial",
		size = math.ceil(45 * mul),
		weight = 3000
	})

	--

	surface.CreateFont("HS.18",{
		font = "Arial",
		size = math.ceil(18 * mul),
		weight = 1100,
		shadow = true
	})

	surface.CreateFont("HOS.18",{
		font = "Arial",
		size = math.ceil(18 * mul),
		weight = 1100,
		shadow = true
	})

	surface.CreateFont("HS.25",{
		font = "Arial",
		size = math.ceil(25 * mul),
		weight = 1100,
		shadow = true
	})

	surface.CreateFont("HS.45",{
		font = "Arial",
		size = math.ceil(45 * mul),
		weight = 1100,
		shadow = true
	})

	surface.CreateFont("HS.12",{
		font = "Arial",
		size = math.ceil(12 * mul),
		weight = 1000,
		shadow = true
	})
	
	surface.ClearFontCache()
end)

hook.Add("InitPostEntity","Screen Size",function()
	ScreenSize = hg_screensize:GetFloat()

	event.Run("Screen Size",ScreenSize)
end)
