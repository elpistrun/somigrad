--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/levels/hl2tdm/combine_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hgamemode/roundsystem/levels/hl2tdm/init_tier_0_sh.lua:3
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

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\levels\\hl2tdm\\combine_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local CLASS = player.RegClass("combine")
if not CLASS then return end

CLASS.main_weapons = {
    "weapon_sar2","weapon_spas12","weapon_mp7"
}

function CLASS:Off()
    if CLIENT then return end

    self.isCombine = nil
    self.cantUsePer4ik = nil
    self.ProtectFireGas = nil
    self.stopHungry = nil
end

function CLASS:On()
    if CLIENT then return end

    self:SetModel("models/player/combine_soldier.mdl")

    self:SetHealth(150)
    self:SetMaxHealth(150)

    self.isCombine = true
    self.cantUsePer4ik = true
    self.ProtectFireGas = true

    self.stopHungry = true
    
    self:EmitSound("radio/go.wav")

    if SERVER then self:PlayerClassEvent("UpdateUnvisible") end
end

function CLASS:CreateNPC(ent)
    if not NPCS_Combine[ent] then return end
    
    self:PlayerClassEvent("UpdateUnvisible")
end

function CLASS:UpdateUnvisible()
    for ent in pairs(NPCS_Combine) do
        if not IsValid(ent) then NPCS_Combine[ent] = nil continue end

        ent:AddEntityRelationship(self,D_LI,99)
    end
end

function CLASS:PlayerFootstep(pos,foot,name,volume,filter)
    if SERVER then return true end

    sound.Emit(nil,"npc/combine_soldier/gear" .. math.random(1,6) .. ".wav",75,1,100,pos)
end

local function getList(self)
    local list = {}

    for i,ply in RandomPairs(player.GetAll()) do
        if ply == self or not ply.isCombine then continue end
        
        local pos = ply:EyePos()
        local deathPos = self:GetPos()

        if pos:Distance(deathPos) > 1000 then continue end

        local trace = {start = pos}
        trace.endpos = deathPos
        trace.filter = ply
        
        if util.TraceLine(trace).HitPos:Distance(deathPos) <= 512 then
            list[#list + 1] = ply
        end
    end

    return list
end

function CLASS:PlayerDeath()
    sound.Play(Sound("npc/overwatch/radiovoice/die" .. math.random(1,3) .. ".wav"),self:GetPos())
    --self:EmitSound("npc/combine_soldier/die" .. math.random(1,3) .. ".wav")

    for i,ply in RandomPairs(getList(self)) do
        sound.Emit(ply:EntIndex(),Sound("npc/combine_soldier/vo/ripcordripcord.wav"))

        break
    end

    self:SetPlayerClass()
end

function CLASS:Think()
    if SERVER then
        if (self.delaysoundpain or 0) < CurTime() then
            self.pain = math.max(self.pain - 45 * FrameTime())
            self.blood = math.min(self.blood + 7.5 * FrameTime(),5000)
        end

        if (self.delayNeedle or 0) < CurTime() and self:Health() < self:GetMaxHealth() / 4 then
            self.delayNeedle = CurTime() + 10

            self:SetHealth(math.min(self:Health() + 75,self:GetMaxHealth()))
        end
    end
end

function CLASS:PlayerStartVoice()
    for i,ply in pairs(player.GetAll()) do
        if not ply.isCombine then continue end

        sound.Emit(ply:EntIndex(),"npc/combine_soldier/vo/on" .. math.random(1,3) .. ".wav",75,0.5,100)
    end
end

function CLASS:PlayerEndVoice()
    for i,ply in pairs(player.GetAll()) do
        if not ply.isCombine then continue end

        sound.Emit(ply:EntIndex(),"npc/combine_soldier/vo/off" .. math.random(1,3) .. ".wav",75,0.5,100)
    end
end

function CLASS.CanLisenOutput(output,input,isChat)
    --if input.isCombine then return true end
end

function CLASS.CanLisenInput(input,output,isChat)
    --if not output:Alive() then return false end
end

function CLASS:DamageInput(att,dmgInfo,hitGroup)
    if (self.delaysoundpain or 0) < CurTime() then
        self.delaysoundpain = CurTime() + math.Rand(0.25,0.5)

        sound.Emit(self:EntIndex(),"npc/combine_soldier/pain" .. math.random(1,3) .. ".wav")
    end
end
