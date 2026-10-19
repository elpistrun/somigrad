--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_0/tier_0/player/msg_cl.lua <
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

-- "addons\\homigrad_core\\lua\\shlib\\tier_0\\tier_0\\player\\msg_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local PLAYER = FindMetaTable("Player")

net.Receive("console print",function() print(net.ReadString()) end)

net.Receive("chat print",function()
    local lply = LocalPlayer()
    if not lply.ChatPrint then return end--wtf

    LocalPlayer():ChatPrint(net.ReadString())
end)

net.Receive("notify print",function()
    notification.AddLegacy(net.ReadString(),net.ReadInt(16),net.ReadInt(16))
end)

function PLAYER:ConsolePrint(text)
    if self ~= LocalPlayer() then return end--lol

    print(text)
end

net.Receive("msgcall",function()
    MsgC(unpack(net.ReadTable()))
end)

net.Receive("chataddtext",function()
    chat.AddText(unpack(net.ReadTable()))
end)
