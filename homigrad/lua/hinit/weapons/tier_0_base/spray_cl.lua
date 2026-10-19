--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/weapons/tier_0_base/spray_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hinit/weapons/tier_0_base/tier_0_sh.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad\\lua\\hinit\\weapons\\tier_0_base\\spray_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Get("hg_wep")
if not SWEP then return end

SWEP.eyeSpray = Angle()
SWEP.eyeSpraySet = Angle()

local angZero = Angle()

SWEP.eyeSprayLSet = 0.2
SWEP.eyeSprayLReset = 0.1

SWEP:Event_Add("Think","Eye",function(self,owner,ft,time)
    if not self:IsLocal() then return end

    self:ApplyEye()
    
    self.eyeSpray:Lerp(self.eyeSprayLSet,self.eyeSpraySet)
    self.eyeSpraySet:Lerp(self.eyeSprayLReset)
end)

local min = math.min

SWEP.eyeSprayHoldK = 1

function SWEP:ApplyEye()
    local ply = self:GetOwner()
    local k = min(1 + (CurTime() - self.attackHold) * self.eyeSprayHoldK,5) * 0.8

    local ang = ply:EyeAngles():Add(self.eyeSpray * k)

    ang:Add(Angle(0.05 * math.sin(math.rad(360 * self.recoil)),0,0))

    ply:SetEyeAngles(ang)
end

SWEP.eyeSprayH = 0.3

SWEP.eyeSpraySinAddW = 0
SWEP.eyeSpraySinW = 0.075
SWEP.eyeSpraySinFreqW = 3

SWEP.eyeSpraySinRandW = 0.2
SWEP.eyeSprayRandW = 0.1

function SWEP:ApplySpray()
    local time = CurTime() - self.attackHold

    local add = Angle(
        -math.Rand(0.1,0.2) * self.eyeSprayH * math.Rand(0.95,1.05),
        math.sin(self.eyeSpraySinAddW + time * self.eyeSpraySinFreqW + self.eyeSpraySinRandW * math.Rand(-0.1,0.1)) * self.eyeSpraySinW * math.Rand(0.95,1.05) +
        self.eyeSprayRandW * math.Rand(-0.35,0.35) * math.Rand(0.95,1.05),
        0)

    add:Add(Angle(0,math.Rand(-0.15,0.15)))

    self.eyeSpraySet:Add(add)

    self:ApplyEye()
end
