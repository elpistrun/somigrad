--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_2_world/render/particles/particle_cl.lua <
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

-- "addons\\homigrad_core\\lua\\shlib\\tier_2_world\\render\\particles\\particle_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
ParticlesList = ParticlesList or {}

if not ParticlesListFreeID then
    ParticlesListFreeID = {}

    for i = 1,1000000 do
        ParticlesListFreeID[i] = true
    end
end

local ParticlesList = ParticlesList
local ParticlesListFreeID = ParticlesListFreeID

//

local CLuaParticle = FindMetaTable("CLuaParticle")

local example = {}
exampleParticle = example

function ParticlesListRemoveByID(ID)
    ParticlesListFreeID[ID] = true

    local part = ParticlesList[ID]
    if part then
        part.emitter.particles[ID] = nil
        part.ID = nil
    end

    ParticlesList[ID] = nil
end

local ParticlesListRemoveByID = ParticlesListRemoveByID

function example:Remove()
    if self.removed then return end
    self.removed = true

    if self.ID then ParticlesListRemoveByID(self.ID) end

    self:SetDieTime(0)

    if self.OnRemove then self:OnRemove() end
end

function example:ThinkFunction(time)
    self:Think(time)
    self:LightFunc(time)
end

function example:Think() end

function example:IsValid()
    return not self.removed and self.create + self.dietime - CurTime() > 0
end

example.MulLight = 1
local empty = function() end

function example:SetLight(value)
    if value == "slow" then
        self.LightFunc = ParticleLight_Slow
    elseif value == "fast" then
        self.LightFunc = ParticleLight_Fast
    else
        self.LightFunc = empty
        self.NoLight = true//х3 зачем
    end
end

for _,name in pairs({
    "SetAirResistance",
    "SetAngles",
    "SetAngleVelocity",
    "SetBounce",
    "SetCollide",
    "SetCollideCallback",
    "SetColor",
    "SetGravity",
    "SetLifeTime",
    "SetLighting",
    "SetMaterial",
    "SetNextThink",
    "SetPos",
    "SetRoll",
    "SetRollDelta",
    "SetThinkFunction",
    "SetVelocity",
    "SetVelocityScale",

    "GetAirResistance",
    "GetAngles",
    "GetAngleVelocity",
    "GetBounce",
    "GetColor",
    "GetDieTime",
    "GetGravity",
    "GetLifeTime",
    "GetMaterial",
    "GetPos",
    "GetRoll",
    "GetRollDelta",
    "GetVelocity",

    "SetStartAlpha",
    "SetStartLength",

    "SetEndAlpha",
    "SetEndLength",
}) do
    local handle = CLuaParticle[name]

    example[name] = function(self,...) return handle(self.self,...) end
end

local function addFunc(name,valueName)
    local handle = CLuaParticle[name]
    example[name] = function(self,value)
        self[valueName] = value
        handle(self.self,value)
    end
end

addFunc("SetDieTime","dietime")
addFunc("SetStartSize","startSize")
addFunc("SetEndSize","endSize")

addFunc("SetStartAlpha","startAlpha")
addFunc("SetEndAlpha","endAlpha")

local handle = CLuaParticle.SetColor
function example:SetColor(r,g,b)
    if TypeID(r) == TYPE_TABLE then
        local color = r
        r,g,b = color.r,color.g,color.b
    end

    self.r = r
    self.g = g
    self.b = b

    handle(self.self,r,g,b)
end
