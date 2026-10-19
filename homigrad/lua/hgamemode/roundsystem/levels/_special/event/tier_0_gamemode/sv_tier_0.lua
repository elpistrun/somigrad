if not SERVER then return end

--[[
    Level Event Server Logic
    Controls round lifecycle, player spawns, loadouts, permissions,
    and prevents round from prematurely ending on death.
]]

local Level = oop.Get("level_event")
if not Level then return end

Level.RoundTime = 7200 -- 2 hours default
Level.DisableGib = true
Level.DisableWH = true
Level.DisableCenter = true

function Level:CanUseContextMenu(ply) return Event_CanAccess(ply, EventCanHelpHiredAdmins) or ply:IsAdmin() end
function Level:CanUseSpawnMenu(ply) return Event_CanAccess(ply, EventCanHelpHiredAdmins) or ply:IsAdmin() end

function Level:Start()
    print("[Homigrad] Event round started!")
    if Homigrad_ResetLighting then
        Homigrad_ResetLighting()
    end
end

function Level:CheckEnd()
    -- Event rounds do not end when players die
    return false
end

function Level:PlayerSpawn(ply)
    local group = ply.eventGroup
    if group then
        if group.health then
            ply:SetMaxHealth(group.health)
            ply:SetHealth(group.health)
        end

        if group.models and table.Count(group.models) > 0 then
            local mdlList = table.GetKeys(group.models)
            local mdlName = mdlList[math.random(1, #mdlList)]
            if mdlName and mdlName ~= "" then
                ply:SetModel(mdlName)
                local mdlInfo = group.models[mdlName]
                if mdlInfo and mdlInfo.bodygroups then
                    for bgID, val in pairs(mdlInfo.bodygroups) do
                        if istable(val) then
                            ply:SetBodygroup(bgID, math.random(val[1] or 0, val[2] or 0))
                        elseif isnumber(val) then
                            ply:SetBodygroup(bgID, val)
                        end
                    end
                end
            end
        end

        if group.color then
            ply:SetPlayerColor(Vector(group.color.r / 255, group.color.g / 255, group.color.b / 255))
        end
    end

    if Event_CanAccess(ply, EventCanHelpHiredAdmins) or ply:IsAdmin() then
        ply:Give("weapon_physgun")
        ply:Give("gmod_tool")
    end
end

function Level:PlayerDeath(ply)
    ply:SetNWFloat("DeadStart", CurTime())
    ply:SetNWFloat("DeathStart", CurTime())
    local grp = ply.eventGroup
    local delay = (grp and grp.spawnTime) or 5
    ply:SetNWFloat("DeathWait", CurTime() + delay)
end
