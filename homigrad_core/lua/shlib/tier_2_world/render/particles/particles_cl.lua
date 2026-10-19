--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_2_world/render/particles/particles_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_2_world\\render\\particles\\particles_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
//чот тут и нихуя 10000 не наберётся.. походу лимит это 8к бляль ура source engine дайте мне работу уже в facepunch

// World

local ParticlesList,ParticlesListFreeID = ParticlesList,ParticlesListFreeID
local ParticlesEmiterList = ParticlesEmiterList

local function particleRemove(ID)
    ParticlesListFreeID[ID] = true
    ParticlesList[ID] = nil
end

local delay = 0
local id,max

local calculateCount = 0

cvars.CreateOption("hg_particle_calculatemax","10000",function(value)
    calculateCount = tonumber(value or 10000) or 10000
end,0,100000)

local ParticlesListRemoveByID = ParticlesListRemoveByID

hook.Add("PreRender","ParticlesList",function()
    if not id then
        id = 1
        max = 1

        for id,part in pairs(ParticlesList) do
            max = math.max(max,id)
        end
    end

    local time = RealTime()

    calculateCount = 0

    while true do
        if calculateCount >= 10000 then break end
        calculateCount = calculateCount + 1
        
        local part = ParticlesList[id]
        if part then
            if part.removed or part.create + part.dietime - time <= 0 then
                ParticlesListRemoveByID(id)
            else
                part:ThinkFunction(time)
            end
        end

        id = id + 1
        if id > max then id = nil break end
    end
end)

hook.Add("PostCleanupMap","ParticlesList",function()
    for id,part in pairs(ParticlesList) do
        ParticlesListRemoveByID(id)
        part:Remove()
    end

    for obj in pairs(ParticlesEmiterList) do
        ParticlesEmiterList[obj] = nil
        if IsValid(obj) then obj:Finish() end
    end
end)

// DEV

concommand.Add("hg_particle_dev",function(ply,cmd,args)
    hg_particle_dev = tonumber(args[1] or 0) > 0
end)

local random,Rand = math.random,math.Rand

concommand.Add("hg_particle",function(ply,cmd,args)
    local tr =  LocalPlayer():GetEyeTrace()
    local pos = tr.HitPos + tr.HitNormal * 25
    
    local emitter = ParticleEmitterLight(pos)
    
    for i = 1,((args[1] and tonumber(args[1])) or 750) do
        local part = emitter:Add(ParticleMatSmoke[random(1,#ParticleMatSmoke)],pos)

        if part then
            part:SetDieTime(Rand(9,11))
    
            part:SetStartAlpha(200)
            part:SetEndAlpha(0)
    
            part:SetStartSize(125)
            part:SetEndSize(100)
    
            part:SetGravity(Vector(0,0,0))
            part:SetVelocity(Vector(Rand(-75,75) * Rand(0.5,2),Rand(-75,75) * Rand(0.5,2),Rand(-5,5)))
            part:SetCollide(true)
            part:SetBounce(0.25)
        end
    end
    
    emitter:Finish()
end)

hook.Add("HUDPaint","Particles Count",function()
    if not hg_particle_dev then return end

    draw.SimpleText("particles: " .. table.Count(ParticlesList),"HS.12",0,0)
    draw.SimpleText("particleEmitters: " .. table.Count(ParticlesEmiterList),"HS.12",0,12)
    draw.SimpleText("calculateCount: " .. calculateCount,"HS.12",0,24)
end)
