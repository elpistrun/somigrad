--[[
    New file (not stolen): hot reload for the shlib loader.

    The loader in homigrad_core/lua/shlib/loader.lua has no notion of re-including
    anything: every edit meant a full server restart, which is painful while chasing
    errors. This wraps IncludeDir/IncludeFile so every path that was ever loaded is
    remembered, polls FileTime on them, and re-includes whatever changed -- on the
    server, on every connected client (via AddCSLuaFile + a net message), and on the
    local client.

    Caveats, on purpose:
      * re-including does not undo anything the old code did to global state, so files
        that register hooks or spawn entities may double up. Those are blacklisted
        below.
      * a syntax error in an edited file now throws every scan tick instead of once at
        boot. The poller backs off while errors keep coming.

    ConVars / commands:
      shlib_hotreload        1 = watch, 0 = off           (default 1)
      shlib_hotreload_delay  seconds between scans        (default 2)
      shlib_reload <file>    reload one path immediately
      shlib_reload_scan      rescan and reload every change now
      shlib_reload_stop      unload this and forget all tracked paths
]]

if SERVER then CreateConVar("shlib_hotreload","1",{FCVAR_ARCHIVE,FCVAR_REPLICATED},"Re-include changed shlib files without restarting (1/0)") end
CreateConVar("shlib_hotreload_delay","2",{FCVAR_ARCHIVE},"Seconds between hot reload scans")

local string_sub = string.sub
local string_GetFileFromFilename = string.GetFileFromFilename
local string_split = string.Split
local table_insert,table_concat,table_sort = table.insert,table.concat,table.sort

local VALID_TAG = {
	["cl"] = true,
	["sv"] = true,
	["sh"] = true,
}

-- Same prefix rule as IncludeFile_External: first two chars, else the last chunk.
local function GetTag(fileName)
	local prefix = string_split(fileName,"_")[1]
	prefix = #prefix == 2 and string_sub(prefix,1,2) or ""

	if not VALID_TAG[prefix] then
		prefix = string_sub(string_split(fileName,"_")[#string_split(fileName,"_")],1,2)
	end

	return VALID_TAG[prefix] and prefix or nil
end

local NET_RELOAD = "shlib_hot_reload"

-- net.Start throws on an unpooled name, and that throw used to escape ReloadServer and
-- kill the scan timer outright -- which is exactly how a missing line here turns into
-- "hot reload just silently stopped working". Pool it before anything can send it.
if SERVER then util.AddNetworkString(NET_RELOAD) end

local TRACKED = {}
local STAMP = {}
local DIRTY = {}

-- NOTE on paths: autorun and the shlib loader both work with paths relative to the LUA
-- search path ("shlib/loader.lua"), not "addons/homigrad_core/lua/shlib/loader.lua".
-- include(), AddCSLuaFile() and file.Time(_, "LUA") all want that shorter form.

-- Files that must not be re-run live. Registering a hook or a GM override twice is
-- worse than not reloading at all, and these are the ones that do it.
-- DIRTY: path -> the file revision whose reload threw, so one bad save is retried once
-- per revision instead of on every scan tick.
local BLACKLIST = {
	["shlib/tier_0/tier_0/player/init_protocol_sv.lua"] = true,
	["shlib/loader.lua"] = true,
	["shlib/tier_3_data_manager/tier_0/sync_data_manager_cl.lua"] = true,
}

-- Roots the loader walks. shlib.lua pulls the first three in before this file even
-- loads, so they have to be discovered from disk rather than from the wrapper.
local ROOTS = {
	"shlib/",
	"hlocalize/",
	"hadminpanel/",
	"hgame/",
	"hgamemode/",
	"hinit/",
}

local function TrackTree(path)
	local files,dirs = file.Find(path .. "*","LUA")

	if not files then return end

	for i = 1,#files do
		if string_sub(files[i],-4) == ".lua" then TRACKED[path .. files[i]] = true end
	end

	for i = 1,#dirs do
		if string_sub(dirs[i],1,1) ~= "!" then TrackTree(path .. dirs[i] .. "/") end
	end
end

-- Wrap the loader. The original IncludeDir passes the *globals* IncludeDir/IncludeFile
-- down into IncludeTree_External, so replacing the globals is enough: every file that
-- goes through the tree passes through IncludeFile and gets tracked.
do
	local rawIncludeDir,rawIncludeFile = IncludeDir,IncludeFile

	function IncludeDir(path)
		TRACKED[path] = true

		return rawIncludeDir(path)
	end

	function IncludeFile(path,...)
		if string_sub(path,-4) == ".lua" then TRACKED[path] = true end

		return rawIncludeFile(path,...)
	end

	for i = 1,#ROOTS do TrackTree(ROOTS[i]) end
end

local TrackedList

local function BuildList()
	TrackedList = {}

	for path in pairs(TRACKED) do
		TrackedList[#TrackedList + 1] = path
	end

	table_sort(TrackedList)
end

-- file.Time is the real name; the second argument is the search path, and these paths
-- only resolve inside "LUA", not "DATA".
local function Stamp(path)
	return file.Time(path,"LUA")
end

-- Re-include on the server, then push it to everyone. AddCSLuaFile has to happen before
-- the net message so the client actually has fresh bytes to include.
local function ReloadServer(path)
	local tag = GetTag(string_GetFileFromFilename(path))

	if not tag or BLACKLIST[path] then return false end

	if tag ~= "sv" then AddCSLuaFile(path) end

	-- Mirror what the loader itself does per tag: a cl file is client-only code and must
	-- never be run here. include()ing it on the server is how a perfectly good client file
	-- turns into a server error, or quietly pollutes server globals.
	--   cl -> AddCSLuaFile only (done above)
	--   sv -> include here only
	--   sh -> both
	if tag ~= "cl" then
		local ok,err = pcall(include,path)

		if not ok then
			ErrorNoHalt("[shlib hot reload] " .. path .. ": " .. tostring(err) .. "\n")

			return false
		end
	end

	if tag ~= "sv" then
		-- the file itself is already reloaded on the server, so a push failure here must
		-- not bubble up and take the scan timer down with it
		local sent = pcall(function()
			net.Start(NET_RELOAD)
				net.WriteString(path)
			net.Broadcast()
		end)

		if not sent then
			ErrorNoHalt("[shlib hot reload] " .. path .. ": reloaded on the server but could not reach clients\n")
		end
	end

	MsgN("[shlib hot reload] reloaded ",path," (",tag,")\n")

	return true
end

if SERVER then
	local errors = 0
	local consecutive = 0

	local function Scan()
		if GetConVarNumber("shlib_hotreload") == 0 then return end
		if errors > 0 then
			-- a file we just included is broken; stop hammering the console until it
			-- changes again
			consecutive = consecutive + 1
			if consecutive > 3 then return end
		end

		if not TrackedList then BuildList() end

		local changed = 0

		for i = 1,#TrackedList do
			local path = TrackedList[i]

			-- nothing in one file may be allowed to stop the scan loop: a timer that throws
			-- is not rescheduled, so a single bad file would end hot reloading for the rest
			-- of the session. That is not hypothetical -- an unpooled net message in here is
			-- what silently killed this timer the first time it ran.
			local alive,err = pcall(function()
				local stamp = Stamp(path)

				if not stamp then
					STAMP[path] = nil

					return
				end

				local old = STAMP[path]

				STAMP[path] = stamp

				if old == nil or old == stamp then return end

				-- DIRTY is keyed by the revision that threw, not just by the path. Keying it
				-- by path alone meant one bad save blacklisted the file for the rest of the
				-- session, so the *second* edit was never picked up -- which is the whole
				-- point of this thing.
				if DIRTY[path] == stamp then return end

				if ReloadServer(path) then
					DIRTY[path] = nil
					changed = changed + 1
					errors = 0
				else
					DIRTY[path] = stamp
					errors = errors + 1
				end
			end)

			if not alive then
				if DIRTY[path] ~= STAMP[path] then
					ErrorNoHalt("[shlib hot reload] " .. path .. ": " .. tostring(err) .. "\n")
				end

				DIRTY[path] = STAMP[path]
				errors = errors + 1
			end
		end

		if changed == 0 then errors = 0 consecutive = 0 end
	end

	-- a 0 here would turn Scan into a busy loop and eat the whole server frame
	timer.Create("shlib_hotreload_scan",math.max(GetConVarNumber("shlib_hotreload_delay"),0.25),0,Scan)

	concommand.Add("shlib_reload",function(_,_,args)
		local path = args[1]
		if not path or path == "" then
			MsgN("[shlib hot reload] usage: shlib_reload <path/to/file.lua>\n")

			return
		end

		ReloadServer(path)
		STAMP[path] = Stamp(path)
		DIRTY[path] = nil
	end)

	concommand.Add("shlib_reload_scan",function()
		BuildList()

		for path in pairs(DIRTY) do DIRTY[path] = nil end

		Scan()
	end)

	concommand.Add("shlib_reload_stop",function()
		timer.Remove("shlib_hotreload_scan")

		TRACKED,STAMP,DIRTY,TrackedList = {},{},{},nil
	end)

	hook.Add("ShutDown","SHLib Hot Reload",function() timer.Remove("shlib_hotreload_scan") end)
end

if CLIENT then
	net.Receive("shlib_hot_reload",function(len)
		local path = net.ReadString()
		local tag = GetTag(string_GetFileFromFilename(path))

		-- a sv file has no client half, there is nothing to include here
		if not tag or tag == "sv" then return end

		pcall(include,path)
	end)
end