--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_0/sh_timer.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_0\\sh_timer.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
timer.queueSimple = timer.queueSimple or {}
local queueSimple = timer.queueSimple

local free = {}
for i = 1,4096 do free[i] = true end

function timer.GameSimple(wait,func,r1,r2,r3,r4,r5,r6)
    if TypeID(func) ~= TYPE_FUNCTION then ErrorNoHaltWithStack("no func") return end

    local id

    for i in pairs(free) do id = i free[id] = nil break end

    queueSimple[id] = {CurTime() + wait,func,r1,r2,r3,r4,r5,r6}

    return id
end

function timer.GameSimpleRemove(id)
    queueSimple[id] = nil
    free[id] = true
end

local function err(err) ErrorNoHaltWithStack(err) end

hook.Add("Think","Timer Game",function()
    local Time = CurTime()
    local count = 0
    local i = 1

    for id,time in pairs(queueSimple) do
        if time[1] > Time then continue end

        queueSimple[id] = nil
        free[id] = true

        xpcall(time[2],err,time[3],time[4],time[5],time[6],time[7],time[8])
    end
end)

hook.Add("PostCleanupMap","Timer Game",function()
    for k in pairs(queueSimple) do queueSimple[k] = nil end--ae
end)
