--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/jmod-master/lua/effects/eff_jack_turretmuzzlelight/init.lua <
    > Callstack:  <
]]

function EFFECT:Init(data)
	local dirkshun = data:GetNormal()
	local pozishun = data:GetStart()
	local skayul = data:GetScale()
	local dlight = DynamicLight(0)

	if dlight then
		dlight.Pos = pozishun
		dlight.r = 190
		dlight.g = 225
		dlight.b = 255
		dlight.Brightness = .8 * skayul
		dlight.Size = 150 * skayul
		dlight.Decay = 1200 * skayul
		dlight.DieTime = CurTime() + 0.03 * skayul ^ 0.25
		dlight.Style = 0
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end

