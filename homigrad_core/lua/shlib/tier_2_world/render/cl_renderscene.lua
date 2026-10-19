--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_2_world/render/cl_renderscene.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_2_world\\render\\cl_renderscene.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
hook.Add("RenderScene","Homigrad",function(pos,angle,fov)
	local result = event.Call("RenderScene",pos,angle,fov)

	if result == "nil" then
		return
	else
		return result
	end
end)

if not render._origEnableClipping then
	render._origEnableClipping = render.EnableClipping
	function render.EnableClipping(b)
		return render._origEnableClipping(tobool(b))
	end
end

RenderView = {
	x = 0,
	y = 0,
	drawhud = false,
	drawviewmodel = true,
	dopostprocess = true,
	drawmonitors = false,
	bloomtone = true,

	aspectratio = 0
}

local inf = 0 / 0

local disable_render = false

cvars.CreateOption("hg_disable_render","0",function(value)
	disable_render = (tonumber(value or 0) or 0) > 0
end)

event.Add("RenderScene","Main",function(pos,angle,fov)
	if disable_render then return end

	local ply = LocalPlayer()

	if event.Call("Pre Render") == false then return true end
	
	local view = CalcView(ply,pos,angle,fov)
	if not view then return true end

	RenderView.w = ScrW()
	RenderView.h = ScrH()

	view.angles:Normalize()

	local vec = view.origin
	if vec[1] == inf then vec[1] = 0 end
	if vec[2] == inf then vec[2] = 0 end
	if vec[3] == inf then vec[3] = 0 end

	local ang = view.angles
	if ang[1] == inf then ang[1] = 0 end
	if ang[2] == inf then ang[2] = 0 end
	if ang[3] == inf then ang[3] = 0 end

	RenderView.fov = view.fov
	RenderView.origin = view.vec or view.origin
	RenderView.angles = view.ang or view.angles
	RenderView.znear = view.znear or 1
	RenderView.zfar = view.zfar
	RenderView.drawviewer = view.drawviewer

	RenderView.bypassEngineCamera = view.bypassEngineCamera

	if INVEHICLE then
		RenderView.origin = ORIGIN
		RenderView.angles = ANGLES
	end

	render.Clear(0,0,0,0,true,true)

	if event.Call("PreRenderScene",RenderView) == nil then
		render.RenderView(RenderView)
	end

	if event.Call("PreRenderHUD",RenderView) == nil then
		render.RenderHUD(0,0,RenderView.w,RenderView.h)
	end

	event.Call("Post Render")
	
	return true
end)

//

hook.Add("CalcView","zEngineVehicleCamera",function(ply,origin,angles,fov)
	INVEHICLE = nil

	if ply:InVehicle() then
		if RenderView.bypassEngineCamera or ply:GetVehicle():GetParent().BypassEngineCamera then return RenderView end
		
		INVEHICLE = true

		RenderView.origin = origin
		RenderView.angles = angles
		RenderView.drawviewer = false
	end

	return RenderView
end)

//

CalcView = function(ply,origin,angles,fov,znear,zfar)
	local fallbackPos = (IsValid(ply) and ply:Alive() and not ply:InVehicle() and ply:EyePos()) or origin
	local fallbackAng = (IsValid(ply) and ply:Alive() and not ply:InVehicle() and ply:EyeAngles()) or angles

	local view = {
		origin = fallbackPos,
		angles = fallbackAng,
		fov = fov,

		vec = fallbackPos,
		ang = fallbackAng,

		znear = znear or 1,
		zfar = zfar,

		drawviewer = false
	}

	local result = event.Run("PreCalcView",ply,view,oldView or view)
	
	if result ~= nil then
		if result == false then return false end

		oldView = table.Copy(result)

		return result
	end

	oldView = table.Copy(view)

	return view
end

//

function CamReset(znear)--WTF
	cam.Start3D(RenderView.origin,RenderView.angles,RenderView.fov,0,0,ScrW(),ScrH(),znear or 1,16000)
end

//hook.Add("PreDrawEffects","!Clear Depth",function() render.ClearDepth(true) end)--чо за кринж

