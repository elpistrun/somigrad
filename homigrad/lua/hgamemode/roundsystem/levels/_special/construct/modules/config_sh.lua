--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/levels/_special/construct/modules/config_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hgamemode/roundsystem/levels/_special/construct/init_tier_0_sh.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\levels\\_special\\construct\\modules\\config_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Level = oop.Get("level_construct")
if not Level then return end

Level.limits = {
    prop = 10,
    sent = 10,
    vehicle = false,
    swep = false,
    tool = true
}

Level.cooldownTypes = {
    prop = 1,
    sent = 2.5,
    swep = 5
}

Level.blacklistModel = {
    ["models/props_c17/oildrum001_explosive.mdl"] = true,
    ["models/props_junk/gascan001a.mdl"] = true,
    ["models/props_junk/propane_tank001a.mdl"] = true,

    ["models/props_phx/torpedo.mdl"] = true,
    ["models/props_phx/mk-82.mdl"] = true,
    ["models/props_phx/ww2bomb.mdl"] = true,
    ["models/props_phx/oildrum001_explosive.mdl"] = true,
    ["models/props_phx/ball.mdl"] = true,
    ["models/props_phx/amraam.mdl"] = true,
    ["models/props_c17/canister02a.mdl"] = true,
    ["models/props_junk/metalgascan.mdl"] = true,
    ["models/props_c17/canister01a.mdl"] = true,

    ["models/props_junk/propanecanister001a.mdl"] = true,
    ["models/props_junk/PropaneCanister001a.mdl"] = true,
    
    ["models/tadano/fumo/pack/flandere.mdl"] = true,
    ["models/tadano/fumo/pack/cirno.mdl"] = true,
    ["models/tadano/fumo/pack/inu.mdl"] = true,
    ["models/tadano/fumo/pack/reimu.mdl"] = true,
    ["models/tadano/fumo/pack/yuuka.mdl"] = true,
    ["models/tadano/fumo/pack/yuyu.mdl"] = true,
    ["models/tadano/fumo/pack/remilia.mdl"] = true
}

Level.CantPhysgunByClass = {
    "ent_jack_gmod_eztimebomb"
}

Level.tool = {
    ["colour"] = true,
    ["remover"] = true,
    ["keypad_willox"] = true,
    ["fading_door"] = true
}
