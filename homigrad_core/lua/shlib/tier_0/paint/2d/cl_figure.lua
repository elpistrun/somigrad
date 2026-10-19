--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_0/paint/2d/cl_figure.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_0\\paint\\2d\\cl_figure.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local constructManual = {
    "circle",
    "circle_contr",

    "romb",
    "romb_contr",
    
    "star",
    "star_contr",

    "triangle",
    "triangle_contr"
}

local pngParametrs = "mips"
local materials = {}

for i,name in pairs(constructManual) do
	materials[name] = Material("homigrad/vgui/models/" .. name .. ".png",pngParametrs)
end

local SetMaterial = surface.SetMaterial
local DrawTexturedRectRotated = surface.DrawTexturedRectRotated

materials.loading = Material("homigrad/vgui/loading.png",pngParametrs)

function surface.SetFigure(name)
    SetMaterial(materials[name])
end

function draw.Figure(x,y,w,h,r)
    DrawTexturedRectRotated(x,y,w,h,r or 0)
end
