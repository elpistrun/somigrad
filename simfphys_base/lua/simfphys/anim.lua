--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/simfphys_base/lua/simfphys/anim.lua <
    > Callstack: addons/simfphys_base/lua/simfphys/init.lua:38
[C]:-1
addons/simfphys_base/lua/autorun/simfphys_init.lua:4 <
]]

hook.Add("CalcMainActivity", "simfphysSeatActivityOverride", function(ply)
	local veh = ply:GetSimfphys()

	if not IsValid( veh ) then return end

	if ply.m_bWasNoclipping then 
		ply.m_bWasNoclipping = nil 
		ply:AnimResetGestureSlot( GESTURE_SLOT_CUSTOM ) 
		
		if CLIENT then 
			ply:SetIK( true )
		end 
	end 

	ply.CalcIdeal = ACT_HL2MP_SIT
	ply.CalcSeqOverride = isfunction( veh.GetSeatAnimation ) and veh:GetSeatAnimation( ply ) or -1

	if not ply:IsDrivingSimfphys() and ply:GetAllowWeaponsInVehicle() and IsValid( ply:GetActiveWeapon() ) then
		
		local holdtype = ply:GetActiveWeapon():GetHoldType()
		
		if holdtype == "smg" then 
			holdtype = "smg1"
		end

		local seqid = ply:LookupSequence( "sit_" .. holdtype )
		
		if seqid ~= -1 then
			ply.CalcSeqOverride = seqid
		end
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end)

hook.Add("UpdateAnimation", "simfphysPoseparameters", function(ply , vel, seq)
	if CLIENT then
		if not ply:IsDrivingSimfphys() then return end
		
		local Car = ply:GetSimfphys()
		
		if not IsValid( Car ) then return end
		
		local Steer = Car:GetVehicleSteer()
		
		ply:SetPoseParameter( "vehicle_steer", Steer )
		ply:InvalidateBoneCache()
		
		GAMEMODE:GrabEarAnimation( ply ) 
 		GAMEMODE:MouthMoveAnimation( ply ) 
		
		return true
	end
end)
