-- Server half of the homigrad init protocol.
--
-- The client half (init_protocol_cl.lua) runs a strict handshake:
--   waitSourceReady -> waitResponseFromServer -> sendingData -> waitReadyFromServer -> setupWorld -> ready
-- and only sets InitNET = true at the very end. glua-steal only ships AddCSLuaFile'd
-- files, so this server half was never recovered: nobody answered "initProtocol" and
-- every client hung forever on the loading screen showing "waitSourceReady".
--
-- It also mattered more than just the loading screen: init_sh.lua gates Move/SetupMove/
-- FinishMove/Player Think on ply.init and overrides Player:Alive() with a NWBool, and
-- only this file ever set those. Without it the whole gamemode stayed inert on the server.

print("[init_protocol_sv] server half loaded")

util.AddNetworkString("initProtocol")
util.AddNetworkString("ply spawn")

local STAGE_DATA   = 1 -- client asked for the server payload
local STAGE_READY  = 2 -- client finished uploading its own payload
local STAGE_START  = 3 -- client set up the world and is ready to play

-- The gamemode server half normally picks a class model and drops the player at a
-- spawn point. That half was never recovered, so the entity keeps whatever the
-- engine gave it and renders wrong right in front of the camera. These are stock
-- HL2 models that ship with the game, so they always resolve.
local DEFAULT_MODEL  = "models/player/group01/male_01.mdl"
local DEFAULT_MODEL_F = "models/player/group01/female_01.mdl"

local stages = {}

local function answer(ply)
	net.Start("initProtocol")
	net.Send(ply)
end

-- Everything the gamemode waits for before it starts touching a player.
local function finishSetup(ply)
	if not IsValid(ply) or ply.init then return end

	ply:SetNWBool("Alive", true)
	ply.init = true

	event.Call("Player Create", ply)

	-- give the entity a model that actually exists and place it on a spawn point,
	-- otherwise the camera ends up inside an unsolid/error model
	local model = ply:GetModel()

	if not model or model == "" or model == "models/error.mdl" then
		model = ply:GetGender() == GENDER_FEMALE and DEFAULT_MODEL_F or DEFAULT_MODEL
	end

	ply:SetModel(model)
	ply:Spawn()

	ply:RemoveAllDecals()

	event.Call("Player Spawn", ply)

	-- Let the client run its own "Setup World" for every player it knows about.
	net.Start("ply spawn")
		net.WriteEntity(ply)
	net.Send(ply)
end

net.Receive("initProtocol", function(length, ply)
	if not IsValid(ply) then return end

	stages[ply] = (stages[ply] or 0) + 1

	local stage = stages[ply]

	if stage == STAGE_DATA then
		-- Hand over whatever the gamemode wants the client to know about before the
		-- world is built. Missing server halves have nothing to send yet.
		event.Call("Send Data To Client", ply)
	elseif stage == STAGE_READY then
		event.Call("Ready Data", ply)
	elseif stage >= STAGE_START then
		finishSetup(ply)
	end

	-- Every stage ends with "initProtocol" back to the client, that is the only
	-- signal the client state machine reacts to.
	answer(ply)
end)

hook.Add("PlayerDisconnected", "InitProtocol", function(ply)
	stages[ply] = nil
end)

-- init_sh.lua overrides Player:Alive() with this exact NWBool, so it has to be set
-- before anything (client HUD included) asks.
hook.Add("PlayerInitialSpawn", "InitProtocol", function(ply)
	if not IsValid(ply) then return end

	ply:SetNWBool("Alive", true)
end)