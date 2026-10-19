--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/other/ent_taser_hook/tier_0_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\other\\ent_taser_hook\\tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("ent_taser_hook",{"base_entity"},true)
if not ENT then return INCLUDE_BREAK end

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "handcuffs"

function ENT:Initialize()
    self:SetModel("models/hunter/plates/plate.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    self:DrawShadow(false)

    if SERVER then
        self:GetPhysicsObject():Wake()
        self:GetPhysicsObject():SetMass(51)
    end

    self.createTime = CurTime()
end

ENT.DelayZip = 10

function ENT:Think()
    local anim = math.max(self:GetNWFloat("Start",0) - CurTime() + self.DelayZip,0) / self.DelayZip

    if anim > 0 then
        self:ThinkZip(anim)
    else
        self:EndedZip()
    end

    if SERVER then self:PhysWake() end
end

function ENT:ThinkZip()
    if not IsValid(self.soundEmit) then
        self.soundEmit = sound.CreatePoint(self,"homigrad/items/taser/loop.wav",75,"onechannel")
    end

    self.soundEmit:Play()
end

function ENT:EndedZip()
    if IsValid(self.soundEmit) then
        self.soundEmit:Remove()
    end
end

function ENT:Draw() end

