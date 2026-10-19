--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/armor/cl_armor.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\armor\\cl_armor.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
event.Add("Player Spawn","Armor",function(ply)
	ply:GetNWTable("Armor")
end)

function Armor_GetBuildSpecsFromArmors(armors)
	local specs = {}
	
	for id,item in pairs(armors) do
		local spec = ArmorListClasses[item.name]
		if not spec then continue end //WTFFFF
		
		local newItem = {
			col = item.col
		}

		util.tableLink(newItem,spec)

		if item.toggle and spec.tgl then
			util.tableLink(newItem,spec.tgl)
		end

		specs[id] = newItem
	end

	return specs
end

FindMetaTable("Player").OnNWTable_Armor = function(self,tbl)
	self.Armors = tbl//dmem
	self.ArmorsSpecs = Armor_GetBuildSpecsFromArmors(tbl)
	
	event.Run("JMod_EZarmorSync",self,self.ArmorsSpecs)
end

// Что видит клиент по броне -- одной командой, без догадок на стороне сервера.
concommand.Add("hg_armor_dump",function()
	local ply = LocalPlayer()

	print("[armor] NW table:",ply.Armors)

	for id,spec in pairs(ply.ArmorsSpecs or {}) do
		local item = (ply.Armors or {})[id] or {}

		print(string.format("[armor] %s: name=%s ent=%s mdl=%s dur=%s/%s known=%s",
			id,item.name,spec.ent,spec.mdl,tostring(item.dur),tostring(spec.dur),
			tostring(ArmorListClasses[item.name] ~= nil)))
	end

	for _,slot in ipairs({"head","eyes","chest","pelvis","acc_backpack"}) do
		local id,item,spec = Armor_GetItemInSlot(ply.Armors,slot)

		print(string.format("[armor] slot %-14s -> %s (%s)",slot,tostring(id),item and tostring(item.name) or "-"))
	end
end)

hook.Add("HUDPaintBackground","Armor Mask",function()
	local ent = GetViewEntity()
	if not ent.Alive or not ent:Alive() or not ent.Armors then return end

	local id,armorData,armorInfo = Armor_GetItemInSlot(ent.Armors,"eyes")
	if not id then return end

	local mat = ent.ArmorsSpecs[id].mskmat
	if not mat or mat == "" then return end

	if mat then
		surface.SetMaterial(Material(mat))
		surface.SetDrawColor(255,255,255)
		surface.DrawTexturedRect(0,0,ScrW(),ScrH())
	end
end)
