--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/med/med_needle/tier_0_sh.lua <
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

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\med\\med_needle\\tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Reg("med_needle","med_kit",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName = L("med_needle")
SWEP.Instructions = L("med_needle_desc")

SWEP.Slot = 3
SWEP.SlotPos = 3

SWEP.WorldModel = "models/bloocobalt/l4d/items/w_eq_adrenaline.mdl"

SWEP.vbwPos = Vector(-2,-1.5,-7)
SWEP.vbwAng = Angle(-90,90,180)
SWEP.vbwModelScale = Vector(0.8,0.8,0.8)

SWEP.vbwPos2 = Vector(-3,0.2,-7)
SWEP.vbwAng2 = Angle(-90,90,180)

SWEP.dwsItemPos = Vector(0,-1.5,-0.7)
SWEP.dwsItemAng = Angle(90 - 45,-90,0)
SWEP.dwsItemFOV = -13

function SWEP:vbwFunc(ply)
    local ent = ply:GetWeapon("medkit")
    if ent and ent.vbwActive then return self.vbwPos,self.vbwAng end
    return self.vbwPos2,self.vbwAng2
end

SWEP.InvMoveSnd = InvMoveSnd

SWEP.wmVector = Vector(3.5,2,0)
SWEP.wmAngle = Angle(0,0,-90)

SWEP.HealSound = "items/medshot4.wav"
SWEP.InvCount = 1
SWEP.Charges = 1

function SWEP:ApplyEffect(target, isSelf, entHit)
    local curBlood = target.blood or target:GetNWFloat("blood", 5000)
    local newBlood = math.min(5000, curBlood + 1200)
    target.blood = newBlood
    target:SetNWFloat("blood", newBlood)

    local curHp = target:Health()
    local maxHp = target:GetMaxHealth()
    target:SetHealth(math.min(maxHp, curHp + 35))

    local curPain = target:GetNWFloat("pain", 0)
    target.pain = math.max(0, curPain - 30)
    target:SetNWFloat("pain", target.pain)
end

