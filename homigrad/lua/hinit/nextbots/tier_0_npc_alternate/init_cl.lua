--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/nextbots/tier_0_npc_alternate/init_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hinit/nextbots/tier_0_npc_alternate/tier_0_sh.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad\\lua\\hinit\\nextbots\\tier_0_npc_alternate\\init_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Get("npc_alternate")
if not ENT then return end

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:GetMusicDSP(point,pos,filter)
	local pen = sound.Trace(pos,1024,5,filter)

	if pen <= 0.25 then
		return 0
	elseif pen <= 0.7 then
		return 13
	else
		return 14
	end
end

function ENT:GetCloseMe(list,dis,filter)
	local volume = 0
	local pos = LocalPlayer():GetPos()

	local closeEnt

	for id, ent in pairs(list) do
		if not IsValid(ent) then list[id] = nil continue end
		if ent:GetClass() ~= self.ClassName or filter and filter(ent) == false then continue end
	
		local dis = math.Clamp((dis - pos:Distance(ent:GetPos())) / dis,0,1)

		if volume < dis then
			closeEnt = ent
			volume = dis
		end
	end

	return volume,closeEnt
end

ENT.MusicStart = 0

function ENT:TauntMusic(list)
	local ply = LocalPlayer()

	local volume,closeEnt = self:GetCloseMe(list,self.MusicDistance,function(ent)
		if not self.MusicHide then return true end

		return ent:GetNWString("State") == "Follow"
	end)
		
	local time = CurTime()

	if closeEnt then
		local fade = self.MusicFade

		if fade then
			if self:CanSee(closeEnt) then self.MusicStart = time + fade end

			volume = volume * math.Clamp((self.MusicStart - time) / fade,0,1)
		end
	end

	local panicMusic = self.panicMusic

	if volume <= 0 then
		if IsValid(panicMusic) then self.panicMusic:Remove() end

		return
	end

	if closeEnt then
		if not IsValid(panicMusic) then
			panicMusic = sound.CreatePoint(LocalPlayer(),self.Music,self.MusicLevel)
			self.panicMusic = panicMusic
			panicMusic:Stop()
		end

		local posEnt = closeEnt:GetPos() + closeEnt:OBBCenter()

		panicMusic.CalculateDSP = function(point,_,filter) return self:GetMusicDSP(point,posEnt,filter) end

		if self.MusicPosLocal then
			panicMusic.pos = ply:GetPos()
		else
			panicMusic.pos = posEnt
		end
	end	

	panicMusic.filter[closeEnt] = true
	panicMusic.reloadTime = self.MusicRestartDelay
	panicMusic.inParent = self.MusicPosLocal

	if not ply:Alive() then volume = volume / 4 end

	panicMusic:Play()

	panicMusic.pitch = 1
	panicMusic.volume = volume * self.MusicVolume
end

g_nextbots = g_nextbots or {}

local delay = 0

local list = {}

hook.Add("Think","NextBot Music",function()
	local time = CurTime()
	if delay > time then return end
	delay = time + 0.05

	for ent in pairs(g_nextbots) do
		if not IsValid(ent) then g_nextbots[ent] = nil continue end

		local class = ent:GetClass()
		list[class] = list[class] or {}
		list[class][#list[class] + 1] = ent
	end

	for class,list in pairs(list) do
		oop.listClass[class][1]:TauntMusic(list)
	end
end)

function ENT:Initialize()
	local SPRITE_SIZE = self.SpriteSize

	self:SetRenderBounds(
		Vector(-SPRITE_SIZE / 2, -SPRITE_SIZE / 2, 0),
		Vector(SPRITE_SIZE / 2, SPRITE_SIZE / 2, SPRITE_SIZE),
		Vector(5, 5, 5)
	)

	g_nextbots[self] = true

	if self.Init then self:Init() end
end

function ENT:DrawSprite(pos,normal,size,color,rot)
	render.DrawQuadEasy(pos,normal,size,size,color,rot + math.cos(CurTime() * 360))
end

function ENT:DrawTranslucent()
	if not self.ShowIfStateGoAway and self:GetNWString("State") == "GoAway" then return end

	render.SetMaterial(self.SpriteMat)

	local pos = self:GetPos() + self.SpriteSize / 2 * vector_up
	local normal = EyePos() - pos
	normal:Normalize()

	local xyNormal = Vector(normal.x, normal.y, 0)
	xyNormal:Normalize()

	local pitch = math.acos(math.Clamp(normal:Dot(xyNormal),-1,1)) / 3
	local cos = math.cos(pitch)
	normal = Vector(
		xyNormal.x * cos,
		xyNormal.y * cos,
		math.sin(pitch)
	)

	surface.SetDrawColor(255,255,255)

	self:DrawSprite(pos,normal,self.SpriteSize,color_white,180)

	local ent = self:GetNWEntity("Controller")

	if not LocalPlayer():Alive() and IsValid(ent) then
		normal = (EyePos() - self:GetPos()):Angle()

		local ang = RenderAngles()

		cam.Start3D2D(pos + Vector(0,0,self.SpriteSize / 2 + 5),Angle(0,ang.y - 90,90 - ang[1]),1)
			draw.SimpleText(ent:Name(),"ChatFont",0,0,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		cam.End3D2D()
	end
end

local tr = {
	mask = MASK_SHOT
}

function ENT:Spectate1(ply,view)
	tr.start = self:GetPos() + Vector(0,0,self.SpriteSize / 2)
	tr.endpos = tr.start - Vector(125,0,0):Rotate(view.ang)
	tr.filter = {self}

	view.vec = util.TraceLine(tr).HitPos

	return view
end

function ENT:Spectate2(ply,view)
	view.vec = self:GetPos() + Vector(0,0,self.SpriteSize / 2)

	return view
end

hook.Add("HUDPaint","Show Nextbots",function()
	if not WH or SpectateHideNick then return end

	for ent in pairs(g_nextbots) do
		if not IsValid(ent) then g_nextbots[ent] = nil continue end

		DrawWHEnt(ent,ent:GetPos())
	end
end)
