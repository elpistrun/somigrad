--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/mutator/lava/particle_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hgamemode/roundsystem/mutator/lava/tier_0_sh.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\mutator\\lava\\particle_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local MUTATOR = Mutator_Get("lava")
if not MUTATOR then return end

MUTATOR.ResetWithCleanUp = true

if SERVER then
    util.AddNetworkString("lava in")
    util.AddNetworkString("lava out")

    return
end

local flame = {
    Material("particles/flamelet1"),
    Material("particles/flamelet2"),
    Material("particles/flamelet3"),
    Material("particles/flamelet4")
}

net.Receive("lava in",function()
    local pos = net.ReadVector()
    local size = tonumber(net.ReadString())

    local emitter = ParticleEmitter(pos)
    local random,Rand = math.random,math.Rand
    
    for i = 1,random(12,15) do--up
        local part = emitter:Add(flame[random(1,4)],pos)
        if part then
            part:SetDieTime(Rand(3,4))
    
            part:SetColor(255,255,255)
    
            part:SetStartAlpha(Rand(75,155))
            part:SetEndAlpha(Rand(0,5))
    
            part:SetStartSize(Rand(25,55) * size)
            part:SetEndSize(Rand(190,175) * size)
            part:SetRoll(Rand(-1200,1200))
    
            part:SetVelocity(Vector(0,0,Rand(500,1200) * size):Rotate(Angle(Rand(-45,45),Rand(-45,45))))
    
            part:SetAirResistance(Rand(55,75))
            part:SetGravity(ParticleGravity * size)
        end
    end
    
    local max = random(16,23)
    
    for i = 1,max do--ring
        local part = emitter:Add(flame[random(1,4)],pos)
        if part then
            part:SetDieTime(Rand(3,5))
    
            part:SetColor(255,145,0)
    
            part:SetStartAlpha(Rand(75,155))
            part:SetEndAlpha(Rand(0,5))
    
            part:SetStartSize(Rand(25,55) * size)
            part:SetEndSize(Rand(190,175) * size)
            part:SetRoll(Rand(-360,360))
    
            part:SetVelocity(Vector(0,0,Rand(250,500) * size):Rotate(Angle(90,i / max * 360 + Rand(-45,45))))
    
            part:SetAirResistance(Rand(55,75))
        end
    end

    local max = random(16,23)
    
    for i = 1,max do--smoke
        local part = emitter:Add(flame[random(1,4)],pos)
        if part then
            part:SetDieTime(Rand(5,6))
    
            part:SetColor(255,145,0)
    
            part:SetStartAlpha(Rand(15,25))
            part:SetEndAlpha(Rand(0,5))
    
            part:SetStartSize(Rand(25,55) * size)
            part:SetEndSize(Rand(300,400) * size)
            part:SetRoll(Rand(-360,360))
    
            part:SetVelocity(Vector(0,0,Rand(125,750) * size / 2):Rotate(Angle(90,i / max * 360 + Rand(-45,45))))
    
            part:SetAirResistance(Rand(55,75))
        end
    end
    
    emitter:Finish()

    sound.Emit(nil,"ambient/water/water_splash" .. random(1,3) .. ".wav",90,1,75,pos,"0")
    sound.Emit(nil,"physics/rubber/rubber_tire_impact_hard" .. random(1,3) .. ".wav",120,size,Lerp(size,200,80),pos,"0")
end)

net.Receive("lava out",function()
    local pos = net.ReadVector()
    local size = tonumber(net.ReadString())

    local emitter = ParticleEmitter(pos)
    local random,Rand = math.random,math.Rand
    
    for i = 1,random(12,15) do--up
        local part = emitter:Add(flame[random(1,4)],pos)
        if part then
            part:SetDieTime(Rand(3,4))
    
            part:SetColor(255,255,255)
    
            part:SetStartAlpha(Rand(75,155))
            part:SetEndAlpha(Rand(0,5))
    
            part:SetStartSize(Rand(25,55) * size)
            part:SetEndSize(Rand(190,175) * size)
            part:SetRoll(Rand(-1200,1200))
    
            part:SetVelocity(Vector(0,0,Rand(500,1200) * size):Rotate(Angle(Rand(-45,45),Rand(-45,45))))
    
            part:SetAirResistance(Rand(55,75))
            part:SetGravity(ParticleGravity * size)
        end
    end
    
    local max = random(16,23)
    
    for i = 1,max do--ring
        local part = emitter:Add(flame[random(1,4)],pos)
        if part then
            part:SetDieTime(Rand(3,5))
    
            part:SetColor(255,145,0)
    
            part:SetStartAlpha(Rand(75,155))
            part:SetEndAlpha(Rand(0,5))
    
            part:SetStartSize(Rand(25,55) * size)
            part:SetEndSize(Rand(190,175) * size)
            part:SetRoll(Rand(-360,360))
    
            part:SetVelocity(Vector(0,0,Rand(250,500) * size):Rotate(Angle(90,i / max * 360 + Rand(-45,45))))
    
            part:SetAirResistance(Rand(55,75))
        end
    end

    local max = random(16,23)
    
    for i = 1,max do--smoke
        local part = emitter:Add(flame[random(1,4)],pos)
        if part then
            part:SetDieTime(Rand(5,6))
    
            part:SetColor(255,145,0)
    
            part:SetStartAlpha(Rand(15,25))
            part:SetEndAlpha(Rand(0,5))
    
            part:SetStartSize(Rand(25,55) * size)
            part:SetEndSize(Rand(300,400) * size)
            part:SetRoll(Rand(-360,360))
    
            part:SetVelocity(Vector(0,0,Rand(125,750) * size / 2):Rotate(Angle(90,i / max * 360 + Rand(-45,45))))
    
            part:SetAirResistance(Rand(55,75))
        end
    end
    
    emitter:Finish()

    sound.Emit(nil,"ambient/water/water_splash" .. random(1,3) .. ".wav",90,1,100,pos,"0")
end)
