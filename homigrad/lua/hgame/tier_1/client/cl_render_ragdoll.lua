--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/client/cl_render_ragdoll.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\client\\cl_render_ragdoll.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local vecZero = Vector()

/*
hook.Add("PreCalcView","Ragdoll",function(ply,vec,ang,fov,znear,zfar)
	local hand = ply:GetAttachment(ply:LookupAttachment("anim_attachment_rh"))

	local ragdoll = ply:GetNWEntity("Ragdoll")

	if ply:Alive() and IsValid(ragdoll) then
		ragdoll:ManipulateBoneScale(6,vecZero)

        local pos,ang = ply:Eye()

		local view = {
			origin = pos,
			angles = ang,
			fov = fov,
			drawviewer = true
		}

		return view
	end
end)
*/
