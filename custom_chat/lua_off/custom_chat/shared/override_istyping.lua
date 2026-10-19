--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/custom_chat/lua/custom_chat/shared/override_istyping.lua <
    > Callstack: addons/custom_chat/lua/autorun/sh_custom_chat.lua:200 <
]]

-- "addons\\custom_chat\\lua\\custom_chat\\shared\\override_istyping.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
-- Restore the "hands on the ear"
-- behaviour from the default chat.
local PLAYER = FindMetaTable( "Player" )

PLAYER.DefaultIsTyping = PLAYER.DefaultIsTyping or PLAYER.IsTyping

function PLAYER:IsTyping()
    return self:GetNWBool( "IsTyping", false )
end

if SERVER then
    util.AddNetworkString( "customchat.is_typing" )

    net.Receive( "customchat.is_typing", function( _, ply )
        ply:SetNWBool( "IsTyping", net.ReadBool() )
    end )
end

