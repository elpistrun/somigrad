--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/nextbots/contents/honda_mio/init_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hinit/nextbots/contents/honda_mio/tier_0_sh.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad\\lua\\hinit\\nextbots\\contents\\honda_mio\\init_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Get("npc_honda_mio")
if not ENT then return end

function ENT:GetMusicDSP(point,pos,filter)
	local pen = sound.Trace(pos,1024,16,filter)

	if pen <= 0.1 then
		return 0
	elseif pen <= 0.7 then
		return 14
	else
		return 14
	end
end

local mats = {
    Material("homigrad/scp/honda_mio/1.png"),
    Material("homigrad/scp/honda_mio/2.png"),
    Material("homigrad/scp/honda_mio/3.png"),
    Material("homigrad/scp/honda_mio/4.png")
}

ENT.Frame = 1
ENT.FrameInterval = 0.58
ENT.FrameL = 1

function ENT:DrawSprite(pos,normal,size,color,rot)
	local follow = self:GetNWString("State") == "Follow"
	if LocalPlayer():Alive() and not follow then return end

    local mat = mats[self.Frame]
    render.SetMaterial(mat)
    
    local time = RealTime()
    if (self.FrameStart or 0) < time then
        self.FrameStart = time + self.FrameInterval

        self.Frame = self.Frame + 1
        if self.Frame > 4 then self.Frame = 1 end
    end
    
    local k = (self.FrameStart - time) / self.FrameInterval

    if k <= 0.25 then k = k / 2 end

    self.FrameL = LerpFT(self.FrameL < k and 0.15 or 0.75,self.FrameL,k)

    local k2 = self.FrameL

    pos:Add(Vector(0,0,k2 * 25))
	render.DrawQuadEasy(pos,normal,size - k2 * 10,size + k2 * 10,color,rot)

    local swep = self.Weapons[self:GetWeapon()]

    if swep then
        swep.Draw(self,pos,normal,size,color,rot)
    end
end

