--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/damage/armor_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\damage\\armor_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Rand,random = math.Rand,math.random

net.Receive("dmgarmor head",function()
    local pos = net.ReadVector()
    local dir = net.ReadVector()
    local ent = net.ReadInt(13)

    sound.Emit(ent,"player/bhit_helmet-1.wav",90,0.5,100,nil,1)
    sound.Emit(ent,"snd_jack_hmcd_ricochet_1.wav",75,0.5,125,nil,1)

    local dlight = DynamicLight(ent)
    dlight.pos = pos
    dlight.r = random(245,255)
    dlight.g = random(245,255)
    dlight.b = random(75,125)
    dlight.brightness = 10
    dlight.Decay = 1000
    dlight.Size = Rand(60,75)
    dlight.DieTime = CurTime() + 0.1

    local eff = EffectData()
    eff:SetOrigin(pos)
    eff:SetNormal(-dir)
    eff:SetRadius(0.1)
    eff:SetMagnitude(0.25)
    eff:SetScale(0.25)

    util.Effect("Sparks",eff)
    util.Effect("MetalSpark",eff)
end)

net.Receive("dmgarmor rich",function()
    local pos = net.ReadVector()
    local dir = net.ReadVector()
    local ent = net.ReadInt(13)

    sound.Emit(ent,"snd_jack_hmcd_ricochet_" .. net.ReadInt(4) .. ".wav",75,0.5,125,pos,1)

    local dlight = DynamicLight(ent)
    dlight.pos = pos
    dlight.r = random(245,255)
    dlight.g = random(245,255)
    dlight.b = random(75,125)
    dlight.brightness = 10
    dlight.Decay = 1000
    dlight.Size = Rand(60,75)
    dlight.DieTime = CurTime() + 0.1

    local eff = EffectData()
    eff:SetOrigin(pos)
    eff:SetNormal(-dir)
    eff:SetRadius(0.1)
    eff:SetMagnitude(0.25)
    eff:SetScale(0.25)

    util.Effect("Sparks",eff)
    util.Effect("MetalSpark",eff)
end)

net.Receive("dmgarmor kevlar",function()
    local pos = net.ReadVector()
    local dir = net.ReadVector()
    local ent = net.ReadInt(13)

    sound.Emit(ent,"player/kevlar" .. net.ReadInt(4) .. ".wav",75,1,50,pos,1)

    local eff = EffectData()
    eff:SetEntity(Entity(ent))
    eff:SetOrigin(pos)
    --eff:SetNormal(-dir)
    eff:SetRadius(10)
    eff:SetMagnitude(10)
    eff:SetScale(10)

    util.Effect("GlassImpact",eff)
end)
