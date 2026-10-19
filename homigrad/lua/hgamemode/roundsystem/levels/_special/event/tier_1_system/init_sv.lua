if not SERVER then return end

--[[
    Homigrad Event System - Server Director
    Handles planning, event lifecycle, claim/start, co-hosts, groups,
    spawns, comments, and persistence.
]]

util.AddNetworkString("event_create")
util.AddNetworkString("event_info_planing")
util.AddNetworkString("event_claimed_info")
util.AddNetworkString("event_team")
util.AddNetworkString("event_group")
util.AddNetworkString("event_group_spawn")
util.AddNetworkString("event_relationship")
util.AddNetworkString("event_plugin")
util.AddNetworkString("event_plugin_cmd")
util.AddNetworkString("event_respawn")
util.AddNetworkString("event_comment_read")
util.AddNetworkString("event_comment_add")
util.AddNetworkString("event_playerstime_read")
util.AddNetworkString("event_info_edit")
util.AddNetworkString("event_info_edit_ui")
util.AddNetworkString("event_info_cmd")

Event_Planing = Event_Planing or {}
Event_Claimed = Event_Claimed or nil
Event_ClaimedID = Event_ClaimedID or nil
EventGroups = EventGroups or {}
EventEdits = EventEdits or {}
EventEditsUI = EventEditsUI or {}
Event_ChatCommandsUI = Event_ChatCommandsUI or {}

file.CreateDir("homigrad")
local eventsFile = "homigrad/events.json"
local commentsFile = "homigrad/event_comments.json"

local function LoadEvents()
    if file.Exists(eventsFile, "DATA") then
        Event_Planing = util.JSONToTable(file.Read(eventsFile, "DATA") or "{}") or {}
    else
        Event_Planing = {}
    end
end

local function SaveEvents()
    file.Write(eventsFile, util.TableToJSON(Event_Planing, true))
end

LoadEvents()

function Event_SyncPlaning(ply)
    local json = util.TableToJSON(Event_Planing)
    net.Start("event_info_planing")
    net.WriteString(json)
    if IsValid(ply) then net.Send(ply) else net.Broadcast() end
end

function Event_SyncClaimed(ply)
    net.Start("event_claimed_info")
    net.WriteTable(Event_Claimed or {})
    net.WriteString(tostring(Event_ClaimedID or ""))
    if IsValid(ply) then net.Send(ply) else net.Broadcast() end
end

function Event_SyncGroups(ply)
    net.Start("event_group")
    net.WriteTable(EventGroups or {})
    if IsValid(ply) then net.Send(ply) else net.Broadcast() end
end

function Event_SyncEdits(ply)
    net.Start("event_info_edit")
    net.WriteTable(EventEdits or {})
    if IsValid(ply) then net.Send(ply) else net.Broadcast() end

    net.Start("event_info_edit_ui")
    net.WriteTable(EventEditsUI or {})
    if IsValid(ply) then net.Send(ply) else net.Broadcast() end
end

function Event_SyncChatCommands(ply)
    net.Start("event_info_cmd")
    net.WriteTable(Event_ChatCommandsUI or {})
    if IsValid(ply) then net.Send(ply) else net.Broadcast() end
end

-- =========================================================================
-- EVENT PLANNING & CREATION
-- =========================================================================

concommand.Add("hg_event_create", function(ply)
    if not IsValid(ply) then return end
    if not Event_IsAdmin(ply) then return end

    local serverIP = game.GetIPAddress()
    if not serverIP or serverIP == "" or serverIP == "0.0.0.0:0" then
        serverIP = "127.0.0.1:27015"
    end

    local servers = {
        {
            name = GetHostName() or "Homigrad Server",
            ip = serverIP
        }
    }

    net.Start("event_create")
    net.WriteBool(true)
    net.WriteTable(servers)
    net.Send(ply)
end)

net.Receive("event_create", function(len, ply)
    if not IsValid(ply) then return end
    if not Event_IsAdmin(ply) then return end

    local req = net.ReadTable()
    if not req or not req.title then return end

    local newID = #Event_Planing + 1
    while Event_Planing[newID] do newID = newID + 1 end

    local serverIP = game.GetIPAddress()
    if not serverIP or serverIP == "" or serverIP == "0.0.0.0:0" then
        serverIP = "127.0.0.1:27015"
    end

    local eventData = {
        id = newID,
        title = req.title or ("Событие #" .. newID),
        desc = req.desc or "",
        backgroundUrl = req.backgroundUrl or "https://i.pinimg.com/originals/9f/7f/e1/9f7fe1e5419d6766c21f7f7873373685.gif",
        server = req.server or { name = GetHostName() or "Homigrad Server", ip = serverIP },
        period = req.period or { os.time(), os.time() + 3600 },
        ping = req.ping,
        moderate = true,
        owner = {
            steamid = ply:SteamID(),
            name = ply:Name(),
            avatar = (ply.GetAvatar and ply:GetAvatar()) or "",
            avatarFrame = (ply.GetAvatarFrame and ply:GetAvatarFrame()) or "",
            background = ""
        },
        friends = {}
    }

    if req.friends then
        for steamid in pairs(req.friends) do
            local fply = player.GetBySteamID(steamid)
            if IsValid(fply) then
                eventData.friends[steamid] = {
                    name = fply:Name(),
                    avatar = (fply.GetAvatar and fply:GetAvatar()) or "",
                    avatarFrame = (fply.GetAvatarFrame and fply:GetAvatarFrame()) or "",
                    background = ""
                }
            else
                eventData.friends[steamid] = {
                    name = steamid,
                    avatar = "",
                    avatarFrame = "",
                    background = ""
                }
            end
        end
    end

    Event_Planing[newID] = eventData
    SaveEvents()
    Event_SyncPlaning()
end)

concommand.Add("hg_event_remove", function(ply, cmd, args)
    local id = tonumber(args[1])
    if not id or not Event_Planing[id] then return end
    if IsValid(ply) and not (Event_IsAdmin(ply) or (Event_Planing[id].owner and Event_Planing[id].owner.steamid == ply:SteamID())) then
        return
    end

    Event_Planing[id] = nil
    SaveEvents()
    Event_SyncPlaning()
end)

-- =========================================================================
-- EVENT START & CLAIM & FINISH
-- =========================================================================

concommand.Add("hg_event_start", function(ply, cmd, args)
    local id = tonumber(args[1])
    if not id or not Event_Planing[id] then
        if table.Count(Event_Planing) > 0 then
            id = next(Event_Planing)
        end
    end

    if not id or not Event_Planing[id] then
        id = 1
        local serverIP = game.GetIPAddress()
        if not serverIP or serverIP == "" or serverIP == "0.0.0.0:0" then serverIP = "127.0.0.1:27015" end
        Event_Planing[id] = {
            id = id,
            title = "Событие " .. (IsValid(ply) and ply:Name() or "Server"),
            desc = "Кастомный эвент",
            backgroundUrl = "https://i.pinimg.com/originals/9f/7f/e1/9f7fe1e5419d6766c21f7f7873373685.gif",
            server = { name = GetHostName() or "Homigrad Server", ip = serverIP },
            period = { os.time(), os.time() + 7200 },
            moderate = true,
            owner = {
                steamid = IsValid(ply) and ply:SteamID() or "CONSOLE",
                name = IsValid(ply) and ply:Name() or "CONSOLE",
                avatar = (IsValid(ply) and ply.GetAvatar and ply:GetAvatar()) or "",
                avatarFrame = (IsValid(ply) and ply.GetAvatarFrame and ply:GetAvatarFrame()) or "",
                background = ""
            },
            friends = {}
        }
        SaveEvents()
        Event_SyncPlaning()
    end

    local ev = Event_Planing[id]
    if IsValid(ply) and not (ply:IsAdmin() or Event_CanAccess(ply, nil, ev)) then
        return
    end

    Event_Claimed = ev
    Event_ClaimedID = id

    if table.Count(EventGroups) == 0 then
        EventGroups[1] = {
            id = 1,
            name = "Игроки",
            color = Color(75, 175, 255),
            link = 1,
            list = {},
            models = {},
            spawnTime = 5,
            health = 100,
            playerjoin = true,
            playerremovebyleave = false,
            cantDamage = { [1] = false }
        }
    end

    for _, p in ipairs(player.GetAll()) do
        if not p.eventGroup and EventGroups[1] then
            p.eventGroup = EventGroups[1]
            EventGroups[1].list[p:SteamID()] = {
                name = p:Name(),
                avatar = (p.GetAvatar and p:GetAvatar()) or "",
                avatarFrame = (p.GetAvatarFrame and p:GetAvatarFrame()) or ""
            }
        end
    end

    Event_SyncClaimed()
    Event_SyncGroups()

    StartRound("level_event")
end)

concommand.Add("hg_event_claim", function(ply, cmd, args)
    concommand.Run(ply, "hg_event_start", args)
end)

concommand.Add("hg_event_finish", function(ply)
    if IsValid(ply) and not (ply:IsAdmin() or Event_CanAccess(ply)) then
        return
    end

    Event_Claimed = nil
    Event_ClaimedID = nil
    Event_SyncClaimed()

    SetNextLevel("level_homicide")
    StartRound("level_homicide")
end)

-- =========================================================================
-- EVENT CO-HOSTS (TEAM)
-- =========================================================================

net.Receive("event_team", function(len, ply)
    if not IsValid(ply) or not Event_Claimed then return end
    if not (ply:IsAdmin() or Event_CanAccess(ply)) then return end

    local args = net.ReadTable()
    local act = args[1]
    local targetSteamID = args[2]
    if not act or not targetSteamID then return end

    if act == "add" then
        local tply = player.GetBySteamID(targetSteamID)
        Event_Claimed.friends[targetSteamID] = {
            name = IsValid(tply) and tply:Name() or targetSteamID,
            avatar = (IsValid(tply) and tply.GetAvatar and tply:GetAvatar()) or "",
            avatarFrame = (IsValid(tply) and tply.GetAvatarFrame and tply:GetAvatarFrame()) or "",
            background = ""
        }
    elseif act == "remove" then
        Event_Claimed.friends[targetSteamID] = nil
    end

    Event_SyncClaimed()
end)

-- =========================================================================
-- EVENT GROUPS
-- =========================================================================

net.Receive("event_group", function(len, ply)
    if not IsValid(ply) or not (ply:IsAdmin() or Event_CanAccess(ply)) then return end
    local args = net.ReadTable()
    local act = args[1]
    if not act then return end

    if act == "create" then
        local id = #EventGroups + 1
        EventGroups[id] = {
            id = id,
            name = "Группа #" .. id,
            color = Color(math.random(50, 255), math.random(50, 255), math.random(50, 255)),
            link = id,
            list = {},
            models = {},
            spawnTime = 5,
            health = 100,
            playerjoin = false,
            playerremovebyleave = false,
            cantDamage = { [id] = false }
        }
        if event and event.Run then
            event.Run("Event Group Create", EventGroups[id], id)
        end
    elseif act == "remove" then
        local id = tonumber(args[2])
        if id and EventGroups[id] then
            table.remove(EventGroups, id)
            for i, grp in ipairs(EventGroups) do grp.id = i grp.link = i end
        end
    elseif act == "rename" then
        local id, name = tonumber(args[2]), tostring(args[3] or "")
        if id and EventGroups[id] and name ~= "" then
            EventGroups[id].name = name
        end
    elseif act == "recolor" then
        local id, col = tonumber(args[2]), args[3]
        if id and EventGroups[id] and istable(col) then
            EventGroups[id].color = Color(col.r or 255, col.g or 255, col.b or 255)
        end
    elseif act == "playerjoin" then
        local id, state = tonumber(args[2]), tobool(args[3])
        if id and EventGroups[id] then
            EventGroups[id].playerjoin = state
        end
    elseif act == "playerremovebyleave" then
        local id, state = tonumber(args[2]), tobool(args[3])
        if id and EventGroups[id] then
            EventGroups[id].playerremovebyleave = state
        end
    elseif act == "up" then
        local id = tonumber(args[2])
        if id and id > 1 and EventGroups[id] then
            local tmp = EventGroups[id - 1]
            EventGroups[id - 1] = EventGroups[id]
            EventGroups[id] = tmp
            for i, grp in ipairs(EventGroups) do grp.id = i grp.link = i end
        end
    elseif act == "down" then
        local id = tonumber(args[2])
        if id and id < #EventGroups and EventGroups[id] then
            local tmp = EventGroups[id + 1]
            EventGroups[id + 1] = EventGroups[id]
            EventGroups[id] = tmp
            for i, grp in ipairs(EventGroups) do grp.id = i grp.link = i end
        end
    elseif act == "user_add" then
        local id, targetPly = tonumber(args[2]), args[3]
        if id and EventGroups[id] and IsValid(targetPly) then
            for _, grp in pairs(EventGroups) do
                grp.list[targetPly:SteamID()] = nil
            end
            EventGroups[id].list[targetPly:SteamID()] = {
                name = targetPly:Name(),
                avatar = (targetPly.GetAvatar and targetPly:GetAvatar()) or "",
                avatarFrame = (targetPly.GetAvatarFrame and targetPly:GetAvatarFrame()) or ""
            }
            targetPly.eventGroup = EventGroups[id]
        end
    elseif act == "user_remove" then
        local id, steamid = tonumber(args[2]), tostring(args[3])
        if id and EventGroups[id] and steamid then
            EventGroups[id].list[steamid] = nil
            local tp = player.GetBySteamID(steamid)
            if IsValid(tp) and tp.eventGroup == EventGroups[id] then
                tp.eventGroup = nil
            end
        end
    end

    for _, p in ipairs(player.GetAll()) do
        p.eventGroup = nil
        for _, grp in ipairs(EventGroups) do
            if grp.list[p:SteamID()] then
                p.eventGroup = grp
                break
            end
        end
    end

    Event_SyncGroups()
end)

-- =========================================================================
-- EVENT SPAWN & RELATIONSHIPS & MODELS
-- =========================================================================

net.Receive("event_group_spawn", function(len, ply)
    if not IsValid(ply) or not (ply:IsAdmin() or Event_CanAccess(ply)) then return end
    local args = net.ReadTable()
    local act = args[1]
    if not act then return end

    if act == "edit" then
        local groupID, name, val = tonumber(args[2]), args[3], args[4]
        local group = EventGroups[groupID]
        if group then
            if EventSpawnEditCMD then
                EventSpawnEditCMD(name, group, groupID, {val})
            else
                group[name] = val
            end
        end
    elseif act == "relationship" then
        local groupID, name, groupLink, val = tonumber(args[2]), args[3], tonumber(args[4]), args[5]
        local group = EventGroups[groupID]
        if group and EventSpawnRelationshipsCMD then
            EventSpawnRelationshipsCMD(name, group, groupID, {groupLink, val})
        end
    elseif act == "modelcreate" then
        local groupID, mdlName = tonumber(args[2]), tostring(args[3] or "")
        local group = EventGroups[groupID]
        if group and mdlName ~= "" then
            group.models = group.models or {}
            group.models[mdlName] = { bodygroups = {} }
        end
    elseif act == "modelremove" then
        local groupID, mdlName = tonumber(args[2]), tostring(args[3] or "")
        local group = EventGroups[groupID]
        if group and group.models then
            group.models[mdlName] = nil
        end
    elseif act == "bodygroup" then
        local groupID, mdlName, bgID, val = tonumber(args[2]), tostring(args[3] or ""), tonumber(args[4]), args[5]
        local group = EventGroups[groupID]
        if group and group.models and group.models[mdlName] then
            group.models[mdlName].bodygroups[bgID] = val
        end
    end

    Event_SyncGroups()
end)

-- =========================================================================
-- EVENT RESPAWN
-- =========================================================================

net.Receive("event_respawn", function(len, ply)
    if not IsValid(ply) or roundActiveName ~= "level_event" then return end
    if ply:Alive() and not ply:GetNWBool("FakeDeath") then return end

    local grp = ply.eventGroup
    if not grp or grp.spawnTime < 0 then return end

    local deathStart = ply:GetNWFloat("DeathStart", 0)
    if CurTime() < deathStart + grp.spawnTime then return end

    ply.isDead = false
    ply:SetNWBool("isDead", false)
    ply:SetNWBool("Alive", true)
    ply:SetNWBool("FakeDeath", false)
    ply.HeadPop = nil
    ply:SetNWBool("HeadPop", false)

    local rag = ply:GetNWEntity("FakeRagdoll")
    if not IsValid(rag) then rag = ply.fakeEnt end
    if IsValid(rag) and not rag:IsPlayer() then rag:Remove() end
    ply.fakeEnt = nil
    ply:SetNWEntity("FakeRagdoll", NULL)

    ply:UnSpectate()
    ply:SetMoveType(MOVETYPE_WALK)
    ply:SetNoDraw(false)
    ply:SetNotSolid(false)
    ply.eventRespawn = true
    ply:Spawn()
    ply.eventRespawn = nil
    ply:StripWeapons()
    ply:RemoveAllAmmo()
    ply:Give("weapon_hands")

    local Level = Levels and Levels["level_event"]
    if Level and Level.PlayerSpawn then
        Level:PlayerSpawn(ply)
    end
end)

-- =========================================================================
-- EVENT COMMENTS & PLAYTIME
-- =========================================================================

local commentsData = {}
if file.Exists(commentsFile, "DATA") then
    commentsData = util.JSONToTable(file.Read(commentsFile, "DATA") or "{}") or {}
end

net.Receive("event_comment_read", function(len, ply)
    local eventID = net.ReadString()
    local idNum = tonumber(eventID)
    local evComments = (idNum and commentsData[idNum]) or {}
    local json = util.TableToJSON(evComments)
    net.Start("event_comment_read")
    net.WriteString(json)
    net.WriteString(tostring(eventID))
    net.Send(ply)
end)

net.Receive("event_comment_add", function(len, ply)
    if not IsValid(ply) then return end
    local eventID = tonumber(net.ReadString())
    local text = net.ReadString()
    local stars = tonumber(net.ReadString()) or 5
    if not eventID or not text or text == "" then return end

    commentsData[eventID] = commentsData[eventID] or {}
    commentsData[eventID][ply:SteamID()] = {
        text,
        stars,
        steam_profile = {
            name = ply:Name(),
            avatar = (ply.GetAvatar and ply:GetAvatar()) or "",
            avatarFrame = (ply.GetAvatarFrame and ply:GetAvatarFrame()) or ""
        }
    }
    file.Write(commentsFile, util.TableToJSON(commentsData, true))

    net.Start("event_comment_add")
    net.Send(ply)
end)

net.Receive("event_playerstime_read", function(len, ply)
    local eventID = net.ReadString()
    net.Start("event_playerstime_read")
    net.WriteString("{}")
    net.WriteString(tostring(eventID))
    net.Send(ply)
end)

-- Initial Sync
hook.Add("PlayerInitialSpawn", "Homigrad_Event_PlayerSync", function(ply)
    timer.Simple(1.5, function()
        if not IsValid(ply) then return end
        Event_SyncPlaning(ply)
        Event_SyncClaimed(ply)
        Event_SyncGroups(ply)
        Event_SyncEdits(ply)
        Event_SyncChatCommands(ply)
    end)
end)
