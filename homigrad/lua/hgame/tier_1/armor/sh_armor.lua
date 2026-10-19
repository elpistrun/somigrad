--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/armor/sh_armor.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\armor\\sh_armor.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
function Armor_GetAreSlotsClear(currentArmorItems, newArmorName)
	local info = ArmorListClasses[newArmorName]
	local RequiredSlots = info.slots

	for id, currentArmorData in pairs(currentArmorItems) do
		local CurrentArmorInfo = ArmorListClasses[currentArmorData.name]

		for newSlotName, newCoverage in pairs(RequiredSlots) do
			for oldSlotName, oldCoverage in pairs(CurrentArmorInfo.slots) do
				if oldSlotName == newSlotName then return false, id end
			end
		end
	end

	return true, nil
end

function Armor_GetItemInSlot(armorTable,slot)
	if not armorTable then return nil end
	
	for id, armorData in pairs(armorTable) do
		local ArmorInfo = ArmorListClasses[armorData.name]
		// Надетым может оказаться класс, которого нет в этом конфиге (броня из другого
		// аддона, старая запись в таблице): ArmorInfo.slots тогда nil, и обращение к нему
		// убивало отрисовку слота каждый кадр -- то есть все ячейки страницы.
		if ArmorInfo and ArmorInfo.slots and ArmorInfo.slots[slot] then return id, armorData, ArmorInfo end
	end
	
	return nil
end

