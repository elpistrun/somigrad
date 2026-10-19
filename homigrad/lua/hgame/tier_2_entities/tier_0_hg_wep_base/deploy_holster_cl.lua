--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/tier_0_hg_wep_base/deploy_holster_cl.lua <
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

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\tier_0_hg_wep_base\\deploy_holster_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Get("hg_wep_base")
if not SWEP then return end

net.Receive("wep holster",function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end

    local nextWep = net.ReadEntity()
    ent.holsterCan = true

    if IsValid(nextWep) then
        input.SelectWeapon(nextWep)
    else
        ent:Holster(nextWep)
    end
end)

net.Receive("wep deployed",function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end

    ent:Deployed()
end)

net.Receive("wep holstered",function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end

    ent:Holstered()
end)

net.Receive("wep holstered end",function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end

    ent:HolsteredEnd()
end)

function SWEP:CanHolster() return self.holsterCan end

function SWEP:Holster(newWep)
    if not self:CanHolster() then self:SetNWFloat("HolsterStart",CurTime()) return false end

    self.holsterCan = nil

    self:HolsteredEnd()

    return true
end
