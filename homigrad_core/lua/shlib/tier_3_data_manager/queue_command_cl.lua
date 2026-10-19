--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_3_data_manager/queue_command_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_3_data_manager\\queue_command_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
concommand.Add("cl_queue_show",function(ply,cmd,args)
    for name,list in pairs(threadList) do
        print("theard: " .. tostring(name) .. " " .. table.Count(list))

        for id,tab in pairs(list) do
            print(id,tab.doing,tab:Name(),tab.url,tab.async and "->" or ":",tab.removed,tab.id)
        end
    end
end)

concommand.Add("cl_queue_reset_all",function(ply,cmd,args)
    for name,list in pairs(threadList) do
        print("theard: " .. tostring(name) .. " " .. table.Count(list))

        for id,tab in pairs(list) do
            list[id] = nil
        end
    end
end)

concommand.Add("cl_queue_log",function(ply,cmd,args)
    queueLog = tonumber(args[1] or 0) > 0
end)

