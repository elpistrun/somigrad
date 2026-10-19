-- Server side playtime tracking.
--
-- The scoreboard's "Наиграно" column reads:
--     ply:GetTimeStatus()  ->  ply:GetNWInt("Time",-1) + (CurTime() - ply:GetNWFloat("TimeStart",0))
-- and falls back to a spinner when "Time" is still -1. Both NW vars were written by
-- the homigrad server half that never shipped, so the column spun forever for every
-- player. Replicate them here instead.
--
-- Time      -- whole seconds already played
-- TimeStart -- CurTime() of the moment "Time" was last bumped, so the client can add
--              the partial minute on top

if not SERVER then return end

local CurTime = CurTime

hook.Add("PlayerInitialSpawn", "SHLib PlayTime", function(ply)
	if not IsValid(ply) then return end

	-- keep whatever was already banked, just start counting the current minute
	ply:SetNWInt("Time",ply:GetNWInt("Time",0))
	ply:SetNWFloat("TimeStart",CurTime())
end)

event.Add("Player Think 1","SHLib PlayTime",function(ply)
	if not IsValid(ply) or not ply.init then return end
	if (ply.playTimeNext or 0) > CurTime() then return end

	ply.playTimeNext = CurTime() + 60

	ply:SetNWInt("Time",ply:GetNWInt("Time",0) + 60)
	ply:SetNWFloat("TimeStart",CurTime())
end)

hook.Add("PlayerDisconnected", "SHLib PlayTime", function(ply)
	ply.playTimeNext = nil
end)