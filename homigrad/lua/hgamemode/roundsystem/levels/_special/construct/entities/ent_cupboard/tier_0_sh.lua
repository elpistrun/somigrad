--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/levels/_special/construct/entities/ent_cupboard/tier_0_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hgamemode/roundsystem/levels/_special/construct/init_tier_0_sh.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\levels\\_special\\construct\\entities\\ent_cupboard\\tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("ent_cupboard","base_entity",true)
if not ENT then return INCLUDE_BREAK end

ENT.Type = "anim"
ENT.Author = "0oa"
ENT.Spawnable = true
ENT.AdminSpawnable = false

ENT.PrintName = "Cupboard"
ENT.Category = "Homigrad"

ENT.Model = "models/props_c17/FurnitureDresser001a.mdl"
ENT.WorldModel = "models/props_c17/FurnitureDresser001a.mdl"
ENT.DrawWeaponSelection = DrawWeaponSelection
ENT.OverridePaintIcon = OverridePaintIcon

function ENT:Initialize()
    self:SetModel(self.Model or self.WorldModel or "models/props_c17/FurnitureDresser001a.mdl")
    if SERVER then
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
            phys:EnableMotion(true)
            phys:SetMass(120)
        end
        self:SetUseType(SIMPLE_USE)
    end
end

function ENT:CanPhysgun() return true end
function ENT:CanPhysgunFreeze() return true end

if SERVER then
    function ENT:Use(ply)
        if not IsValid(ply) or not ply:IsPlayer() then return end
        if self:GetNWBool("Uses", false) then
            local ownerSteam = self:GetNWString("OwnerSteamID", "")
            local ownerEnt = self:GetNWEntity("Owner")
            if ownerSteam == ply:SteamID() or ownerEnt == ply or ply:IsAdmin() then
                self:SetNWBool("Uses", false)
                self:SetNWEntity("Owner", NULL)
                self:SetNWString("Name", "")
                self:SetNWString("OwnerSteamID", "")
                ply:ChatPrint("Шкаф деактивирован.")
                local phys = self:GetPhysicsObject()
                if IsValid(phys) then
                    phys:EnableMotion(true)
                    phys:Wake()
                end
            else
                ply:ChatPrint("Этот шкаф принадлежит: " .. tostring(self:GetNWString("Name", "другому игроку")))
            end
            return
        end

        self:SetNWBool("Uses", true)
        self:SetNWEntity("Owner", ply)
        self:SetNWString("Name", ply:Nick())
        self:SetNWString("OwnerSteamID", ply:SteamID())
        ply:ChatPrint(L and L("cupboard_set") or "Шкаф активирован.")
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(true)
            phys:Wake()
        end
    end

    return
end

local white = Color(255,255,255)

function ENT:HUDTarget(ent,k,w,h)
    white.a = 255 * k
    
    local anim = (50 * (1 - k))

    local use = self:GetNWString("Name")
    
    draw.SimpleText(tostring((use and use ~= "") and use or (L and L("spawnpoint_free") or "Свободно")),"ChatFont",w / 2,h / 2 - anim,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
end

