--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/communication_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\communication_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local unmutedicon = Material( "icon32/unmuted.png", "noclamp smooth" )
local mutedicon = Material( "icon32/muted.png", "noclamp smooth" )

local black = Color(0,0,0,200)
local white = Color(255,255,255)

local radio = Material("icon16/feed.png")

local cframe1,cframe2 = Color(255,255,255,75),Color(0,0,0,125)

local white = Color(255,255,255)

local function drawPanelAvatar(self,w,h)
	local ply = player.GetBySteamID(self.steamid)
	if not IsValid(ply) then return end

	local force = ply:VoiceVolume() * 1.5 * self.panel.lerp

	surface.SetFigure("circle")

	local color = ply:GetUserColor() or white
	surface.SetDrawColor(color.r,color.g,color.b,math.max(255 * force,75))

	force = force + 0.75

	DisableClipping(true)
	draw.Figure(w/2,h/2,w * force,h * force)
	DisableClipping(false)
end

local function drawPanel(self,w,h)
	local ply = player.GetBySteamID(self.steamid)
	if not IsValid(ply) then return end
	
	local k = self.lerp

	if ply:Alive() then
		if not ply:GetBackground() then
			surface.SetDrawColor(20,20,20,200)
			surface.DrawRect(0,0,w,h)
		end
	else
		surface.SetDrawColor(255,0,0,55)
		surface.DrawRect(0,0,w,h)
	end

	if ActiveLevel and ActiveLevel.red and ActiveLevel.blue then
		local name,color = ply:GetTeamStatus()

		if color then
			surface.SetDrawColor(color)
			local size = h / 6
			surface.DrawRect(w - size + 1,0,size,h)
			local size2 = h / 2
			draw.GradientRight(w - size - size2 + 1,0,size2,h)
		end
	end

	if ply.voiceIsRadio then
		surface.SetDrawColor(255,125,0,25)
		surface.DrawRect(0,0,w,h)
	end

	if not IS64BIT then draw.SimpleText(ply:Name(),"ChatFont",w / 2,h / 2,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end

	if ply.voiceIsRadio then
		surface.SetDrawColor(255,255,255,25)
		surface.SetMaterial(radio)
		local size = 30 + 2.5 * math.sin(CurTime() * 15)
		surface.DrawTexturedRectRotated(h / 2,h / 2,size,size,math.cos(CurTime() * 30) * 10)
	end

	draw.Frame(0,0,w,h,cframe1,cframe2)

	if not ply:IsMuted() and not vgui.CursorVisible() then return end

	local mx,my = self:GetMousePos()
	local hover = math.pointinbox(mx,my,w - h,0,h,h)
	
	local active = input.IsMouseDown(MOUSE_LEFT)
	local click

	if self.old ~= active then
		if hover and active then click = true end

		self.old = active
	end

	surface.SetDrawColor(255,255,255,255 * k)

	surface.SetMaterial(ply:IsMuted() and mutedicon or unmutedicon)
	local size = hover and h * 1.5 or h
	surface.DrawTexturedRectRotated(w - h / 2,h / 2,size,size,hover and not ply:IsMuted() and math.cos(RealTime() * 25) * 25 or 0)
	
	if click then
		ply:SetMuted(not ply:IsMuted())

		MutePlayers[ply:SteamID()] = ply:IsMuted()
	end
end

hook.Add("PlayerStartVoice","Homigrad",function(ply)
	if not InitNET or not IsValid(ply) then return true end

	ply.StartVoice = RealTime()
	ply.voiceEmit = true

	if not IsValid(VoiceHUD) then return end
	
	if VoiceHUD.listID[ply:SteamID()] then
		VoiceHUD.list[VoiceHUD.listID[ply:SteamID()]].lerp = 1

		return true
	end

	local panel,avatar = VoiceHUD:AddPlayer(ply)
	panel.steamid = ply:SteamID()
	panel.lerp = 1
	panel.Draw = function(self,w,h)
		surface.SetAlphaMultiplier(panel.lerp)
		drawPanel(self,w,h)
		surface.SetAlphaMultiplier(1)
	end

	avatar.panel = panel
	avatar.steamid = ply:SteamID()
	avatar.Draw = function(self,w,h)
		surface.SetAlphaMultiplier(panel.lerp)
		drawPanelAvatar(self,w,h)
		surface.SetAlphaMultiplier(1)
	end
	
	return true
end)

hook.Add("PlayerEndVoice","Homigrad",function(ply)
	if not IsValid(ply) then return true end

	ply.voiceEmit = nil

	return true
end)

local PLAYER = FindMetaTable("Player")

function PLAYER:SetMuted(value)
	self.isMuted = value

	UpdateVoiceVolumeScale()
end

event.Add("Voice Volume","Muted",function(ply,value) if ply.isMuted then value[1] = 0 return false end end)

function PLAYER:IsMuted() return self.isMuted end

if not HSetVoiceVolumeScale then HSetVoiceVolumeScale = PLAYER.SetVoiceVolumeScale end
local HSetVoiceVolumeScale = HSetVoiceVolumeScale
local event_Run = event.Run

function PLAYER:UpdateVoiceVolumeScale()
	local value = {1}

	event_Run("Voice Volume",self,value)

	value = value[1]

	if self.voiceVolumeScale ~= value then
		self.voiceVolumeScale = value
		HSetVoiceVolumeScale(self,value)
	end
end

function UpdateVoiceVolumeScale()
	for i,ply in pairs(player.GetAll()) do
		if ply == LocalPlayer() then continue end

		ply.voiceVolumeScale = nil

		ply:UpdateVoiceVolumeScale()
	end
end

if not HVoiceVolume then HVoiceVolume = PLAYER.VoiceVolume end

function PLAYER:VoiceVolume()
	if self == LocalPlayer() and not GetConVar("voice_loopback"):GetBool() then
		return self.voiceEmit and 0.15 + math.cos(RealTime() * 50) / 7 or 0
	else
		return HVoiceVolume(self)
	end
end

event.Add("Voice Volume","Game",function(ply,value)
	value[1] = ply.worldVoiceVolume or 1
end,2)

local hg_radio_volume = 1
cvars.CreateOption("hg_radio_volume","1",function(value) hg_radio_volume = tonumber(value or 0) or 0 end,0,1)

local Player = Player

net.Receive("voice",function()
	for userID,data in pairs(net.ReadTable()) do
		local ply = Player(userID)
		if not ply.SetVoiceVolumeScale then continue end

		local volume = data[1]
		local typeEmit = data[2]

		ply.voiceIsRadio = false
		ply.voiceIs3D = false
		
		if typeEmit == "radio" then
			ply.voiceIsRadio = true
			ply.worldVoiceVolume = hg_radio_volume
		elseif typeEmit == true then
			ply.voiceIs3D = true
			ply.worldVoiceVolume = volume
		elseif typeEmit == false then
			ply.worldVoiceVolume = 1
		else
			ply.worldVoiceVolume = volume
		end

		ply:UpdateVoiceVolumeScale()
	end
end)

local hg_show_voicehud

function OpenVoiceHUD()
	if IsValid(VoiceHUD) then VoiceHUD:Remove() end

	local size = 40

	VoiceHUD = oop.CreatePanel("v_avatarlist"):ad(function(self,w,h)
		self:setSize(math.max(300,ScrW() *0.175),self:H()):setPos(w - 32 - self:W(),h - 32 - self:H())
	end)

	VoiceHUD:SetZPos(-100)
	VoiceHUD:Setup(size)

	function VoiceHUD:Step(w,h)
		local H = size * 0.25
	
		for steamid,iteration in pairs(VoiceHUD.listID) do
			local panel = VoiceHUD.list[iteration].panel
			local ply = player.GetBySteamID(steamid)

			if not IsValid(ply) or (panel.lerp or 1) < 0.01 then
				VoiceHUD:RemovePanel(steamid)

				continue
			end

			H = H + size + size * 0.25
			VoiceHUD:SetAlphaPanel(steamid,panel.lerp)

			panel.lerp = LerpFT(ply.voiceEmit and 0.5 or 0.15,panel.lerp or 0,ply.voiceEmit and 1 or 0)
		end

		if H == 0 then H = 1 end
		VoiceHUD:setSize(VoiceHUD:W(),H,true)
		VoiceHUD:InvalidateChildren()
	end
end

cvars.CreateOption("hg_show_voicehud","1",function(value)
	hg_show_voicehud = tonumber(value or 0) > 0

	if hg_show_voicehud then
		OpenVoiceHUD()
	else
		if IsValid(VoiceHUD) then VoiceHUD:Remove() end
	end
end)

local hg_voiceflex

cvars.CreateOption("hg_voiceflex","1",function(value) hg_voiceflex = tonumber(value) > 0 end)

FlexByPlayerModel = FlexByPlayerModel or {}

local defaultFlex = {
	"jaw_drop",
	"left_part",
	"right_part",
	"left_mouth_drop",
	"right_mouth_drop",

	"A",
	"mouth_a",
	"mouthA"
}

function SetFlexMouth(ply,ent,mul)
	if not hg_voiceflex then return end

	local flexes = FlexByPlayerModel[ent:GetModel()] or defaultFlex

	local weight = ply:IsSpeaking() and math.Clamp(ply:VoiceVolume() * 5,0,5) * mul

	if weight then
		ent.oldFlex = {}

		for k, v in pairs(flexes) do
			v = ent:GetFlexIDByName(v)
			if not v then continue end
		
			ent.oldFlex[k] = v

			ent:SetFlexWeight(v,weight)
		end
	else
		if ent.oldFlex then
			for k, v in pairs(ent.oldFlex) do
				ent:SetFlexWeight(v,0)
			end

			ent.oldFlex = nil
		end
	end
end

event.Add("PlayerDraw","mouthanim",function(ply,tag,link)
	SetFlexMouth(link or ply,ply,2)
end)

