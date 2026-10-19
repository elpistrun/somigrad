--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/gamemodes/homigradcom/gamemode/shit.lua <
    > Callstack: addons/homigrad/gamemodes/homigradcom/gamemode/shared.lua:11
[C]:-1
addons/homigrad/gamemodes/homigradcom/gamemode/cl_init.lua:3 <
]]

-- "addons\\homigrad\\gamemodes\\homigradcom\\gamemode\\shit.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
AddCSLuaFile()

function GM:PlayerSpawn(ply) end
function GM:PlayerLoadout(ply)
	if not IsValid(ply) then return true end
	ply:StripWeapons()
	ply:RemoveAllAmmo()
	ply:Give("weapon_hands")
	return true
end
function GM:IsSpawnpointSuitable() end

function GM:PlayerInitialSpawn(ply) end

function GM:PlayerDeath() end
function GM:PlayerDeathThink() end

function GM:CreateTeams() CreateTeams() end

function GM:PlayerChangedTeam(ply,old,new) end
function GM:PlayerCanJoinTeam(ply,team) return hook.Run("PlayerCanJoinTeam",ply,team) end
function GM:OnPlayerChangedTeam(ply,newproxy) end--OnPlayerChangedTeam(ply,new) end

function GM:PlayerCanSeePlayersChat() end
function GM:PlayerCanHearPlayersVoice() end

function GM:PlayerStartVoice() end
function GM:PlayerEndVoice() end

function GM:ShowTeam(ply) ply:ConCommand("hg_showteam") end

function GM:MouthMoveAnimation() end
function GM:GetTeamColor(ply) return GetTeamColor(ply) end

GM.SecondsBetweenTeamSwitches = 1
