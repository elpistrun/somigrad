--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/glide_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad\\lua\\hinit\\glide_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
hook.Add("Glide_OnLocalEnterVehicle","ZHomigrad",function(vehicle)
	hook.Remove("CalcView","GlideCamera.CalcView")

	event.Add("PreCalcView","GLide",function(ply,view)
		local camera = Glide.Camera

        camera.isInFirstPerson = true
		camera.SetFirstPerson = function() end//fuck you!

		camera.fov = view.fov

		if camera.isActive then 
            local view = camera:CalcView()
            if not view then return end
            
            view.bypassEngineCamera = true
            view.vec = view.origin
            view.ang = view.angles

            return view
        end
	end,-10)

    local Floor = math.floor

    local mat = Material("icon16/lock.png")

    hook.Add("HUDPaint","GLide Homigrad",function()
        if not IsValid(vehicle) or not vehicle:GetIsLocked() then return end

        local screenH = ScrH()

        local margin = Floor( screenH * 0.03 )
        local padding = Floor( screenH * 0.006 )
        local spacing = Floor( screenH * 0.004 )

        local w, h = Floor( screenH * 0.3 ), Floor( screenH * 0.035 )

        local y = screenH - margin * 2 - (h + spacing) * (#vehicle.seats)
        
        surface.SetDrawColor(255,255,255)
        surface.SetMaterial(mat)
        surface.DrawTexturedRectRotated(padding + h / 2,y,h,h,0)
    end)
end)//как же он охуителен

hook.Add("Glide_OnLocalExitVehicle","ZHomigrad",function()
    event.Remove("PreCalcView","GLide")
    hook.Remove("HUDPaint","GLide Homigrad")
end)

//

hook.Remove("HUDDrawTargetID","Glide.HUDDrawTargetID")

hook.Remove("InitPostEntity","Glide.CreateSkidMarkMeshes")
hook.Remove("PreCleanupMap","Glide.RemoveSkidMarkMeshes")
hook.Remove("PostCleanupMap","Glide.RecreateSkidMarkMeshes")
hook.Remove("PreDrawTranslucentRenderables","Glide.RenderSkidMarks")

concommand.Add("hg_dev_get_sequence",function(ply)
    PrintTable(ply:GetSequenceInfo(ply:GetSequence()))
end)
