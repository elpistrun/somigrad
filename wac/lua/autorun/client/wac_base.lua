--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/wac/lua/autorun/client/wac_base.lua <
    > Callstack:  <
]]


local PLAYER = FindMetaTable("Player")
function PLAYER:GetViewEntity()
	return GetViewEntity()
end


local VEHICLE = FindMetaTable("Vehicle")

function VEHICLE:GetPassenger()
	for _,p in pairs(player.GetAll()) do
		if p:GetVehicle()==self then
			return p
		end
	end
end


