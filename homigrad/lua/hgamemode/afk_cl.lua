--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/afk_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\afk_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
afkStart = CurTime()

local afkTime = 60 * 3
local afkStart = RealTime()

local oldX,oldY = 0,0

local time
hook.Add("CreateMove","afk",function(moveData)
	local ply = LocalPlayer()
	local time = RealTime()

	local x,y = moveData:GetMouseX(),moveData:GetMouseY()
	
	if x ~= oldX then
		oldX = x
		afkStart = time
	end

	if x ~= oldY then
		oldY = y
		afkStart = time
	end

	if ply:IsAdmin() or moveData:GetButtons() > 0 or not ply:Alive() or ply:Team() == 1002 then afkStart = time end

	if afkStart + afkTime < time then
		net.Start("afk")
		net.SendToServer()
		RunConsoleCommand("say","афк 9999999")
	end
end)

local oldX,oldY = 0,0
hook.Add("HUDPaint","AFK",function()
	local ply = LocalPlayer()

	local x,y = gui.MouseX(),gui.MouseY()

	if oldX ~= x then
		oldX = x
		afkStart = RealTime()
	end

	if oldY ~= y then
		oldY = y
		afkStart = RealTime()
	end

	local time = afkStart + afkTime - RealTime()

	if time <= 30 then 
		draw.SimpleText("AFK SYSTEM " .. math.floor(time),"HS.45",ScrW() / 2,ScrH() / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
end)

AdminPanel_Command_Registry("afk",{},"game")
