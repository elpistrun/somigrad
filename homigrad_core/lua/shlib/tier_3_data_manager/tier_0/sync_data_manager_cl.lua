--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_3_data_manager/tier_0/sync_data_manager_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_3_data_manager\\tier_0\\sync_data_manager_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
// https://www.youtube.com/watch?v=mXN6P4CK9XI

function Create_SyncDataManager_AboutSteamID64(listData,eventSyncName,netSyncName)
    local manager = {
        eventSyncName = eventSyncName
    }

    net.Receive(netSyncName,function(body)
        local token,steamid64 = net.ReadString(),net.ReadString()

        if token == "now" then
            event.Call(eventSyncName,steamid64,listData[steamid64])
        elseif string.sub(token,1,5) == "json:" then
            local data = util.JSONToTable(string.sub(token,6),true) or {}
            listData[steamid64] = data
            event.Call(eventSyncName,steamid64,data)
        elseif DataBase and DataBase.Read then
            local req = DataBase:Read({token = token,callback = function(res)
                local data = util.JSONToTable(res.body,true) or {}
                listData[steamid64] = data
                event.Call(eventSyncName,steamid64,data)
            end})

            req.name = netSyncName
        end
    end)

    return manager
end//надеюсь я когданибудь съебу с этой помойки

//

function Create_SyncDataManager(nameTable,eventSyncName,threadName,netSyncName)
    local manager = {
        eventSyncName = eventSyncName
    }
    
    net.Receive(netSyncName,function()
        if not DataBase then print(eventSyncName) end
        
        local req = DataBase:Read({token = net.ReadString(),callback = function(res)
            _G[nameTable] = util.JSONToTable(res.body,true)
            event.Call(eventSyncName,data)
        end,thread = threadName})

        req.name = netSyncName
    end)

    function manager.Queue(callback)
        if not _G[nameTable] then
            local queue = queueAdd()
            queue.async = true
            queue.Do = function()
                queue.doing = false
                if not _G[nameTable] then return end
                queue:Remove()
                callback()
            end

            queue:Send()
        else
            callback()
        end
    end

    return manager
end
