--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/tier_0_hg_wep_base/util_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
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

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\tier_0_hg_wep_base\\util_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Get("hg_wep_base")
if not SWEP then return end

function SWEP:IsLocal() return SERVER or self:GetOwner() == LocalPlayer() end

function SWEP:SetStandType(value)
    value = value or "normal"
    
    self:SetNWString("HoldType",value)

    self:SetupStandType()
end

function SWEP:SetupStandType()
    self:SetWeaponHoldType(self:GetNWString("HoldType","normal"))--боже какая эта игра залупа ебаная
    --убить нахуй кто за неты отвечал
end

hook.Add("DoAnimationEvent","Homigrad Weapons",function(ply,event,data)
    local wep = ply:GetActiveWeapon()

    if IsValid(wep) and wep.DoAnimationEvent then return wep:DoAnimationEvent(ply,event,data) end
end)

function SWEP:OwnerChanged()
    self.deployed = nil
    self:Event_Call("Owner Changed")
end

function SWEP:OnDrop(owner)
    if not self:PhysicsInit(SOLID_VPHYSICS) or not IsValid(self:GetPhysicsObject()) then
        self:PhysicsInitBox(Vector(-8, -3, -3), Vector(8, 3, 3))
        self:SetCollisionBounds(Vector(-8, -3, -3), Vector(8, 3, 3))
    end
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(true)
    end
    
    self:Event_Call("Owner Changed")
end

SWEP:Event_Add("Holster End","Off",function(self) self:Event_Call("Off") end)
SWEP:Event_Add("Owner Changed","Off",function(self) self:Event_Call("Off") end)
SWEP:Event_Add("Remove","Off",function(self) self:Event_Call("Off") end)

function SWEP:IsGhostWalk()
    local owner = self:GetOwner()
    if not IsValid(owner) or owner:IsNPC() then return end

    return owner:KeyDown(IN_DUCK) or owner:KeyDown(IN_WALK)
end
