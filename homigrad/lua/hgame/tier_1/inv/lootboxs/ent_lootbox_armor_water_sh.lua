--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/inv/lootboxs/ent_lootbox_armor_water_sh.lua <
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

-- "addons\\homigrad\\lua\\hgame\\tier_1\\inv\\lootboxs\\ent_lootbox_armor_water_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("ent_lootbox_armor_water","ent_lootbox_low")
if not ENT then return end

ENT.PrintName = "LootBox Armor Water"
ENT.Category = "Homigrad"

ENT.WorldModel = "models/props_c17/lockers001a.mdl"

ENT.Name = "lootbox_armor_water"
ENT.w = 2
ENT.h = 3

local random = {
    "ent_jack_gmod_ezarmor_ballon_o2","ent_jack_gmod_ezarmor_respirator",
}

function ENT:GetRandom() return random[math.random(1,#random)] end
function ENT:GetRandomCount() return 2 * 3 end
