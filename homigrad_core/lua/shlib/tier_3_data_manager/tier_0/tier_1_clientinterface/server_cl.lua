--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_3_data_manager/tier_0/tier_1_clientinterface/server_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_3_data_manager\\tier_0\\tier_1_clientinterface\\server_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local example = {}
local empty = function() end

function example:Read(data)
    local callback = data.callback or empty
    local callback_err = data.callback_err or empty
    local token = data.token
    
    local req
    req = queueHTTP(self.api .. "?token=" .. token,function(res)
        req.body = res.body

        if req.body == "invalid token" then
            ErrorNoHalt("DataBase: Invalid token '" .. token .. "'\n")

            callback_err()
        else
            callback(req)
        end
    end)

    event.Call("Token Read",req)

    req:Send()

    return req
end

local function Setup(obj,api)
    obj.api = obj.api or api
    for k,v in pairs(example) do obj[k] = v end
end

net.Receive("dataBaseURL",function()
    print("database setup")
    DataBaseGeneral = {}
    Setup(DataBaseGeneral,net.ReadString())

    DataBase = {}
    Setup(DataBase,net.ReadString())
end)

if Initialize then
    Setup(DataBaseGeneral)
    Setup(DataBase)
end//DEV

//https://music.youtube.com/watch?v=NhxM1YJD-Xw&list=OLAK5uy_m08OFFeBq8HrQS3QIpOVzkWSxolQM3eZs

ReceiveMediaToken = ReceiveMediaToken or {}

function net.ReceiveMediaToken(event,callback)
    ReceiveMediaToken[event] = callback
end

net.Receive("database_token",function()
    local event,token = net.ReadString(),net.ReadString()

    local req = DataBase:Read({token = token,callback = function(res)
        ReceiveMediaToken[event](res.body,res)
    end})

    req.name = event
end)

net.Receive("database_global_token",function()
    local event,token = net.ReadString(),net.ReadString()

    local req = DataBaseGeneral:Read({token = token,callback = function(res)
        ReceiveMediaToken[event](res.body,res)
    end})

    req.name = event
end)

function net.StartToken(event)
    net.Start("database_token")
    net.WriteString(event)
end

function net.StartTokenGlobal(event)
    net.Start("database_global_token")
    net.WriteString(event)
end
