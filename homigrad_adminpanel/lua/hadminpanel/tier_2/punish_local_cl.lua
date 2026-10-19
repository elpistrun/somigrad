--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_adminpanel/lua/hadminpanel/tier_2/punish_local_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:11 <
]]

-- Списки банов/гагов/мутов приезжали из внешней БД через Create_SyncDataManager,
-- которой в сборке нет. Сервер (command_local_sv.lua) присылает их сам тем,
-- у кого есть право ban_list.

net.Receive("hg_ap_punish_sync",function()
    local size = net.ReadUInt(32)
    local data = util.Decompress(net.ReadData(size))
    if not data then return end

    local punish = util.JSONToTable(data)
    if not punish then return end

    AdminPanelBanList = punish.ban or {}
    AdminPanelGagList = punish.gag or {}
    AdminPanelMuteList = punish.mute or {}
    AdminPanelWarnList = punish.warn or {}

    event.Call("AP Ban List Sync")
    event.Call("AP Gag List Sync")
    event.Call("AP Mute List Sync")
    event.Call("AP Warn List Sync")
end)

