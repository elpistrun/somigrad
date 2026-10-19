--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/zone_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\zone_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
ZoneDistance = ZoneDistance or 0

AdminPanel_Command_Registry("zone",{"number","number"},"game")
AdminPanel_Command_Registry("zone_speed",{"number"},"game")

local red = Color(255,0,0,75)
local mat = Material("color")

hook.Add("PostDrawTranslucentRenderables","Zone",function()
	ZoneOrigin = GetGlobalVar("Zone")
	
	if not ZoneOrigin then
		if snd and snd:IsPlaying() then snd:Stop() end

		return
	end

	local set = GetGlobalVar("ZoneDistance")
	if not set then return end--lol
	
	if set - ZoneDistance > 128 then ZoneDistance = set end --weeee

	ZoneDistance = LerpFT(0.01,ZoneDistance,set)

	local ply = LocalPlayer()

	local k = math.max(1 - math.abs(ZoneDistance - ply:GetPos():Distance(ZoneOrigin)) / 1000,0)

	red.a = 255 * k

	render.SetMaterial(mat)
	render.DrawSphere(ZoneOrigin,ZoneDistance,64,64,red)
	render.DrawSphere(ZoneOrigin,-ZoneDistance,64,64,red)

	if not snd or not snd:IsPlaying() then
		snd = CreateSound(ply,"ambient/energy/force_field_loop1.wav")
		snd:PlayEx(0,0)
	end

	/*if not ply:Alive() then
		if snd and snd:IsPlaying() then snd:Stop() end

		return
	end*/

	snd:ChangePitch(math.Clamp(155 * k,75,255))
	snd:ChangeVolume(0.5 * k)
end)
