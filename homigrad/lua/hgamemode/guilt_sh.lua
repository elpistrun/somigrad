-- Homigrad Guilt System
-- Tracks RDM / team-killing and automatically bans offender for 1 hour.

AdminPanelSuccessReg("noguilt", nil, "rights")

if SERVER then
    local GUILT_BAN_MSG = "[ SOMIGRAD.SU  -  GUILT ]\n\nYou Has been banned with rdming\n\n1h"

    local immuneGroups = {
        ["root"] = true,
        ["owner"] = true,
        ["founder"] = true,
        ["superadmin"] = true,
        ["admin"] = true,
        ["dadmin"] = true,
        ["headadmin"] = true,
        ["curator"] = true
    }

    local function IsGuiltImmune(ply)
        if not IsValid(ply) then return true end
        if ply:IsBot() then return true end
        if immuneGroups[string.lower(ply:GetUserGroup() or "")] then return true end
        if ply:IsSuperAdmin() or ply:IsAdmin() then return true end
        if ply.HasSuccess and ply:HasSuccess("noguilt") then return true end
        if isfunction(AdminPanelRole_HasSuccess) and AdminPanelRole_HasSuccess(ply, "noguilt") then return true end
        return false
    end

    function GuiltCheck(ply)
        if not IsValid(ply) then return end
        if IsGuiltImmune(ply) then
            ply.Guilt = 0
            return
        end

        local guilt = ply.Guilt or 0
        if guilt >= 100 then
            local nick = ply:Nick()
            PrintMessage(HUD_PRINTTALK, "[GUILT] " .. nick .. " получил бан на 1 час за RDM.")

            if isfunction(AdminPanel_BanPlayer) then
                AdminPanel_BanPlayer(ply, 60, "rdming", "Guilt System", GUILT_BAN_MSG)
            else
                if ULib and isfunction(ULib.ban) then
                    pcall(ULib.ban, ply, 60, "rdming")
                end
                ply:Kick(GUILT_BAN_MSG)
            end
        end
    end

    -- Decay guilt each round
    hook.Add("Homigrad_RoundStart", "hg_guilt_roundstart", function()
        for _, ply in ipairs(player.GetAll()) do
            if ply.Guilt and ply.Guilt > 0 then
                ply.Guilt = math.max(0, ply.Guilt - 25)
            end
        end
    end)

    -- Check if damage / kill is friendly fire or innocent RDM
    local function CheckRDM(attacker, victim)
        if not IsValid(attacker) or not IsValid(victim) then return false end
        if attacker == victim then return false end
        if not attacker:IsPlayer() or not victim:IsPlayer() then return false end
        if IsGuiltImmune(attacker) then return false end

        local lvlName = (Level and Level.name) or ""
        local isHomicide = (lvlName == "homicide") or (roundActiveName and string.find(string.lower(roundActiveName), "homicide"))

        if isHomicide then
            if not attacker.roleT and not victim.roleT then
                return true
            elseif attacker.roleT and victim.roleT then
                return true
            end
            return false
        end

        -- Team based modes (TDM, Riot, etc.)
        if lvlName == "dm" or lvlName == "hl2dm" then
            return false -- FFA
        end

        local aTeam = attacker:Team()
        local vTeam = victim:Team()
        if aTeam ~= 0 and aTeam == vTeam and aTeam ~= TEAM_UNASSIGNED and aTeam ~= TEAM_SPECTATOR then
            return true
        end

        return false
    end

    local function ResolvePlayer(ent)
        if not IsValid(ent) then return nil end
        if ent:IsPlayer() then return ent end
        if ent.GetPlayer and IsValid(ent:GetPlayer()) then return ent:GetPlayer() end
        if IsValid(ent.player) then return ent.player end
        return nil
    end

    hook.Add("EntityTakeDamage", "hg_guilt_damage", function(target, dmginfo)
        local victim = ResolvePlayer(target)
        local attacker = ResolvePlayer(dmginfo:GetAttacker())

        if not victim or not attacker then return end
        if CheckRDM(attacker, victim) then
            local dmg = dmginfo:GetDamage()
            local addedGuilt = math.Clamp(math.Round(dmg * 0.35), 5, 30)
            attacker.Guilt = (attacker.Guilt or 0) + addedGuilt
            GuiltCheck(attacker)
        end
    end)

    hook.Add("PlayerDeath", "hg_guilt_death", function(victim, inflictor, attacker)
        victim = ResolvePlayer(victim)
        attacker = ResolvePlayer(attacker)

        if not victim or not attacker then return end
        if CheckRDM(attacker, victim) then
            attacker.Guilt = (attacker.Guilt or 0) + 60
            GuiltCheck(attacker)
        end
    end)
end
