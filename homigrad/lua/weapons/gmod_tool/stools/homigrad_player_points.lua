-- File: d:/server/garrysmod/addons/homigrad/lua/weapons/gmod_tool/stools/homigrad_player_points.lua
-- Homigrad Player Point creation tool – creates player spawn points with subtype selection.

TOOL.Category   = "Homigrad"
TOOL.Name       = "Homigrad - Player Point"
TOOL.Command    = nil
TOOL.ConfigName = ""

-- Default subtype for player points
local defaultSubTypes = { "tdm_blue", "tdm_red", "dm" }

if CLIENT then
    local subType = defaultSubTypes[1]

    local function sendPoint(pos, ang)
        local extra = {
            point_type = "player",
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
        CPanel:Help("Create Homigrad player points with subtype selection")
        local subBox = vgui.Create("DComboBox", CPanel)
        subBox:SetSortItems(false)
        subBox:AddChoice("TDM – Blue", "tdm_blue")
        subBox:AddChoice("TDM – Red", "tdm_red")
        subBox:AddChoice("DM – Free", "dm")
        subBox:SetValue("TDM – Blue")
        subBox.OnSelect = function(_, _, _, data) subType = data end
        CPanel:AddItem(subBox)
    end
else
    util.AddNetworkString("hg_points_add")
    util.AddNetworkString("hg_points_remove")
    net.Receive("hg_points_add", function(_, ply)
        if not ply:IsAdmin() then return end
        local pos = net.ReadVector()
        local ang = net.ReadAngle()
        local extra = util.JSONToTable(net.ReadString()) or {}
        hook.Call("HomigradAddPoint", nil, ply, pos, ang, extra)
        ply:ChatPrint("[Homigrad] Player point added")
    end)
    net.Receive("hg_points_remove", function(_, ply)
        if not ply:IsAdmin() then return end
        local pos = net.ReadVector()
        hook.Call("HomigradRemovePoint", nil, ply, pos)
        ply:ChatPrint("[Homigrad] Point removed")
    end)
end
