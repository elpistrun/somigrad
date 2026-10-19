--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/inv/lootboxs/ent_lootbox_armor_sh.lua <
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

-- "addons\\homigrad\\lua\\hgame\\tier_1\\inv\\lootboxs\\ent_lootbox_armor_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("ent_lootbox_armor","ent_lootbox_low")
if not ENT then return end

ENT.PrintName = "LootBox Armor"
ENT.Category = "Homigrad"

ENT.WorldModel = "models/homigrad/creates/medium.mdl"
ENT.WorldSkin = 1

ENT.Name = "lootbox_armor"
ENT.w = 3
ENT.h = 2

local random = {
    "ent_jack_gment_jack_gmod_ezarmor_balmaskod_ezarmor_ballon_o2","ent_jack_gmod_ezarmor_maska",

    "ent_jack_gmod_ezarmor_slcalf","ent_jack_gmod_ezarmor_srcalf","ent_jack_gmod_ezarmor_slforearm","ent_jack_gmod_ezarmor_srforearm",

    "ent_jack_gmod_ezarmor_llshoulder","ent_jack_gmod_ezarmor_lrshoulder",
    "ent_jack_gmod_ezarmor_llthigh","ent_jack_gmod_ezarmor_lrthigh",


    "ent_jack_gmod_ezarmor_thunderbolt","ent_jack_gmod_ezarmor_sprofiass","ent_jack_gmod_ezarmor_azimutb","ent_jack_gmod_ezarmor_bankrobber",

    "ent_jack_gmod_ezarmor_mhtorso","ent_jack_gmod_ezarmor_mhtorso","ent_jack_gmod_ezarmor_mhtorso","ent_jack_gmod_ezarmor_mhtorso"
}

function ENT:GetRandom() return random[math.random(1,#random)] end
function ENT:GetRandomCount() return 6 end
