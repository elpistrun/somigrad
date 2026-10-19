--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/jmod-master/lua/effects/eff_jack_longflamelight/init.lua <
    > Callstack:  <
]]

function EFFECT:Init(data)
	local SelfPos = data:GetOrigin()
	local dlight = DynamicLight(self:EntIndex())

	if dlight then
		dlight.Pos = self:GetPos()
		dlight.r = 255
		dlight.g = 150
		dlight.b = 120
		dlight.Brightness = 7
		dlight.Size = 1700
		dlight.Decay = 41 / JackieSplosivesFireMult
		dlight.DieTime = CurTime() + 30 * JackieSplosivesFireMult
		dlight.Style = 0
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end

