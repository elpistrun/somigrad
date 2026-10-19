-- Server dispatch for the class command layer.
--
-- Clients send "mutator_cmd" / "event_plugin_cmd" (both wire formats are defined in
-- the client halves: Mutator:SendCMD / Plugin:SendCMD). The matching net.Receive lived
-- in a server-only file that was never recovered, so the commands registered through
-- AddCMD could not be reached. This is that receiver.

if not SERVER then return end

util.AddNetworkString("mutator_cmd")
util.AddNetworkString("event_plugin_cmd")

local xpcall = xpcall

local function errorHandler(err)
	ErrorNoHaltWithStack(tostring(err))

	return true
end

local function CanCommand(ply)
	if not IsValid(ply) then return false end
	if ply:IsAdmin() then return true end

	-- root role holders always pass, everyone else needs the "admin" success
	if AdminPanelRole_HasSuccess and AdminPanelRole_HasSuccess(ply,"admin") then return true end

	return false
end

-- prefers the live instance, falls back to the registered class content
local function getInstance(className, classes, active)
	local instance = active and active[className]

	if IsValid(instance) then return instance end

	local class = classes and classes[className]

	return class and class[1] or nil
end

local function runCMD(instance, cmdName, ply, args)
	if not instance or not instance.RunCMD then return end

	xpcall(function()
		return instance:RunCMD(cmdName,ply,args)
	end, errorHandler)
end

net.Receive("mutator_cmd", function(length, ply)
	if not CanCommand(ply) then return end

	local className = net.ReadString()
	local cmdName = net.ReadString()
	local args = net.ReadTable() or {}

	runCMD(getInstance(className, MutatorClasses, ActiveMutators), cmdName, ply, args)
end)

net.Receive("event_plugin_cmd", function(length, ply)
	if not CanCommand(ply) then return end

	local className = net.ReadString()
	local cmdName = net.ReadString()
	local args = net.ReadTable() or {}

	runCMD(getInstance(className, EventPluginsClasses, EventPlugins), cmdName, ply, args)
end)