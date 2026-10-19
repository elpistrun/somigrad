--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/levels/_special/jailbreak/rank_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hgamemode/roundsystem/levels/_special/jailbreak/init_tier_0_sh.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\levels\\_special\\jailbreak\\rank_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Level = oop.Get("level_jailbreak")
if not Level then return end

Level.ranksList = {
    {"jailbreak_rank_1",Color(125,125,255),
        armors = {"Light-Helmet","ent_jack_gmod_ezarmor_azimutb","ent_jack_gmod_ezarmor_gruppa99t30b"}
    },
    {"jailbreak_rank_2",Color(75,75,255),
        armors = {"Light-Helmet","Light-Vest","ent_jack_gmod_ezarmor_azimutb","ent_jack_gmod_ezarmor_gruppa99t30b"}
    },
    {"jailbreak_rank_3",Color(25,25,25,255),
        armors = {"Riot-Helmet","Light-Vest","ent_jack_gmod_ezarmor_azimutb","ent_jack_gmod_ezarmor_gruppa99t30b"}
    },
    {"jailbreak_rank_4",Color(25,25,125),
        armors = {"Medium-Helmet","Medium-Light-Vest","ent_jack_gmod_ezarmor_azimutb","ent_jack_gmod_ezarmor_gruppa99t30b"}
    }
}

function Level:GetRank(ply)
    local rankID = ply:GetNWInt("JailBreakRank",0)
    local rank = self.ranksList[rankID]

    return rank,rankID
end

if SERVER then
    util.AddNetworkString("jailbreak_ranks_mdammm")

    local rankNames = {
        [0] = "Уволен",
        [1] = "Рядовой",
        [2] = "Сержант",
        [3] = "Майор",
        [4] = "Генерал"
    }

    local function GetRanksFilePath()
        if not file.IsDir("homigrad", "DATA") then file.CreateDir("homigrad") end
        return "homigrad/jailbreak_ranks.json"
    end

    local function LoadJailbreakRanks()
        local path = GetRanksFilePath()
        if file.Exists(path, "DATA") then
            local raw = file.Read(path, "DATA")
            local tbl = util.JSONToTable(raw or "")
            if istable(tbl) then return tbl end
        end
        return {}
    end

    local function SaveJailbreakRanks(tbl)
        local path = GetRanksFilePath()
        file.Write(path, util.TableToJSON(tbl or {}, true))
    end

    local jailbreakRanks = LoadJailbreakRanks()

    local function SyncJailbreakRanks(target)
        local jsonStr = util.TableToJSON(jailbreakRanks)
        net.Start("jailbreak_ranks_mdammm")
        net.WriteString(jsonStr)
        if target then net.Send(target) else net.Broadcast() end
    end

    local function ApplyJailbreakRank(ply)
        if not IsValid(ply) then return end
        local sID = ply:SteamID()
        local rankData = jailbreakRanks[sID]
        local rankID = (rankData and tonumber(rankData.id)) or 0
        ply:SetNWInt("JailBreakRank", rankID)
    end

    hook.Add("PlayerInitialSpawn", "Homigrad_Jailbreak_SyncRanks", function(ply)
        ApplyJailbreakRank(ply)
        timer.Simple(2, function()
            if IsValid(ply) then
                SyncJailbreakRanks(ply)
            end
        end)
    end)

    hook.Add("PlayerSpawn", "Homigrad_Jailbreak_ApplyRank", function(ply)
        ApplyJailbreakRank(ply)
    end)

    local function FindTargetPlayerOrSteamID(arg)
        arg = string.Trim(arg or "")
        if arg == "" then return nil, nil end

        if string.StartWith(arg, "STEAM_") or string.StartWith(arg, "[U:") then
            for _, p in ipairs(player.GetAll()) do
                if p:SteamID() == arg then
                    return arg, p:Nick(), p
                end
            end
            return arg, arg, nil
        end

        local search = string.lower(arg)
        for _, p in ipairs(player.GetAll()) do
            if string.find(string.lower(p:Nick()), search, 1, true) then
                return p:SteamID(), p:Nick(), p
            end
        end

        return nil, nil
    end

    local function ExecuteJailbreakAdd(executor, targetArg, rankArg)
        if IsValid(executor) and executor:IsPlayer() and not (executor:IsAdmin() or executor:IsSuperAdmin()) then
            executor:ChatPrint("[Jailbreak] У вас нет прав для выполнения этой команды!")
            return
        end

        local steamID, name, onlinePly = FindTargetPlayerOrSteamID(targetArg)
        if not steamID then
            local err = "[Jailbreak] Игрок или SteamID '" .. tostring(targetArg) .. "' не найден!"
            if IsValid(executor) and executor:IsPlayer() then executor:ChatPrint(err) else print(err) end
            return
        end

        local rankID = tonumber(rankArg)
        if not rankID or rankID < 0 or rankID > 4 then
            local usage = "[Jailbreak] Неверный ранг! Допустимые: 0 (Уволен), 1 (Рядовой), 2 (Сержант), 3 (Майор), 4 (Генерал)"
            if IsValid(executor) and executor:IsPlayer() then executor:ChatPrint(usage) else print(usage) end
            return
        end

        rankID = math.floor(rankID)

        if rankID == 0 then
            jailbreakRanks[steamID] = nil
        else
            jailbreakRanks[steamID] = {
                id = rankID,
                name = name or steamID
            }
        end

        SaveJailbreakRanks(jailbreakRanks)
        SyncJailbreakRanks()

        if IsValid(onlinePly) then
            onlinePly:SetNWInt("JailBreakRank", rankID)
            if rankID > 0 then
                onlinePly:ChatPrint("[Jailbreak] Вам присвоено звание: " .. rankNames[rankID] .. " (" .. rankID .. ")")
            else
                onlinePly:ChatPrint("[Jailbreak] Вы были уволены со звания.")
            end
        end

        local rankTitle = rankNames[rankID] or "Уволен"
        local notify = "[Jailbreak] Игроку " .. tostring(name) .. " (" .. steamID .. ") установлено звание: " .. rankTitle .. " (" .. rankID .. ")"
        print(notify)
        if IsValid(executor) and executor:IsPlayer() then
            executor:ChatPrint(notify)
        end
    end

    concommand.Add("jailbreak_add", function(ply, cmd, args)
        if #args < 2 then
            local usage = "Использование: jailbreak_add <SteamID/Ник> <1-4 или 0 (уволить)>"
            if IsValid(ply) then ply:ChatPrint(usage) else print(usage) end
            return
        end
        ExecuteJailbreakAdd(ply, args[1], args[2])
    end)

    hook.Add("PlayerSay", "Homigrad_Jailbreak_ChatCommand", function(ply, text)
        local parts = string.Explode(" ", string.Trim(text))
        if string.lower(parts[1] or "") == "!jailbreak_add" then
            if #parts < 3 then
                ply:ChatPrint("[Jailbreak] Использование: !jailbreak_add <SteamID/Ник> <1-4 или 0 (уволить)>\n1. Рядовой, 2. Сержант, 3. Майор, 4. Генерал")
                return ""
            end
            ExecuteJailbreakAdd(ply, parts[2], parts[3])
            return ""
        end
    end)

    return
end

JailBreak_ListRanksPlayers = JailBreak_ListRanksPlayers or {}

net.Receive("jailbreak_ranks_mdammm", function()
    local raw = net.ReadString()
    local tbl = util.JSONToTable(raw)
    if istable(tbl) then
        JailBreak_ListRanksPlayers = tbl
        if IsValid(JailBreakMenuRanks) then JailBreakMenuRanks:Update() end
    end
end)

local cframe1 = Color(255,255,255,5)

local Panel = {}
ScoreboardPages[11] = Panel

Panel.Name = "jb_ranks"

function Panel.CanOpen() return roundActiveName == "level_jailbreak" end

function Panel.Open(frame)
    JailBreakMenuRanks = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setSize(w * 0.9,h * 0.9):setPos(w / 2 - self:W() / 2,h / 2 - self:H() / 2) end)

    function JailBreakMenuRanks:Draw(w,h)
        surface.SetDrawColor(255,255,255,5)
        draw.GradientDown(w / 2 - 2,200,4,h / 2)
        draw.GradientUp(w / 2 - 2,h / 2 + 200,4,h / 2 - 400)
    end
    
    local iconSize = 64
    local wide = iconSize * 0.25

    local ranksList = oop.CreatePanel("v_players",JailBreakMenuRanks):ad(function(self,w,h)
        self:setSize(w / 2 - 100,h - 64):setPos(0,64)
    end)

    ranksList:CreateVBar()
    ranksList:Setup(iconSize)
    ranksList.scrolling = (iconSize + wide) * 6

    function ranksList:Draw(w,h)
        DisableClipping(true)
        draw.SimpleText("Players With Ranks","HS.25",w / 2,-32,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        DisableClipping(false)
    end

    local function OpenDermaPanel(steamID)
        local myOwnRankID = ranksList[LocalPlayer():SteamID()]

        if not myOwnRankID and not LocalPlayer():IsAdmin() then return end

        local menu = DermaMenu() 
        
        local sub = menu:AddSubMenu("Повысить до...")

        for id,rank in pairs(level_jailbreak.ranksList) do
            if LocalPlayer():IsAdmin() or myOwnRankID > id then
                sub:AddOption(L(rank[1]),function()
                    RunConsoleCommand("say","!jailbreak_add " .. steamID .. " " .. id)
                end)
            end
        end

        local rankInfo = JailBreak_ListRanksPlayers[steamID]
        rankInfo = rankInfo and level_jailbreak.ranksList[rankInfo.id]

        if rankInfo then
            menu:AddOption("Уволить",function()
                RunConsoleCommand("say","!jailbreak_add " .. steamID .. " 0")
            end)
        end
        
        menu:Open()
    end

    function ranksList:DrawPanel(w,h,panel,info)
        local rankInfo = level_jailbreak.ranksList[JailBreak_ListRanksPlayers[info.id].id]
        local col = rankInfo and rankInfo[2] or Color(25,25,25)

        surface.SetDrawColor(15,15,15,75)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(col.r,col.g,col.b,255)
        surface.DrawRect(0,0,4,h)

        surface.SetDrawColor(col.r,col.g,col.b,25)
        draw.GradientLeft(0,0,w,h)

        if self:IsHovered() then
            surface.SetDrawColor(255,255,255,255)
            surface.DrawRect(0,0,4,h)

            surface.SetDrawColor(255,255,255,1)
            surface.DrawRect(0,0,w,h)
        end

        draw.SimpleText(L(rankInfo and rankInfo[1] or "jailbreak_rank_0"),"HS.25",w -  h / 2,h / 2,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
        
        draw.Frame(0,0,w,h,cframe1,cframe2)
    end

    function ranksList:OnClick(key,info)
        OpenDermaPanel(info.id)
    end

    function ranksList.Update()//mdam
        ranksList:Clear()
  
        for steamid,info in pairs(JailBreak_ListRanksPlayers) do
            ranksList:AddPanel(steamid,info.name,info.avatar,info.avatarFrame,info.background)
        end
    end

    local playersList = oop.CreatePanel("v_players",JailBreakMenuRanks):ad(function(self,w,h)
        self:setSize(w / 2 - 100,h - 64):setPos(w / 2 + 100,64)
    end)

    playersList:CreateVBar()
    playersList.scrolling = (iconSize + wide) * 6
    playersList:Setup(iconSize,wide)

    function playersList:Draw(w,h)
        DisableClipping(true)
        draw.SimpleText("Players","HS.25",w / 2,-32,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        DisableClipping(false)
    end

    function playersList:DrawPanel(w,h,panel,info)
        local rankInfo = JailBreak_ListRanksPlayers[info.id]
        rankInfo = rankInfo and level_jailbreak.ranksList[rankInfo.id]

        local col = rankInfo and rankInfo[2] or Color(25,25,25)

        surface.SetDrawColor(15,15,15,75)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(col.r,col.g,col.b,255)
        surface.DrawRect(0,0,4,h)

        surface.SetDrawColor(col.r,col.g,col.b,25)
        draw.GradientLeft(0,0,w,h)

        if self:IsHovered() then
            surface.SetDrawColor(255,255,255,255)
            surface.DrawRect(0,0,4,h)

            surface.SetDrawColor(255,255,255,1)
            surface.DrawRect(0,0,w,h)
        end

        draw.SimpleText(L(rankInfo and rankInfo[1] or ""),"HS.25",w -  h / 2,h / 2,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
        
        draw.Frame(0,0,w,h,cframe1,cframe2)
    end

    function playersList:OnClick(key,info)
        OpenDermaPanel(info.id)
    end

    function playersList.Update()
        playersList:Clear()
 
        for i,ply in pairs(player.GetAll()) do
            playersList:AddPlayer(ply)
        end
    end

    function JailBreakMenuRanks:Update()
        ranksList.Update()
        playersList.Update()
    end

    JailBreakMenuRanks:Update()
end
