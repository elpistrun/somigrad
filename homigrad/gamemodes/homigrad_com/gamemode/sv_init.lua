-- Server-only gamemode entry point.
--
-- GMod loads this only on the server. The shared setup (DeriveGamemode + GM overrides from
-- shit.lua) already happens in init.lua, so nothing extra is required here yet -- having the
-- file present keeps the gamemode layout complete and gives a place for server-only hooks.

function GM:DoPlayerDeath(ply, attacker, dmginfo)
	-- Homigrad handles corpses through its fake ragdoll system.
	-- Do NOT call ply:CreateRagdoll() here - doing so creates a duplicate 2nd corpse!
	ply.isDead = true
	ply:SetNWBool("isDead", true)
	ply:SetNWBool("Alive", false)
	ply:SetNWBool("FakeDeath", true)
	ply:AddDeaths(1)

	if IsValid(attacker) and attacker:IsPlayer() then
		if attacker == ply then
			attacker:AddFrags(-1)
		else
			attacker:AddFrags(1)
		end
	end
end

function GM:PlayerLoadout(ply)
	if not IsValid(ply) then return true end
	ply:StripWeapons()
	ply:RemoveAllAmmo()
	ply:Give("weapon_hands")
	return true
end

local sandboxWeapons = {
	["weapon_crowbar"] = true,
	["weapon_pistol"] = true,
	["weapon_smg1"] = true,
	["weapon_357"] = true,
	["weapon_ar2"] = true,
	["weapon_shotgun"] = true,
	["weapon_crossbow"] = true,
	["weapon_frag"] = true,
	["weapon_rpg"] = true,
	["weapon_physcannon"] = true,
	["weapon_physgun"] = true,
	["gmod_tool"] = true,
	["gmod_camera"] = true
}

hook.Add("PlayerLoadout","HomigradPreventSandboxLoadout",function(ply)
	if not IsValid(ply) then return true end
	ply:StripWeapons()
	ply:RemoveAllAmmo()
	ply:Give("weapon_hands")
	return true
end)

hook.Add("PlayerSpawn","HomigradPreventSandboxWeapons",function(ply)
	timer.Simple(0,function()
		if not IsValid(ply) or not ply:Alive() then return end
		for _,wep in ipairs(ply:GetWeapons()) do
			if IsValid(wep) and sandboxWeapons[wep:GetClass()] then
				wep:Remove()
			end
		end
		if not ply:HasWeapon("weapon_hands") then
			ply:Give("weapon_hands")
		end
		ply:SelectWeapon("weapon_hands")

		ply:SetWalkSpeed(DEFAULT_SPEED or 125)
		ply:SetRunSpeed(DEFAULT_RUNSPEED or 280)
		ply:SetSlowWalkSpeed(DEFAULT_SLOWWALK or 75)
		ply:SetLadderClimbSpeed(DEFAULT_LADDERSPEED or 75)
		ply:SetJumpPower(DEFAULT_JUMPPOWER or 190)
		ply:SetCrouchedWalkSpeed(0.6)
	end)
end)

local function IsPlayerDead(ply)
	if not IsValid(ply) then return true end
	if not ply:Alive() then return true end
	if ply.isDead or ply:GetNWBool("isDead", false) or ply:GetNWBool("FakeDeath", false) or ply:GetNWBool("Alive") == false then
		return true
	end
	return false
end

-- Живые не читают что пишут мертвые игроки
hook.Add("PlayerCanSeePlayersChat", "Homigrad_DeadPlayerChatBlock", function(text, teamOnly, listener, speaker)
	if not IsValid(speaker) or not IsValid(listener) then return end
	if IsPlayerDead(speaker) and not IsPlayerDead(listener) then
		return false
	end
end)

-- Живые не слышат что говорят мертвые игроки
hook.Add("PlayerCanHearPlayersVoice", "Homigrad_DeadPlayerVoiceBlock", function(listener, talker)
	if not IsValid(talker) or not IsValid(listener) then return end
	if IsPlayerDead(talker) and not IsPlayerDead(listener) then
		return false, false
	end
end)

local adminGroups = {
	["root"] = true,
	["superadmin"] = true,
	["dsuperadmin"] = true,
	["admin"] = true,
	["dadmin"] = true,
	["operator"] = true,
	["doperator"] = true,
	["owner"] = true,
	["founder"] = true,
	["headadmin"] = true,
	["moderator"] = true,
	["curator"] = true
}

local function HasSpawnPrivilege(ply)
	if not IsValid(ply) then return false end
	local grp = string.lower(ply:GetUserGroup() or ply:GetNWString("UserGroup", "") or "")
	if adminGroups[grp] or ply:IsAdmin() or ply:IsSuperAdmin() then return true end
	if roundActiveName == "level_construct" then return true end
	if ply.HasSuccess and ply:HasSuccess("spawnmenu_access") then return true end
	if AdminPanelRole_HasSuccess and AdminPanelRole_HasSuccess(ply, "spawnmenu_access") then return true end
	return false
end

hook.Add("PlayerSpawnProp", "Homigrad_PrivilegeSpawnProp", function(ply, model)
	if HasSpawnPrivilege(ply) then return true end
end)

hook.Add("PlayerSpawnSENT", "Homigrad_PrivilegeSpawnSENT", function(ply, class)
	if HasSpawnPrivilege(ply) then return true end
end)

hook.Add("PlayerSpawnSWEP", "Homigrad_PrivilegeSpawnSWEP", function(ply, class)
	if HasSpawnPrivilege(ply) then return true end
end)

hook.Add("PlayerGiveSWEP", "Homigrad_PrivilegeGiveSWEP", function(ply, class)
	if HasSpawnPrivilege(ply) then return true end
end)

hook.Add("PlayerSpawnVehicle", "Homigrad_PrivilegeSpawnVehicle", function(ply, model, name, tab)
	if HasSpawnPrivilege(ply) then return true end
end)

hook.Add("PlayerSpawnNPC", "Homigrad_PrivilegeSpawnNPC", function(ply, npc_type, weapon)
	if HasSpawnPrivilege(ply) then return true end
end)

hook.Add("PlayerSpawnRagdoll", "Homigrad_PrivilegeSpawnRagdoll", function(ply, model)
	if HasSpawnPrivilege(ply) then return true end
end)

hook.Add("PlayerSpawnEffect", "Homigrad_PrivilegeSpawnEffect", function(ply, model)
	if HasSpawnPrivilege(ply) then return true end
end)

hook.Add("CanTool", "Homigrad_PrivilegeCanTool", function(ply, tr, tool)
	if HasSpawnPrivilege(ply) then return true end
end)

hook.Add("CanProperty", "Homigrad_PrivilegeCanProperty", function(ply, prop, ent)
	if HasSpawnPrivilege(ply) then return true end
end)


