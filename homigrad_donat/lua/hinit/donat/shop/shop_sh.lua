--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_donat/lua/hinit/donat/shop/shop_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
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

-- "addons\\homigrad_donat\\lua\\hinit\\donat\\shop\\shop_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
if CLIENT then
    BalanceData = BalanceData or {}

    Create_SyncDataManager_AboutSteamID64(BalanceData,"Balance Sync","balance_sync")
end

AdminPanel_Command_Registry("balance_set",{"string","number"}):SetCategory("rcon")
AdminPanel_Command_Registry("balance_donat_set",{"string","number"}):SetCategory("rcon")

event.Add("Balance Sync","Construct",function(steamid64,data)
    data.money = data.money or 0
    data.moneyDonat = data.moneyDonat or 0
end)

ShopConfig = ShopConfig or {}

ShopConfig[5] = {
    name = "Сезонные",
    list = {

    }
}

ShopConfig[1] = {
    name = "donat_ui_shop_model_anime",
    list = {
        {
            category = "Case",
            list = {
                {class = "case",case = "anime",priceDonat = 50},
                {class = "case_key",case = "anime",priceDonat = 25},
                {class = "case",case = "anime2",priceDonat = 50},
                {class = "case_key",case = "anime2",priceDonat = 25},

                {class = "case",case = "anime",price = 3000},
                {class = "case",case = "anime2",price = 4000},
            }
        },
        {
            category = "Models",
            list = {
                {class = "playermodel",model = "models/nuj02/ori/Realistic/Tactical Anime/pm/[tac]ukon_pm.mdl",priceDonat = 3000},
                {class = "playermodel",model = "models/MiSide/mita.mdl",priceDonat = 2000},
                {class = "playermodel",model = "models/drm/vrc/Rabbit_Hole_Miku.mdl",priceDonat = 2000},
                {class = "playermodel",model = "models/MiSide/Player.mdl",priceDonat = 600},
                {class = "playermodel",model = "models/hololive/Hachaama-PM.mdl",priceDonat = 2500},
                {class = "playermodel",model = "models/player/dewobedil/maid_dragon/kanna/default_p.mdl",priceDonat = 2500},
                {class = "playermodel",model = "models/xinus22/mikuhl1.mdl",priceDonat = 2500},
                {class = "playermodel",model = "models/zenlesszonezero/Corin Wickes.mdl",priceDonat = 2500},
                {class = "playermodel",model = "models/gamespy/mesmerizer/MSMikuHatsune.mdl",priceDonat = 2500},
                {class = "playermodel",model = "models/gamespy/mesmerizer/MSKasaneTeto.mdl",priceDonat = 2500},
                {class = "playermodel",model = "models/linqure/yangji/linq_american_soldier_pm.mdl",priceDonat = 2500},
                {class = "playermodel",model = "models/dih/hl2tower_angel.mdl",priceDonat = 2500},
                {class = "playermodel",model = "models/cypo/dokibird/dokibird_pm.mdl",priceDonat = 600},
                {class = "playermodel",model = "models/player/gfl2_lenna.mdl",priceDonat = 600},
                {class = "playermodel",model = "models/player/gfl2_lenna_dorm.mdl",priceDonat = 600},
                {class = "playermodel",model = "models/player/gfl2_lenna_energetic_magic.mdl",priceDonat = 600},
                {class = "playermodel",model = "models/player/gfl2_lenna_flying_phantom.mdl",priceDonat = 600},
                {class = "playermodel",model = "models/player/gfl2_mosin_nagant.mdl",priceDonat = 600},
                {class = "playermodel",model = "models/player/gfl2_mosin_nagant_dorm.mdl",priceDonat = 600},
            }
        }
    }
}

ShopConfig[2] = {
    name = "donat_ui_shop_model_fun",
    list = {
        {
            category = "Cases",
            list = {
                {class = "case",case = "fun",priceDonat = 30},
                {class = "case",case = "fun",price = 300},
                {class = "case_key",case = "fun",priceDonat = 10},
                {class = "case_key",case = "fun",price = 200},
            }
        },
        {
            category = "Models",
            list = {
                {class = "playermodel",model = "models/vedatys/orangutan.mdl",priceDonat = 3000},
                {class = "playermodel",model = "models/player/open season/boog.mdl",priceDonat = 3000},
                {class = "playermodel",model = "models/player/vitaly PM.mdl",priceDonat = 3000},
                {class = "playermodel",model = "models/player/zelenium.mdl",priceDonat = 3000},

                {class = "playermodel",model = "models/player/kuhnya/nagiev.mdl",priceDonat = 500},
                {class = "playermodel",model = "models/nirny/vroid/hev_osaka_san.mdl",priceDonat = 500},
                {class = "playermodel",model = "models/player/rim/el_gato_01_pm.mdl",priceDonat = 500},

                {class = "playermodel",model = "models/kuhnya/barinov.mdl",priceDonat = 500},
                {class = "playermodel",model = "models/kuhnya/senya.mdl",priceDonat = 500},
                {class = "playermodel",model = "models/kuhnya/fedya.mdl",priceDonat = 500},
                {class = "playermodel",model = "models/player/oguzok.mdl",priceDonat = 500},

                {class = "playermodel",model = "models/player/joe/k_pm.mdl",priceDonat = 500},
                {class = "playermodel",model = "models/Dexter_Morgan.mdl",priceDonat = 500},
                {class = "playermodel",model = "models/patrickbateman/Playermodels/patrickbateman.mdl",priceDonat = 500},
                {class = "playermodel",model = "models/theboys/homelander.mdl",priceDonat = 500},
                {class = "playermodel",model = "models/cmbfdr/rashkinsk/bodrov.mdl",priceDonat = 500},
                {class = "playermodel",model = "models/snoopdogg.mdl",priceDonat = 250},
                {class = "playermodel",model = "models/panman/borat_cosplayer_09.mdl",priceDonat = 600},
                {class = "playermodel",model = "models/breaking_bad/hank_schrader.mdl",priceDonat = 600},

                {class = "playermodel",model = "models/player/cj.mdl",priceDonat = 500},
                {class = "playermodel",model = "models/player/santa/santa.mdl",priceDonat = 500},
                {class = "playermodel",model = "models/konnie/isa/detroit/connor.mdl",priceDonat = 500},

                {class = "playermodel",model = "models/vinrax/player/spiderman.mdl",priceDonat = 500},
                {class = "playermodel",model = "models/batdr/henry_stein.mdl",priceDonat = 500},
                {class = "playermodel",model = "models/characters/puze/pu.mdl",priceDonat = 500},
                {class = "playermodel",model = "models/characters/puze/ze.mdl",priceDonat = 500},

                {class = "playermodel",model = "models/vinrax/player/Billy_Herrington.mdl",priceDonat = 500},
                {class = "playermodel",model = "models/carlwheezer/Playermodels/carlwheezer.mdl",priceDonat = 500},
                {class = "playermodel",model = "models/player/jesus/jesus.mdl",priceDonat = 500},
                {class = "playermodel",model = "models/player/azumanga/Barney.mdl",priceDonat = 500},
                {class = "playermodel",model = "models/catalina/lizardman.mdl",priceDonat = 500},
                {class = "playermodel",model = "models/player/drocheslav.mdl",priceDonat = 500},
                {class = "playermodel",model = "models/ronald_mcdonald.mdl",priceDonat = 500},
                {class = "playermodel",model = "models/player/MT_foxtrot_life.mdl",priceDonat = 500},
                {class = "playermodel",model = "models/player/MT_foxtrot.mdl",priceDonat = 500},
            }
        }
    }
}

ShopConfig[3] = {
    name = "donat_ui_shop_model",
    list = {
        {
            category = "Cases",
            list = {
                {class = "case",case = "common",priceDonat = 30},
                {class = "case",case = "common",price = 200},
                {class = "case_key",case = "common",priceDonat = 10},
                {class = "case_key",case = "common",price = 100},
            }
        },
        {
            category = "Models Donat",
            list = {
                {class = "playermodel",model = "models/player/pissbaby.mdl",priceDonat = 3000},
                {class = "playermodel",model = "models/disgustedcat/disgustedcat.mdl",priceDonat = 2000},

                {class = "playermodel",model = "models/player/furry/wolfy.mdl",priceDonat = 250},
                {class = "playermodel",model = "models/eradium/nardo/lepetitnardo.mdl",priceDonat = 250},
                {class = "playermodel",model = "models/Keith3201/Ligeia/Ligeia_pm.mdl",priceDonat = 3000},
                {class = "playermodel",model = "models/boykisser/boykisser.mdl",priceDonat = 3000},
                //{class = "playermodel",model = "models/player/ghost_rider/ghost_rider.mdl",priceDonat = 500},

                {class = "playermodel",model = "models/ebmage/funnyrat.mdl",priceDonat = 500},
                {class = "playermodel",model = "models/Ultrakill/V1_PM.mdl",priceDonat = 500},
                {class = "playermodel",model = "models/Ultrakill/V2.mdl",priceDonat = 500},
                {class = "playermodel",model = "models/gruchk/oc/cool_skeleton.mdl",priceDonat = 250},
                {class = "playermodel",model = "models/player/hellmentor.mdl",priceDonat = 250},
            }
        },
        {
            category = "Models",
            list = {
                {class = "playermodel",model = "models/player/Rusty/NatGuard/male_01.mdl",price = 1000},
                {class = "playermodel",model = "models/player/Rusty/NatGuard/male_02.mdl",price = 1000},
                {class = "playermodel",model = "models/player/Rusty/NatGuard/male_03.mdl",price = 1000},
                {class = "playermodel",model = "models/player/Rusty/NatGuard/male_04.mdl",price = 1000},
                {class = "playermodel",model = "models/player/Rusty/NatGuard/male_05.mdl",price = 1000},
                {class = "playermodel",model = "models/player/Rusty/NatGuard/male_06.mdl",price = 1000},
                {class = "playermodel",model = "models/player/Rusty/NatGuard/male_07.mdl",price = 1000},
                {class = "playermodel",model = "models/player/Rusty/NatGuard/male_08.mdl",price = 1000},
                {class = "playermodel",model = "models/player/Rusty/NatGuard/male_09.mdl",price = 1000},

                {class = "playermodel",model = "models/player/SGG/hev_helmet.mdl",price = 3000},
            }
        }
    }
}

ShopConfig[4] = {
    name = "donat_ui_shop_item",
    list = {
        {
            category = "Cases",
            list = {
                {class = "case",case = "mlg",price = 2000},
                {class = "case_key",case = "mlg",price = 500},

                {class = "case",case = "fireworks",price = 1000},
                {class = "case_key",case = "fireworks",price = 500},

                {class = "case",case = "entities",price = 200},
                {class = "case_key",case = "entities",price = 100},

                {class = "case",case = "vapes",price = 800},
                {class = "case_key",case = "vapes",price = 200},
            }
        },
        {
            category = "Cases Donat Price",
            list = {
                {class = "case",case = "mlg_danger",priceDonat = 1500},
                {class = "case_key",case = "mlg_danger",priceDonat = 500},
                
                {class = "case",case = "mlg",priceDonat = 75},
                {class = "case_key",case = "mlg",priceDonat = 25},

                {class = "case",case = "fireworks",priceDonat = 40},
                {class = "case_key",case = "fireworks",priceDonat = 10},

                {class = "case",case = "entities",priceDonat = 20},
                {class = "case_key",case = "entities",priceDonat = 20},

                {class = "case",case = "vapes",priceDonat = 15},
                {class = "case_key",case = "vapes",priceDonat = 15},
            }
        },
        {
            category = "Инструменты",
            list = {
                {class = "receiver",price = 1000},
                {class = "crafter",price = 1000},
            }
        },
    }
}
