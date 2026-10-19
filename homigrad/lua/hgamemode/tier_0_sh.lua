--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/tier_0_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
DEFAULT_SPEED = 125
DEFAULT_RUNSPEED = 280
DEFAULT_SLOWWALK = 75
DEFAULT_LADDERSPEED = 75
DEFAULT_JUMPPOWER = 190

function CreateTeams()
	team.SetUp(1,"Terrorists",Color(255,0,0))
	team.SetUp(2,"Counter Terrorists",Color(0,0,255))
	team.SetUp(3,"Other",Color(0,255,0))

	team.MaxTeams = 3
end

function OpposingTeam(team)
	if team == 1 then return 2 elseif team == 2 then return 1 end
end

function ReadPoint(point)
	if TypeID(point) == TYPE_VECTOR then
		return {point,Angle(0,0,0)}
	elseif type(point) == "table" then
		if type(point[2]) == "number" then
			point[3] = point[2]
			point[2] = Angle(0,0,0)
		end

		return point
	end
end

-- Игрок считается участником раунда, пока он не ушёл в спектаторы.
-- Раньше тут перебирались только команды 1..3, но команду при заходе никто
-- не выставляет (по умолчанию она нулевая) — из-за этого список всегда был
-- пустым, раунд не стартовал и SetupFMTeams никого не спавнил.
function PlayerInGame(ply)
    if not IsValid(ply) then return false end
    if not ply:IsPlayer() then return false end
    if ply:Team() == TEAM_SPECTATOR then return false end

    return true
end

function PlayersInGame()
    local newTbl = {}

    for i,ply in ipairs(player.GetAll()) do
        if not PlayerInGame(ply) then continue end

        newTbl[#newTbl + 1] = ply
    end

    return newTbl
end

local white = Color(255,255,255)

function GetTeamColor(ply)
	local name,color = ply:GetTeamStatus()

	return color or white
end
