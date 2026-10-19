--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/override_ttt/lua/entities/base_ammo_ttt.lua <
    > Callstack:  <
]]

-- "addons\\override_ttt\\lua\\entities\\base_ammo_ttt.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
AddCSLuaFile()
ENT.Type = "anim"
function ENT:Initialize() if SERVER then self:Remove() end end
function ENT:SetupDataTables() end
