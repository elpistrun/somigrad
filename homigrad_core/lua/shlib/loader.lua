--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/loader.lua <
    > Callstack: addons/homigrad_core/lua/autorun/shlib.lua:4 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\loader.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
AddCSLuaFile()

local string_sub = string.sub
local string_split = string.Split
local string_find = string.find

local string_GetFileFromFilename = string.GetFileFromFilename

local validTag = {
	["cl"] = true,
	["sv"] = true,
	["sh"] = true
}

function IncludeFile_External(path,includeClient,includeServer,includeShared,...)--aaaaaaaeeeeeeeeeeeee😎
	-- Skip non-.lua files (notably the *.lua_ duplicate/backup copies). file.Find
	-- returns them, but include() rejects them and AddCSLuaFile raises
	-- "Invalid filename", spamming the console with hundreds of errors.
	if string_sub(path,-4) ~= ".lua" then return end

	local fileName = string_GetFileFromFilename(path)
	if string_sub(fileName,1,1) == "!" then return end

	local split = string_split(fileName,"_")
	local prefix

	prefix = split[1]
	prefix = #prefix == 2 and string_sub(prefix,1,2) or ""
	
	if not validTag[prefix] then
		prefix = split[#split]
		prefix = string_sub(prefix,1,2)

		if not validTag[prefix] then return end--lol4ik
	end

	if prefix == "cl" then
		return includeClient(path,...)
	elseif prefix == "sv" then
		return includeServer(path,...)
	elseif prefix == "sh" then
		return includeShared(path,...)
	end
end

local function includeClient(path)
	if SERVER then
		AddCSLuaFile(path)
	else
		if ONLYADDCSLUAFILE then return end

		return include(path)
	end
end

local function includeServer(path)
	if not SERVER or ONLYADDCSLUAFILE then return end

	return include(path)
end

local function includeShared(path)
	if SERVER then AddCSLuaFile(path) end
	if ONLYADDCSLUAFILE then return end

	return include(path)
end

function IncludeFile(path,...)
	return IncludeFile_External(path,includeClient,includeServer,includeShared,...)
end

-- File-local aliases for the two callbacks the tree recurses through.
--
-- IncludeDir used to hand its own *globals* down into IncludeTree_External, so the
-- per-file callback was whatever the global IncludeFile pointed at when the recursion
-- started. Anything that reassigns that global -- a second loader, a helper from another
-- addon, an older copy of this file -- silently replaced the per-tag dispatch with a raw
-- include(): the realm checks below never ran and a _cl file was *executed* on the server.
-- That is how hgame/tier_1/fake/main_cl.lua, whose first line indexes the client-only
-- `keyboard` table, took the boot down: the throw aborted the rest of the IncludeDir pass,
-- and every file the loader had not reached yet (weapons, gamemode, melee) stayed
-- unloaded. The tree now uses these two locals, which nothing outside this file can
-- overwrite.
local IncludeFileLocal
local IncludeDirLocal

IncludeFileLocal = IncludeFile

local string_gsub = string.gsub

INCLUDE_BREAK = 1

function IncludeTree_External(path,_files,_dirs,includeDir,includeFile,...)
	local files,dirs,tier_files,tier_dirs = {},{},{},{}
	local v,v2,tier

	for i = 1,#_files do
		v = _files[i]

		local tier = nil
		for i,sum in pairs(string_split(v,"_")) do
			if tier then
				sum = string_gsub(sum,".lua","")
				tier = tonumber(sum)

				break
			end

			if sum == "tier" or sum == "t" then tier = true end
		end

		if tier then
			v2 = tier_files[tier]

			if not v2 then
				v2 = {}
				tier_files[tier] = v2
			end

			v2[#v2 + 1] = v

			continue
		end

		files[#files + 1] = v
	end

	for i = 1,#_dirs do
		v = _dirs[i]

		if string_sub(v,1,1) == "!" then continue end

		tier = nil
		for i,sum in pairs(string_split(v,"_")) do
			if tier then tier = tonumber(sum) break end
			if sum == "tier" or sum == "t" then tier = true end
		end

		if tier then
			v2 = tier_dirs[tier]

			if not v2 then
				v2 = {}
				tier_dirs[tier] = v2
			end

			v2[#v2 + 1] = v .. "/"

			continue
		end

		dirs[#dirs + 1] = v .. "/"
	end

	local result
	local empty = {}

	for tier = 0,#tier_files do
		v2 = tier_files[tier] or empty

		for i = 1,#v2 do
			result = IncludeFileLocal(path .. v2[i],...)
			if result == INCLUDE_BREAK then return end--спалился
		end
	end

	for i = 1,#files do
		result = IncludeFileLocal(path .. files[i],...)
		if result == INCLUDE_BREAK then return end
	end

	for tier = 0,#tier_dirs do
		v2 = tier_dirs[tier] or empty

		for i = 1,#v2 do
			IncludeDirLocal(path .. v2[i],...)
		end
	end

	for i = 1,#dirs do
		IncludeDirLocal(path .. dirs[i],...)
	end
end

function IncludeDir(path)
	local _files,_dirs = file.Find(path .. "*","LUA")

	IncludeTree_External(
		path,
		
		_files,
		_dirs,

		IncludeDirLocal,
		IncludeFileLocal
	)
end--бесплатно!

IncludeDirLocal = IncludeDir

local string_sub,string_split,string_gsub,string_find = string.sub,string.Split,string.gsub,string.find
local trace

function GetPath(levelUp)
	trace = debug.traceback()

	if levelUp then levelUp = 3 + levelUp end

	local lines = string_split(trace,"\n")
	local line = lines[levelUp or #lines]
	if not line then return "" end

	line = string.Trim(line)

	local path = line:match("^(.-):%d+:") or line:match("^(.-):") or line
	if string_sub(path,1,1) == "@" then path = string_sub(path,2) end
	path = string_gsub(path,"\\","/")

	local luaPos = string_find(path,"/lua/")
	if luaPos then
		return string_sub(path,luaPos + 5)
	elseif string_sub(path,1,4) == "lua/" then
		return string_sub(path,5)
	end

	if string_sub(path,1,7) == "addons/" then
		path = string_sub(path,8)
		local s = string_find(path,"/")
		if s then return string_sub(path,s + 5) end
	end

	return path
end

hook.Add("Initialize","SHLib",function()
	event.Call("Initialize")

	Initialize = true
end)

hook.Add("InitPostEntity","SHLib",function() InitPostEntity = true end)
