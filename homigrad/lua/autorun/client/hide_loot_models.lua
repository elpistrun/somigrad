-- File: hide_loot_models.lua
-- Prevents other players' weapons/armor from being drawn when looking at a lootbox.
-- Hides the entire player model for non‑local players when the view ray hits a lootbox entity.

if CLIENT then
    hook.Add( "PrePlayerDraw", "HG_HideLootAttachments", function( ply )
        if not IsValid( ply ) then return end
        if ply == LocalPlayer() then return end
        local tr = util.TraceLine({
            start = EyePos(),
            endpos = EyePos() + EyeVector() * 8192,
            filter = { LocalPlayer() }
        })
        if IsValid( tr.Entity ) and tr.Entity:GetClass():find( "ent_lootbox" ) then
            return false -- cancel drawing of the other player's model
        end
    end )
end
