--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/jmod-master/lua/effects/eff_jack_plasmaarc/init.lua <
    > Callstack:  <
]]

function EFFECT:Init(data)
	self.StartPos = data:GetStart()
	self.EndPos = data:GetOrigin()
	self.Scayul = data:GetScale() ^ 0.5
	self.Delay = math.Clamp(0.06 * data:GetScale(), 0.025, 0.06)
	self.EndTime = CurTime() + self.Delay
	self.Entity:SetRenderBoundsWS(self.StartPos, self.EndPos)
	local dlightend = DynamicLight(0)
	dlightend.Pos = self.EndPos
	dlightend.Size = 500 * self.Scayul
	dlightend.Decay = 10000
	dlightend.R = 100
	dlightend.G = 150
	dlightend.B = 255
	dlightend.Brightness = 3 * self.Scayul
	dlightend.DieTime = CurTime() + self.Delay
end

function EFFECT:Think()
	if self.EndTime < CurTime() then
		--self:Remove()
		return false
	else
		return true
	end
end

function EFFECT:Render()
	self.Entity:SetRenderBoundsWS(self.StartPos, self.EndPos)

	local Beamtwo = CreateMaterial("xeno/beamgauss", "UnlitGeneric", {
		["$basetexture"] = "sprites/spotlight",
		["$additive"] = "1",
		["$vertexcolor"] = "1",
		["$vertexalpha"] = "1",
	})

	render.SetMaterial(Beamtwo)
	render.DrawBeam(self.StartPos, self.EndPos, Lerp((self.EndTime - CurTime()) / self.Delay, 0, 8 * self.Scayul), 0, 0, Color(100, 150, 255, 254))
end

