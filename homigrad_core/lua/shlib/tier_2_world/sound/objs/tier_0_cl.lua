--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_2_world/sound/objs/tier_0_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_2_world\\sound\\objs\\tier_0_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
sound.listPoint = sound.listPoint or {}
local list = sound.listPoint

function sound.CreatePoint(parent,sndName,level,className)
    local id = parent:EntIndex() .. sndName

    local point = list[id]

    if not point then
        point = oop.Create("sound_" .. (className or "onechannel"))

        list[id] = point
        point.id = id

        point.pitch = 1
        point.volume = 1
        point.volumeTrue = 1
        point.dsp = 0
        point.disFadeout = -1
        point.sndPath = sndName
        point.parent = parent
        point.reloadTime = 5
        point.channels = {
            [0] = {},
            [14] = {}
        }
    end

    point.level = level or 120
    point.filter = filter or point.filter or {}

    point.fadeStart = nil
    point.remove = nil

    point.dis = dis or 750
    point.disK = disK or 1
    
    return point
end

hook.Add("PostCleanupMap","RemoveSNDPoint",function()
    for id,point in pairs(list) do
        list[id] = nil
        point:Remove()
    end
end)

hook.Add("Think","Sound",function()
    local eyePos = EyePos()

    for id,point in pairs(list) do point:Think(eyePos) end
end)


