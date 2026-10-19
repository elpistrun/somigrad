--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_0/sh_file.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_0\\sh_file.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local file_Find = file.Find
local d,f,split,path2
local string_sub,string_split = string.sub,string.Split

function file.Exists(path,gamePath)
	split = string_split(path,"/")

	path2 = split[#split]
	if path2 == "" then
		path2 = split[#split - 1]
		path = string_sub(path,1,#path - #path2 - 1)
	else
		path = string_sub(path,1,#path - #path2)
	end

	f,d = file_Find(path .. "*",gamePath)

	if d then
		for i = 1,#d do
			if d[i] == path2 then return true end
		end
	end

	if f then
		for i = 1,#f do
			if f[i] == path2 then return true end
		end
	end

	return false
end--sasi xyi
