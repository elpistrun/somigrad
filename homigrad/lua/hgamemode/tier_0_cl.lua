--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/tier_0_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\tier_0_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
hook.Add("HUDShouldDraw","HideHUD_ammo",function(name)
	if name == "CHudAmmo" then return false end
end)

hook.Add("DrawDeathNotice","no",function() return false end)
hook.Add("HUDDrawTargetID","no",function() return false end)

concommand.Add("hg_getentity",function()
	local ent = LocalPlayer():GetEyeTrace().Entity
	print(ent)
	if not IsValid(ent) then return end
	print(ent:GetModel())
	print(ent:GetClass())
end)

event.Add("Player Spawn","HullSize",function(ply)
	local hullmin,hull,hullduck = Vector(-DEFAULT_HULLSIZE,-DEFAULT_HULLSIZE,0),Vector(DEFAULT_HULLSIZE,DEFAULT_HULLSIZE,DEFAULT_VIEW_OFFSET[3]),Vector(DEFAULT_HULLSIZE,DEFAULT_HULLSIZE,DEFAULT_VIEW_OFFSET_DUCKED[3])

	ply:SetHull(hullmin,hull)
	ply:SetHullDuck(hullmin,hullduck)

	ply:SetViewOffset(DEFAULT_VIEW_OFFSET)
	ply:SetViewOffsetDucked(DEFAULT_VIEW_OFFSET_DUCKED)
end,1)

hook.Add("HUDPaint","Show If Spectate",function()
	local trace = LocalPlayer():EyeTrace(512)
	if not trace then return end
	
	local ent = trace.Entity
	if IsValid(ent) and ent:IsPlayer() and ent:Team() == 1002 then
		local pos = ent:GetPos():Add(ent:OBBCenter()):ToScreen()
		draw.SimpleText("SPECTATOR","HS.12",pos.x,pos.y,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
end)
