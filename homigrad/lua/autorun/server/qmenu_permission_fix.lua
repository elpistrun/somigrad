-- File: qmenu_permission_fix.lua
-- Fix admin groups that cannot open qmenu / cmenu.
-- Adds a permissive hook mirroring the default admin check.

if SERVER then
    hook.Add( "PlayerCanUseMenu", "HG_QMenuPermissionFix", function( ply )
        if not IsValid( ply ) then return false end
        if ply:IsSuperAdmin() or ply:IsAdmin() then return true end
        local extra = { "root", "operator", "dsuperadmin", "dadmin", "doperator" }
        for _, grp in ipairs( extra ) do
            if ply:IsUserGroup( grp ) then return true end
        end
        return false
    end )
end
