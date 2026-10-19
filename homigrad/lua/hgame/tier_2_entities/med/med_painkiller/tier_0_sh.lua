--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/med/med_painkiller/tier_0_sh.lua <
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

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\med\\med_painkiller\\tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Reg("med_painkiller","med_kit",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName = L("med_painkiller")
SWEP.Instructions = L("med_painkiller_desc")

SWEP.Spawnable = true

SWEP.Slot = 3
SWEP.SlotPos = 3

SWEP.WorldModel = "models/w_models/weapons/w_eq_painpills.mdl"

SWEP.vbwPos = Vector(-5,6,-7)
SWEP.vbwAng = Angle(90,0,0)
SWEP.vbwModelScale = Vector(0.8,0.8,0.8)

SWEP.vbwPos2 = Vector(-2.2,5,-7)
SWEP.vbwAng2 = Angle(90,0,0)

SWEP.dwsItemPos = Vector(0,0,-3)
SWEP.dwsItemAng = Angle(0,-90,0)
SWEP.dwsItemFOV = -15

function SWEP:vbwFunc(ply)
    local ent = ply:GetWeapon("medkit")
    if ent and ent.vbwActive then return self.vbwPos,self.vbwAng end
    return self.vbwPos2,self.vbwAng2
end

SWEP.InvMoveSnd = InvMoveSnd
SWEP.InvCount = 1

SWEP.wmVector = Vector(3,2,0)
SWEP.wmAngle = Angle(0,0,180)

SWEP.HealSound = "snd_jack_bandage.ogg"
SWEP.Charges = 1

function SWEP:ApplyEffect(target, isSelf, entHit)
    local curPain = target:GetNWFloat("pain", 0)
    local newPain = math.max(0, curPain - 90)
    target.pain = newPain
    target:SetNWFloat("pain", newPain)

    if (target.Otrub or target:GetNWBool("Otrub", false)) and newPain < 160 then
        target.Otrub = false
        target:SetNWBool("Otrub", false)
        target:SetNW2Bool("Otrub", false)
    end
end

