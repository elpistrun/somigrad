--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/client/view_armor_config_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\client\\view_armor_config_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
ViewArmorOffsetByModel = ViewArmorOffsetByModel or {}

local femaleSettings = {
    ["ValveBiped.Bip01_Head1"] = {
        vec = Vector(0,-1,0),
        size = -Vector(0,0.1,0)
    },
    ["ValveBiped.Bip01_Spine2"] = {
        vec = Vector(1,-3,0),
        size = -Vector(0.05,0.1,0.01)
    }
}

for i = 1,9 do ViewArmorOffsetByModel["models/player/pandafishizens/female_0" .. i .. ".mdl"] = femaleSettings end//enchaned
for i = 10,25 do ViewArmorOffsetByModel["models/player/pandafishizens/female_" .. i .. ".mdl"] = femaleSettings end//enchaned

for i = 1,9 do ViewArmorOffsetByModel["models/player/group01/female_0" .. i .. ".mdl"] = femaleSettings end//hl2
for i = 1,9 do ViewArmorOffsetByModel["models/player/group03/female_0" .. i .. ".mdl"] = femaleSettings end//hl2 rebels
for i = 1,6 do
    ViewArmorOffsetByModel["models/monolithservers/mpd/female_0" ..i.. ".mdl"] = femaleSettings
    ViewArmorOffsetByModel["models/monolithservers/mpd/female_0" ..i.. "_2.mdl"] = femaleSettings
end

