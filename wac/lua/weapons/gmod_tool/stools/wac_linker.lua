--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/wac/lua/weapons/gmod_tool/stools/wac_linker.lua <
    > Callstack: gamemodes/sandbox/entities/weapons/gmod_tool/stool.lua:159
[C]:-1
gamemodes/sandbox/entities/weapons/gmod_tool/shared.lua:390
[C]:-1
gamemodes/sandbox/entities/weapons/gmod_tool/cl_init.lua:11 <
]]


TOOL.Category = wac.menu.category
TOOL.Name = "Entity Linker"
TOOL.Command = nil
TOOL.ConfigName = ""

if CLIENT then
	language.Add("tool.wac_linker.name", "Entity Linker")
	language.Add("tool.wac_linker.desc", "Link WAC entities")
	language.Add("tool.wac_linker.0", "Click on the entity you want to link")
	language.Add("tool.wac_linker.1", "Now click on the second entity, or press R to clear.")
	language.Add("tool.wac_linker.2", "That didn't work.")
end

function TOOL:reload(b)
	self:SetStage(b and 0 or 2)
	self.entity = nil
	return b
end

function TOOL:LeftClick(tr)
	if tr.Hit and IsValid(tr.Entity) then
		if not self.entity then
			self.entity = tr.Entity
			self:SetStage(1)
			return true
		else
			if self.entity.wacLink then
				return self:reload(self.entity:wacLink(tr.Entity))
			elseif tr.Entity.wacLink then
				return self:reload(tr.Entity:wacLink(self.entity))
			else
				return self:reload(false)
			end
		end
	end
end

function TOOL:Reload(tr)
	self:SetStage(0)
	self.entity = nil
	return false
end

