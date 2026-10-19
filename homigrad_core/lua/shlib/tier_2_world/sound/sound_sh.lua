--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_2_world/sound/sound_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_2_world\\sound\\sound_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
sound = sound or {}

SOUNDHIGHROOFDISTANCE = 6000
UNITS_TO_METERS = 0.01905
SOUNDSPEED = 343 // в метрах

DSP_LEVEL0 = 0
DSP_LEVEL1 = 30
DSP_LEVEL2 = 30

DSP_LEVEL0_PEN = 0.35
DSP_LEVEL1_PEN = 0.5
DSP_LEVEL2_PEN = 0.75

function GetNameDSPLevel(dspLevel)
    if dspLevel == DSP_LEVEL0 then return "DSP_LEVEL0" end
    if dspLevel == DSP_LEVEL1 then return "DSP_LEVEL1" end
    if dspLevel == DSP_LEVEL2 then return "DSP_LEVEL2" end--cring
end

local hg_best_soundtrace = 3

if CLIENT then
    cvars.CreateOption("hg_best_soundtrace","3",function(value) hg_best_soundtrace = tonumber(value or 3) end,0,30)
end

function sound.GetDSP(pos,filter,earPos,fast)
    local pen = sound.Trace(pos,60,fast == true and 1 or fast or hg_best_soundtrace,filter,earPos)

    if pen <= DSP_LEVEL0_PEN then--если проникло (в коофиценте)
        return DSP_LEVEL0
    elseif pen <= DSP_LEVEL1_PEN then
        return DSP_LEVEL1
    elseif pen <= DSP_LEVEL2_PEN then
        return DSP_LEVEL2
    end

    return DSP_LEVEL2,1
end

local tr = {}
tr.mask = MASK_SHOT

tr.filter = FilterFunctionSND

local empty = {}

function sound.Trace(pos,dis,penDis,_filter,earPos)
    FilterSND = _filter or empty

    return tracePenetrationToEndPos(pos,earPos or EyePos(),FilterFunctionSND,dis,penDis)
end

local d = 1 / 60
local max = math.max
local TraceLine = util.TraceLine

function tracePenetrationToEndPos(pos,endpos,filter,dis,penDisK)--mul это скок раз типо... х3
    tr.filter = filter

    if penDisK <= 1 then
        tr.start = pos
        tr.endpos = endpos

        return TraceLine(tr).HitPos:Distance(endpos) <= 1 and 0 or DSP_LEVEL1_PEN
    end
    
    local penDis = dis / penDisK

    local dir = endpos - pos
    dir:Normalize()
    dir:Mul(penDis)

    pos = pos:Clone()
    local lineDis = pos:Distance(endpos)
    local startPos = pos:Clone()

    local startDis = dis

    for i = 1,512 do
        tr.start = pos
        tr.endpos = endpos

        local result = TraceLine(tr)
        local pos2 = result.HitPos
        if pos2 == endpos then return (startDis - dis) / startDis end

        --debugoverlay.Sphere(pos2,1,0.02,Color(255,0,0),true)--input
        
        if result.Hit then
            --local hitNormal = -result.HitNormal
            pos:Set(pos2)

            for i = 1,512 do
                pos:Add(dir)
                
                tr.start = pos
                tr.endpos = pos

                result = TraceLine(tr)

                --debugoverlay.Sphere(pos,1,0.05,Color(165,165,165,165),true)--step

                dis = dis - penDis
                if pos:Distance(startPos) >= lineDis then return (startDis - dis) / startDis end
                if dis <= 0 then return (startDis - dis) / startDis end

                if result.Hit then
                    --dir:Set(LerpVector(0.001,dir,hitNormal))
                else
                    --debugoverlay.Sphere(pos,1,0.1,Color(0,0,255),true)--output

                    break
                end
            end
        end
    end

    return (startDis - dis) / startDis
end

/*local start = Vector()
local endpos = Vector()

hook.Add("HUDPaint","Test SND Trace",function()
    if input.IsButtonDown(MOUSE_LEFT) then
        start = EyePos()
        endpos = EyePos():Add(Vector(10000,0,0):Rotate(EyeAngles()))
    end

    tracePenetrationToEndPos(start,endpos,LocalPlayer(),512,10)
end)*/
