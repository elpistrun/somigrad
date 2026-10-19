--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/inv/lootboxs/ent_destroy_storage_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\inv\\lootboxs\\ent_destroy_storage_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("ent_destroy_storage","base_entity")
if not ENT then return end

ENT.Type = "anim"
ENT.Author = "0oa"
ENT.Spawnable = true
ENT.AdminSpawnable = false

ENT.PrintName = "lootbox_destroy"
ENT.Category = "Homigrad"

ENT.WorldModel = "models/homigrad/creates/supply2.mdl"
ENT.WorldSkin = 2
ENT.DrawWeaponSelection = DrawWeaponSelection
ENT.OverridePaintIcon = OverridePaintIcon
ENT.dwsPos = Vector(75,75,45)
ENT.dwsItemPos = Vector(0,0,0)

ENT.Name = "lootbox_destroy"

if SERVER then
    function ENT:Initialize()
        self:SetModel(self.WorldModel)
        self:SetSkin(self.WorldSkin)
        
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
    end
    
    function ENT:Use(ply)
        if not ply:IsLookOn(self) or self.isGhost then return end

        self.inv:Open(ply)
    end
    
    function InvDestroy(inv)
        if not inv or not inv.GetAllItems then return end
        if homigrad_cleaning_map or GetGlobalBool("MapCleaning", false) then return end
        if #inv:GetAllItems() == 0 then return end
        if not IsValid(inv.parent) then return end
        
        local ent = ents.Create("ent_destroy_storage")
        if not IsValid(ent) then return end
        ent:SetPos(inv.parent:GetPos() + inv.parent:OBBCenter())
        ent:SetAngles(inv.parent:GetAngles())
        ent:Spawn()
    
        ent.inv = inv
        inv:SetParent(ent,"storage")
    
        inv.CanInsertItem = function() return false end
        inv.PopItem = function() if #inv:GetAllItems() == 0 then ent:Remove() end end
    
        inv.OnOpen = function() ent:EmitSound("physics/cardboard/cardboard_box_impact_hard3.wav") end
        inv.OnClose = function()
            if #inv:GetAllItems() == 0 then
                ent:EmitSound("physics/wood/wood_plank_break" .. math.random(1,4) .. ".wav")

                ent:Remove()
            else
                ent:EmitSound("physics/cardboard/cardboard_box_impact_soft3.wav")
            end
        end

        ent:PhysWake()
    end

    function ENT:CanPhysgun() return true end
    function ENT:CanPhysgunFreeze() return true end

    return
else
    function ENT:CanPhysgun() return true end
    function ENT:CanPhysgunFreeze() return true end
    ENT.HUDTarget = oop.listClass.ent_lootbox_low[1].HUDTarget
end

