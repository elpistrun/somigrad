-- File: d:/server/garrysmod/addons/homigrad/lua/autorun/homigrad_utilities.lua
-- Homigrad utilities for managing player and loot points.
-- Stores points in a persistent table and saves/loads from a JSON file.

if SERVER then
    local dataFile = "homigrad_points.json"
    HomigradPoints = HomigradPoints or { points = {} }

    -- Load points from file on server start
    local function LoadPoints()
        if not file.Exists(dataFile, "DATA") then return end
        local json = file.Read(dataFile, "DATA")
        local tbl = util.JSONToTable(json)
        if tbl and tbl.points then
            HomigradPoints.points = tbl.points
            print("[Homigrad] Loaded " .. #tbl.points .. " points from " .. dataFile)
        end
    end

    -- Save current points to file
    local function SavePoints()
        local json = util.TableToJSON({ points = HomigradPoints.points })
        file.Write(dataFile, json)
        print("[Homigrad] Saved " .. #HomigradPoints.points .. " points to " .. dataFile)
    end

    -- Add a new point (pos, ang, extra table)
    function HomigradAddPoint(ply, pos, ang, extra)
        if not IsValid(ply) or not ply:IsAdmin() then return false end
        extra = extra or {}
        local pt = {
            id   = #HomigradPoints.points + 1,
            pos  = pos,
            ang  = ang,
            extra = extra,
        }
        table.insert(HomigradPoints.points, pt)
        SavePoints()
        hook.Run("HomigradPointAdded", pt)
        return true
    end

    -- Remove the point nearest to a given position (within 100 units)
    function HomigradRemovePoint(ply, pos)
        if not IsValid(ply) or not ply:IsAdmin() then return false end
        local nearestIdx, nearestDist = nil, 100
        for i, pt in ipairs(HomigradPoints.points) do
            local d = pt.pos:Distance(pos)
            if d < nearestDist then
                nearestDist = d
                nearestIdx = i
            end
        end
        if nearestIdx then
            local removed = table.remove(HomigradPoints.points, nearestIdx)
            SavePoints()
            hook.Run("HomigradPointRemoved", removed)
            return true
        end
        return false
    end

    -- Retrieve all points (optionally filter by type/subtype)
    function HomigradGetPoints(filter)
        if not filter then return HomigradPoints.points end
        local out = {}
        for _, pt in ipairs(HomigradPoints.points) do
            local ok = true
            if filter.point_type and pt.extra.point_type ~= filter.point_type then ok = false end
            if filter.subtype and pt.extra.subtype ~= filter.subtype then ok = false end
            if ok then table.insert(out, pt) end
        end
        return out
    end

    -- Hook the net messages to use the above utilities
    util.AddNetworkString("hg_points_add")
    util.AddNetworkString("hg_points_remove")

    net.Receive("hg_points_add", function(_, ply)
        if not ply:IsAdmin() then return end
        local pos = net.ReadVector()
        local ang = net.ReadAngle()
        local extra = util.JSONToTable(net.ReadString()) or {}
        HomigradAddPoint(ply, pos, ang, extra)
    end)

    net.Receive("hg_points_remove", function(_, ply)
        if not ply:IsAdmin() then return end
        local pos = net.ReadVector()
        HomigradRemovePoint(ply, pos)
    end)

    -- Load points when the script is first executed
    LoadPoints()
end
