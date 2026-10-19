--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/jmod-master/lua/effects/eff_jack_gmod_jetflyby.lua <
    > Callstack:  <
]]

function EFFECT:Init(data)
	self.LifeTime = 1.75
	self.DieTime = CurTime() + self.LifeTime
	self.Plane = ClientsideModel("models/xqm/jetbody3_s2.mdl")
	self.Plane:SetNoDraw(true)
	self.TotalDistance = data:GetStart() * 100
	self.Pos = data:GetOrigin()
	-- according to my math, this plane is doing about mach 1.25 when it passes
	-- if this effect is called with data:SetStart() velocity length of 400
end

function EFFECT:Think()
	local TimeLeft = self.DieTime - CurTime()
	if TimeLeft > 0 then return true end

	return false
end

function EFFECT:Render()
	local Frac = ((self.DieTime - CurTime()) / self.LifeTime) - .5
	local Pos = self.Pos + self.TotalDistance * Frac
	self.Plane:SetRenderOrigin(Pos)
	local Ang = self.TotalDistance:Angle()
	Ang:RotateAroundAxis(Ang:Up(), -90)
	self.Plane:SetRenderAngles(Ang)
	self.Plane:DrawModel()
end

