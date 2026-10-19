--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/fog_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\fog_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
--local diffDis = list2[game.GetMap()]
local adddis = 0

local fogMode = render.FogMode
local fogStart = render.FogStart
local fogEnd = render.FogEnd
local fogMaxDensity = render.FogMaxDensity
local fogColor = render.FogColor

AdminPanel_Command_Registry("fog",{"number","number","number","number"},"game",nil,"mapData")

hook.Add("SetupFog","ZFog",function()
	local dis = GetGlobalVar("Fog Dis")

	if not dis or dis <= 0 then return end

	local content = util.PointContents(EyePos())
	if
		((bit.band(content,CONTENTS_SOLID) == CONTENTS_SOLID) and
		(LocalPlayer():GetMoveType() == MOVETYPE_NOCLIP and not LocalPlayer():InVehicle()))
	then
		return
	end
	
	return dis,GetGlobalVar("Fog Color")
end)

event.Add("PreCalcView","Fog",function(ply,view)
	local dis = hook.Run("SetupFog")
	if not dis then return end

	view.zfar = dis + 100
end,-10)

hook.Add("SetupWorldFog","shlib",function()
	local dis,color = hook.Run("SetupFog")
	if not dis then return end

	fogMode(MATERIAL_FOG_LINEAR)
	fogStart(dis / 16)
	fogEnd(dis - 25)
	fogMaxDensity(1)

	fogColor(color[1],color[2],color[3],255)

	return true
end)

local ang = Angle(0,0,0)

local white = Color(255,255,255)
local mat = Material("color")

local surface_SetMaterial = surface.SetMaterial
local surface_SetDrawColor = surface.SetDrawColor
local render_SetColorMaterial = render.SetColorMaterial
local render_DrawQuadEasy = render.DrawQuadEasy

hook.Add("PostDrawOpaqueRenderables","shlib",function()
	local dis,color = hook.Run("SetupFog")
	if not dis then return end

	local vec = EyePos():Add(Vector(dis,0,0):Rotate(EyeAngles()))

	local normal = EyePos():Sub(vec):GetNormalized()
    local color = color
	surface_SetDrawColor(155,155,155,255)
	surface_SetMaterial(mat)
	render_SetColorMaterial()

	render_DrawQuadEasy(vec,normal,100000,100000,white)
end)

concommand.Add("hg_fog",function(ply)
	local dis,color = hook.Run("SetupFog")
	if not dis then return end
	
    print(dis)
    print(color)
end)

