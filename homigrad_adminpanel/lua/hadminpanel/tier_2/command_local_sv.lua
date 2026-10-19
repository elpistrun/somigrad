-- Homigrad AdminPanel Server Implementation
-- Handles adminpanel_command, ulx_cmd, punishments sync, and server moderation commands.

if CLIENT then return end

util.AddNetworkString("adminpanel_command")
util.AddNetworkString("hg_ap_punish_sync")

local PUNISH_FILE = "hg_adminpanel_punish.json"

local punishData = {
    bans = {},
    gags = {},
    mutes = {},
    warns = {}
}

local function LoadPunishData()
    if file.Exists(PUNISH_FILE, "DATA") then
        local raw = file.Read(PUNISH_FILE, "DATA")
        local tbl = util.JSONToTable(raw or "")
        if istable(tbl) then
            punishData.bans = tbl.bans or {}
            punishData.gags = tbl.gags or {}
            punishData.mutes = tbl.mutes or {}
            punishData.warns = tbl.warns or {}
        end
    end
end

local function SavePunishData()
    file.Write(PUNISH_FILE, util.TableToJSON(punishData, true))
end

LoadPunishData()

local function SyncPunish(ply)
    local compressed = util.Compress(util.TableToJSON(punishData))
    if not compressed then return end

    net.Start("hg_ap_punish_sync")
    net.WriteUInt(#compressed, 32)
    net.WriteData(compressed, #compressed)
    if IsValid(ply) then
        net.Send(ply)
    else
        net.Broadcast()
    end
end

hook.Add("PlayerInitialSpawn", "hg_ap_punish_sync", function(ply)
    timer.Simple(2, function()
        if IsValid(ply) and AdminPanelRole_HasSuccess(ply, "ban_list") then
            SyncPunish(ply)
        end
    end)
end)

-- Voice gag hook
hook.Add("PlayerCanHearPlayersVoice", "hg_ap_gag", function(listener, talker)
    if not IsValid(talker) then return end
    local sid64 = talker:SteamID64()
    if sid64 and punishData.gags[sid64] then
        local exp = punishData.gags[sid64].expire or 0
        if exp == 0 or exp > os.time() then
            return false, false
        else
            punishData.gags[sid64] = nil
            SavePunishData()
        end
    end
end)

-- Chat mute hook
hook.Add("PlayerCanSeePlayersChat", "hg_ap_mute", function(text, teamOnly, listener, speaker)
    if not IsValid(speaker) then return end
    local sid64 = speaker:SteamID64()
    if sid64 and punishData.mutes[sid64] then
        local exp = punishData.mutes[sid64].expire or 0
        if exp == 0 or exp > os.time() then
            return false
        else
            punishData.mutes[sid64] = nil
            SavePunishData()
        end
    end
end)

-- Check ban on connect
hook.Add("CheckPassword", "hg_ap_ban_check", function(steamID64, ipAddress, svPassword, clPassword, name)
    if punishData.bans[steamID64] then
        local ban = punishData.bans[steamID64]
        local exp = ban.expire or 0
        if exp == 0 or exp > os.time() then
            if ban.customKickMsg then
                return false, ban.customKickMsg
            end
            local reason = ban.reason or "Banned by Admin"
            local timeLeft = exp == 0 and "Permanent" or string.NiceTime(exp - os.time())
            return false, string.format("You are banned!\nReason: %s\nTime remaining: %s", reason, timeLeft)
        else
            punishData.bans[steamID64] = nil
            SavePunishData()
        end
    end
end)

function AdminPanel_BanPlayer(target, minutes, reason, adminName, customKickMsg)
    local steamID64 = nil
    local nick = "Unknown"
    local tPly = nil

    if isentity(target) and target:IsPlayer() then
        tPly = target
        steamID64 = target:SteamID64()
        nick = target:Nick()
    elseif isstring(target) or isnumber(target) then
        steamID64 = tostring(target)
        for _, ply in ipairs(player.GetAll()) do
            if ply:SteamID64() == steamID64 or ply:SteamID() == steamID64 then
                tPly = ply
                nick = ply:Nick()
                steamID64 = ply:SteamID64()
                break
            end
        end
    end

    if not steamID64 then return end

    minutes = tonumber(minutes) or 0
    local expire = minutes > 0 and (os.time() + (minutes * 60)) or 0
    reason = reason or "Banned by administrator"

    punishData.bans[steamID64] = {
        name = nick,
        steamid = util.SteamIDFrom64(steamID64),
        steamid64 = steamID64,
        reason = reason,
        admin = adminName or "Console",
        expire = expire,
        date = os.time(),
        customKickMsg = customKickMsg
    }

    SavePunishData()
    SyncPunish()

    if ULib and isfunction(ULib.ban) then
        pcall(ULib.ban, tPly or steamID64, minutes, reason)
    end

    if IsValid(tPly) then
        tPly:Kick(customKickMsg or ("Banned: " .. reason))
    end
end

local function FindPlayer(target)
    if not target or target == "" then return nil end
    if isentity(target) and target:IsPlayer() then return target end
    target = string.lower(tostring(target))

    if target == "^" or target == "me" then return nil end

    for _, ply in ipairs(player.GetAll()) do
        if string.lower(ply:Nick()) == target or ply:SteamID() == target or ply:SteamID64() == target then
            return ply
        end
    end

    for _, ply in ipairs(player.GetAll()) do
        if string.find(string.lower(ply:Nick()), target, 1, true) then
            return ply
        end
    end

    return nil
end

local commands = {}

local function CheckPerm(ply, perm)
    if not IsValid(ply) then return true end
    if ply:IsSuperAdmin() then return true end
    return AdminPanelRole_HasSuccess(ply, perm)
end

-- Teleport / Movement commands
commands["noclip"] = function(ply, target)
    local tPly = FindPlayer(target) or ply
    if not IsValid(tPly) then return end
    if not CheckPerm(ply, "command_noclip") then return end

    if tPly:GetMoveType() == MOVETYPE_NOCLIP then
        tPly:SetMoveType(MOVETYPE_WALK)
    else
        tPly:SetMoveType(MOVETYPE_NOCLIP)
    end
end

commands["god"] = function(ply, target)
    local tPly = FindPlayer(target) or ply
    if not IsValid(tPly) then return end
    if not CheckPerm(ply, "command_god") then return end

    tPly:GodEnable()
    tPly:ChatPrint("Godmode enabled.")
end

commands["ungod"] = function(ply, target)
    local tPly = FindPlayer(target) or ply
    if not IsValid(tPly) then return end
    if not CheckPerm(ply, "command_god") then return end

    tPly:GodDisable()
    tPly:ChatPrint("Godmode disabled.")
end

commands["goto"] = function(ply, target)
    if not IsValid(ply) then return end
    if not CheckPerm(ply, "command_tp") then return end
    local tPly = FindPlayer(target)
    if not IsValid(tPly) then return end

    ply:SetPos(tPly:GetPos() + tPly:GetForward() * -45 + Vector(0, 0, 5))
end

commands["bring"] = function(ply, target)
    if not IsValid(ply) then return end
    if not CheckPerm(ply, "command_tp") then return end
    local tPly = FindPlayer(target)
    if not IsValid(tPly) then return end

    tPly:SetPos(ply:GetPos() + ply:GetForward() * 45 + Vector(0, 0, 5))
end

commands["tp"] = function(ply, target, dest)
    if not CheckPerm(ply, "command_tp") then return end
    local tPly = FindPlayer(target)
    local dPly = FindPlayer(dest)
    if IsValid(tPly) and IsValid(dPly) then
        tPly:SetPos(dPly:GetPos() + dPly:GetForward() * 45 + Vector(0, 0, 5))
    end
end

commands["slay"] = function(ply, target)
    if not CheckPerm(ply, "command_slay") then return end
    local tPly = FindPlayer(target) or ply
    if IsValid(tPly) then
        tPly:Kill()
    end
end

commands["respawn"] = function(ply, target)
    if not CheckPerm(ply, "command_respawn") then return end
    local tPly = FindPlayer(target) or ply
    if IsValid(tPly) then
        if isfunction(Homigrad_RespawnPlayer) then
            Homigrad_RespawnPlayer(tPly)
        else
            tPly:Spawn()
        end
    end
end

commands["hp"] = function(ply, target, amount)
    if not CheckPerm(ply, "command_hp") then return end
    local tPly = FindPlayer(target) or ply
    local hp = tonumber(amount) or 100
    if IsValid(tPly) then
        tPly:SetHealth(hp)
    end
end

commands["setmodel"] = function(ply, target, mdl)
    if not CheckPerm(ply, "command_setmodel") then return end
    local tPly = FindPlayer(target) or ply
    if IsValid(tPly) and mdl then
        tPly:SetModel(mdl)
    end
end

commands["give"] = function(ply, target, class)
    if not CheckPerm(ply, "command_give") then return end
    local tPly = FindPlayer(target) or ply
    if IsValid(tPly) and class then
        tPly:Give(class)
    end
end

commands["setmaterial"] = function(ply, target, mat)
    if not CheckPerm(ply, "command_setmaterial") then return end
    local tPly = FindPlayer(target) or ply
    if IsValid(tPly) then
        tPly:SetMaterial(mat or "")
    end
end

commands["setcolor"] = function(ply, target, r, g, b, a)
    if not CheckPerm(ply, "command_setcolor") then return end
    local tPly = FindPlayer(target) or ply
    if IsValid(tPly) then
        tPly:SetColor(Color(tonumber(r) or 255, tonumber(g) or 255, tonumber(b) or 255, tonumber(a) or 255))
    end
end

-- Moderation commands
commands["kick"] = function(ply, target, ...)
    if not CheckPerm(ply, "command_kick") then return end
    local tPly = FindPlayer(target)
    if not IsValid(tPly) then return end
    local reason = table.concat({...}, " ")
    if reason == "" then reason = "Kicked by administrator" end

    tPly:Kick(reason)
end

commands["ban"] = function(ply, target, time, ...)
    if not CheckPerm(ply, "command_ban") then return end
    local minutes = tonumber(time) or 0
    local reason = table.concat({...}, " ")
    if reason == "" then reason = "Banned by administrator" end
    local adminName = IsValid(ply) and ply:Nick() or "Console"

    local tPly = FindPlayer(target)
    if IsValid(tPly) then
        AdminPanel_BanPlayer(tPly, minutes, reason, adminName)
    elseif string.match(tostring(target), "^%d+$") then
        AdminPanel_BanPlayer(tostring(target), minutes, reason, adminName)
    end
end

commands["unban"] = function(ply, steamID64)
    if not CheckPerm(ply, "command_ban") then return end
    if punishData.bans[steamID64] then
        punishData.bans[steamID64] = nil
        SavePunishData()
        SyncPunish()
    end
end

commands["mute"] = function(ply, target, time, ...)
    if not CheckPerm(ply, "command_mute") then return end
    local tPly = FindPlayer(target)
    if not IsValid(tPly) then return end

    local minutes = tonumber(time) or 0
    local expire = minutes > 0 and (os.time() + (minutes * 60)) or 0
    local reason = table.concat({...}, " ")
    if reason == "" then reason = "Muted by administrator" end

    local sid64 = tPly:SteamID64()
    punishData.mutes[sid64] = {
        name = tPly:Nick(),
        steamid = tPly:SteamID(),
        steamid64 = sid64,
        reason = reason,
        admin = IsValid(ply) and ply:Nick() or "Console",
        expire = expire,
        date = os.time()
    }

    SavePunishData()
    SyncPunish()
    tPly:ChatPrint("[Admin] You have been muted in text chat.")
end

commands["unmute"] = function(ply, target)
    if not CheckPerm(ply, "command_mute") then return end
    local tPly = FindPlayer(target)
    local sid64 = IsValid(tPly) and tPly:SteamID64() or tostring(target)

    if punishData.mutes[sid64] then
        punishData.mutes[sid64] = nil
        SavePunishData()
        SyncPunish()
        if IsValid(tPly) then tPly:ChatPrint("[Admin] You have been unmuted.") end
    end
end

commands["gag"] = function(ply, target, time, ...)
    if not CheckPerm(ply, "command_gag") then return end
    local tPly = FindPlayer(target)
    if not IsValid(tPly) then return end

    local minutes = tonumber(time) or 0
    local expire = minutes > 0 and (os.time() + (minutes * 60)) or 0
    local reason = table.concat({...}, " ")
    if reason == "" then reason = "Gagged by administrator" end

    local sid64 = tPly:SteamID64()
    punishData.gags[sid64] = {
        name = tPly:Nick(),
        steamid = tPly:SteamID(),
        steamid64 = sid64,
        reason = reason,
        admin = IsValid(ply) and ply:Nick() or "Console",
        expire = expire,
        date = os.time()
    }

    SavePunishData()
    SyncPunish()
    tPly:ChatPrint("[Admin] You have been gagged in voice chat.")
end

commands["ungag"] = function(ply, target)
    if not CheckPerm(ply, "command_gag") then return end
    local tPly = FindPlayer(target)
    local sid64 = IsValid(tPly) and tPly:SteamID64() or tostring(target)

    if punishData.gags[sid64] then
        punishData.gags[sid64] = nil
        SavePunishData()
        SyncPunish()
        if IsValid(tPly) then tPly:ChatPrint("[Admin] You have been ungagged.") end
    end
end

-- Map change command
commands["map"] = function(ply, mapName)
    if not CheckPerm(ply, "map_change") then return end
    if not mapName or mapName == "" then return end

    PrintMessage(HUD_PRINTTALK, "[Admin] Changing map to " .. mapName .. " in 3 seconds...")
    timer.Simple(3, function()
        RunConsoleCommand("changelevel", mapName)
    end)
end

local function ExecuteAdminCommand(ply, cmdName, args)
    cmdName = string.lower(cmdName or "")
    if not istable(args) then args = {args} end

    -- Check if registered in role_local_sh.lua AdminPanel_ServerCommands
    if AdminPanel_ServerCommands and AdminPanel_ServerCommands[cmdName] then
        AdminPanel_ServerCommands[cmdName](ply, args)
        return
    end

    if commands[cmdName] then
        commands[cmdName](ply, unpack(args))
    end
end

-- Network receiver for adminpanel_command
net.Receive("adminpanel_command", function(len, ply)
    local cmdName = net.ReadString()
    local count = net.ReadUInt(8)
    local args = {}
    for i = 1, count do
        table.insert(args, net.ReadString())
    end

    ExecuteAdminCommand(ply, cmdName, args)
end)

-- ConCommand receiver for ulx_cmd
concommand.Add("ulx_cmd", function(ply, cmd, args)
    if #args == 0 then return end
    local cmdName = table.remove(args, 1)
    ExecuteAdminCommand(ply, cmdName, args)
end)
