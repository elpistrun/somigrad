--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/ammo_base/tier_0_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\ammo_base\\tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("ammo_base",{"ent_resource_base"},true)
if not ENT then return INCLUDE_BREAK end

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "hg_ammo_base"
ENT.Category = L("weapon_category_ammo")

ENT.Spawnable = true

ENT.OverridePaintIcon = OverridePaintIcon

ENT.itemType = "ammo"

ENT.InvMoveSnd = InvMoveSndAmmo
ENT.SndPickup = "snd_jack_hmcd_ammobox.wav"

