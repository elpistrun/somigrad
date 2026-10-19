--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/levels/_special/event/tier_1_system/init_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\levels\\_special\\event\\tier_1_system\\init_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
AdminPanelSuccessReg("eventplaning_access",nil,"rights")
AdminPanelSuccessReg("eventplaning_moderator",nil,"rights")

function Event_IsAdmin(ply)
    if not IsValid(ply) then return true end
    if ply:IsSuperAdmin() or ply:IsAdmin() then return true end

    if AdminPanelRole_HasSuccess and (AdminPanelRole_HasSuccess(ply, "admin") or AdminPanelRole_HasSuccess(ply, "rcon") or AdminPanelRole_HasSuccess(ply, "eventplaning_access")) then
        return true
    end
    if ply.HasSuccess and (ply:HasSuccess("admin") or ply:HasSuccess("rcon") or ply:HasSuccess("eventplaning_access")) then
        return true
    end

    local group = string.lower(ply:GetUserGroup() or "")
    if group == "superadmin" or group == "admin" or group == "root" or group == "owner" or group == "dadmin" or group == "operator" or group == "moderator" or group == "curator" or group == "headadmin" then
        return true
    end

    if ULib and ULib.ucl and ULib.ucl.query and (ULib.ucl.query(ply, "ulx rcon") or ULib.ucl.query(ply, "ulx kick")) then
        return true
    end
    if CAMI and isfunction(CAMI.PlayerHasAccess) then
        local has = false
        pcall(CAMI.PlayerHasAccess, ply, "Homigrad Admin", function(res) has = res end)
        if has then return true end
    end

    return false
end

function Event_CanAccess(steamid,checkHired,event)
    local ply = steamid
    if TypeID(steamid) == TYPE_ENTITY then
        if Event_IsAdmin(ply) then return true end
        steamid = steamid:SteamID()
    end

    event = event or Event_Claimed
    if not event then return false end

    return (event.owner and event.owner.steamid == steamid) or (event.friends and event.friends[steamid] and true) or false
end

Event_PlaningLimit = {
    dadmin = {6, 60 * 60 * 12},
    operator = {3, 60 * 60 * 12}
}

EventCanHelpHiredAdmins = false

if SERVER then return end

net.Receive("event_claimed_info",function()
    Event_Claimed = net.ReadTable()
    Event_ClaimedID = tonumber(net.ReadString())

    if not Event_ClaimedID then Event_Claimed = nil return end

    event.Run("Event Claimed Info Updated")
end)
