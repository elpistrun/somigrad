--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/wac/lua/entities/wac_seat_connector/shared.lua <
    > Callstack: addons/wac/lua/entities/wac_seat_connector/cl_init.lua:2 <
]]

ENT.Type 		="anim"
ENT.Base 		="base_gmodentity" 
ENT.PrintName 	="Seat Connector"
ENT.Author 	=wac.author
ENT.Category 	=wac.menu.category

ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:wacLink(e)
	if type(e) == "Vehicle" then
		if SERVER then
			self:addVehicle(e)
		end
		return true
	end
end

