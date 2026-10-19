--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_0/tier_0/net/net_incoming_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_0\\tier_0\\net\\net_incoming_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Receivers = net.Receivers
local net_ReadHeader = net.ReadHeader
local util_NetworkIDToString = util.NetworkIDToString

local string_lower = string.lower

net.Incoming = function(len)
	local strName = util_NetworkIDToString(net_ReadHeader())
	if not strName then return end

	local func = Receivers[string_lower(strName)]
	if not func then ErrorNoHalt("net unkown channel: " .. string_lower(strName) .. "\n") return end
	
	func(len - 16)//я богатый парень маладой. ой ой
end
