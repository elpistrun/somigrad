--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/simfphys_base/lua/simfphys/client/damage.lua <
    > Callstack: addons/simfphys_base/lua/simfphys/init.lua:34
[C]:-1
addons/simfphys_base/lua/autorun/simfphys_init.lua:4 <
]]

local function damagedbackfire( length )
	local veh = net.ReadEntity()
	if not IsValid( veh ) then return end
	veh:Backfire( true )
end
net.Receive("simfphys_backfire", damagedbackfire)

