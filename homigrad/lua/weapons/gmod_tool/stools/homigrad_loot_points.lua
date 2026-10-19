-- File: d:/server/garrysmod/addons/homigrad/lua/weapons/gmod_tool/stools/homigrad_loot_points.lua
-- Homigrad Loot Point creation tool – creates loot spawn points with subtype selection.

TOOL.Category   = "Homigrad"
TOOL.Name       = "Homigrad - Loot Point"
TOOL.Command    = nil
TOOL.ConfigName = ""

if CLIENT then
    local subType = "medium"

    local function sendPoint(pos, ang)
        local extra = {
            point_type = "loot",
            subtype    = subType,
        }
        net.Start("hg_points_add")
            net.WriteVector(pos)
            net.WriteAngle(ang)
            net.WriteString(util.TableToJSON(extra))
        net.SendToServer()
    end

    function TOOL:LeftClick(trace)
        if not IsFirstTimePredicted() then return false end
        if not trace.Hit then return false end
        sendPoint(trace.HitPos, trace.HitNormal:Angle())
        return true
    end

    function TOOL:RightClick(trace)
        if not IsFirstTimePredicted() then return false end
        if not trace.Hit then return false end
        net.Start("hg_points_remove")
            net.WriteVector(trace.HitPos)
        net.SendToServer()
        return true
    end

    function TOOL.BuildCPanel(CPanel)
        CPanel:Help("Create Homigrad loot points with subtype selection")
        local subBox = vgui.Create("DComboBox", CPanel)
        subBox:SetSortItems(false)
        subBox:AddChoice("Medium", "medium")
        subBox:AddChoice("Low", "low")
        subBox:AddChoice("Food", "food")
        subBox:SetValue("Medium")
        subBox.OnSelect = function(_, _, _, data) subType = data end
        CPanel:AddItem(subBox)
    end
else
    -- Server‑side net strings already defined in other tool; ensure they exist.
    if not util.NetworkStringToID("hg_points_add") then
        util.AddNetworkString("hg_points_add")
    end
    if not util.NetworkStringToID("hg_points_remove") then
        util.AddNetworkString("hg_points_remove")
    end
    net.Receive("hg_points_add", function(_, ply)
        if not ply:IsAdmin() then return end
        local pos = net.ReadVector()
        local ang = net.ReadAngle()
        local extra = util.JSONToTable(net.ReadString()) or {}
        hook.Call("HomigradAddPoint", nil, ply, pos, ang, extra)
        ply:ChatPrint("[Homigrad] Loot point added")
    end)
    net.Receive("hg_points_remove", function(_, ply)
        if not ply:IsAdmin() then return end
        local pos = net.ReadVector()
        hook.Call("HomigradRemovePoint", nil, ply, pos)
        ply:ChatPrint("[Homigrad] Point removed")
    end)
end
