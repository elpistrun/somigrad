--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/tier_0_hg_wep_base/render/draw_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hgame/tier_2_entities/tier_0_hg_wep_base/tier_0_sh.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\tier_0_hg_wep_base\\render\\draw_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Get("hg_wep_base")
if not SWEP then return end

event.Add("PlayerDraw","Weapon",function(ply,tag,link)
    link = link or ply
    local owner = (IsValid(link) and link:IsPlayer() and link) or (IsValid(ply) and ply:IsPlayer() and ply) or (ply.GetPlayer and ply:GetPlayer()) or (ply.GetNWEntity and ply:GetNWEntity("RagdollOwner"))
    if not IsValid(owner) or not owner:IsPlayer() then return end

    local wep = owner:GetActiveWeapon()

    if IsValid(wep) and wep.DrawFromPlayer then
        wep:DrawFromPlayer(ply,tag,owner)
    end
end)

function SWEP:DrawFromPlayer(ply,tag,link)
    if not self.EnableTransformModel then return end
    
    local isWorld = (not tag and true) or false

    -- SetupGun returns nothing when the hold bone is not there yet (first frames after a
    -- spawn or a model change) or when the model has no usable hand bone at all. Render()
    -- indexes the model immediately, so a nil gun has to be a skipped frame, not a call:
    -- passing it on threw "attempt to index local 'gun' (a nil value)" from
    -- cl_drawworldmodel.lua:33 on every pass, for every weapon.
    local gun = self:SetupGun(ply,isWorld)
    if not gun then return end

    self:Render(gun)
end

function SWEP:SetupGun(rag,isWorld)
    local Pos,Ang = self:GetTransformFromRagdoll(rag)
    if not Pos then return end
    
    local gun = self:InitWorldModel(nil,isWorld)
    gun:SetPos(Pos)
    gun:SetAngles(Ang)
    gun:SetupBones()

    self:SetupGunPost(rag,gun,isWorld)

    return gun
end

function SWEP:SetupGunPost() end

function SWEP:DrawFromNPC(rag)
    local gun = self:SetupGun(rag,true)
    if not gun then return end

    self:Render(gun)
end

SWEP.wmVectorDrop = Vector(0,0,0)

function SWEP:DrawFromWorld()
    local gun,isCreate = self:InitWorldModel("world",false)
    gun:SetPos(self:GetPos():Add(self.wmVectorDrop:Clone():Rotate(self:GetAngles())))
    gun:SetAngles(self:GetAngles())
    gun:SetupBones()

    self:SetupGunPost(gun)
    self:Render(gun)
end

// Render

function SWEP:DrawWorldModel()//engine function
    local owner = self:GetOwner()
    
    if self.EnableTransformModel and IsValid(owner) then
        self:SetupBones()//Почему-то без него SetBoneMatrix не будет работать на игроке... 

        if not owner:IsPlayer() then
            self:DrawFromNPC(owner)
        end

        return
    end

    self:DrawFromWorld()
end

function SWEP:Render(gun)
    gun:DrawModel()

    self:DrawWorldModelPost(gun)
end

hook.Add("PreDrawEffects","Weapons",function()
    if RenderScope or GetViewEntity() ~= LocalPlayer() then return end
    
    render.ClearDepth(true)
    local wep = LocalPlayer():GetActiveWeapon()
    if not IsValid(wep) or not wep.PreDrawEffects then return end

    CamReset(0.01)
    render.SetColorModulation(1,1,1)
    wep:PreDrawEffects()
    cam.End3D()
end)
