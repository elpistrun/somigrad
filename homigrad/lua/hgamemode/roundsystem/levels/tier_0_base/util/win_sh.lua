--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/levels/tier_0_base/util/win_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hgamemode/roundsystem/levels/tier_0_base/tier_0_sh.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

local Level = oop.Get("level_base")
if not Level then return end

Level.WinnerSound = "homigrad/vgui/panorama/case_awarded_4_legendary_01.wav"

-- Сколько секунд после старта не проверять конец раунда: игроки в этот момент
-- ещё респавнятся, иначе раунд закрывается сам на первом же тике.
Level.EndCheckDelay = 1

-- Общий для обоих реалмов: уровни зовут его из _sh-файлов.
function Level:SetEndType(value)
    self.EndType = value

    if SERVER then return end

    self.End = function(self)
        self:StartWinnerVGUI(roundDataEnd and roundDataEnd.winnerVGUI)
    end
end

if CLIENT then return end

local gray = Color(160,160,160)

function Level:GetTeamTable(teamID)
    local key = self.teamEncoder and self.teamEncoder[teamID]

    return key and self[key]
end

function Level:AlivePlayers()
    local alive = {}

    for i,ply in ipairs(PlayersInGame()) do
        local isAlive = ply:Alive() and not ply.isDead and not ply:GetNWBool("isDead") and not ply:GetNWBool("FakeDeath") and ply:Health() > 0
        if not isAlive then continue end

        alive[#alive + 1] = ply
    end

    return alive
end

function Level:GetLevelTeams()
    local teams = {}
    if istable(self.teamEncoder) then
        for id in pairs(self.teamEncoder) do
            if isnumber(id) then
                teams[#teams + 1] = id
            end
        end
        table.sort(teams)
    elseif istable(self.Teams) then
        for _, id in ipairs(self.Teams) do
            teams[#teams + 1] = id
        end
    end
    return teams
end

-- Возвращает список команд, в которых ещё остались живые.
function Level:AliveTeams()
    local teams = (self.GetLevelTeams and self:GetLevelTeams()) or {}
    if #teams == 0 and istable(self.teamEncoder) then
        for id in pairs(self.teamEncoder) do
            if isnumber(id) then teams[#teams + 1] = id end
        end
        table.sort(teams)
    end

    local counts = {}

    for i,ply in ipairs(self:AlivePlayers()) do
        local id = ply:Team()
        counts[id] = (counts[id] or 0) + 1
    end

    local result = {}

    for i = 1,#teams do
        if (counts[teams[i]] or 0) > 0 then result[#result + 1] = teams[i] end
    end

    return result,teams
end

function Level:CheckEnd()
    -- Уровень не объявил тип победы (homicide, construct и т.п.) — раунд ведёт
    -- только таймер, иначе мы бы закрыли его на первом же трупе.
    if not self.EndType then return end
    if CurTime() - roundTimeStart < (self.EndCheckDelay or 1) then return end
    if GetGlobalVar("God Time", 0) > CurTime() then return end

    if self.EndType == "player" then
        local alive = self:AlivePlayers()
        if #alive > 1 then return end

        return EndRound(alive[1] or "nobody")
    end

    local aliveTeams,teams = self:AliveTeams()

    -- В одну команду победу присуждать не по чему.
    if #teams < 2 then return end
    if #aliveTeams > 1 then return end

    EndRound(aliveTeams[1] or "nobody")
end

-- Данные для верхней плашки победителя (winner_cl.lua:StartWinnerVGUI).
function Level:EndData(winner)
    local data = {}

    if isnumber(winner) then
        local team = self:GetTeamTable(winner)

        data.winnerTeam = winner
        data.winnerVGUI = {
            color = (team and team[2]) or gray,
            name = "round_winner",
            text = (team and team[1]) or "unknown",
            sound = self.WinnerSound
        }
    elseif IsValid(winner) and winner:IsPlayer() then
        local team = self:GetTeamTable(winner:Team())

        data.winnerNick = winner:Nick()
        data.winnerSteamID = winner:SteamID()
        data.winnerSteamID64 = winner:SteamID64()
        data.winnerVGUI = {
            color = (team and team[2]) or gray,
            name = "round_winner",
            text = winner:Nick(),
            ply = winner,
            steamid = winner:SteamID(),
            steamid64 = winner:SteamID64(),
            avatar = (winner:GetNWString("Avatar", "") ~= "" and winner:GetNWString("Avatar")) or winner:SteamID64(),
            avatarFrame = winner:GetNWString("AvatarFrame"),
            playerNick = winner:Nick(),
            sound = self.WinnerSound
        }
    else
        data.winnerVGUI = {
            color = gray,
            name = "round_end",
            text = "nobody_win",
            sound = self.WinnerSound
        }
    end

    return data
end

