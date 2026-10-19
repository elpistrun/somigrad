-- One-shot server diagnostic.
--
-- Most of this pack is a client-side leak (glua-steal only retrieves AddCSLuaFile'd
-- files), so the honest question is not "why did it error" but "what is still absent".
-- This prints exactly that once per server start, so the console tells us instead of
-- guessing from stack traces.
--
-- Safe to keep: it only reads state and prints. Every probe is wrapped in pcall so a
-- bad entry can never kill the report itself.

if not SERVER then return end

-- resolve "a.b.c" / "a:b:c" without assuming the middle is a table
local function lookup(path)
	local root,rest = string.match(path,"^([^%.:]+)[%.:](.+)$")

	if not root then return _G[path] end

	local value = _G[root]
	if type(value) ~= "table" and type(value) ~= "userdata" then return nil end

	for key in string.gmatch(rest,"([^.]+)") do
		if type(value) ~= "table" then return nil end

		value = value[key]
	end

	return value
end

local function report(label,name,value)
	print(string.format("  %-4s %-42s %s", label, name, value and "ok" or "MISSING"))
end

hook.Add("Initialize","HG_Diag",function()
	timer.Simple(3,function()
		print("\n================ [homigrad] recovery report ================")

		-- registration layer --------------------------------------------------
		-- note: client-only entries are expected to read MISSING here
		local api = {
			"oop.Reg",
			"oop.Get",
			"Mutator_Reg",
			"EventPlugin_Reg",
			"DonatItem_Reg",
			"MissionItem_Reg",
			"DonatItem_Create",
			"Point_Add",
			"EntCopy",
			"EntPaste",
			"Armor_Equip",
			"AdminPanel_Command_Registry",
			"Create_SyncDataManager_AboutSteamID64",
			"CreateItems_SyncDataManager_AboutSteamID64",
			"InvCreate",
		}

		for _,name in ipairs(api) do
			local ok,value = pcall(lookup,name)

			report("api",name,ok and value or false)
		end

		-- base classes --------------------------------------------------------
		local classes = {
			["base_entity"] = function() return scripted_ents.Get("base_entity") end,
			["base_weapon"] = function() return scripted_ents.Get("base_weapon") end,
			["arccw_base"] = function() return weapons.Get("arccw_base") end,
			["gunbase"] = function() return weapons.Get("wep_jack_gmod_gunbase") end,
		}

		for name in SortedPairs(classes) do
			local ok,value = pcall(classes[name])

			report("ent",name,ok and value or false)
		end

		-- addon globals -------------------------------------------------------
		local globals = {"LVS","StreamRadioLib","JMod","arccw","RIGS","VJBase"}

		for _,name in ipairs(globals) do
			report("add",name,lookup(name))
		end

		-- JMod: the shipped sh_*.lua and the workshop sv_*.lua must be the same
		-- version, otherwise the server calls functions the shared half never
		-- defined (GetHoliday, PlyHasArmorEff, ...).
		do
			local missing = 0

			for _,name in ipairs({"GetHoliday","PlyHasArmorEff","GetArmor"}) do
				if not lookup("JMod." .. name) then
					missing = missing + 1
					report("jmod","JMod." .. name,false)
				end
			end

			if missing == 0 then report("jmod","shared/server version match",true) end
		end

		-- registered classes --------------------------------------------------
		local lists = {
			{"oop classes",oop.listClass},
			{"mutators",_MutatorClasses},
			{"event plugins",_EventPluginsClasses},
			{"donat items",DonatItemClasses},
			{"mission items",MissionItemClasses},
		}

		for _,list in ipairs(lists) do
			local n = 0

			for _ in pairs(list[2] or {}) do n = n + 1 end

			print(string.format("  reg  %-42s %d", list[1],n))
		end

		-- mounted addons: helps spotting a locally unpacked addon shadowing the
		-- complete workshop copy of the same addon ------------------------------
		print(string.format("  addons mounted: %d",#(file.Find("addons/*","GAME") or {})))

		print("==========================================================\n")
	end,1)
end)