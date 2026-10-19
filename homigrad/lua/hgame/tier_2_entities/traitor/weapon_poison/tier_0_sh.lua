--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/traitor/weapon_poison/tier_0_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hgame/tier_2_entities/traitor/explosive_hidebomb_sh.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\traitor\\weapon_poison\\tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Reg("weapon_poison","med_kit",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName = L("weapon_poison")
SWEP.Author = "akurse"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Category = L("weapon_category_traitor")

SWEP.WorldModel = "models/weapons/w_models/w_syringe_proj.mdl"

SWEP.ShouldDropOnDie = false
SWEP.Charges = 3

SWEP.HoldType = "normal"

SWEP.EnableTransformModel = true

SWEP.wmVector = Vector(4,2,-3)
SWEP.wmAngle = Angle(0,-90,0)

SWEP.dwsItemPos = Vector(1.8,30,0)
SWEP.dwsItemAng = Angle(45,0,0)

SWEP.itemType = "poison"
SWEP.itemColor = Color(220, 30, 30)

function SWEP:Initialize()
    self:SetModel(self.WorldModel or "models/weapons/w_models/w_syringe_proj.mdl")
    self:DrawShadow(false)
    self:Event_Call("Init")
    self:OnInit()
end

function SWEP:OnDrop()
    self:SetModel(self.WorldModel or "models/weapons/w_models/w_syringe_proj.mdl")
    if not self:PhysicsInit(SOLID_VPHYSICS) or not IsValid(self:GetPhysicsObject()) then
        self:PhysicsInitBox(Vector(-6, -2, -2), Vector(6, 2, 2))
        self:SetCollisionBounds(Vector(-6, -2, -2), Vector(6, 2, 2))
    end
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(true)
    end
end

function SWEP:ApplyEffect(target, isSelf, entHit)
    local curPoison = target:GetNWFloat("PoisonValue", 0)
    target:SetNWFloat("PoisonValue", curPoison + 0.35)
    target.pain = (target.pain or 0) + 15
    target:SetNWFloat("pain", target.pain)
end


hook.Add("RenderScreenspaceEffects","Poison",function()
	local ply = LocalPlayer()
	if not ply:Alive() then return end

	if hook.Run("Should Draw Screenspace") == false then return end

    local k = ply:GetNWFloat("PoisonValue",0)
    k = math.Clamp(math.max(k - 0.25,0) * 5,0,1)

    if k <= 0 then return end

    k = k / 3

    DrawMotionBlur(0.4 - k / 10,0.1 + k,0.15)
end)

