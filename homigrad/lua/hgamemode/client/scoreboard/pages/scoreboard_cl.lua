--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/client/scoreboard/pages/scoreboard_cl.lua <
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

-- "addons\\homigrad\\lua\\hgamemode\\client\\scoreboard\\pages\\scoreboard_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Panel = {}
ScoreboardPages[1] = Panel

Panel.Name = "scoreboard"

local SetDrawColor,DrawRect = surface.SetDrawColor,surface.DrawRect

local delaySend = 0

local specColor = Color(155,155,155)
local white = Color(255,255,255,255)
local colorSpec = Color(155,155,155)
local colorRed = Color(205,55,55)
local colorGreen = Color(55,255,55)
local colorBlue = Color(175,175,255)

ScoreboardRed = colorRed
ScoreboardBlue = colorBlue
ScoreboardSpec = colorSpec
ScoreboardGreen = colorGreen
ScoreboardBlack = Color(0,0,0,200)

local function timeSort(a,b)
    return a:GetNWFloat("Time",0) > b:GetNWFloat("Time",-1)
end

local green = Color(75,255,75)

function OpenDermaPlayer(ply)
    local name,steamID

    if TypeID(ply) == TYPE_TABLE then
        name = ply.name
        steamID = ply.steamID
    else
        name = ply:Name()
        steamID = ply:SteamID()
    end

    local menu = DermaMenu()

    menu:AddOption(L("copy_nickname"),function()
        SetClipboardText(ply:Name())
        chat.AddText(Color(255,255,255),ply:Name())
    end)

    menu:AddOption(L("copy_steamid"),function()
        SetClipboardText(ply:SteamID())
        chat.AddText(Color(255,255,255),ply:SteamID())
    end)

    menu:AddOption(L("copy_steamid64"),function()
        SetClipboardText(ply:SteamID64())
        chat.AddText(Color(255,255,255),ply:SteamID64())
    end)
    
    if not ply.ShowProfile then menu:Open() menu:MakePopup() return end
    
    menu:AddOption(L("open_profile"),function() ply:ShowProfile() end)

    if LocalPlayer():IsAdmin() then
        local sub = menu:AddSubMenu("Set Team")

        for i = 1,3 do
            sub:AddOption(i,function() RunConsoleCommand("say","!teamforce " .. ply:SteamID() .. " " .. i) end)
        end

        sub:AddOption("Spectators",function() RunConsoleCommand("say","!teamforce " .. ply:SteamID() .. " 1002") end)

        menu:AddOption(L("kick"),function() RunConsoleCommand("ulx_cmd","kick",ply:Name(),"kick with tab") end)
    end

    menu:Open()
    menu:MakePopup()
end

local err = function(err) ErrorNoHaltWithStack(err) end

local history = {}
local historyPhys = {}

function Panel.Open(panelPage)
    local panel = oop.CreatePanel("v_panel",panelPage):ad(function(self,w,h)
        self.iconSize = 80 * ScreenSize
        self.WIDE = self.iconSize * 0.25
        self.bottomCorner = 100 * ScreenSize

        self:setSize(w * 0.85 + 64,h * 0.85):setPos(w / 2 - self:W() / 2,h / 2 - self:H() / 2)
    end)

    ScroreboardPlayersPanel = panel
    
    function panel:Draw(w,h)
        SetDrawColor(0,0,0,100 * ScoreboardClose)
        DrawRect(0,0,w,h)

        DrawBlurByPanel(4,self)

        self:DrawTickRate(w,h)
        self:DrawScoreboard(w,h)
    end

    function panel:DrawTickRate(w,h)
        local wide = 1

        history[#history + 1] = {1 / ServerPerformance[1],ServerPerformance[2] * 1000 * 30}
        
        surface.SetDrawColor(0,255,0,15)

        for i = 1,#history do
            local v = self.bottomCorner * (history[i][1] / 120)

            surface.DrawRect(0 + wide * i,h - v + 1,wide,v)
        end

        surface.SetDrawColor(125,125,255,15)

        for i = 1,#history do
            local v = self.bottomCorner * (history[i][2] / 120)

            surface.DrawRect(0 + wide * i,h - v + 1,wide,v)
        end

        if #history >= w / wide then table.remove(history,1) end
    end

    function panel:DrawScoreboard() end

    function panel:Sort()
        local round = TableLevel()

        local teams = {}
        local lives,deads = {},{}

        for i,ply in pairs(player.GetAll()) do
            ply.last = nil

            local teamID = ply:Team()
            teams[teamID] = teams[teamID] or {{},{}}
            teamID = teams[teamID]

            local func = round.Scoreboard_Status
            if func then alive,alivecol,colorAdd = func(round,ply) end

            if ply:Alive() then
                teamID[1][#teamID[1] + 1] = ply
            else
                teamID[2][#teamID[2] + 1] = ply
            end
        end
        
        for teamID,list in pairs(teams) do
            xpcall(table.sort,err,list[1],timeSort)
            xpcall(table.sort,err,list[2],timeSort)
        end

        local sort = {}

        local func = round.ScoreboardSort
        if func then
            func(round,sort,teams)
        else
            for teamID,team in pairs(teams) do
                for i,ply in pairs(team[1]) do sort[#sort + 1] = ply end
                for i,ply in pairs(team[2]) do sort[#sort + 1] = ply end

                local last = team[1][#team[1]]
                if last then
                    local func = round.Scoreboard_DrawLast
                    if func and func(round,last) ~= nil then continue end

                    last.last = #team[1]
                end

                last = team[2][#team[2]]
                if last then
                    local func = round.Scoreboard_DrawLast
                    if func and func(round,last) ~= nil then continue end

                    last.last = #team[2]
                end
            end
        end

        self.sort = sort
    end

    local scroll = oop.CreatePanel("v_scrollpanel",panel):ad(function(self) self:setPos(0,30):setSize(panel:W(),panel:H() - panel.bottomCorner) end)
    scroll.scrolling = panel.iconSize + panel.WIDE / 2 / 2
    scroll.scrollMul = 3.5
    scroll.scrollLerp = 0.25
    
    local html = ScoreboardBuildOnHTML(panel,scroll)

    function panel:Update()
        self:Sort()

        if html.Ready then html:OnReady() end
    end

    panel:Update()

    local butt = oop.CreatePanel("v_button",panel):ad(function(self) self:setSize(200 * ScreenSize,35 * ScreenSize):setPos(panel:W() / 2 - self:W() - 16,panel:H() - (panel:H() - (scroll.y + scroll:H())) / 2 - self:H() / 2) end)
    butt.text = L("scoreboard_muteall")
    butt.font = "HS.18"

    function butt:OnMouse(key,value)
        if not value then return end

        MuteAll = not MuteAll
        butt.textColor = MuteAll and green or white

        UpdateVoiceVolumeScale()
    end
    butt.textColor = MuteAll and green or white

    local butt = oop.CreatePanel("v_button",panel):ad(function(self) self:setSize(200 * ScreenSize,35 * ScreenSize):setPos(panel:W() / 2 + 16,panel:H() - (panel:H() - (scroll.y + scroll:H())) / 2 - self:H() / 2) end)
    butt.text = L("scoreboard_mutedead")
    butt.font = "HS.18"
    
    function butt:OnMouse(key,value)
        if not value then return end

        MuteAllDeath = not MuteAllDeath
        butt.textColor = MuteAllDeath and green or white

        UpdateVoiceVolumeScale()
    end
    butt.textColor = MuteAllDeath and green or white
end

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect","Scoreboard Players",function()
    if IsValid(ScroreboardPlayersPanel) then ScroreboardPlayersPanel:Update() end
end)

gameevent.Listen("player_spawn")
hook.Add("player_spawn","Scoreboard Players",function()
    if IsValid(ScroreboardPlayersPanel) then ScroreboardPlayersPanel:Update() end
end)

event.Add("Voice Volume","MuteAll",function(ply,value)
    if MuteAll then value[1] = 0 return false end
end)

event.Add("Voice Volume","MuteAllDeath",function(ply,value)
    if MuteAllDeath and not ply:Alive() then value[1] = 0 return false end
end)

if Initialize and LocalPlayer():SteamID() == "STEAM_0:1:215196702" then OpenTab() end

//

local PLAYER = FindMetaTable("Player")

function PLAYER:GetAliveStatus()
    local lply = LocalPlayer()
    if (IsValid(lply) and lply:Alive()) or self:Alive() then
        return "scoreboard_unknown",ScoreboardSpec
    end

    local alive,alivecol,colorAdd

	local func = ActiveLevel and ActiveLevel.Scoreboard_Status
            
	if func then
		alive,alivecol,colorAdd = func(ActiveLevel,self)
	end

	if not func or (not alive) then
		if self:Alive() then
			alive = "scoreboard_unknown"
			alivecol = ScoreboardSpec
		elseif self:Team() == 1002 then
			alive = "scoreboard_spectate"
			alivecol = ScoreboardSpec
		else
			alive = "scoreboard_dead"
			alivecol = ScoreboardRed
			colorAdd = ScoreboardRed
		end
	end

    return alive,alivecol,colorAdd
end

function PLAYER:GetTeamStatus()
    local level = TableLevel()

    if roundActiveName == "level_homicide" then
        local lply = LocalPlayer()

        -- 1. Show LocalPlayer their own role
        if self == lply then
            if lply.roleT then
                return "traitor", (level and level.ColorRed) or Color(255, 0, 0)
            elseif lply.roleCT then
                return "Невиновный", (level and level.ColorBlue) or Color(0, 100, 255)
            else
                return "innocent", (level and level.red and level.red[2]) or Color(122, 122, 122)
            end
        end

        -- 2. Traitors see other traitors in TAB
        if IsValid(lply) and lply.roleT and self.roleT then
            return "traitor", (level and level.ColorRed) or Color(255, 0, 0)
        end

        -- 3. Armed Innocent (blue) is visible to everyone
        if self.roleCT then
            return "Невиновный", (level and level.ColorBlue) or Color(0, 100, 255)
        end

        -- 4. During active round, traitors and ordinary innocents display as innocent (Невиновный)
        local isRoundRunning = roundActive or (roundTimeStart and CurTime() - roundTimeStart < (roundTime or 300))
        if isRoundRunning and ((IsValid(lply) and lply:Alive() and not lply.isDead) or (self:Alive() and not self.isDead)) then
            return "innocent", (level and level.red and level.red[2]) or ScoreboardSpec
        end

        -- Round ended or dead
        if self.roleT then
            return "traitor", (level and level.ColorRed) or Color(255, 0, 0)
        elseif self.roleCT then
            return "Невиновный", (level and level.ColorBlue) or Color(0, 100, 255)
        else
            return "innocent", (level and level.red and level.red[2]) or Color(122, 122, 122)
        end
    end

    -- In all other game modes: show everyone their actual teams!
    local name, color = self:PlayerClassEvent("TeamName")
    if not name and level then
        if level.GetTeamName and level.teamEncoder then
            name, color = level:GetTeamName(self)
        elseif level.teamEncoder then
            local teamKey = level.teamEncoder[self:Team()]
            if teamKey and level[teamKey] then
                name = level[teamKey][1]
                color = level[teamKey][2]
            end
        end
    end

    name = name or "spectate"
    color = color or ScoreboardSpec

    return name, color
end

function PLAYER:GetTimeStatus()
    local time = (self:IsBot() and 0) or self:GetNWInt("Time",-1)

    if time == -1 then
        return false
    else
        time = math.floor(time + (CurTime() - self:GetNWFloat("TimeStart",0)))

        local result = time / 60 / 60
        local octatok = math.floor(result) % 10

        return math.floor(result) .. (octatok > 0 and ("," .. octatok) or "")

        //local dTime,hTime,mTime = math.floor(time / 60 / 60 / 24),(math.floor(time / 60 / 60) % 24),tostring(math.floor(time / 60) % 60)

        //return dTime,hTime,mTime
    end
end
