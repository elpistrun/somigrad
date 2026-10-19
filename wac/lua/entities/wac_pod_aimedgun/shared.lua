--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/wac/lua/entities/wac_pod_aimedgun/shared.lua <
    > Callstack: addons/wac/lua/entities/wac_pod_aimedgun/cl_init.lua:2 <
]]


ENT.Base = "wac_pod_base"
ENT.Type = "anim"

ENT.PrintName = ""
ENT.Author = wac.author
ENT.Category = wac.aircraft.spawnCategory
ENT.Contact = ""
ENT.Purpose = ""
ENT.Instructions = ""

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.Name = "M197"
ENT.Ammo = 750
ENT.FireRate = 730
ENT.Spray = 0.3
ENT.FireOffset = Vector(60, 0, 0)


function ENT:SetupDataTables()
	self:base("wac_pod_base").SetupDataTables(self)
	self:NetworkVar("Float", 2, "SpinSpeed")
end


