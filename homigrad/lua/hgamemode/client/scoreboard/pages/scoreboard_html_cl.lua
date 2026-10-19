--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/client/scoreboard/pages/scoreboard_html_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\client\\scoreboard\\pages\\scoreboard_html_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
//https://cdn.discordapp.com/attachments/1249395086584840273/1301494462513545268/video_2024-10-31_17-33-32_1.mp4?ex=6724aeac&is=67235d2c&hm=61f7f623c83cb5fa0f825ce94325a2c59498176d08685334f87aa18435faba25&

local function ReadMuteStatusPlayers()
	return util.JSONToTable(file.Read("homigrad_mute.txt","DATA") or "") or {}
end

MutePlayers = ReadMuteStatusPlayers()

local function SaveMuteStatusPlayer(ply,value)
	if value == false then value = nil end
	MutePlayers[ply:SteamID()] = value
	file.Write("homigrad_mute.txt",util.TableToJSON(MutePlayers))
end

local SetDrawColor = surface.SetDrawColor
local DrawRect = surface.DrawRect

local unmutedicon = Material( "icon32/unmuted.png", "noclamp smooth" )
local mutedicon = Material( "icon32/muted.png", "noclamp smooth" )

local color_gray = Color(125,125,125)
local empty = {}

function ScoreboardDrawPlayer(ply,w,h,tbl,self)
    tbl = tbl or empty
    if TypeID(ply) != TYPE_TABLE and not IsValid(ply) then return end
    
    SetDrawColor(0,0,0,75)
    DrawRect(0,0,w,h)

    if ply == LocalPlayer() then
        SetDrawColor(125,125,125,15)
        DrawRect(0,0,w,h)
    end

    local alive,colorAlive,colorAddAlive

    if not tbl.dontDrawAlive then
        alive,colorAlive,colorAddAlive = ply:GetAliveStatus()

        if colorAddAlive then
            SetDrawColor(colorAddAlive.r,colorAddAlive.g,colorAddAlive.b,5)
            DrawRect(0,0,w,h)

            SetDrawColor(colorAddAlive.r / 2,colorAddAlive.g / 2,colorAddAlive.b / 2,75)
            draw.GradientLeft(0,0,w / 4,h)
        else
            SetDrawColor(colorAlive.r / 5,colorAlive.g / 5,colorAlive.b / 5,75)
            draw.GradientLeft(0,0,w / 4,h)
        end

        draw.SimpleText(L(alive),"HS.18",h / 2,h / 2,colorAlive,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
    end

    local nameGroup = (ply.GetUserName and ply:GetUserName()) or (ply.GetUserGroup and ply:GetUserGroup()) or "user"
    local color = (ply.GetUserColor and ply:GetUserColor()) or (team and team.GetColor and team.GetColor(ply:Team())) or color_white

    if color then
        SetDrawColor(color)
        DrawRect(0,h - 2,w,2)

        if not tbl.dontDrawGroup then
            if nameGroup then
                draw.SimpleText(nameGroup,"HS.18",w * 0.25,h / 2,ply:GetNWBool("DontShowMyPerm") and color_gray or color,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            end
        end

        SetDrawColor(color.r / 4,color.g / 4,color.b / 4,75)
        draw.GradientDown(0,h / 2,w,h / 2)
    end

    //draw.SimpleText(ply:Name(),"HS.18",w / 2,h / 2,color,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    if ply:IsBot() then draw.SimpleText("BOT","HS.12",w / 2,4,color_gray,TEXT_ALIGN_CENTER) end
    
    if colorAddAlive then
        SetDrawColor(colorAddAlive.r,colorAddAlive.g,colorAddAlive.b,255)
        DrawRect(0,0,2,h)
    elseif not tbl.dontDrawAlive then
        SetDrawColor(colorAlive.r,colorAlive.g,colorAlive.b,255)
        DrawRect(0,0,2,h)
    end

    if not tbl.dontDrawTime then
        local hours = ply:GetTimeStatus()

        if hours then
            draw.SimpleText(hours .. " h","HS.18",w * 0.7,h / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        else
            DrawLoading(w * 0.7,h / 2,h / 2,h / 2)
        end
    end

    if not tbl.dontDrawPing then
        draw.SimpleText(ply:Ping(),"HS.18",w * 0.8,h / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    if not tbl.dontDrawTeam then
        local name,color = ply:GetTeamStatus()

        SetDrawColor(color.r / 2,color.g / 2,color.b / 2,75)
        draw.GradientRight(w - w / 3,0,w / 3,h)

        SetDrawColor(color.r,color.g,color.b,255)
        DrawRect(w - 2,0,2,h)

        draw.SimpleText(L(name),"HS.18",w - h / (dontShowMute and 2 or 1),h / 2,color,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
    end

    if not tbl.dontDrawMute then
        surface.SetMaterial(ply:IsMuted() and mutedicon or unmutedicon)

        local size = h / 2
        local isDown
        local ms,my = self:GetMousePos()

        isDown = ms > w - h / 2 - h / 4 and ms < w - h / 2 + h / 4 and my > h / 2 - h / 4 and my < h / 2 + h / 4

        SetDrawColor(0,0,0,125)
        surface.DrawTexturedRectRotated(w - h / 2 + 6,h / 2 + 6,size,size,isDown and not ply:IsMuted() and math.cos(RealTime() * 25) * 25 or 0)
        
        SetDrawColor(255,255,255)
        surface.DrawTexturedRectRotated(w - h / 2,h / 2,size,size,isDown and not ply:IsMuted() and math.cos(RealTime() * 25) * 25 or 0)

        local active = self.mouse[MOUSE_LEFT] and true or false
        if self.active ~= active then
            self.active = active
            
            if isDown and active then
                ply:SetMuted(not ply:IsMuted())
                SaveMuteStatusPlayer(ply,ply:IsMuted())
            end
        end
    end

    draw.Frame(0,0,w,h,cframe1,cframe2)
end

local discord_icon = Material("homigrad/discord_icon.png")

function ScoreboardAddPlayerHTML(html,ply,tab)
    local p,avatar = html:AddPlayer(ply)

    function avatar:DrawOver(w,h)
        if not IsValid(ply) then return end
        
        if ply:GetNWBool("DontShowMyDiscord") then return end//;c
        
        local profile = ply:GetDiscordProfile()
        if not profile then return end

        self:SetCursor("blank")

        surface.SetMaterial(discord_icon)
        surface.SetDrawColor(86,98,246)
        local corner = w * 0.25/2
        surface.DrawTexturedRectRotated(corner,corner,w/4,w/4,25)

        if self:IsHovered() then
            DiscordProfileDraw(ply:SteamID(),gui.MouseX(),gui.MouseY(),{
                avatar = profile.avatar,
                banner = profile.banner,
                username = profile.username,
                displayName = profile.displayName,
                roles = ply:GetNWBool("DontShowMyPerm") and {["user"] = true} or ply.roles
            })
        end 
    end

    function p:Draw(w,h)
        ScoreboardDrawPlayer(ply,w,h,tab or {drawDiscordProfile = true},self)
    end

    function p:OnClick(value)
        if value ~= MOUSE_RIGHT then return end

        OpenDermaPlayer(ply)
    end
end

function ScoreboardBuildOnHTML(panel,scroll)
    scroll:ad(function(self) scroll:setPos(0,40) end)

    local H = 0

    local html = oop.CreatePanel("v_avatarlist",scroll)
    html:Setup(panel.iconSize)

    html:SetScrollPanel(scroll)

    scroll:CreateVBar()

    function html.OnReady()
        scroll:Clear()
        html:Clear()//очищает html элементы

        H = panel.WIDE * 2

        for id,ply in pairs(panel.sort) do
            ScoreboardAddPlayerHTML(html,ply)

            H = H + panel.iconSize + panel.WIDE
        end

        H = H - panel.WIDE

        scroll.canvasH = H
        scroll.canvasPanel:InvalidateLayout(true)
    end

    function panel:DrawScoreboard(w,h)
        SetDrawColor(0,0,0,25)
        DrawRect(0,0,w,40)
        DrawRect(0,h - 60,w,100)

        draw.SimpleText(L("scoreboard_players",table.Count(player.GetAll())),"HS.18",20,h - 30,ScoreboardGreen,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
        
        local tick = math.Round(1 / ServerPerformance[1])
        draw.SimpleText(L("scoreboard_tickrate",tick),"HS.18",w - 15,h - 30,tick <= 15 and ScoreboardRed or ScoreboardGreen,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
 
        local tick = math.ceil(1 / ServerPerformance[2])
        if tick > 1000 then tick = ">1000" end

        draw.SimpleText(L("scoreboard_tickrate_phys",tick),"HS.18",w - 150,h - 30,tick ~= ">1000" and ScoreboardRed or ScoreboardBlue,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)

        local x = self.iconSize + self.WIDE * 2
        w = w - x - self.WIDE

        draw.SimpleText(L("scoreboard_status"),"HS.18",x + self.iconSize / 2,20,white,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
        draw.SimpleText(L("scoreboard_name"),"HS.18",x + w / 2,20,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        draw.SimpleText(L("scoreboard_played"),"HS.18",x + w * 0.7,20,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        draw.SimpleText(L("scoreboard_ping"),"HS.18",x + w * 0.8,20,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        draw.SimpleText(L("scoreboard_team"),"HS.18",x + w - self.iconSize,20,white,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
    end

    function panel:DrawOver(w,h)
        draw.Frame(0,0,w,h,cframe1,cframe2)
    end

    function scroll:DrawOver(w,h)
        SetDrawColor(255,255,255,25)
        draw.GradientRight(0,0,w / 2,1)
        SetDrawColor(55,55,55,25)
        draw.GradientLeft(0,0,w / 2,1)
        
        SetDrawColor(255,255,255,25)
        draw.GradientLeft(w / 2,0,w / 2,1)
        SetDrawColor(55,55,55,25)
        draw.GradientRight(w / 2,0,w / 2,1)

        SetDrawColor(255,255,255,25)
        draw.GradientRight(0,h - 1,w / 2,1)
        SetDrawColor(55,55,55,25)
        draw.GradientLeft(0,h - 1,w / 2,1)

        SetDrawColor(255,255,255,25)
        draw.GradientLeft(w / 2,h - 1,w / 2,1)
        SetDrawColor(55,55,55,25)
        draw.GradientRight(w / 2,h - 1,w / 2,1)
    end

    return html
end

if Initialize and LocalPlayer():SteamID() == "STEAM_0:1:164889146" then OpenTab() end
