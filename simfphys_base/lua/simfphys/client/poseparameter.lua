--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/simfphys_base/lua/simfphys/client/poseparameter.lua <
    > Callstack: addons/simfphys_base/lua/simfphys/init.lua:35
[C]:-1
addons/simfphys_base/lua/autorun/simfphys_init.lua:4 <
]]

local function receiveppdata( length )
	local ent = net.ReadEntity()
	
	if IsValid( ent ) then
		ent.CustomWheels = net.ReadBool()
		
		if not ent.CustomWheels then
			local wheelFL = net.ReadEntity()
			local posFL = net.ReadFloat()
			local travelFL = net.ReadFloat()
			
			local wheelFR = net.ReadEntity()
			local posFR = net.ReadFloat()
			local travelFR = net.ReadFloat()
			
			local wheelRL = net.ReadEntity()
			local posRL = net.ReadFloat()
			local travelRL = net.ReadFloat()
			
			local wheelRR = net.ReadEntity()
			local posRR = net.ReadFloat()
			local travelRR = net.ReadFloat()
			
			if not IsValid( wheelFL ) or not IsValid( wheelFR ) or not IsValid( wheelRL ) or not IsValid( wheelRR ) then return end
			
			ent.pp_data = {
				[1] = {
					name = "vehicle_wheel_fl_height",
					entity = wheelFL,
					pos = posFL,
					travel = travelFL,
					dradius = (wheelFL:BoundingRadius() * 0.28),
				},
				[2] = {
					name = "vehicle_wheel_fr_height",
					entity = wheelFR,
					pos = posFR,
					travel = travelFR,
					dradius = (wheelFR:BoundingRadius() * 0.28),
				},
				[3] = {
					name = "vehicle_wheel_rl_height",
					entity = wheelRL,
					pos = posRL,
					travel = travelRL,
					dradius = (wheelRL:BoundingRadius() * 0.28),
				},
				[4] = {
					name = "vehicle_wheel_rr_height",
					entity = wheelRR,
					pos = posRR,
					travel = travelRR,
					dradius = (wheelRR:BoundingRadius() * 0.28),
				},
			}
		end
	end
end
net.Receive("simfphys_send_ppdata", receiveppdata)
