--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_donat/lua/hinit/donat/inventory/items/tier_1/crafter/config_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad_donat/lua/hinit/donat/inventory/items/tier_1/crafter/tier_0_sh.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
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

-- "addons\\homigrad_donat\\lua\\hinit\\donat\\inventory\\items\\tier_1\\crafter\\config_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
DonatCraftList = DonatCraftList or {}

DonatCraftList["bodygroup1_to_5"] = {
    category = "Аксесуары",
    name = "Bodygroup 1 to 5",
    input = {
        {class = "bodygroup",typeItem = 1},
        {class = "bodygroup",typeItem = 1},
        {class = "bodygroup",typeItem = 1},
        {class = "bodygroup",typeItem = 1},
        {class = "bodygroup",typeItem = 1},

        {class = "bodygroup",typeItem = 1},
        {class = "bodygroup",typeItem = 1},
        {class = "bodygroup",typeItem = 1},
        {class = "bodygroup",typeItem = 1},
        {class = "bodygroup",typeItem = 1},
    },
    output = {
        {class = "bodygroup",typeItem = 2},
        {class = "bodygroup",typeItem = 2},
    }
}

DonatCraftList["bodygroup2_to_10"] = {
    category = "Аксесуары",
    name = "Bodygroup 5 to 10",
    input = {
        {class = "bodygroup",typeItem = 2},
        {class = "bodygroup",typeItem = 2},
        {class = "bodygroup",typeItem = 2},
        {class = "bodygroup",typeItem = 2},
    },
    output = {
        {class = "bodygroup",typeItem = 3},
        {class = "bodygroup",typeItem = 3},
    }
}

DonatCraftList["bodygroup3_to_100"] = {
    category = "Аксесуары",
    name = "Bodygroup 10 to 100",
    input = {
        {class = "bodygroup",typeItem = 3},
        {class = "bodygroup",typeItem = 3},
        {class = "bodygroup",typeItem = 3},
        {class = "bodygroup",typeItem = 3},
        {class = "bodygroup",typeItem = 3},
        {class = "bodygroup",typeItem = 3},
        {class = "bodygroup",typeItem = 3},
        {class = "bodygroup",typeItem = 3},
        {class = "bodygroup",typeItem = 3},
        {class = "bodygroup",typeItem = 3},
    },
    output = {
        {class = "bodygroup",typeItem = 4},
    }
}

DonatCraftList["bodygroup4_to_money"] = {
    category = "Аксесуары",
    name = "Bodygroup 100 to 1000 money",
    input = {
        {class = "bodygroup",typeItem = 4},
    },
    output = {
        {class = "money",money = 1000},
    }
}

DonatCraftList["mlg_to_mlg_danger"] = {
    category = "Аксесуары",
    name = "10 MLG to MLG DANGER",
    input = {
        {class = "case",case = "mlg"},
        {class = "case",case = "mlg"},
        {class = "case",case = "mlg"},
        {class = "case",case = "mlg"},
        {class = "case",case = "mlg"},
        {class = "case",case = "mlg"},
        {class = "case",case = "mlg"},
        {class = "case",case = "mlg"},
        {class = "case",case = "mlg"},
        {class = "case",case = "mlg"},
    },
    output = {
        {class = "case",case = "mlg_danger"},
    }
}

DonatCraftList["key_fun_to_anime"] = {
    category = "Ключи",
    name = "Key Fun Models > Key Anime Models",
    input = {
        {class = "case_key",case = "fun"},
        {class = "case_key",case = "fun"},

        {class = "bodygroup",typeItem = 4},
        {class = "bodygroup",typeItem = 4},
        {class = "bodygroup",typeItem = 4},
        
        {class = "receiver"},
    },
    output = {
        {class = "case_key",case = "anime"},
    }
}

DonatCraftList["key_fun_to_anime2"] = {
    category = "Ключи",
    name = "Key MLG > Key Anime Models 2",
    input = {
        {class = "case_key",case = "mlg"},
        {class = "case_key",case = "mlg"},

        {class = "bodygroup",typeItem = 4},
        {class = "bodygroup",typeItem = 4},
        {class = "bodygroup",typeItem = 4},

        {class = "receiver"},
    },
    output = {
        {class = "case_key",case = "anime2"},
    }
}

DonatCraftList["combat_pass"] = {
    category = "Ключи",
    name = "ZOMBIE SURVIVAL PASS",
    input = {
        {class = "item",item = "sent_she_sleep"},
        {class = "item",item = "sent_she_fire"},
        {class = "item",item = "sent_she_sleep"},
        {class = "item",item = "sent_she_fire"},

        {class = "bodygroup",typeItem = 4},
    },
    output = {
        {class = "combat_pass"},
        {class = "combat_pass"},
    }
}

DonatCraftList["halflife_pass"] = {
    category = "Ключи",
    name = "HALFLIFE 2 COOP PASS",
    input = {
        {class = "item",item = "sent_she_tick"},
        {class = "item",item = "sent_she_fire"},
        {class = "item",item = "sent_she_sleep"},
        
        {class = "bodygroup",typeItem = 3},
        {class = "bodygroup",typeItem = 3},
        {class = "bodygroup",typeItem = 3},
        {class = "bodygroup",typeItem = 3},
        {class = "bodygroup",typeItem = 3},
    },
    output = {
        {class = "halflife_pass"},
        {class = "halflife_pass"},
    }
}
