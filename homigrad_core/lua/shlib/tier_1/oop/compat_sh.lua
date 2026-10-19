-- Compatibility layer for the shlib APIs whose defining files never made it into the
-- recovered pack. glua-steal only ships AddCSLuaFile'd files, so every registration
-- helper that lived in a server-only file is missing and the shared (both-realm)
-- files that call them die at load time.
--
-- Everything here is guarded/derived so that if the real file ever turns up it simply
-- wins -- nothing here is meant to replace working code, only to unblock the load.

--

-- IsValid against numbers ------------------------------------------------------
-- optimization/lua/autorun/random_patches.lua replaces the *global* IsValid with one
-- that does `local func = object.IsValid` and no type check at all, so IsValid(5)
-- raises "attempt to index local 'object' (a number value)" instead of returning false.
-- Our restored helpers do get handed raw numbers: the caller in the log is
-- weapon_hands/tier_0_sh.lua:379, which does
--   sound.Emit(self:EntIndex(),"weapons/slam/throw.wav",...)   -- an index, not an entity
-- and the Emit below then asked IsValid about it. Nothing in a pack this size can
-- promise that every caller passes an entity, so funnel our own checks through this:
-- anything that cannot be an entity is not a valid one. Deliberately looks the global
-- IsValid up at call time, so it stays safe whichever addon installed it last.
local function IsEnt(object)
	local objectType = type(object)

	-- Note: GMod's type() reports "Entity"/"Player"/"Vehicle"/... for entities, so test
	-- for the types that can never be one. Only numbers, booleans, functions and threads
	-- actually blow up when indexed (`("x").IsValid` is a harmless nil through the string
	-- metatable), but every one of them is unambiguously not an entity anyway.
	if objectType == "number" or objectType == "boolean" or objectType == "function" or objectType == "thread" or objectType == "nil" then
		return false
	end

	return IsValid(object)
end

-- donat items -------------------------------------------------------------------

DonatItemClasses = DonatItemClasses or {}
MissionItemClasses = MissionItemClasses or {}

DonatItemsList = DonatItemsList or {}
DonatCasesClasses = DonatCasesClasses or {}
DonatCategories = DonatCategories or {}

-- filled by homigrad/hgame communication code on the client, read by shared donat files
FlexByPlayerModel = FlexByPlayerModel or {}

function DonatItem_Reg(class, base, isFolder)
	return oop.Reg(class, base, isFolder, 0, DonatItemClasses)
end

function DonatItem_Get(class)
	return oop.Get(class, DonatItemClasses)
end

function MissionItem_Reg(class, base, isFolder)
	return oop.Reg(class, base, isFolder, 0, MissionItemClasses)
end

function MissionItem_Get(class)
	return oop.Get(class, MissionItemClasses)
end

local function createItem(classList, item, data)
	item = util.tableCopy(item)

	local class = classList[item.class] or classList["base"]

	item.data = data or {}

	if class then util.tableLink(item,class[1]) end

	return item
end

DonatItem_Create = DonatItem_Create or function(item, data)
	return createItem(DonatItemClasses, item, data)
end

MissionItem_Create = MissionItem_Create or function(item, data)
	return createItem(MissionItemClasses, item, data)
end

-- Real (sync driven) versions are installed by CreateItems_SyncDataManager_AboutSteamID64
-- on the client; on the server they have no data source at all yet, so stay inert.
DonatItem_SetupList = DonatItem_SetupList or function() end
MissionItem_SetupList = MissionItem_SetupList or function() end

-- donat sync data -------------------------------------------------------------
-- Every donat UI reads its data as Data[AccountSteamID64] and then walks it with
-- pairs(). The half that pushes those tables from the server never shipped, so the
-- entries stay nil and the panels crash (pairs(nil), indexing a nil 'data', ...).
--
-- Give these tables an auto-vivifying index: reading an unknown steamid64 returns
-- (and caches) an empty table, so the UIs render empty instead of exploding. pairs()
-- only ever sees rawset keys, so nothing shows up that the server did not send.
--
-- Declared here, before homigrad_donat does its own `X = X or {}`, so those files
-- keep this table instead of replacing it.

local function AutoDefault(tbl,defaults)
	if getmetatable(tbl) then return tbl end

	return setmetatable(tbl,{
		__index = function(t,key)
			local value = {}

			if defaults then
				setmetatable(value,{__index = defaults})
			end

			rawset(t,key,value)

			return value
		end
	})
end

EmailData         = AutoDefault(EmailData         or {})
FreeDropData      = AutoDefault(FreeDropData      or {})
MissionData       = AutoDefault(MissionData       or {})
MissionList       = AutoDefault(MissionList       or {})
DonatInventoryData = AutoDefault(DonatInventoryData or {})
DonatInventoryList = AutoDefault(DonatInventoryList or {})
OutfitData        = AutoDefault(OutfitData        or {})

-- the shop and the trade window read .money/.moneyDonat straight off the entry and
-- compare them numerically, so an empty table is not enough here: they need zeroes
BalanceData       = AutoDefault(BalanceData       or {},{money = 0,moneyDonat = 0})

-- level points ------------------------------------------------------------------
-- shape expected by hgamemode/data/point_cl.lua:
--   PointsList[name] = { color, category, list = { {pos, ang}, ... } }

PointsList = PointsList or {}
PointsCategory = PointsCategory or {}

Point_Add = Point_Add or function(name,data)
	local info = PointsList[name]

	if not info then
		info = {list = {}}
		PointsList[name] = info
	end

	if type(data) == "table" then
		for k,v in pairs(data) do info[k] = v end
	end

	return info
end

-- sound helpers ----------------------------------------------------------------
-- sound.Emit lives in shlib/tier_2_world/sound/sound_cl.lua, which is a _cl file: it is
-- simply absent on the server. sound.EmitNET is not defined anywhere in this pack at all.
-- Both are still called from shared files, including under an explicit `if SERVER`:
--   hinit/weapons/tier_0_base/tier_0_sh.lua:   if SERVER then sound.Emit(...) end
--   hgame/tier_2_entities/melee/tier_0_base/tier_0_sh.lua:  sound.EmitNET(...)
-- which is the source of "attempt to call field 'Emit' (a nil value)" on the server.
--
-- The client half of that pipe does exist: sound_cl.lua has net.Receive("sound") and turns
-- the packet into sound.Emit, letting the receiving client apply its own DSP and its own
-- sound-travel delay (it even schedules the emit with timer.GameSimple for distance). So
-- the server side only has to send that packet, and its shape is whatever that receiver
-- reads: { ent, sndName, level, volume, pitch, pos, dsp, filter, chan }. Both helpers
-- forward into it rather than guessing at EmitSound's argument order.

if SERVER then
	-- nothing else in the pack registers this name, and net.Start throws on an unpooled
	-- name, so own it here.
	util.AddNetworkString("sound")

	sound.EmitNET = sound.EmitNET or function(ent,sndName,level,volume,pitch,pos,dsp,filter,chan)
		if not sndName then return end

		-- the receiver accepts either form, but a number survives WriteTable without
		-- pulling an entity along in the packet
		if IsEnt(ent) then ent = ent:EntIndex() end

		net.Start("sound")
			net.WriteTable({ent,sndName,level,volume,pitch,pos,dsp,filter,chan})
		net.Broadcast()

		return ent
	end

	sound.Emit = sound.Emit or function(ent,sndName,level,volume,pitch,pos,dsp,filter,chan)
		if not sndName then return end

		return sound.EmitNET(ent,sndName,level,volume,pitch,pos or (IsEnt(ent) and ent:GetPos()),dsp,filter,chan)
	end
else
	-- EmitNET is called from _sh files too, where the sensible thing on a client is simply
	-- to play the sound locally through the real implementation.
	sound.EmitNET = sound.EmitNET or function(ent,sndName,level,volume,pitch,pos,dsp,filter,chan)
		if not sndName or not sound.Emit then return end

		if IsEnt(ent) then ent = ent:EntIndex() end

		return sound.Emit(ent,sndName,level,volume,pitch,pos,dsp,filter,chan)
	end
end

-- ragdoll -> player ------------------------------------------------------------
-- Called from about twenty places on both realms and defined nowhere in this pack.
-- blood_cl.lua alone hits it from HUDPaint, which is why it spams "attempt to call
-- global 'RagdollOwner' (a nil value)" hundreds of times a frame.
-- Homigrad links a ragdoll back to its owner through the replicated "Controller"
-- entity -- fake/ragdoll/init_cl.lua does exactly `return self:GetNWEntity("Controller")`,
-- and weapon_handcuffs reads the same field. Returns nil for anything that is not a
-- ragdoll with a player controller, which is what every call site's
-- `RagdollOwner(x) or x` expects.

function RagdollOwner(ent)
	if not IsEnt(ent) then return end
	if ent:IsPlayer() or ent:IsNPC() then return end

	local owner = ent.GetNWEntity and ent:GetNWEntity("Controller")

	if IsEnt(owner) and owner:IsPlayer() then return owner end

	return nil
end

-- player -> controlled entity --------------------------------------------------
-- LocalPlayer():GetEntity() is called every Think by hgame/tier_1/wind_cl.lua (the wind
-- sound and the FOV kick) and by breath_cl.lua, the death screen, the spectate camera
-- and the inventory page. All six call sites throw "attempt to call method 'GetEntity'
-- (a nil value)" when it is missing -- the wind hook alone spams it 251 times a frame.
--
-- The method belongs to the fake/ragdoll module (fake/ragdoll/tier_0_sh.lua, where the
-- player-as-ragdoll class is registered). That module sits behind the whole hgame/ tree
-- in the loader, and the loader aborts the rest of an IncludeDir pass on the first file
-- that throws, so one bad file earlier in hgame/ leaves the method undefined for the
-- entire session. Define it on the base Player metatable here instead, next to the other
-- restored APIs, so it exists from shlib/ onwards whatever the fake module does.
--
-- The possessed body is published as "FakeRagdoll" (and on the older path as
-- "Ragdoll"); a player who is not possessing anything returns itself, which is what every
-- call site wants: they all do `ent == LocalPlayer()` / GetVelocity / GetNoDraw on it.

local PLAYER_MT = FindMetaTable("Player")

PLAYER_MT.GetEntity = PLAYER_MT.GetEntity or function(self)
	if not IsEnt(self) then return self end

	local rag = self.hgFakeRagdoll or self.FakeRagdoll

	if not IsEnt(rag) and self.GetNWEntity then
		rag = self:GetNWEntity("FakeRagdoll")

		if not IsEnt(rag) then rag = self:GetNWEntity("Ragdoll") end
	end

	return IsEnt(rag) and rag or self
end

-- hg.* helpers -----------------------------------------------------------------
-- Helpers that the fake/ragdoll halves call on the "hg" framework table and whose
-- defining file never shipped. All three sit on live paths:
--   hg.RateLimit           fake/sv/sv_fake.lua:32 -- the "fake" net receiver, so every
--                          press of the possession key threw "attempt to call field
--                          'RateLimit' (a nil value)" straight out of net.Incoming
--   hg.GetCurrentCharacter sv_fake.lua:52 (takes :GetPos of the body you control) and
--                          fake/cl/cl_fake.lua:18 (poses fingers on the ragdoll)
--   hg.RagdollOwner        main_sv.lua, and sv_fake.lua:464 literally does
--                          `RagdollOwner = hg.RagdollOwner`, which nils out the global
--                          above if this does not exist

hg = hg or {}

hg.RagdollOwner = function(ent)
	if not IsValid(ent) then return nil end
	if ent:IsPlayer() then return ent end
	if ent.RagdollOwner and IsValid(ent.RagdollOwner) then return ent.RagdollOwner end
	if ent.ragdollPly and IsValid(ent.ragdollPly) then return ent.ragdollPly end
	if ent.GetController then
		local c = ent:GetController()
		if IsValid(c) and c:IsPlayer() then return c end
	end
	if ent.GetNWEntity then
		local nw = ent:GetNWEntity("RagdollOwner")
		if IsValid(nw) and nw:IsPlayer() then return nw end
		nw = ent:GetNWEntity("RagdollController")
		if IsValid(nw) and nw:IsPlayer() then return nw end
		nw = ent:GetNWEntity("Controller")
		if IsValid(nw) and nw:IsPlayer() then return nw end
	end
	if ent.bull and IsValid(ent.bull.ply) then return ent.bull.ply end
	for _, ply in ipairs(player.GetAll()) do
		if ply.FakeRagdoll == ent or ply.hgFakeRagdoll == ent or (ply.GetDummy and ply:GetDummy() == ent) or (ply.GetNWEntity and ply:GetNWEntity("FakeRagdoll") == ent) then
			return ply
		end
	end
	return nil
end
RagdollOwner = hg.RagdollOwner

PLAYER_MT.InFake = PLAYER_MT.InFake or function(self)
	if not IsValid(self) then return false end
	return self.fake or self.Fake or (self.GetNWBool and (self:GetNWBool("fake", false) or self:GetNWBool("Fake", false))) or IsValid(self.FakeRagdoll) or IsValid(self.hgFakeRagdoll) or (self.GetDummy and IsValid(self:GetDummy())) or false
end

local DamageTabMeta = {}
DamageTabMeta.__index = DamageTabMeta

function DamageTabMeta:AddKill(reason)
	self.kills = self.kills or {}
	table.insert(self.kills, reason)
end

function DamageTabMeta:GetKills()
	return self.kills or {}
end

function DamageTabMeta:SetDamage(val)
	self.damage = tonumber(val) or 0
end

function DamageTabMeta:GetDamage()
	return self.damage or 0
end

function DamageTabMeta:SetDamageType(val)
	self.damageType = val or DMG_GENERIC
	self.dmgType = val or DMG_GENERIC
end

function DamageTabMeta:GetDamageType()
	return self.damageType or self.dmgType or DMG_GENERIC
end

function DamageTabMeta:SetAttacker(att)
	self.attacker = att
end

function DamageTabMeta:GetAttacker()
	return self.attacker
end

function DamageTabMeta:SetInflictor(inf)
	self.inflictor = inf
end

function DamageTabMeta:GetInflictor()
	return self.inflictor
end

function DamageTabMeta:SetDamagePosition(pos)
	self.pos = pos
end

function DamageTabMeta:GetDamagePosition()
	return self.pos
end

function DamageTabMeta:SetDamageForce(force)
	self.force = force
end

function DamageTabMeta:GetDamageForce()
	return self.force
end

function CreateDamageTab(target, attacker, inflictor, damage, damageType)
	local tab = setmetatable({
		target = target,
		ent = target,
		attacker = attacker,
		inflictor = inflictor,
		damage = tonumber(damage) or 0,
		damageType = damageType or DMG_GENERIC,
		dmgType = damageType or DMG_GENERIC,
		pos = IsValid(target) and target:GetPos() or vector_origin,
		force = Vector(0, 0, 0),
		kills = {},
		pain = 0,
		bleed = 0,
	}, DamageTabMeta)
	return tab
end

local function ApplyDamageTab(ent, dmgTab, reasons)
	if not IsValid(ent) or not istable(dmgTab) then return end

	local damage = dmgTab.damage or (dmgTab.GetDamage and dmgTab:GetDamage()) or 0
	local dmgType = dmgTab.damageType or (dmgTab.GetDamageType and dmgTab:GetDamageType()) or DMG_GENERIC
	local attacker = dmgTab.attacker or (dmgTab.GetAttacker and dmgTab:GetAttacker()) or ent
	local inflictor = dmgTab.inflictor or (dmgTab.GetInflictor and dmgTab:GetInflictor()) or attacker
	local pos = dmgTab.pos or (dmgTab.GetDamagePosition and dmgTab:GetDamagePosition()) or ent:GetPos()
	local force = dmgTab.force or (dmgTab.GetDamageForce and dmgTab:GetDamageForce()) or vector_origin

	if ent:GetClass() == "prop_ragdoll" then
		local ply = hg.RagdollOwner(ent)
		if IsValid(ply) and ply ~= ent and ply:Alive() then
			if isvector(force) and force ~= vector_origin then
				local phys = ent:GetPhysicsObject()
				if dmgTab.bone and ent:TranslateBoneToPhysBone(dmgTab.bone) then
					phys = ent:GetPhysicsObjectNum(ent:TranslateBoneToPhysBone(dmgTab.bone)) or phys
				end
				if IsValid(phys) then
					phys:ApplyForceOffset(force * 50, pos)
				end
			end
			return ply:TakeDamageTab(dmgTab, reasons)
		end
	end

	if SERVER then
		if ent:IsPlayer() then
			if not ent:Alive() or ent:HasGodMode() then return end

			local pain = dmgTab.pain or dmgTab.dmgPain or (damage * 1.2)
			local bleed = dmgTab.bleed or dmgTab.dmgBleed or (damage > 20 and (damage * 0.1) or 0)
			if pain and pain > 0 then
				local curPain = ent:GetNWFloat("pain", 0) + pain
				ent:SetNWFloat("pain", curPain)
				if curPain > 180 and not ent:GetNWBool("Otrub", false) then
					ent:SetNWBool("Otrub", true)
				end
			end
			if bleed and bleed > 0 then
				local curBleed = ent:GetNWFloat("bleed", 0) + bleed
				ent:SetNWFloat("bleed", curBleed)
			end

			local kills = dmgTab.kills or (dmgTab.GetKills and dmgTab:GetKills())
			if (reasons and table.HasValue(reasons, "killyourself")) or (kills and table.HasValue(kills, "killyourself")) then
				ent:Kill()
				return
			end

			local dinfo = DamageInfo()
			dinfo:SetDamage(damage)
			dinfo:SetDamageType(dmgType)
			dinfo:SetAttacker(IsValid(attacker) and attacker or ent)
			dinfo:SetInflictor(IsValid(inflictor) and inflictor or ent)
			dinfo:SetDamagePosition(pos)
			dinfo:SetDamageForce(force)
			ent:TakeDamageInfo(dinfo)

			if ent:Health() <= damage and ent:Alive() then
				ent:Kill()
			end
		else
			local dinfo = DamageInfo()
			dinfo:SetDamage(damage)
			dinfo:SetDamageType(dmgType)
			dinfo:SetAttacker(IsValid(attacker) and attacker or ent)
			dinfo:SetInflictor(IsValid(inflictor) and inflictor or ent)
			dinfo:SetDamagePosition(pos)
			dinfo:SetDamageForce(force)
			ent:TakeDamageInfo(dinfo)
		end
	end
end

local ENTITY_MT = FindMetaTable("Entity")
ENTITY_MT.TakeDamageTab = ENTITY_MT.TakeDamageTab or ApplyDamageTab
PLAYER_MT.TakeDamageTab = PLAYER_MT.TakeDamageTab or ApplyDamageTab

-- the body the player is actually controlling: the possessed ragdoll while the fake
-- system owns it, otherwise the player itself
hg.GetCurrentCharacter = hg.GetCurrentCharacter or function(ply)
	if not IsEnt(ply) then return end

	return ply.GetEntity and ply:GetEntity() or ply
end

-- Net anti-spam: true while the player may do "key" again. Server only -- it gates
-- incoming net messages, and the call sites that run on the client check for it first.
if SERVER then
	local LIMITS = setmetatable({},{__mode = "k"})

	hg.RateLimit = hg.RateLimit or function(ply,key,seconds)
		if not IsEnt(ply) then return false end

		key = tostring(key)
		seconds = tonumber(seconds) or 1

		local times = LIMITS[ply]

		if not times then
			times = {}
			LIMITS[ply] = times
		end

		local now = CurTime()
		local nextTime = times[key]

		if nextTime and nextTime > now then return false end

		times[key] = now + seconds

		return true
	end
end

-- player -> dummy body ---------------------------------------------------------
-- The entity that stands in for the player while the fake/ragdoll system owns the body.
-- fake/sv sets it on every state change (main_sv.lua:SetFakeState, which is on the spawn
-- path) and fake/cl reads it to find the body to take hand-bone positions from
-- (main_cl.lua:fakeRag). Both halves are called on the very first respawn, so a missing
-- method is not a rare failure: it is "attempt to call method 'SetDummy' (a nil value)"
-- out of the Spawn hook, every round, and it aborts the rest of that spawn.
--
-- The real definition lived in a file that did not ship, so this keeps the contract the
-- two call sites already assume: store the entity locally and publish it through an NW
-- slot so the client half sees exactly what the server set, and answer with the live
-- entity or nil (never an invalid one).
local PLAYER_DUMMY_NW = "hgDummy"

PLAYER_MT.SetDummy = PLAYER_MT.SetDummy or function(self,ent)
	if not IsEnt(self) then return end

	if not IsEnt(ent) then ent = nil end

	self.hgDummy = ent

	if self.SetNWEntity then self:SetNWEntity(PLAYER_DUMMY_NW,ent or NULL) end

	return ent
end

PLAYER_MT.GetDummy = PLAYER_MT.GetDummy or function(self)
	if not IsEnt(self) then return end

	local dummy = self.hgDummy

	if not IsEnt(dummy) and self.GetNWEntity then
		dummy = self:GetNWEntity(PLAYER_DUMMY_NW)

		if IsEnt(dummy) then self.hgDummy = dummy end
	end

	return IsEnt(dummy) and dummy or nil
end

-- ragdoll -> controlling player -------------------------------------------------
-- fake/main_sv.lua:355 links a freshly spawned ragdoll back to its owner with
--   rag:SetController(self)
-- and four places read it back: main_sv.lua:366 (the CallOnRemove cleanup) and :989
-- (the corpse path, itself written defensively as `if rag.SetController then ...`),
-- fake/ragdoll/init_cl.lua:10/:32 (ENT:GetPlayer and the render path) and
-- fake/ragdoll/tier_0_sh.lua:46 (ENT:Eye). The file that defined it never shipped, so
-- the very first fake spawn threw "attempt to call method 'SetController' (a nil value)"
-- out of sv_fake's net receiver.
--
-- main_sv.lua:356 already writes the same link by hand into the replicated
-- "RagdollController" slot, and init_cl.lua:10 reads "Controller" on other paths, so
-- keep the value locally and mirror it into the NW slot: that makes it work on the
-- server (where SetController is called) and on the client (where GetController is).

local ENTITY_MT = FindMetaTable("Entity")

ENTITY_MT.SetController = ENTITY_MT.SetController or function(self,owner)
	if not IsEnt(self) then return end

	if not IsEnt(owner) then owner = nil end

	self.hgController = owner

	if self.SetNWEntity then self:SetNWEntity("RagdollController",owner or NULL) end

	return owner
end

ENTITY_MT.GetController = ENTITY_MT.GetController or function(self)
	if not IsEnt(self) then return end

	local owner = self.hgController

	if not IsEnt(owner) then
		if self.GetNWEntity then owner = self:GetNWEntity("RagdollController") end

		if not IsEnt(owner) and self.GetNWEntity then owner = self:GetNWEntity("Controller") end
	end

	return IsEnt(owner) and owner or nil
end

-- PVS ("per-viewer") entity variables ---------------------------------------------
-- Homigrad's own PVSVar interface existed in files that never shipped, but the
-- fake/ragdoll halves are built on it:
--   main_sv.lua:359-360  rag:SetPVSVar("IsFakeRagdoll",true) / ("PlayerColor",color)
--   init_cl.lua:24       ENT:GetPlayerColor -> GetPVSVar("PlayerColor",Vector(1,1,1))
--   init_cl.lua:101      ent:ProxyPVSVar("IsFakeRagdoll",cb) -> runs setup(ent) once
-- The real thing only pushed a value to clients that had the entity in their PVS;
-- nothing in the pack depends on that narrowing. main_sv.lua:361-362 already writes the
-- same two values into plain NW slots, and every reader falls back to those, so back the
-- interface with NW vars: same names, same data, visible on both realms.

local function PVS_Key(key) return tostring(key) end

ENTITY_MT.SetPVSVar = ENTITY_MT.SetPVSVar or function(self,key,value)
	if not IsEnt(self) or key == nil then return end

	key = PVS_Key(key)

	self.hgPVSVars = self.hgPVSVars or {}
	self.hgPVSVars[key] = value

	if isbool(value) then self:SetNWBool(key,value)
	elseif isstring(value) then self:SetNWString(key,value)
	elseif isvector(value) then self:SetNWVector(key,value)
	elseif isangle(value) then self:SetNWAngle(key,value)
	elseif isnumber(value) then self:SetNWFloat(key,value)
	elseif IsEnt(value) then self:SetNWEntity(key,value) end

	return value
end

ENTITY_MT.GetPVSVar = ENTITY_MT.GetPVSVar or function(self,key,default)
	if not IsEnt(self) or key == nil then return default end

	key = PVS_Key(key)

	local cache = self.hgPVSVars

	if cache and cache[key] ~= nil then return cache[key] end

	-- The NW slot is the replicated copy. Read the getter that matches the caller's
	-- fallback first; with no fallback at all, probe the types the pack actually uses
	-- (booleans from Init/SetFakeState, vectors from PlayerColor).
	if isbool(default) then
		local value = self:GetNWBool(key,default)
		if value ~= default then return value end
	elseif isvector(default) then
		local value = self:GetNWVector(key,nil)
		if value ~= nil then return value end
	elseif isangle(default) then
		local value = self:GetNWAngle(key,nil)
		if value ~= nil then return value end
	elseif isstring(default) then
		local value = self:GetNWString(key,nil)
		if value ~= nil then return value end
	elseif isnumber(default) then
		local value = self:GetNWFloat(key,default)
		if value ~= default then return value end
	elseif IsEnt(default) then
		local value = self:GetNWEntity(key,nil)
		if IsEnt(value) then return value end
	else
		if self:GetNWBool(key,false) then return true end

		local vec = self:GetNWVector(key,nil)
		if vec ~= nil then return vec end

		local str = self:GetNWString(key,nil)
		if str ~= nil then return str end

		local num = self:GetNWFloat(key,nil)
		if num ~= nil then return num end

		local ent = self:GetNWEntity(key,nil)
		if IsEnt(ent) then return ent end
	end

	return default
end

-- The value arrives with the entity's NW data, i.e. *after* EntityCreate, so a proxy
-- registered from init_cl.lua:101 cannot fire at registration time. Watch the registered
-- entities from a Think hook instead and fire on each change -- init_cl's callback is
-- idempotent (it early-outs once the ragdoll is in ragdollManager.entities).
if CLIENT then
	local PVS_PROXIES = setmetatable({},{__mode = "k"})

	ENTITY_MT.ProxyPVSVar = ENTITY_MT.ProxyPVSVar or function(self,key,func)
		if not IsEnt(self) or key == nil or not isfunction(func) then return end

		local proxies = PVS_PROXIES[self]

		if not proxies then
			proxies = {}
			PVS_PROXIES[self] = proxies
		end

		proxies[PVS_Key(key)] = func
	end

	hook.Add("Think","HG PVSVar Proxies",function()
		for ent,proxies in pairs(PVS_PROXIES) do
			if not IsEnt(ent) then continue end

			for key,func in pairs(proxies) do
				local value = ent:GetPVSVar(key)
				if value == nil then continue end

				ent.hgPVSFired = ent.hgPVSFired or {}
				if ent.hgPVSFired[key] == value then continue end

				ent.hgPVSFired[key] = value

				local ok,err = pcall(func,ent,key,value)
				if not ok then Msg("[hg pvs proxy] " .. tostring(err) .. "\n") end
			end
		end
	end)
end

-- finger posing ----------------------------------------------------------------
-- fake/cl/cl_fake.lua:16-28 asks the framework to curl the ragdoll's fingers every
-- PlayerThink (`framework.bone.Set(ent,"l_finger0",... , speed)`). `hg.bone` never
-- shipped, so the call site's own guard turns the pose into a no-op and the hands stay
-- splayed. The short names it uses are homigrad's (`l_finger0`), not ValveBiped's, so
-- resolve them against the skeleton before manipulating.

local function resolveBone(ent,name)
	local id = ent:LookupBone(name)
	if id and id >= 0 then return id end

	local want = tostring(name):lower()
	local short = want:gsub("^valvebiped%.bip01_","")

	for i = 0,ent:GetBoneCount() - 1 do
		local bone = ent:GetBoneName(i)
		if not bone then continue end

		local lower = bone:lower()

		if lower == want then return i end
		if lower:gsub("^valvebiped%.bip01_","") == short then return i end
	end
end

hg.bone = hg.bone or {}

hg.bone.Set = hg.bone.Set or function(ent,name,pos,ang,scale,speed)
	if not IsEnt(ent) then return end

	local id = resolveBone(ent,name)
	if id == nil then return end

	if isvector(pos) then ent:ManipulateBonePosition(id,pos) end
	if isangle(ang) then ent:ManipulateBoneAngles(id,ang) end
	if isnumber(scale) then ent:ManipulateBoneScale(id,Vector(scale,scale,scale)) end
end

-- fake ragdoll draw LOD ---------------------------------------------------------
-- fake/ragdoll/init_cl.lua:25 draws the body through the custom renderer and asks a
-- missing helper first:
--   function ENT:Draw(flags)
--       DeterminateLODFirst(self)                       -- :27, threw "attempt to call
--       if not self.renderLOD2_5 then return end        --     global" every frame
--       if not self.renderLOD2 then self:DrawModel() return end
--       ... RenderLocalPlayer / RenderPlayer + weapon on the hand
-- So the helper only has to publish two flags, and the levels read the way the names
-- suggest: renderLOD2_5 == false skips the body entirely (far away), renderLOD2 ==
-- false keeps it but drops to a plain DrawModel (no head pop, no weapon in hand).
-- The cutoff is deliberately far (6000 units ~ 114 m) so a corpse you can actually see
-- never stops being drawn, and matches the pack's own lod_TransitionDist taste
-- (hgamemode/.../settings/graphis_cl.lua sets it to 2000) for the full-quality band.
-- Your own body ignores both: you are inside it, and RenderLocalPlayer is what pops the
-- head so it does not block the view.
if CLIENT then
	local RAGDOLL_FULL_LOD_DIST = 2000
	local RAGDOLL_DRAW_LOD_DIST = 6000
	local RAGDOLL_FULL_LOD_DIST_SQR = RAGDOLL_FULL_LOD_DIST * RAGDOLL_FULL_LOD_DIST
	local RAGDOLL_DRAW_LOD_DIST_SQR = RAGDOLL_DRAW_LOD_DIST * RAGDOLL_DRAW_LOD_DIST

	function DeterminateLODFirst(ent)
		if not IsEnt(ent) then return end

		if ent.GetController and ent:GetController() == LocalPlayer() then
			ent.renderLOD2_5 = true
			ent.renderLOD2 = true

			return
		end

		local distSqr = ent:GetPos():DistToSqr(EyePos())

		ent.renderLOD2_5 = distSqr <= RAGDOLL_DRAW_LOD_DIST_SQR
		ent.renderLOD2 = distSqr <= RAGDOLL_FULL_LOD_DIST_SQR
	end

	-- fake ragdoll player render --------------------------------------------------
	-- The two calls right after the LOD gate in fake/ragdoll/init_cl.lua:36-39 are the
	-- same story -- helpers that never shipped:
	--   RenderLocalPlayer(self,nil,owner,flags)   -- your own body (owner == LocalPlayer())
	--   RenderPlayer(self,nil,owner,flags)        -- everybody else's
	-- They were the shlib "draw this entity as a player" entry points, and the rest of
	-- that pipeline is present and only needs kicking: playerdrawing_cl.lua registers
	-- event "PlayerDraw" ("SetupBones" at -20, "Main" at 10 -> SetEyeTarget + DrawModel),
	-- bones_cl.lua registers its BoneManager on the same event, and the real player
	-- entity reaches it through `ply.RenderOverride = function(self,flags)
	-- event.Run("PlayerDraw",ply) end` (playerdrawing_cl.lua:15-24). So run the same
	-- event for the body, and fall back to a plain DrawModel if it ever has no handlers.

	local function PlayerDrawHandlers()
		local ev = event_list and event_list["PlayerDraw"]
		local list = ev and ev.list

		return istable(list) and #list > 0
	end

	local function DrawAsPlayer(ent,tag,flags)
		if PlayerDrawHandlers() then
			event.Run("PlayerDraw",ent,tag)
		else
			ent:DrawModel(flags)
		end
	end

	function RenderPlayer(ent,tag,ply,flags)
		if not IsEnt(ent) then return end

		DrawAsPlayer(ent,tag,flags)
	end

	-- Local player in first-person fake state hides head only to avoid camera clipping while alive.
	-- When head explodes or player dies, head remains visible (no disappearance).
	function RenderLocalPlayer(ent,tag,ply,flags)
		if not IsEnt(ent) then return end

		local isAliveLocal = IsValid(ply) and ply == LocalPlayer() and ply:Alive() and not ply:GetNWBool("isDead",false) and not ply:GetNWBool("FakeDeath",false)
		local hideHead = isAliveLocal and (ent.r_headPop or event.Call("RenderLocalPlayerHead",ply or ent))
		local head = hideHead and resolveBone(ent,"ValveBiped.Bip01_Head1")

		if not head then
			DrawAsPlayer(ent,tag,flags)

			return
		end

		ent:ManipulateBoneScale(head,Vector(0.001,0.001,0.001))
		DrawAsPlayer(ent,tag,flags)
		ent:ManipulateBoneScale(head,Vector(1,1,1))
	end
end

-- armour -----------------------------------------------------------------------
-- Player classes (homicide police/CT) call Armor_Equip from shared code, but the
-- half of homigrad/hgame/tier_1/armor that defined it lived in a file that never
-- shipped. The data model itself is fully visible in cl_armor.lua:
--   ply.Armors      -> replicated NWTable "Armor", { [id] = {name = class, col = color} }
--   ply.ArmorsSpecs -> ArmorListClasses entries merged per worn piece

Armor_GetBuildSpecsFromArmors = Armor_GetBuildSpecsFromArmors or function(armors)
	local specs = {}

	for id,item in pairs(armors) do
		local spec = ArmorListClasses[item.name]
		if not spec then continue end

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

function Armor_Sync(ply)
	if not IsValid(ply) then return end
	local armors = ply.Armors or {}

	ply.Armors = armors
	ply.ArmorsSpecs = Armor_GetBuildSpecsFromArmors(armors)

	if SERVER then
		ply:SetNWTable("Armor",armors)
	end
end
_G.Armor_Sync = Armor_Sync

Armor_Equip = Armor_Equip or function(ply,armorClass,col)
	if not IsEnt(ply) then return end

	-- Player classes hand this either the display name ("Medium-Vest") or the entity class
	-- a piece registers as ("ent_jack_gmod_ezarmor_thorcrv" -- police_sh, and the dm/riot
	-- levels' spawn tables). Armor_GetValidName is the pack's own mapping between the two,
	-- and the worn table has to hold the *display* name: every reader indexes
	-- ArmorListClasses by it (Armor_GetItemInSlot for the scoreboard inventory).
	if Armor_GetValidName then armorClass = Armor_GetValidName(armorClass) end

	local spec = ArmorListClasses[armorClass]
	if not spec then return end

	ply.Armors = ply.Armors or {}

	-- a piece that would cover an already worn slot is refused, same rule as
	-- Armor_GetAreSlotsClear
	if Armor_GetAreSlotsClear then
		local clear = Armor_GetAreSlotsClear(ply.Armors,armorClass)

		if not clear then return end
	end

	local id = 1
	while ply.Armors[id] do id = id + 1 end

	-- The worn entry is the piece's live state, not just its name: the inventory page reads
	-- itemData.dur / itemData.chrg straight out of here (inventory_cl.lua -> CreateSlot),
	-- so a bare {name,col} entry makes that arithmetic fail and the piece never draws.
	local chrg = {}

	for resource,maxAmount in pairs(spec.chrg or {}) do
		chrg[resource] = maxAmount
	end

	ply.Armors[id] = {
		name = armorClass,
		col = col,
		dur = spec.dur,
		chrg = chrg
	}

	Armor_Sync(ply)
end

if SERVER then
	-- The client asks for the table itself on spawn (cl_armor.lua: "Player Spawn");
	-- sending it from here as well means a spawn whose armour was handed out by a player
	-- class before the client had the chunks cannot end up with an empty inventory page.
	hook.Add("PlayerSpawn","Armor Sync",function(ply)
		timer.Simple(1,function()
			if not IsEnt(ply) then return end

			Armor_Sync(ply)
		end)
	end)
end

-- admin gate used by the homigrad map manager UI
COMMANDS_ISADMIN = COMMANDS_ISADMIN or function(ply)
	if not IsEnt(ply) then return false end
	if ply:IsAdmin() then return true end

	if AdminPanelRole_HasSuccess and AdminPanelRole_HasSuccess(ply,"admin") then return true end

	return false
end

-- entity copy/paste ------------------------------------------------------------

function EntCopy(ent)
	if not IsEnt(ent) then return end

	local data = {
		class = ent:GetClass(),
		pos = ent:GetPos(),
		ang = ent:GetAngles(),
	}

	if ent.GetModel then data.model = ent:GetModel() end
	if ent.GetSkin then data.skin = ent:GetSkin() end

	local color = ent.GetColor and ent:GetColor()
	if color and color ~= Color(255,255,255,255) then data.color = color end

	if ent.GetBodygroup then
		local bodygroups = {}

		for i = 0,16 do
			local bodygroup = ent:GetBodygroup(i)
			if not bodygroup or bodygroup == 0 then break end

			bodygroups[i] = bodygroup
		end

		if next(bodygroups) then data.bodygroups = bodygroups end
	end

	if ent.GetNumSubMaterials and ent.GetSubMaterial then
		local subs = {}

		for i = 0,ent:GetNumSubMaterials() - 1 do
			subs[i] = ent:GetSubMaterial(i)
		end

		if next(subs) then data.sub = subs end
	end

	return data
end

function EntPaste(data)
	if type(data) ~= "table" or not data.class then return end

	local ent = ents.Create(data.class)
	if not IsEnt(ent) then return end

	if data.model and ent.SetModel then ent:SetModel(data.model) end

	if data.sub and ent.SetSubMaterial then
		for i,sub in pairs(data.sub) do ent:SetSubMaterial(i,sub) end
	end

	ent:SetPos(data.pos or Vector(0,0,0))
	ent:SetAngles(data.ang or Angle(0,0,0))

	ent:Spawn()

	if data.skin and ent.SetSkin then ent:SetSkin(data.skin) end

	if data.bodygroups and ent.SetBodygroup then
		for i,bodygroup in pairs(data.bodygroups) do ent:SetBodygroup(i,bodygroup) end
	end

	if data.color then ent:SetColor(data.color) end

	ent:Activate()

	return ent
end