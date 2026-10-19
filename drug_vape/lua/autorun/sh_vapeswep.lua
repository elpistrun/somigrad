--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/drug_vape/lua/autorun/sh_vapeswep.lua <
    > Callstack:  <
]]

-- "addons\\drug_vape\\lua\\autorun\\sh_vapeswep.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
-- autorun/client/cl_vapeswep.lua
-- Defines shared globals for Vape SWEP

-- Vape SWEP by Swamp Onions - http://steamcommunity.com/id/swamponions/

CreateConVar("vape_block_sounds", "0", FCVAR_REPLICATED, "Set to 1 to disable Vape SWEP speech sounds")

--override Entity:SetMaterial to make sure vape shows for ponies
meta = FindMetaTable("Entity")
if meta.VapeOrigSetMaterial == nil then
	meta.VapeOrigSetMaterial = meta.SetMaterial
	meta.SetMaterial = function(self, materialName, forceMaterial)
		if self:GetClass():sub(1,11)=="weapon_vape" and materialName=="Models/effects/vol_light001" then return end
		self:VapeOrigSetMaterial(materialName, forceMaterial)
	end
end
