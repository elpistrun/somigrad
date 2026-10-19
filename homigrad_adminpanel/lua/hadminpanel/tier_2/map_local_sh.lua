--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_adminpanel/lua/hadminpanel/tier_2/map_local_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:11 <
]]

-- MapList/MapsBlocked приезжали из внешней БД (net.ReceiveMediaToken -> HTTP),
-- которой в этой сборке нет, поэтому вкладка "Карты" была пустой.
-- Список берём прямо с сервера через file.Find, блокировки храним локально.

if CLIENT then
    net.Receive("hg_ap_map_local",function()
        local size = net.ReadUInt(32)
        local data = util.Decompress(net.ReadData(size))
        if not data then return end

        data = util.JSONToTable(data)
        if not data then return end

        MapList = data.maps or {}
        MapsBlocked = data.blocked or {}

        event.Call("Map List Sync")
        event.Call("Map Blocked Sync")
    end)

    return
end

util.AddNetworkString("hg_ap_map_local")

local commands = AdminPanel_ServerCommands or {}
AdminPanel_ServerCommands = commands

local BLOCK_FILE = "hg_adminpanel_mapblock.json"

local blocked = util.JSONToTable(file.Read(BLOCK_FILE,"DATA") or "") or {}

local maps

local function BuildMapList()
    maps = {}

    for _,fileName in ipairs(file.Find("maps/*.bsp","GAME")) do
        local name = string.sub(fileName,1,#fileName - 4)

        -- Служебные карты движка в списке не нужны.
        if string.sub(name,1,3) == "sp_" or name == "background01" then continue end

        maps[name] = {name = name}
    end
end

BuildMapList()

local function Send(target)
    if not maps then BuildMapList() end

    local data = util.Compress(util.TableToJSON({maps = maps,blocked = blocked}))
    local size = #data

    net.Start("hg_ap_map_local")
    net.WriteUInt(size,32)
    net.WriteData(data,size)

    if IsValid(target) then net.Send(target) else net.Broadcast() end
end

AdminPanel_Map_Send = Send

function commands.map_block(ply,args)
    local map = string.gsub(tostring(args[1] or ""),"%.bsp$","")
    if map == "" or not maps[map] then return "Нет такой карты: " .. map end

    local value = args[2]
    value = value == true or value == 1 or value == "1" or value == "true"

    blocked[map] = value or nil

    file.Write(BLOCK_FILE,util.TableToJSON(blocked,true))

    Send()

    return map .. (value and " закрыта" or " открыта")
end

event.Add("Player Create","AP Local Maps",function(ply)
    Send(ply)
end)

