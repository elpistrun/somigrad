-- File: spectate_cam_fix.lua
-- Allows free camera rotation while spectating / in observer mode.
-- Enables mouse capture when the player is an observer and not in a vehicle.

if CLIENT then
    hook.Add( "Think", "HG_SpectateCamFix", function()
        local ply = LocalPlayer()
        if not IsValid( ply ) then return end
        if ply:IsObserver() and not ply:InVehicle() then
            ply:SetMouseCapture( true )
            ply:SetViewEntity( ply )
        else
            ply:SetMouseCapture( false )
        end
    end )
end
