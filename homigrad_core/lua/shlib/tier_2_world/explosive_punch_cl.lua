--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_2_world/explosive_punch_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_2_world\\explosive_punch_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local punch = 0
local punchSide = 0

local punchSet,punchSideSet = 0,0

function ExplosivePunch(pos,distance)
    if sound.GetDSP(pos,LocalPlayer()) ~= DSP_LEVEL0 then return end
    
    local dis = EyePos():Distance(pos)

    local k = 1 * (1 - math.min(dis / distance,1))

    local posScreen = pos:ToScreen()
    local kSide = (math.Clamp(posScreen.x,0,ScrW()) - ScrW() / 2) / (ScrW() / 2)

    kSide = math.Clamp(kSide * 10000,-1,1) * k

    local d = dis * UNITS_TO_METERS / SOUNDSPEED

    if d > 0.06 then
        timer.GameSimple(d,function()
            punchSet = math.min(punchSet + k,k * 4)
            punchSideSet = math.min(punchSideSet + kSide,kSide * 4 )
        end)
    else
        punchSet = math.min(punchSet + k,k * 4)
        punchSideSet = math.min(punchSideSet + kSide,kSide * 4 )
    end
end

event.Add("PreCalcView","Explosive Punch",function(ply,view)
    if not view then return end
    local ang = view.ang or view.angles
    if not ang then return end

    if (punch or 0) ~= 0 or (punchSide or 0) ~= 0 then
        ang:Add(Angle((punch or 0) * 3,(punchSide or 0) * 6,-(punchSide or 0) * 6 + math.Rand(-(punch or 0),punch or 0)))
    end
end)

hook.Add("Think","Explosive Punch",function()
    punch = LerpFTLess(0.5,punch,punchSet,0.001)
    punchSide = LerpFTLess(0.5,punchSide,punchSideSet,0.001)
    
    punchSet = LerpFTLess(0.1,punchSet,0,0.001)
    punchSideSet = LerpFTLess(0.1,punchSideSet,0,0.001)
end)
