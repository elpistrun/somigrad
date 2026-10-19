--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_2_world/render/particles/particleemit_cl.lua <
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

-- "addons\\homigrad_core\\lua\\shlib\\tier_2_world\\render\\particles\\particleemit_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
ParticlesEmiterList = ParticlesEmiterList or {}
local ParticlesEmiterList = ParticlesEmiterList

//

local CLuaEmitter = FindMetaTable("CLuaEmitter")
local CLuaEmitter_Add = CLuaEmitter.Add
local CLuaEmitter_Finish = CLuaEmitter.Finish

local example = {}

function example:IsValid() return not self.removed end

function example:Finish()
    if self.removed then return end
    self.removed = true

    ParticlesEmiterList[self] = nil

    if IsValid(self.self) then
        CLuaEmitter_Finish(self.self)
    end
end

function example:IsValid() return not self.removed and IsValid(self.self) end

//почему-то после 7600 одновременого создания партиклов, память объекта идёт по пизде, я не могу присвоить ему функцию и мне пишет что ThinkFunction нету
//если сделать принт print(part.ThinkFunction,exampleParticle.ThinkFunction) то можно увидеть как он НЕ присвоил part эту функцию.
//впринципе пошёл в пизду, по сути только с луа теперь буду взаимодействовать, а не lua -> c++ -> lua (dietime,create переменные)

local RealTime,pairs,tostring = RealTime,pairs,tostring

function example:Add(mat,pos)
    if not IsValid(self.self) or self.removed then
        self:Finish()
        return
    end

    local part = CLuaEmitter_Add(self.self,mat,pos)
    if not part or tostring(part) == "CLuaParticle [<null>]" then return end//WTFFFFF
    
    part = {self = part}

    local ID
    
    for newID in pairs(ParticlesListFreeID) do
        ParticlesListFreeID[newID] = nil
        ID = newID
        break
    end

    part.ID = ID
    part.emitter = self
    ParticlesList[part.ID] = part
    self.particles[ID] = part

    part.create = RealTime()
    
    for k,v in pairs(exampleParticle) do part[k] = v end

    part:SetColor(255,255,255)

    part:SetLight(self.light)
    part.LightFlashMul = 1

    return part
end

function example:SetLight(value) self.light = value end
function example:SetPos(pos)
    if IsValid(self.self) then
        self.self:SetPos(pos)
    end
end

for _,name in pairs({
    "SetNoDraw",
}) do
    local handle = CLuaEmitter[name]

    example[name] = function(self,...)
        if IsValid(self.self) then
            return handle(self.self,...)
        end
    end
end

function ParticleEmitterLight(pos)
    local obj = {self = ParticleEmitter(pos)}

    obj.particles = {}

    ParticlesEmiterList[obj] = true

    for k,v in pairs(example) do obj[k] = v end

    obj:SetLight("slow")

    return obj
end
