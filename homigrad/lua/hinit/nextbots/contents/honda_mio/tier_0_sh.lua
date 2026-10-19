--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/nextbots/contents/honda_mio/tier_0_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad\\lua\\hinit\\nextbots\\contents\\honda_mio\\tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("npc_honda_mio","npc_alternate",true)
if not ENT then return INCLUDE_BREAK end

ENT.PrintName = "Honda Mio"
ENT.IconOverride = "homigrad/scp/honda_mio/4.png"

ENT.AttackSounds = false
ENT.JumpSounds = false
ENT.TauntSounds = false

ENT.Music = Sound("homigrad/scp/honda_mio/pain.mp3")
ENT.MusicDistance = 99999
ENT.ScanTargetDistance = 9999
ENT.MusicHide = false

ENT.Speed = 800
ENT.Acceleration = 800
ENT.Deceleration = 800

ENT.AttackDelay = 0

ENT.Weapons = {}

function ENT:Init()
    if CLIENT then
        self:SetNWVarProxy("Weapon",function(_,_,old,new)
            self:WeaponChange(old,new)--uf
        end)
    else
        self.StartTime = CurTime()
    end
end

function ENT:WeaponChange(old,new)
    if old == new then return end--;c;c;c

    local wep = self.Weapons[old or ""]
    if wep and wep.Off then wep.Off(self) end

    wep = self.Weapons[new]
    if wep and wep.On then wep.On(self) end
end

function ENT:SetWeapon(name)
    local old = self:GetNWString("Weapon")
    self:SetNWString("Weapon",name)

    self:WeaponChange(old,name)
end

function ENT:GetWeapon() return self:GetNWString("Weapon") end
