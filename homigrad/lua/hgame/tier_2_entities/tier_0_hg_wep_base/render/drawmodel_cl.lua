--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/tier_0_hg_wep_base/render/drawmodel_cl.lua <
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

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\tier_0_hg_wep_base\\render\\drawmodel_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Get("hg_wep_base")
if not SWEP then return end

local empty = {}

SWEP.GunRenderOverride = false

function SWEP:InitWorldModel(tag,isWorldModel)
    if isWorldModel == nil then isWorldModel = true end

    local wm = self:GetWorldModelName()
    local wm,isCreate = CSMById(wm,tostring(self) .. wm .. (tag or ""),isWorldModel)

    if isCreate then
        self.wm = wm

        wm:SetModelScale(self.wmScale)

        for id,value in pairs(self.WorldBodygroups or empty) do
            wm:SetBodygroup(id,value)
        end
    end

    return wm,isCreate
end

SWEP.wmVectorDrop = Vector(0,0,0)
