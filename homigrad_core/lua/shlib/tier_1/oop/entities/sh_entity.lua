--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_1/oop/entities/sh_entity.lua <
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

-- "addons\\homigrad_core\\lua\\shlib\\tier_1\\oop\\entities\\sh_entity.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT,CLASS = oop.Reg("base_entity",{"lib_event","lib_duplicate"})
if not ENT then return end

CLASS.NonRegisterGMOD = true

ENT.Base = "base_entity"
ENT.Type = "anim"--навсякий

function ENT:Draw() self:DrawModel() end

function ENT:SpawnFunction(ply,tr,name)
    if not tr.Hit then return end

    local ent = ents.Create(name)
    ent:SetPos(tr.HitPos + tr.HitNormal * 16 + ent:OBBCenter())
    ent.spawned = true
    ent:Spawn()
    ent:Activate()

    ent:PhysWake()

    return ent
end

function ENT:OnTakeDamage(dmgInfo)
    self:TakePhysicsDamage(dmgInfo)
end

ENT:Event_Add("Construct","register",function(class)
    local content = class[1]
    if content.NonRegisterGMOD or class.NonRegisterGMOD then return end

    scripted_ents.Register(content,content.ClassName)
end)

//

oop.FirstInheritEnts = oop.FirstInheritEnts or {}

function ENT:InheritFromScriptedEnt(class)
    local content = oop.FirstInheritEnts[class]

    if not content then
        content = scripted_ents.Get(class)
        if not content then return false end
        
        oop.FirstInheritEnts[class] = content
    end

    for k,v in pairs(content) do self[k] = v end

    return true
end
