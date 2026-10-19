--[[
    Homigrad Points — Client
    Receives point list from server, draws 3D world markers.
]]

if not CLIENT then return end

include("hinit/homigrad_points/sh_points.lua")

-- ============================================================
-- Local state
-- ============================================================

local clientPoints = {}  -- mirror of server list

-- ============================================================
-- Net: receive full point list from server
-- ============================================================

net.Receive("hg_points_sync", function()
    local tbl = net.ReadTable()
    clientPoints = {}
    for _, entry in ipairs(tbl) do
        clientPoints[#clientPoints + 1] = {
            id   = entry.id,
            type = entry.type,
            pos  = Vector(entry.pos[1], entry.pos[2], entry.pos[3]),
            ang  = Angle(entry.ang[1], entry.ang[2], entry.ang[3]),
        }
    end
end)

-- ============================================================
-- Accessor used by homigrad_points tool (cl side)
-- ============================================================

function HGPoints_GetClientPoints()
    return clientPoints
end

-- ============================================================
-- Draw markers in world
-- ============================================================

local MAT_BEAM = Material("sprites/laserbeam")

local function DrawMarker(p)
    local col = (p.type == HGPOINTS.PLAYER) and HGPOINTS.COLOR_PLAYER or HGPOINTS.COLOR_LOOT
    local label = (p.type == HGPOINTS.PLAYER) and "PLAYER" or "LOOT"
    local base  = p.pos
    local top   = base + Vector(0, 0, 72)

    -- Vertical beam pillar
    render.SetMaterial(MAT_BEAM)
    render.DrawBeam(base, top, 6,
        0, 1,
        Color(col.r, col.g, col.b, 160))

    -- Circle at base
    local ringSegs = 16
    local ringRadius = 24
    local prevX = base.x + ringRadius
    local prevY = base.y
    local prevZ = base.z + 2
    render.SetColorMaterial()
    for i = 1, ringSegs do
        local angle = (i / ringSegs) * math.pi * 2
        local nx = base.x + math.cos(angle) * ringRadius
        local ny = base.y + math.sin(angle) * ringRadius
        local nz = base.z + 2
        render.DrawLine(Vector(prevX, prevY, prevZ), Vector(nx, ny, nz), col, true)
        prevX, prevY, prevZ = nx, ny, nz
    end

    -- 3D2D label above pillar
    local distSqr = (EyePos() - top):LengthSqr()
    if distSqr > (3000 * 3000) then return end  -- cull beyond 3000 units

    local scale = math.Clamp(math.sqrt(distSqr) / 600, 0.15, 0.55)
    local ang   = Angle(0, (EyePos() - top):Angle().y + 180, 0)

    cam.Start3D2D(top + Vector(0, 0, 8), ang, scale)
        draw.SimpleTextOutlined(label, "DermaLarge",
            0, 0,
            col,
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
            1, Color(0, 0, 0, 220))
        draw.SimpleTextOutlined("#" .. p.id, "DermaDefault",
            0, 24,
            Color(255, 255, 255, 200),
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
            1, Color(0, 0, 0, 200))
    cam.End3D2D()
end

hook.Add("PostDrawOpaqueRenderables", "HGPoints_DrawMarkers", function(isDrawingDepth, isDrawSkybox)
    if isDrawSkybox then return end
    if #clientPoints == 0 then return end

    -- Only draw when the toolgun is active OR an admin is nearby
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local wep = ply:GetActiveWeapon()
    local toolActive = IsValid(wep) and wep:GetClass() == "gmod_tool"
    if not toolActive then
        -- Also draw if any admin is viewing — hidden during normal gameplay
        return
    end

    for _, p in ipairs(clientPoints) do
        DrawMarker(p)
    end
end)
