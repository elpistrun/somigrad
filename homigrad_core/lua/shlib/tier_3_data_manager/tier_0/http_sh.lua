--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_3_data_manager/tier_0/http_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_3_data_manager\\tier_0\\http_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local empty = function() end

local developer

if SERVER then
    developer = true
else
    cvars.CreateOption("hg_http_dev","0",function(value)
        developer = (tonumber(value or 0) or 0) > 0
    end)
end

function queueHTTP(url,callback,body,headers,req,failed)
    callback = callback or empty

    req = queueAdd(req)//если не нужно создавать новую таблицу

    req.url = url
    req.name = url
    
    req.method = body and "POST" or "GET"
    req.body = body
    req.headers = headers
    req.callback = callback
    
    req.success = function(code,body,headers)
        if not req.id or req.removed then req:Remove() return end//FUCK YOU!

        req:Remove()

        if code ~= 200 then
            if developer then ErrorNoHalt("queue: '" .. req:Name() .. "' backend script error code:" .. tostring(code) .. ",body:" .. string.sub(tostring(body),1,30) .. "\n") end

            return
        end

        local res = {
            body = body,
            headers = headers,
            code = code,
            path = req.path,
        }

        req.callback(res)
    end

    req.failed = function(err)
        req.doing = false
        
        if failed and failed(req,err) == false then return end

        if developer then ErrorNoHalt("queue: '" ..  req:Name() .. "' http failed:" .. err .. "\n") end
    end

    req.Do = function()
        local requestHTTP = SERVER and CHTTP or HTTP

        requestHTTP(req)
    end

    return req
end

function HTTPFAST(req,callback)
    local queue
    queue = queueHTTP(req.url,function(res)
        res.success = true
        callback(res)
    end,req.body,req.headers,nil,function(req,err)
        queue:Remove()

        callback({
            success = false,
            err = err
        })

        return false
    end)

    queue:Send()

    return queue
end

//

local find = string.find

function ComputeURLServerID(url)
    if not find(url,"?") then
        return url .. "?port=" .. ServerPort
    else
        return url .. "&port=" .. ServerPort
    end
end

function ComputePathForServer(path)
    local ip = game.GetIPAddress()
    ip = string.Replace(ip,".","")
    ip = string.Replace(ip,":","")

    return "temp/" .. ip .. "/" .. (path or "")
end

local removeSpecSumbol = {
    "?",
    "/",
    "\\",
    ":",
    "<",
    ">",
    ",",
    "\"",
    "|"
}

function RemoveSpecialSumbolsFromURL(url)
    for _,sum in pairs(removeSpecSumbol) do url = string.gsub(url,sum,"") end
    return url
end

local find,Split,sub = string.find,string.Split,string.sub

function GetURLArgs(url)
    local line = find(url,"?")
    if not line then return end

    line = sub(url,line + 1,#url)

    local args = {}

    for _,arg in pairs(Split(line,"&")) do
        arg = Split(arg,"=")
        
        local v = arg[2]

        if v == nil then
            args[arg[1]] = true
        else
            args[arg[1]] = v
        end
    end

    return args
end

local MapName

function GetMapURL()
	if MapName then return MapName end
	
	MapName = game.GetMap()
	MapName = string.gsub(MapName," ","_")

	return MapName
end
