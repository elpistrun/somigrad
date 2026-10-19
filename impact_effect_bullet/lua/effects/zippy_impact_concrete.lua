--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/impact_effect_bullet/lua/effects/zippy_impact_concrete.lua <
    > Callstack:  <
]]

-- "addons\\impact_effect_bullet\\lua\\effects\\zippy_impact_concrete.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local smoke_mats = {}
for i = 1,9 do
    table.insert(smoke_mats, "particle/smokesprites_000" .. i)
end
for i = 10,16 do
    table.insert(smoke_mats, "particle/smokesprites_00" .. i)
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Init(data)
    local pos = data:GetStart()
    local normal = data:GetNormal()
    local intensity = data:GetMagnitude()

    local emitter = ParticleEmitter(pos)

    for i = 1,8*intensity do
        local smoke = emitter:Add(table.Random(smoke_mats), pos)
        
        smoke:SetStartAlpha(math.Rand(33, 66))
        smoke:SetEndAlpha(0)
        smoke:SetColor(255,255,255)
        smoke:SetLighting(true)
        smoke:SetGravity(Vector(0,0,-math.Rand(33, 66)))
        smoke:SetRollDelta(math.random(0, 0.5*math.pi))
        smoke:SetAirResistance(175)

        smoke:SetStartSize(5*intensity)
        smoke:SetDieTime(math.Rand(0.5, 1)*intensity)
        smoke:SetEndSize(math.Rand(15, 30)*intensity)
        smoke:SetVelocity((normal*math.Rand(40, 200)+VectorRand()*50)*intensity)
    end

    for i = 1,15*intensity do
        local pebble = emitter:Add("effects/fleck_cement" .. math.random(1, 2), pos+normal*8)
        
        pebble:SetStartAlpha(255)
        pebble:SetEndAlpha(0)
        pebble:SetCollide(true)
        pebble:SetBounce(math.Rand(0,1))
        pebble:SetColor(255,255,255)
        pebble:SetLighting(true)
        pebble:SetGravity(Vector(0,0,-600))
        pebble:SetRollDelta(math.random(0, 0.5*math.pi))

        local size = math.Rand(0.5, 2)*intensity
        pebble:SetEndSize(size)
        pebble:SetStartSize(size)

        pebble:SetDieTime(math.Rand(0.5, 1)*intensity)
        pebble:SetVelocity((normal*math.Rand(40, 200)+VectorRand()*125)*intensity*1.33)
    end

    emitter:Finish()
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Think() end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Render() end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
