--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/levels/_special/event/tier_1_system/plan/init_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
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

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\levels\\_special\\event\\tier_1_system\\plan\\init_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
Event_Planing = Event_Planing or {}

DataBase = DataBase or {}
if not DataBase.Read then
    function DataBase:Read(req)
        if istable(req) and isfunction(req.callback) then
            req.callback({ body = (isstring(req.token) and req.token) or "{}" })
        end
    end
end

net.Receive("event_info_planing",function()
    local raw = net.ReadString()
    local parsed = util.JSONToTable(raw)

    if parsed then
        Event_Planing = {}
        for k, v in pairs(parsed) do
            local num = tonumber(k) or k
            Event_Planing[num] = v
        end
        hook.Run("Event Planing Update")
    else
        DataBase:Read({token = raw, callback = function(res)
            local tbl = util.JSONToTable(res.body) or {}
            Event_Planing = {}
            for k, v in pairs(tbl) do
                local num = tonumber(k) or k
                Event_Planing[num] = v
            end
            hook.Run("Event Planing Update")
        end})
    end
end)

AdminPanel_Command_Registry("discord_event",{{type = "string",name = "ChannelId"},{type = "string",name = "roleId"}},"async",nil,"project")
