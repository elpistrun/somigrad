--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_2_world/sound/earrape_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_2_world\\sound\\earrape_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local earrapeSet = 0
local earrape = 0

EarrapeSound = nil

hook.Add("Think","Earrape",function()
    if not LocalPlayer():Alive() then
        earrapeSet = 0
        earrape = 0
    end

    earrapeSet = math.max(earrapeSet - FrameTime() / 30,0)
    
    if earrape < earrapeSet then
        earrape = LerpFT(1,earrape,earrapeSet)
    else
        earrape = math.max(earrape - FrameTime() / 30,0)
    end

    if not EarrapeSound then
        EarrapeSound = CreateSound(LocalPlayer(),"homigrad/earraopoee.wav")
    end

    if earrape <= 0 then EarrapeSound:Stop() return end

    if not EarrapeSound:IsPlaying() then EarrapeSound:PlayEx(0,100) end

    EarrapeSound:ChangeVolume(earrape,0.1)
end)

function GiveEarrapeOfPos(pos,radius)
    local dis = EyePos():Distance(pos)

    local d = dis * UNITS_TO_METERS / SOUNDSPEED

    local add = (1 - math.min(dis / radius,1)) / 4
    if add < 0.06 then return end

    if sound.GetDSP(pos,LocalPlayer()) ~= DSP_LEVEL0 then return end
    
    if d > 0.06 then
        timer.GameSimple(d,function() earrapeSet = math.min(earrapeSet + add,add) end)
    else
        earrapeSet = math.min(earrapeSet + add,add)
    end
end

function GiveEarrape(add)
    earrapeSet = earrapeSet + add
end
