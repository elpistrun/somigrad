--[[
    Homigrad Points — Server
    Handles save/load (per-map JSON), concommands, net sync,
    and integration with the round system (spawn positions + loot points).
]]

if not SERVER then return end

include("hinit/homigrad_points/sh_points.lua")

-- ============================================================
-- State
-- ============================================================

local SAVE_DIR  = "homigrad/points"
local points    = {}   -- { id, type, pos, ang }
local nextID    = 1

-- ============================================================
-- Persistence
-- ============================================================

local function SavePath()
    return SAVE_DIR .. "/" .. game.GetMap() .. ".json"
end

local function LoadPoints()
    if not file.IsDir(SAVE_DIR, "DATA") then
        file.CreateDir(SAVE_DIR)
    end

    local path = SavePath()
    if not file.Exists(path, "DATA") then
        points = {}
        nextID = 1
        return
    end

    local raw = file.Read(path, "DATA")
    if not raw or raw == "" then
        points = {}
        nextID = 1
        return
    end

    local decoded = util.JSONToTable(raw)
    if not decoded then
        points = {}
        nextID = 1
        print("[HGPoints] Failed to decode points JSON for map: " .. game.GetMap())
        return
    end

    points = {}
    nextID = 1
    for _, entry in ipairs(decoded) do
        local p = {
            id  = entry.id  or nextID,
            type = entry.type or HGPOINTS.PLAYER,
            pos = Vector(entry.pos[1], entry.pos[2], entry.pos[3]),
            ang = Angle(entry.ang[1], entry.ang[2], entry.ang[3]),
        }
        points[#points + 1] = p
        if p.id >= nextID then
            nextID = p.id + 1
        end
    end

    print("[HGPoints] Loaded " .. #points .. " points for map: " .. game.GetMap())
end

local function SavePoints()
    if not file.IsDir(SAVE_DIR, "DATA") then
        file.CreateDir(SAVE_DIR)
    end

    local serialisable = {}
    for _, p in ipairs(points) do
        serialisable[#serialisable + 1] = {
            id   = p.id,
            type = p.type,
            pos  = { p.pos.x, p.pos.y, p.pos.z },
            ang  = { p.ang.p, p.ang.y, p.ang.r },
        }
    end

    file.Write(SavePath(), util.TableToJSON(serialisable, true))
end

-- ============================================================
-- Sync
-- ============================================================

local function SyncPoints(target)
    -- Pack points as a flat table — net.WriteTable handles it fine
    local tbl = {}
    for _, p in ipairs(points) do
        tbl[#tbl + 1] = {
            id   = p.id,
            type = p.type,
            pos  = { p.pos.x, p.pos.y, p.pos.z },
            ang  = { p.ang.p, p.ang.y, p.ang.r },
        }
    end

    net.Start("hg_points_sync")
    net.WriteTable(tbl)
    if target then
        net.Send(target)
    else
        net.Broadcast()
    end
end

-- ============================================================
-- Add / Remove
-- ============================================================

local function AddPoint(pointType, pos, ang, extra)
    local p = {
        id   = nextID,
        type = pointType,
        pos  = pos,
        ang  = ang,
        extra = extra or {},
    }
    nextID = nextID + 1
    points[#points + 1] = p
    SavePoints()
    SyncPoints()
    return p
end

local function RemoveNearestPoint(pos, pointType, radius)
    radius = radius or 128
    local best, bestDist, bestIdx = nil, math.huge, -1

    for i, p in ipairs(points) do
        if not pointType or p.type == pointType then
            local d = pos:DistToSqr(p.pos)
            if d < bestDist then
                bestDist = d
                best = p
                bestIdx = i
            end
        end
    end

    if best and bestDist <= (radius * radius) then
        table.remove(points, bestIdx)
        SavePoints()
        SyncPoints()
        return true, best
    end
    return false, nil
end

local function ClearPoints(pointType)
    if pointType then
        for i = #points, 1, -1 do
            if points[i].type == pointType then
                table.remove(points, i)
            end
        end
    else
        points = {}
    end
    SavePoints()
    SyncPoints()
end

-- ============================================================
-- Net receivers (from tool client-side)
-- ============================================================

local function CanUsePoints(ply)
    if not IsValid(ply) then return false end
    if ply:IsAdmin() or ply:IsSuperAdmin() then return true end
    -- Support homigrad admin panel permission if available
    if AdminPanelRole_HasSuccess and AdminPanelRole_HasSuccess(ply, "admin") then return true end
    return false
end

net.Receive("hg_points_add", function(len, ply)
    if not CanUsePoints(ply) then return end

    local pointType = net.ReadUInt(2)   -- 2 bits: 1 or 2
    local pos       = net.ReadVector()
    local ang       = net.ReadAngle()

    if pointType ~= HGPOINTS.PLAYER and pointType ~= HGPOINTS.LOOT then return end

    AddPoint(pointType, pos, ang)
    print("[HGPoints] " .. ply:Nick() .. " added " .. (pointType == HGPOINTS.PLAYER and "PLAYER" or "LOOT") .. " point at " .. tostring(pos))
end)

net.Receive("hg_points_remove", function(len, ply)
    if not CanUsePoints(ply) then return end

    local pointType = net.ReadUInt(2)
    local pos       = net.ReadVector()

    if pointType ~= HGPOINTS.PLAYER and pointType ~= HGPOINTS.LOOT then return end

    local ok, removed = RemoveNearestPoint(pos, pointType, 256)
    if ok then
        print("[HGPoints] " .. ply:Nick() .. " removed a " .. (pointType == HGPOINTS.PLAYER and "PLAYER" or "LOOT") .. " point")
    end
end)

net.Receive("hg_points_clear", function(len, ply)
    if not CanUsePoints(ply) then return end

    local pointType = net.ReadUInt(2)
    -- 0 means "all"
    if pointType == 0 then
        ClearPoints()
        print("[HGPoints] " .. ply:Nick() .. " cleared ALL points")
    else
        ClearPoints(pointType)
        print("[HGPoints] " .. ply:Nick() .. " cleared " .. (pointType == HGPOINTS.PLAYER and "PLAYER" or "LOOT") .. " points")
    end
end)

-- ============================================================
-- Sync on player join
-- ============================================================

hook.Add("PlayerInitialSpawn", "HGPoints_SyncOnJoin", function(ply)
    timer.Simple(2, function()
        if IsValid(ply) then
            SyncPoints(ply)
        end
    end)
end)

-- ============================================================
-- Load on map start
-- ============================================================

hook.Add("InitPostEntity", "HGPoints_LoadOnMapStart", function()
    LoadPoints()
end)

-- ============================================================
-- PlayerSpawnPoint — use saved player points if any exist
-- ============================================================

hook.Add("PlayerSpawnPoint", "HGPoints_SpawnPosition", function(ply)
    local playerPts = {}
    for _, p in ipairs(points) do
        if p.type == HGPOINTS.PLAYER then
            playerPts[#playerPts + 1] = p
        end
    end

    if #playerPts == 0 then return end  -- fall through to default

    local chosen = playerPts[math.random(1, #playerPts)]
    return chosen.pos, chosen.ang
end)

-- ============================================================
-- Loot spawn integration — expose list for round system use
-- ============================================================

function HGPoints_GetLootPositions()
    local result = {}
    for _, p in ipairs(points) do
        if p.type == HGPOINTS.LOOT then
            result[#result + 1] = p.pos
        end
    end
    return result
end

-- Patch Homigrad_SpawnLootBoxes to prefer saved loot points
-- (runs AFTER roundsystem_sv.lua defines it, so wrap safely)
hook.Add("InitPostEntity", "HGPoints_PatchLootSpawn", function()
    local origSpawnLoot = Homigrad_SpawnLootBoxes

    Homigrad_SpawnLootBoxes = function()
        local lootPts = HGPoints_GetLootPositions()
        if #lootPts == 0 then
            -- No saved loot points — fall through to original random logic
            if origSpawnLoot then origSpawnLoot() end
            return
        end

        -- Clean existing lootboxes
        for _, ent in ipairs(ents.FindByClass("ent_lootbox*")) do
            if IsValid(ent) then ent:Remove() end
        end

        local lootBoxPool = {
            {"ent_lootbox_low",        45},
            {"ent_lootbox_small",       35},
            {"ent_lootbox_medium",      10},
            {"ent_lootbox_medical",      5},
            {"ent_lootbox_small_ammo",   5},
        }

        local function PickBox()
            local total = 0
            for _, item in ipairs(lootBoxPool) do total = total + item[2] end
            local roll, cur = math.random(1, total), 0
            for _, item in ipairs(lootBoxPool) do
                cur = cur + item[2]
                if roll <= cur then return item[1] end
            end
            return "ent_lootbox_low"
        end

        table.Shuffle(lootPts)
        local targetCount = math.min(#lootPts, math.random(8, 14))
        local spawned = 0

        for i = 1, targetCount do
            local pos = lootPts[i]
            local tr = util.TraceLine({
                start  = pos + Vector(0, 0, 50),
                endpos = pos - Vector(0, 0, 200),
                mask   = MASK_SOLID_BRUSHONLY,
            })
            local spawnPos = tr.Hit and (tr.HitPos + tr.HitNormal * 4) or (pos + Vector(0, 0, 4))

            local box = ents.Create(PickBox())
            if IsValid(box) then
                box:SetPos(spawnPos)
                box:SetAngles(Angle(0, math.random(0, 360), 0))
                box:Spawn()
                box:Activate()
                local phys = box:GetPhysicsObject()
                if IsValid(phys) then phys:Wake(); phys:EnableMotion(true) end
                spawned = spawned + 1
            end
        end

        print("[HGPoints] Spawned " .. spawned .. " loot boxes from saved loot points")
    end
end)

-- ============================================================
-- Concommands (server-side admin utility)
-- ============================================================

concommand.Add("hg_points_list", function(ply)
    if IsValid(ply) and not CanUsePoints(ply) then return end
    for _, p in ipairs(points) do
        local typeName = p.type == HGPOINTS.PLAYER and "PLAYER" or "LOOT"
        print(string.format("[HGPoints] #%d %s @ %s", p.id, typeName, tostring(p.pos)))
    end
    print("[HGPoints] Total: " .. #points)
end)

concommand.Add("hg_points_reload", function(ply)
    if IsValid(ply) and not CanUsePoints(ply) then return end
    LoadPoints()
    SyncPoints()
    print("[HGPoints] Reloaded points from disk and synced")
end)
