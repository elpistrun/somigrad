--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_1/oop/entities/duplicate_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_1\\oop\\entities\\duplicate_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local LIB = oop.Reg("lib_duplicate")
if not LIB then return end

// Named save/load blocks. `ENT:Duplicate("Save Items", saveFunc, loadFunc)` registers
// one; SaveData/LoadData run them all. The whole block was missing from the recovered
// pack, so every entity that declared duplicates (ent_storage) crashed on load.

function LIB:Duplicate(name,save,load)
	local list = self.duplicates

	if not list then
		list = {}
		self.duplicates = list
	end

	list[name] = {save = save, load = load}
end

function LIB:GetDuplicate(name)
	local list = self.duplicates

	return list and list[name]
end

function LIB:SaveData()
	local data = {}

	for name,duplicate in pairs(self.duplicates or {}) do
		if duplicate.save then
			local sub = {}

			duplicate.save(self,sub)

			data[name] = sub
		end
	end

	return data
end

function LIB:LoadData(data)
	if type(data) ~= "table" then return end

	for name,sub in pairs(data) do
		local duplicate = self:GetDuplicate(name)

		if duplicate and duplicate.load then duplicate.load(self,sub) end
	end
end

//а хуй тэбэ
