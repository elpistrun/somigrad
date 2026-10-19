--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/drgbase/lua/drgbase/meta/npc.lua <
    > Callstack: addons/drgbase/lua/autorun/drgbase.lua:93
addons/drgbase/lua/autorun/drgbase.lua:109 <
]]


local npcMETA = FindMetaTable("NPC")

if SERVER then

	function npcMETA:DrG_SetRelationship(ent, disp)
		if not IsValid(ent) then return end
		if self.CPTBase_NPC then
			self:AddEntityRelationship(ent, disp, 99)
		else
			self._DrGBaseRelPrios = self._DrGBaseRelPrios or {}
			if not self._DrGBaseRelPrios[ent] then self._DrGBaseRelPrios[ent] = 0 end
			self._DrGBaseRelPrios[ent] = self._DrGBaseRelPrios[ent]+1
			self:AddEntityRelationship(ent, disp, self._DrGBaseRelPrios[ent])
			if not self.IsVJBaseSNPC or not ent.IsDrGNextbot then return end
			if istable(self.CurrentPossibleEnemies) and
			not table.HasValue(self.CurrentPossibleEnemies, ent) then
				table.insert(self.CurrentPossibleEnemies, ent)
			end
			if istable(self.VJ_AddCertainEntityAsEnemy) then
				if (disp == D_HT or disp == D_FR) then
					if not table.HasValue(self.VJ_AddCertainEntityAsEnemy, ent) then
						table.insert(self.VJ_AddCertainEntityAsEnemy, ent)
					end
				else table.RemoveByValue(self.VJ_AddCertainEntityAsEnemy, ent) end
			end
			if istable(self.VJ_AddCertainEntityAsFriendly) then
				if disp == D_LI then
					if not table.HasValue(self.VJ_AddCertainEntityAsFriendly, ent) then
						table.insert(self.VJ_AddCertainEntityAsFriendly, ent)
					end
				else table.RemoveByValue(self.VJ_AddCertainEntityAsFriendly, ent) end
			end
		end
	end

end

