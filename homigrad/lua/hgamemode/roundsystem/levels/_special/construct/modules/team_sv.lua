local Level = oop.Get("level_construct")
if not Level then return end

util.AddNetworkString("Construct team")

Construct_Teams = Construct_Teams or {}
local Teams = Construct_Teams

local function SyncTeams(ply)
    net.Start("Construct team")
    net.WriteTable(Teams)
    if IsValid(ply) then
        net.Send(ply)
    else
        net.Broadcast()
    end
end

local function FindTeamByPlayer(steamID)
    for ownerID, team in pairs(Teams) do
        if team.members and team.members[steamID] then
            return team, ownerID
        end
    end
end

concommand.Add("hg_construct_team_request", function(ply, cmd, args)
    if not IsValid(ply) or not ply:Alive() then return end
    local targetUserID = tonumber(args[1])
    if not targetUserID then return end

    local target = Player(targetUserID)
    if not IsValid(target) or not target:IsPlayer() or not target:Alive() or target == ply then return end

    local pSteam = ply:SteamID()
    local tSteam = target:SteamID()

    -- Check if target is already in a team
    if FindTeamByPlayer(tSteam) then return end

    local team = FindTeamByPlayer(pSteam)
    if not team then
        team = {
            ownerID = pSteam,
            members = {
                [pSteam] = ply:Nick()
            },
            wait = {}
        }
        Teams[pSteam] = team
    end

    team.wait[tSteam] = pSteam
    SyncTeams()
end)

concommand.Add("hg_construct_team_join", function(ply, cmd, args)
    if not IsValid(ply) then return end
    local callerID = args[1]
    if not callerID then return end

    local pSteam = ply:SteamID()

    for ownerID, team in pairs(Teams) do
        if team.wait and team.wait[pSteam] == callerID then
            team.wait[pSteam] = nil
            team.members[pSteam] = ply:Nick()
            SyncTeams()
            break
        end
    end
end)

concommand.Add("hg_construct_team_cancel", function(ply, cmd, args)
    if not IsValid(ply) then return end
    local callerID = args[1]
    local pSteam = ply:SteamID()

    for ownerID, team in pairs(Teams) do
        if team.wait and team.wait[pSteam] == callerID then
            team.wait[pSteam] = nil
            SyncTeams()
            break
        end
    end
end)

concommand.Add("hg_construct_team_kick", function(ply, cmd, args)
    if not IsValid(ply) then return end
    local targetSteamID = args[1]
    if not targetSteamID then return end

    local pSteam = ply:SteamID()
    local team, ownerID = FindTeamByPlayer(pSteam)
    if not team then return end

    if team.ownerID == pSteam or pSteam == targetSteamID then
        team.members[targetSteamID] = nil
        if table.Count(team.members) == 0 then
            Teams[ownerID] = nil
        elseif team.ownerID == targetSteamID then
            -- Assign next available member as owner
            local nextOwner = next(team.members)
            team.ownerID = nextOwner
        end
        SyncTeams()
    end
end)

hook.Add("PlayerInitialSpawn", "Construct_Team_InitialSync", function(ply)
    timer.Simple(1, function()
        if IsValid(ply) then
            SyncTeams(ply)
        end
    end)
end)

hook.Add("PlayerDisconnected", "Construct_Team_Disconnect", function(ply)
    local pSteam = ply:SteamID()
    local team, ownerID = FindTeamByPlayer(pSteam)
    if team then
        team.members[pSteam] = nil
        if table.Count(team.members) == 0 then
            Teams[ownerID] = nil
        elseif team.ownerID == pSteam then
            local nextOwner = next(team.members)
            team.ownerID = nextOwner
        end
        SyncTeams()
    end
end)
