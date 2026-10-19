--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_0/tier_0/player/init_protocol_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_0\\tier_0\\player\\init_protocol_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local function initProtocol_1()//Говорим что можно безопасно отправлять данные
    if util.NetworkStringToID("initProtocol") == 0 then return end--серверная половина отсутствует
    InitProtocol = "waitResponseFromServer"
    net.Start("initProtocol")
    net.SendToServer()
    //После получаем данные с сервера в виде net.Receive
    //(Информация о текущем раунде, ваше наиграное времмя и т.п)
    //В конце этой цепочки сервер отправляем initProtocol
end

local function initProtocol_2()//Говори что получили данные с сервера, отправляем свои данные
    InitProtocol = "sendingData"
    event.Call("Send Data")//Посылаем различные данные (информация о скине, выборке класса и прочее)

    if util.NetworkStringToID("initProtocol") == 0 then return end
    InitProtocol = "waitReadyFromServer"
    net.Start("initProtocol")//Говорим что данных больше не будет и их нужно обработать.
    net.SendToServer()
    //Ждём ответа от сервера.
end


local function initProtocol_3()//Говорим что мы готовы к игре\
    InitProtocol = "setupWorld"
    event.Call("Setup World")//Подготавливаем мир, настраивам объекты к игре.

    if util.NetworkStringToID("initProtocol") == 0 then return end
    InitProtocol = "ready"
    InitNET = true
    net.Start("initProtocol")
    net.SendToServer()
end

hook.Add("InitPostEntity","Player Spawn",function()
    InitProtocol = "waitSourceReady"
    Start = RealTime()
    
    timer.Simple(1,initProtocol_1)
end)

net.Receive("initProtocol",function()
    if InitProtocol == "waitResponseFromServer" then//Принимаем данные с сервера, отправляем свои.
        initProtocol_2()
    elseif InitProtocol == "waitReadyFromServer" then//Подготавливаем мир.
        if not initProtocolQueue then initProtocolQueue = queueAdd() end
        initProtocolQueue.async = true
        initProtocolQueue:SetThread({})

        initProtocolQueue.Do = function()
            initProtocolQueue.doing = false

            local success,err = event.Call("initProtocol_3()")
            if success == false then initProtocol_3_WaitReason = err return end
    
            initProtocolQueue:Remove()
    
            initProtocol_3()
        end
    
        initProtocolQueue:Send()
    end
end)

//

local function Init(ply)
    ply.init = true
    event.Call("Player Create",ply)
end

net.Receive("ply spawn",function()
    if not InitNET then return end
    
    local ply = net.ReadEntity()
    if not IsValid(ply) then return end--doesnt

    if not ply.init then Init(ply) end

    event.Call("Player Spawn",ply)

    if ply == LocalPlayer() then event.Call("LocalPlayer Spawn",ply) end
end)

event.Add("Setup World","Player Spawn",function()
    for i,ply in pairs(player.GetAll()) do
        if not ply.init then Init(ply) end

        event.Call("Player Spawn",ply)
    end
end)

