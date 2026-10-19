--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/drgbase/lua/entities/drgbase_entity.lua <
    > Callstack:  <
]]

ENT.Base = "base_entity"
ENT.Type = "anim"
ENT.IsDrGEntity = true

if SERVER then AddCSLuaFile() end
DrGBase.IncludeFile("drgbase/entity_helpers.lua")

local entMETA = FindMetaTable("Entity")

local old_tostring = entMETA.__tostring
function entMETA:__tostring()
	if self.IsDrGProjectile then
		return "Projectile ["..self:EntIndex().."]["..self:GetClass().."]"
	elseif self.IsDrGSpawner then
		return "Spawner ["..self:EntIndex().."]["..self:GetClass().."]"
	else return old_tostring(self) end
end

