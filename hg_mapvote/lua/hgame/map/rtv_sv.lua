-- hg_mapvote/lua/hgame/map/rtv_sv.lua
-- Server-side RTV (Rock The Vote) engine for map changes.

if not SERVER then return end

util.AddNetworkString("rtv vote")
util.AddNetworkString("rtv add map")
util.AddNetworkString("rtv notify")
util.AddNetworkString("rtv status")
util.AddNetworkString("rtv maps list")

-- Configuration --------------------------------------------------------------
local RTV_RoundsForced = 0       -- 0 = disabled (automatic forced voting disabled)
local RTV_VoteTime     = 30      -- seconds a vote stays open before resolving
local RTV_Cooldown     = 60      -- minimum seconds between player-triggered RTVs
local RTV_MapsDir      = "maps/*.bsp"

-- State ----------------------------------------------------------------------
RTVStatus     = nil              -- nil | "vote" | "random"
RTVVote       = {}               -- [map] = { [steamid64] = {avatar=,avatarFrame=} }
RTVVoteNumber = {}
RTVVoteMax    = 0
RTVLeaders    = {}

local rtvRounds      = 0         -- completed rounds since last forced vote
local rtvNoVote      = false     -- nortv toggle
local rtvLastStart   = 0         -- CurTime of the last player-triggered start
local rtvMaps        = {}        -- cached votable map names (array)
local rtvPlayerVotes = {}        -- [steamid64] = true (rock the vote lobby)

local RTVEndVote

local function RTVResolveMaps()
    rtvMaps = {}

    local cur = game.GetMap()
    local files = file.Find(RTV_MapsDir, "GAME")

    if files then
        for _, f in ipairs(files) do
            local name = string.sub(f, 1, -5) -- strip ".bsp"
            if name ~= "" and name ~= cur then rtvMaps[#rtvMaps + 1] = name end
        end
    end

    if #rtvMaps == 0 and files then
        for _, f in ipairs(files) do
            local name = string.sub(f, 1, -5)
            if name ~= "" then rtvMaps[#rtvMaps + 1] = name end
        end
    end

    table.sort(rtvMaps)
    return rtvMaps
end

local function RTVIsValidMap(map)
    for _, m in ipairs(rtvMaps) do if m == map then return true end end
    return false
end

-- Networking helpers ---------------------------------------------------------
local function RTVNotify(ply, text, color)
    if not IsValid(ply) then return end
    net.Start("rtv notify")
        net.WriteString(text)
        net.WriteColor(color or Color(255,255,255))
    net.Send(ply)
end

local function RTVNotifyAll(text, color)
    net.Start("rtv notify")
        net.WriteString(text)
        net.WriteColor(color or Color(255,255,255))
    net.Broadcast()
end

local function RTVSendMapsList(ply)
    if #rtvMaps == 0 then RTVResolveMaps() end

    net.Start("rtv maps list")
        net.WriteTable(rtvMaps)
    if IsValid(ply) then net.Send(ply) else net.Broadcast() end
end

local function RTVGetWinner()
    local best, winner = 0, nil

    for vote, list in pairs(RTVVote) do
        local n = table.Count(list)
        if n > best then
            best = n
            winner = vote
        end
    end

    return winner
end

local function RTVBroadcastStatus()
    if RTVStatus == "vote" then
        RTVLeaders = { RTVGetWinner() }

        RTVVoteNumber = {}
        local max = 0
        for vote, list in pairs(RTVVote) do
            local n = table.Count(list)
            RTVVoteNumber[vote] = n
            max = max + n
        end
        RTVVoteMax = max

        net.Start("rtv status")
            net.WriteString("vote")
            net.WriteTable(RTVVote)
        net.Broadcast()
    elseif RTVStatus == "random" then
        net.Start("rtv status")
            net.WriteString("random")
            net.WriteTable(rtvMaps)
            net.WriteString(RTVRandomWinner or "")
            net.WriteString("35")
            net.WriteString("4")
        net.Broadcast()
    else
        net.Start("rtv status")
            net.WriteString("")
        net.Broadcast()
    end
end

-- Vote lifecycle -------------------------------------------------------------
function RTVCreateVote(force)
    if rtvNoVote and force ~= true then return false end

    RTVResolveMaps()
    if #rtvMaps == 0 then
        RTVNotifyAll("rtv_cant_no_maps", Color(255,80,80))
        return false
    end

    RTVStatus = "vote"
    RTVVote = {}
    rtvPlayerVotes = {}

    for _, map in ipairs(rtvMaps) do RTVVote[map] = {} end

    RTVVoteNumber = {}
    RTVVoteMax = 0
    RTVLeaders = {}

    SetGlobalString("RTVTitle", "rtv_title")
    SetGlobalFloat("RTVStart", CurTime())
    SetGlobalFloat("RTVTime", RTV_VoteTime)

    RTVSendMapsList()
    RTVBroadcastStatus()

    timer.Remove("RTVResolve")
    timer.Create("RTVResolve", RTV_VoteTime, 1, function()
        if RTVStatus == "vote" then RTVEndVote() end
    end)

    return true
end

local function RTVPickRandomMap()
    if #rtvMaps == 0 then return nil end
    return rtvMaps[math.random(1, #rtvMaps)]
end

RTVEndVote = function()
    timer.Remove("RTVResolve")

    local status = RTVStatus
    local winner = RTVGetWinner()

    if status == "vote" then
        if not winner or winner == "extend" then
            RTVStatus = nil
            RTVNotifyAll("rtv_extend", Color(120,255,120))
            rtvRounds = 0
            net.Start("rtv status")
                net.WriteString("")
            net.Broadcast()
        elseif winner == "random" then
            local targetMap = RTVPickRandomMap() or game.GetMap()
            RTVStatus = "random"
            RTVRandomWinner = targetMap

            net.Start("rtv status")
                net.WriteString("random")
                net.WriteTable(rtvMaps)
                net.WriteString(targetMap)
                net.WriteString("35")
                net.WriteString("4")
            net.Broadcast()

            rtvRounds = 0
            timer.Simple(7.5, function()
                RTVStatus = nil
                RunConsoleCommand("changelevel", targetMap)
            end)
            return
        else
            RTVStatus = nil
            RTVNotifyAll("rtv_changemap", Color(255,255,255))
            rtvRounds = 0
            net.Start("rtv status")
                net.WriteString("")
            net.Broadcast()
            timer.Simple(3, function() RunConsoleCommand("changelevel", winner) end)
        end
    elseif status == "random" then
        local targetMap = RTVPickRandomMap() or game.GetMap()
        RTVStatus = nil
        rtvRounds = 0
        timer.Simple(3, function() RunConsoleCommand("changelevel", targetMap) end)
    else
        RTVStatus = nil
        net.Start("rtv status")
            net.WriteString("")
        net.Broadcast()
    end

    RTVVote = {}
    RTVVoteNumber = {}
    RTVVoteMax = 0
    RTVLeaders = {}
    rtvPlayerVotes = {}
end

local function RTVClose()
    timer.Remove("RTVResolve")
    RTVStatus = nil

    net.Start("rtv status")
        net.WriteString("")
    net.Broadcast()
end

-- Player votes ---------------------------------------------------------------
net.Receive("rtv vote", function(len, ply)
    if not IsValid(ply) then return end
    if RTVStatus ~= "vote" then return end

    local vote = net.ReadString()
    local steamid64 = ply:SteamID64()
    local old

    for oldMap, list in pairs(RTVVote) do
        if list[steamid64] then old = oldMap break end
    end

    if vote == "extend" then
        vote = "extend"
    elseif vote == "random" then
        vote = "random"
    elseif not RTVIsValidMap(vote) then
        RTVNotify(ply, "rtv_cant_invalid", Color(255,120,80))
        return
    end

    if old and old == vote then
        RTVVote[old][steamid64] = nil
        if next(RTVVote[old]) == nil and (old == "extend" or old == "random") then RTVVote[old] = nil end
        RTVNotify(ply, "rtv_unvote_done", Color(255,255,255))
    else
        if old then
            RTVVote[old][steamid64] = nil
            if next(RTVVote[old]) == nil and (old == "extend" or old == "random") then RTVVote[old] = nil end
        end

        RTVVote[vote] = RTVVote[vote] or {}
        RTVVote[vote][steamid64] = {
            avatar = ply:GetNWString("Avatar"),
            avatarFrame = ply:GetNWString("AvatarFrame"),
        }

        RTVNotify(ply, "rtv_vote_done", Color(255,255,255))
    end

    RTVBroadcastStatus()
end)

net.Receive("rtv add map", function(len, ply)
    if not IsValid(ply) or RTVStatus ~= "vote" then return end

    local map = net.ReadString()
    if map == "" then return end

    RTVResolveMaps()
    if not RTVIsValidMap(map) then
        RTVNotify(ply, "rtv_cant_invalid", Color(255,120,80))
        return
    end

    local steamid64 = ply:SteamID64()

    for oldMap, list in pairs(RTVVote) do
        if list[steamid64] then
            list[steamid64] = nil
            if next(list) == nil and (oldMap == "extend" or oldMap == "random") then RTVVote[oldMap] = nil end
            break
        end
    end

    RTVVote[map] = RTVVote[map] or {}
    RTVVote[map][steamid64] = {
        avatar = ply:GetNWString("Avatar"),
        avatarFrame = ply:GetNWString("AvatarFrame"),
    }

    RTVNotify(ply, "rtv_vote_done", Color(255,255,255))
    RTVBroadcastStatus()
end)

-- Forced vote counter (DISABLED) ---------------------------------------------
-- Принудительное голосование по окончанию раундов полностью отключено
local function OnRoundEndTrigger()
    return
end

hook.Remove("Homigrad_RoundEnd", "RTV_Counter")
hook.Remove("HG RoundEnd", "RTV_Counter")
hook.Remove("RoundEnd", "RTV_Counter")

-- Rock The Vote Counter -------------------------------------------------------
local function CheckRTVVotes()
    local plys = player.GetAll()
    local total = #plys
    if total == 0 then return 0, 1 end

    local count = 0
    for id in pairs(rtvPlayerVotes) do
        local p = player.GetBySteamID64(id)
        if IsValid(p) then
            count = count + 1
        else
            rtvPlayerVotes[id] = nil
        end
    end

    local needed = math.max(math.ceil(total * 0.5), 1)
    return count, needed
end

local function HandleRTVCommand(ply)
    if not IsValid(ply) then
        RTVCreateVote(true)
        return
    end

    if rtvNoVote then
        RTVNotify(ply, "rtv_cant_disable", Color(255,120,80))
        return
    end

    if RTVStatus == "vote" then
        RTVSendMapsList(ply)
        net.Start("rtv status")
            net.WriteString("vote")
            net.WriteTable(RTVVote)
        net.Send(ply)
        return
    end

    if CurTime() - rtvLastStart < RTV_Cooldown then
        RTVNotify(ply, "rtv_cant_timeout", Color(255,120,80))
        return
    end

    local id64 = ply:SteamID64()
    if rtvPlayerVotes[id64] then
        rtvPlayerVotes[id64] = nil
        local count, needed = CheckRTVVotes()
        local msg = (L and L("rtv_unvote", ply:Name(), tostring(count), tostring(needed))) or (ply:Name() .. " снял голос за смену карты (" .. count .. " / " .. needed .. ")")
        RTVNotifyAll(msg, Color(255,200,80))
    else
        rtvPlayerVotes[id64] = true
        local count, needed = CheckRTVVotes()
        local msg = (L and L("rtv_vote", ply:Name(), tostring(count), tostring(needed))) or (ply:Name() .. " проголосовал за смену карты (" .. count .. " / " .. needed .. ")")
        RTVNotifyAll(msg, Color(255,255,255))

        if count >= needed then
            rtvPlayerVotes = {}
            rtvLastStart = CurTime()
            if RTVCreateVote() then
                RTVNotifyAll("rtv_start_vote", Color(255,255,255))
            end
        end
    end
end

local function CanRunAdminCmd(ply)
    if not IsValid(ply) then return true end -- console / RCON
    if ply:IsSuperAdmin() or ply:IsAdmin() then return true end

    -- Homigrad admin panel role permissions
    if AdminPanelRole_HasSuccess and (AdminPanelRole_HasSuccess(ply, "admin") or AdminPanelRole_HasSuccess(ply, "rcon") or AdminPanelRole_HasSuccess(ply, "command_rtv_start")) then
        return true
    end
    if ply.HasSuccess and (ply:HasSuccess("admin") or ply:HasSuccess("rcon") or ply:HasSuccess("command_rtv_start")) then
        return true
    end

    -- Common administrative usergroups
    local group = string.lower(ply:GetUserGroup() or "")
    if group == "superadmin" or group == "admin" or group == "root" or group == "owner" or group == "dadmin" or group == "operator" or group == "moderator" or group == "curator" or group == "headadmin" then
        return true
    end

    -- ULib / CAMI integration
    if ULib and ULib.ucl and ULib.ucl.query and (ULib.ucl.query(ply, "ulx rcon") or ULib.ucl.query(ply, "ulx map") or ULib.ucl.query(ply, "ulx kick")) then
        return true
    end

    if CAMI and CAMI.PlayerHasAccess and CAMI.PlayerHasAccess(ply, "Homigrad Admin") then
        return true
    end

    return false
end

local function HandleForceRTV(ply)
    if not CanRunAdminCmd(ply) then
        RTVNotify(ply, "У вас нет прав для принудительного голосования.", Color(255,120,80))
        return
    end

    rtvPlayerVotes = {}
    if RTVCreateVote(true) then
        RTVNotifyAll("rtv_force_vote", Color(255,200,80))
    end
end

-- Chat hook -------------------------------------------------------------------
hook.Add("PlayerSay", "RTV_ChatHooks", function(ply, text, team)
    if not IsValid(ply) or not isstring(text) then return end
    local clean = string.Trim(string.lower(text))

    if clean == "!rtv" or clean == "/rtv" or clean == ".rtv" or clean == "!ртв" or clean == "/ртв" or clean == "rtv" then
        HandleRTVCommand(ply)
        return ""
    end

    if clean == "!forcertv" or clean == "/forcertv" or clean == ".forcertv" then
        HandleForceRTV(ply)
        return ""
    end
end)

-- Console commands ------------------------------------------------------------
concommand.Add("rtv", function(ply)
    HandleRTVCommand(ply)
end)

concommand.Add("forcertv", function(ply)
    HandleForceRTV(ply)
end)

concommand.Add("rtv_start", function(ply)
    HandleForceRTV(ply)
end)

concommand.Add("rtv_end", function(ply)
    if not CanRunAdminCmd(ply) then return end
    if RTVStatus ~= "vote" then
        if IsValid(ply) then ply:ChatPrint("[RTV] Голосование не активно") end
        return
    end
    RTVEndVote()
    if IsValid(ply) then ply:ChatPrint("[RTV] Голосование завершено") end
end)

concommand.Add("nortv", function(ply, cmd, args)
    if not CanRunAdminCmd(ply) then return end
    local val = args[1]
    rtvNoVote = val == true or val == "1" or val == 1
    if rtvNoVote then
        RTVClose()
        net.Start("rtv notify")
            net.WriteString("rtv_cant_disable")
            net.WriteColor(Color(255,120,80))
        net.Broadcast()
    end
end)

-- Admin panel bindings --------------------------------------------------------
timer.Simple(0, function()
    local function reg(name, func)
        if AdminPanel_Command_Create then
            AdminPanel_Command_Create(name, {}, func, nil, nil, "rcon")
        elseif adminPanel and adminPanel.commandCreate then
            adminPanel.commandCreate(name, func, nil, nil, "rcon")
        end
    end

    reg("rtv_start", function(caller)
        if RTVStatus then
            if IsValid(caller) then caller:ChatPrint("[RTV] Голосование уже идёт") end
            return
        end
        if RTVCreateVote(true) and IsValid(caller) then
            caller:ChatPrint("[RTV] Голосование запущено")
        end
    end)

    reg("rtv_end", function(caller)
        if RTVStatus ~= "vote" then
            if IsValid(caller) then caller:ChatPrint("[RTV] Голосование не активно") end
            return
        end
        RTVEndVote()
        if IsValid(caller) then caller:ChatPrint("[RTV] Голосование завершено") end
    end)

    reg("nortv", function(caller, value)
        rtvNoVote = value == true or value == "1" or value == 1
        if rtvNoVote then
            RTVClose()
            net.Start("rtv notify")
                net.WriteString("rtv_cant_disable")
                net.WriteColor(Color(255,120,80))
            net.Broadcast()
        end
    end)
end)

-- Player disconnect cleanup ---------------------------------------------------
hook.Add("PlayerDisconnected", "RTV_DisconnectCleanup", function(ply)
    if not IsValid(ply) then return end
    local id64 = ply:SteamID64()
    if rtvPlayerVotes[id64] then
        rtvPlayerVotes[id64] = nil
    end

    if RTVStatus == "vote" then
        for vote, list in pairs(RTVVote) do
            if list[id64] then
                list[id64] = nil
                RTVBroadcastStatus()
                break
            end
        end
    end
end)

-- Late-joiner sync -----------------------------------------------------------
hook.Add("PlayerInitialSpawn", "RTV Sync", function(ply)
    timer.Simple(1, function()
        if not IsValid(ply) then return end

        RTVSendMapsList(ply)

        if RTVStatus == "vote" then
            net.Start("rtv status")
                net.WriteString("vote")
                net.WriteTable(RTVVote)
            net.Send(ply)
        end
    end)
end)

if Initialize then RTVResolveMaps() end
