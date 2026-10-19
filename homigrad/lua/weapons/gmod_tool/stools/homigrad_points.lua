// Homigrad Points tool – adds/removes PLAYER and LOOT points for the Homigrad system.

TOOL.Category   = "Construction"
TOOL.Name       = "HG Points"
TOOL.Command    = nil
TOOL.ConfigName = ""

if CLIENT then
    language.Add( "tool.homigrad_points.name", "HG Points" )
    language.Add( "tool.homigrad_points.desc", "Place player‑spawn or loot points for the Homigrad system." )
    language.Add( "tool.homigrad_points.0", "Left‑click: add PLAYER point | Right‑click: add LOOT point | Reload: remove nearest point" )
    language.Add( "tool.homigrad_points.left", "Add PLAYER point" )
    language.Add( "tool.homigrad_points.right", "Add LOOT point" )
    language.Add( "tool.homigrad_points.reload", "Remove nearest point" )
end

-- Helper: safely start a net message only if the server has registered it.
local function SafeNetStart( name )
    if not util.NetworkStringToID( name ) or util.NetworkStringToID( name ) == 0 then
        return false
    end
    net.Start( name )
    return true
end

function TOOL:LeftClick( trace )
    if SERVER then return true end
    if not SafeNetStart( "hg_points_add" ) then return false end
    net.WriteUInt( HGPOINTS.PLAYER, 2 )
    net.WriteVector( trace.HitPos )
    net.WriteAngle( Angle( 0, 0, 0 ) )
    net.SendToServer()
    return true
end

function TOOL:RightClick( trace )
    if SERVER then return true end
    if not SafeNetStart( "hg_points_add" ) then return false end
    net.WriteUInt( HGPOINTS.LOOT, 2 )
    net.WriteVector( trace.HitPos )
    net.WriteAngle( Angle( 0, 0, 0 ) )
    net.SendToServer()
    return true
end

function TOOL:Reload( trace )
    if SERVER then return true end
    if not SafeNetStart( "hg_points_remove" ) then return false end
    -- 0 = any type (both PLAYER and LOOT)
    net.WriteUInt( 0, 2 )
    net.WriteVector( trace.HitPos )
    net.SendToServer()
    return true
end

list.Set( "ToolCategory", "construction", "#tool.construction.name", "icon16/wrench.png" )
