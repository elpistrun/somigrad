--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_donat/lua/hinit/donat/tier_1_manager_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad_donat\\lua\\hinit\\donat\\tier_1_manager_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
// https://t.me/homigrad/74?comment=33048
// https://soundcloud.com/diklordefenil/popytka-nomer-5

function CreateItems_SyncDataManager_AboutSteamID64(name,nameItem,manager)
    local data,list = _G[name .. "Data"] or {},_G[name .. "List"] or {}
    _G[name .. "Data"] = data
    _G[name .. "List"] = list

    local classes = _G[nameItem .. "Classes"] or {}
    _G[nameItem .. "Classes"] = classes

    _G[nameItem .. "_Reg"] = function(class,base,isFolder) return oop.Reg(class,base,isFolder,0,classes) end
    _G[nameItem .. "_Get"] = function(class) return oop.Get(class,classes) end

    _G[nameItem .. "_Create"] = function(item,data)
        item = util.tableCopy(item)

        local class = classes[item.class]
        class = class and class[1] or classes["base"][1]
    
        item.data = data or {}

        util.tableLink(item,class)

        return item
    end

    _G[nameItem .. "_SetupList"] = function(steamid64)
        if not list[steamid64] then
            list[steamid64] = {}
        end
    
        local list = list[steamid64]
        local data = data[steamid64]
    
        local ply = player.GetBySteamID64(steamid64)
        
        for id,item in pairs(list) do
            if not data[id] or data[id].class != item.class then
                if list[id].OnRemove then list[id]:OnRemove() end
                
                list[id] = nil
            end//предмет был удалён
        end

        for id,data in pairs(data) do
            local item = list[id]

            local created
            if not item then
                item = {class = data.class}
                list[id] = item
                created = true
            end

            item.class = data.class
            
            local class = classes[item.class]
            class = class and class[1]
            if class then util.tableLink(item,class) end

            item.owner = steamid64
            item.id = id
            item.data = data
            item.ownerPly = ply
            
            if created and item.OnInit then item:OnInit() end
            if item.OnSync then item:OnSync() end
        end
    end

    event.Add(manager.eventSyncName,"Construct",function(steamid64)
        _G[nameItem .. "_SetupList"](steamid64)
    end,-10)
end

