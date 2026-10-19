--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/drgbase/lua/drgbase/modules/render.lua <
    > Callstack: addons/drgbase/lua/autorun/drgbase.lua:93
addons/drgbase/lua/autorun/drgbase.lua:110 <
]]

if SERVER then return end

function render.DrG_DrawSprite(sprite, pos, size, options)
	options = options or {}
	size = isnumber(size) and math.Clamp(size, 0, math.huge) or 100
	local normal = pos:DrG_Direction(isvector(options.origin) and options.origin or EyePos())
	normal.z = 0
	local material = DrGBase.Material(sprite)
	if material:IsError() then return end
	render.SetMaterial(material)
	local color = options.color or Color(255, 255, 255)
	if options.lighting then
		local light = (render.GetLightColor(pos)*255):ToColor()
		local p = ((light.r + light.g + light.b)/3)/255
		color = Color(color.r*p, color.g*p, color.b*p, color.a)
	end
	render.DrawQuadEasy(pos, normal, size, size, color, (options.rotation or 0) + 180)
end

