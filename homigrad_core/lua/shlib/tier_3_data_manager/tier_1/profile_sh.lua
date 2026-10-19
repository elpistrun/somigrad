--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_3_data_manager/tier_1/profile_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_3_data_manager\\tier_1\\profile_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
Profiles = Profiles or {}

if CLIENT then
    net.ReceiveMediaToken("profile_sync",function(body)
        for steamid,info in pairs(util.JSONToTableUnLimit(body,true)) do
            Profiles[steamid] = info
            event.Call("Profile Sync",steamid,info)
        end
    end)
end

local PLAYER = FindMetaTable("Player")

function PLAYER:GetAvatar()
    local steamid = self:SteamID()
    local profile = Profiles[steamid]

    return profile and profile.avatar
end

function PLAYER:GetAvatarFrame()
    local steamid = self:SteamID()
    local profile = Profiles[steamid]

    return profile and profile.avatarFrame
end

function PLAYER:GetBackground()
    local steamid = self:SteamID()
    local profile = Profiles[steamid]

    return profile and profile.background
end

function PLAYER:GetBackgroundOpacity()
    local steamid = self:SteamID()
    local profile = Profiles[steamid]

    return profile and profile.backgroundOpacity or 1
end

function PLAYER:GetBackgroundY()
    local steamid = self:SteamID()
    local profile = Profiles[steamid]

    return profile and profile.backgroundY or 0.5
end
