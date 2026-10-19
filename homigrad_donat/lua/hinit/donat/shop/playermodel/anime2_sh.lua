--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_donat/lua/hinit/donat/shop/playermodel/anime2_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
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

-- "addons\\homigrad_donat\\lua\\hinit\\donat\\shop\\playermodel\\anime2_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal

DonatItem_PlayerModelEasyReg("models/animeworld/hutao_tac.mdl","Tactical Hu Tao","","epic",{
    xp = 10000,
    raryType = "legendary",
    [3] = {
        name = "Head",
        max = 4
    },
    [4] = {
        name = "Vest",
        max = 1
    },
    [6] = {
        name = "Backpack",
        max = 1
    },
    [7] = {
        name = "Headset",
        max = 1
    },
    [8] = {
        name = "Faceover",
        max = 1
    },
    [9] = {
        name = "NVG Grip",
        max = 1
    },
    [10] = {
        name = "NVG",
        max = 1
    },
    [11] = {
        name = "Eye-patch",
        max = 1
    },
    [12] = {
        name = "Accessories",
        max = 1
    },
    [13] = {
        name = "Bants",
        max = 1
    },
    [16] = {
        name = "Glasses",
        max = 2
    },
    [20] = {
        name = "Ring",
        max = 1
    },
    [21] = {
        raryType = "epic",
        xp = 30000,
        name = "Shoes",
        max = 1
    }
},
{
    [3] = 2,
    [4] = 1,
    [5] = 1,
    [6] = 1,
    [7] = 1,
    [8] = 1,
    [9] = 1,
    [10] = 2,
    [16] = 2,
    [20] = 1
})
ViewArmorOffsetByModel["models/animeworld/hutao.mdl"] = {
    ["ValveBiped.Bip01_Head1"] = {
        vec = Vector(-1.3,-0.5,0),
        size = Vector(0.05,0.05,0),
    },
    ["ValveBiped.Bip01_Spine2"] = {
        vec = Vector(3.2,-4,0),
        size = -Vector(0.2,0.1,0.1)
    }
}


DonatItem_PlayerModelEasyReg("models/animeworld/hutao.mdl","Hu Tao","","legendary",{
    xp = 4000,
    raryType = "rary",
    [3] = {
        name = "Headset",
        max = 8
    },
    [4] = {
        name = "Moustache",
        max = 1
    },
    [5] = {
        name = "Eye-patch",
        max = 1
    },
    [6] = {
        name = "Accessories",
        max = 1
    },
    [7] = {
        name = "Bants",
        max = 1
    },
    [10] = {
        name = "Glasses",
        max = 2
    },
    [15] = {
        name = "Ring",
        max = 1
    },
    [16] = {
        raryType = "epic",
        xp = 30000,
        name = "Shoes",
        max = 1,
    }
},
{
    [3] = 8,
    [15] = 1
})
ViewArmorOffsetByModel["models/animeworld/hutao.mdl"] = {
    ["ValveBiped.Bip01_Head1"] = {
        vec = Vector(-1.3,-0.5,0),
        size = Vector(0.05,0.05,0),
    },
    ["ValveBiped.Bip01_Spine2"] = {
        vec = Vector(3.2,-4,0),
        size = -Vector(0.2,0.1,0.1)
    }
}

DonatItem_PlayerModelEasyReg("models/vrc/ukon.mdl","UKON","","epic",{
    xp = 10000,
    raryType = "legendary",
    [3] = {
        name = "Косички",
        max = 1
    },
    [5] = {
        name = "Кошачьи уши",
        max = 1
    },
    [6] = {
        name = "Бантик",
        max = 1
    },
    [7] = {
        name = "Косички верёвки",
        max = 1
    },
    [8] = {
        name = "Длинная обувь",
        max = 1
    },
    [10] = {
        name = "Юбка",
        max = 1
    },
    [11] = {
        name = "Хвост",
        max = 1
    },
    [12] = {
        name = "Задние бантики",
        max = 1
    },
    [14] = {
        name = "Амулет",
        max = 1
    },
    [15] = {
        name = "Амулетные шипы",
        max = 1
    },
    [16] = {
        name = "Хвост",
        max = 1
    },
    [17] = {
        name = "Туфли",
        max = 1
    },
    [18] = {
        name = "Задние бантики 2",
        max = 1
    }
},{
    [3] = 1,
    [5] = 1,
    [6] = 1,
    [7] = 1,
    [8] = 1,
    [10] = 1,
    [11] = 1,
    [12] = 1,
    [14] = 1,
    [15] = 1,
    [16] = 1,
    [17] = 1,
    [18] = 1
})
ViewArmorOffsetByModel["models/vrc/ukon.mdl"] = {
    ["ValveBiped.Bip01_Head1"] = {
        vec = Vector(-1,0.1,0),
        size = Vector(0.1,0.1,0.1),
    },
    ["ValveBiped.Bip01_Spine2"] = {
        vec = Vector(2,-3.7,0),
        size = -Vector(0.25,0.1,0.1)
    }
}

DonatItem_PlayerModelEasyReg("models/player/gfl2_cheeta.mdl","Cheeta","","rary",{
    xp = 4000,
    raryType = "rary",
    [3] = {
        name = "Берета",
        max = 1
    },
    [4] = {
        name = "Наушники",
        max = 1
    },
    [5] = {
        name = "Shoulder Plate",
        max = 1
    },
    [6] = {
        name = "Radio",
        max = 1
    },
    [7] = {
        name = "Handbag",
        max = 1
    },
    [8] = {
        name = "Panda Bags",
        max = 1
    },
    [9] = {
        name = "Leg Pouch",
        max = 1
    }
},{
    [3] = 1,
    [4] = 1,
    [5] = 1,
    [6] = 1,
    [7] = 1,
    [8] = 1,
    [9] = 1
})
ViewArmorOffsetByModel["models/player/gfl2_cheeta.mdl"] = {
    ["ValveBiped.Bip01_Head1"] = {
        vec = Vector(-1,-0.6,0),
        size = -Vector(0.1,0.1,0.1),
    },
    ["ValveBiped.Bip01_Spine2"] = {
        vec = Vector(2,-3.4,0),
        size = -Vector(0.25,0.1,0.1)
    }
}

DonatItem_PlayerModelEasyReg("models/player/gfl2_cheeta_dorm.mdl","Cheeta Dorm","","rary",{
    xp = 4000,
    raryType = "rary",
    [2] = {
        name = "Hair Accessories",
        max = 1
    },
    [4] = {
        name = "Wristband Left",
        max = 1
    },
    [5] = {
        name = "Wristband Right",
        max = 1
    },
    [6] = {
        name = "Stocking",
        max = 1
    },
    [7] = {
        name = "Sandals",
        max = 1
    }
},{
    [2] = 1,
    [4] = 1,
    [5] = 1,
    [6] = 1,
    [7] = 1
})
ViewArmorOffsetByModel["models/player/gfl2_cheeta_dorm.mdl"] = {
    ["ValveBiped.Bip01_Head1"] = {
        vec = Vector(-1,-0.6,0),
        size = -Vector(0.1,0.1,0.1),
    },
    ["ValveBiped.Bip01_Spine2"] = {
        vec = Vector(2,-3.4,0),
        size = -Vector(0.25,0.1,0.1)
    }
}

DonatItem_PlayerModelEasyReg("models/player/gfl2_vector.mdl","Vector","","rary",{
    xp = 4000,
    raryType = "rary",
    [2] = {
        name = "Jacket",
        max = 2
    },
    [4] = {
        name = "Knife",
        max = 2
    },
    [5] = {
        name = "Radio",
        max = 1
    },
    [6] = {
        name = "Pounch1",
        max = 1
    },
    [7] = {
        name = "Pounch2",
        max = 1
    },
    [8] = {
        name = "Armour Hips",
        max = 1 
    },
    [9] = {
        name = "Dagger",
        max = 2
    }
},{
    [2] = 1,
    [4] = 1,
    [5] = 1,
    [6] = 1,
    [7] = 1
})
ViewArmorOffsetByModel["models/player/gfl2_vector.mdl"] = {
    ["ValveBiped.Bip01_Head1"] = {
        vec = Vector(-1.3,-0.8,0),
        size = Vector(0,0,0),
    },
    ["ValveBiped.Bip01_Spine2"] = {
        vec = Vector(1,-2,0),
        size = -Vector(0.25,0.1,0.1)
    }
}

DonatItem_PlayerModelEasyReg("models/player/gfl2_vector_dorm.mdl","Vector Dorm","","rary",{
    xp = 4000,
    raryType = "rary",
    [3] = {
        name = "Wristband Left",
        max = 1
    },
    [4] = {
        name = "Wristband Right",
        max = 1
    },
    [5] = {
        name = "Stocking",
        max = 1
    },
    [6] = {
        name = "Sandals",
        max = 1
    }
},{
    [3] = 1,
    [4] = 1,
    [5] = 1,
    [6] = 1,
})
ViewArmorOffsetByModel["models/player/gfl2_vector_dorm.mdl"] = {
    ["ValveBiped.Bip01_Head1"] = {
        vec = Vector(-1.3,-0.8,0),
        size = Vector(0,0,0),
    },
    ["ValveBiped.Bip01_Spine2"] = {
        vec = Vector(1,-2,0),
        size = -Vector(0.25,0.1,0.1)
    }
}

DonatItem_PlayerModelEasyReg("models/player/gfl2_vector_vivi_sometimes_hides_her_molotov.mdl","Vector School","","legendary",{
    xp = 6000,
    raryType = "rary",
    [1] = {
        name = "Hair Bands",
        max = 2
    },
    [3] = {
        name = "Glasses",
        max = 1
    },
    [4] = {
        name = "Earring",
        max = 1
    },
    [5] = {
        name = "Jacket",
        max = 1
    },
    [6] = {
        name = "Torso",
        max = 3
    },
    [7] = {
        name = "Knee Pad",
        max = 1
    },
    [8] = {
        name = "Legs",
        max = 8
    }
},{
    [7] = 1
})
ViewArmorOffsetByModel["models/player/gfl2_vector_vivi_sometimes_hides_her_molotov.mdl"] = {
    ["ValveBiped.Bip01_Head1"] = {
        vec = Vector(-1.3,-0.8,0),
        size = Vector(0,0,0),
    },
    ["ValveBiped.Bip01_Spine2"] = {
        vec = Vector(1,-2,0),
        size = -Vector(0.25,0.1,0.1)
    }
}

DonatItem_PlayerModelEasyReg("models/sheepylord/kantai_collection/chuixue_white.mdl","Chuixue (White)","","epic",{
    xp = 1000,
    raryType = "rary",
    [1] = {
        name = "Arm Clotches",
        max = 1
    },
    [2] = {
        name = "Belt",
        max = 1
    },
    [6] = {
        name = "Headset",
        max = 1
    },
    [7] = {
        name = "Neck",
        max = 1
    },
    [8] = {
        name = "Shoes",
        max = 1
    }
},{
    [1] = 1,
    [2] = 1,
    [6] = 1,
    [7] = 1,
    [8] = 1
})
ViewArmorOffsetByModel["models/sheepylord/kantai_collection/chuixue_white.mdl"] = {
    ["ValveBiped.Bip01_Head1"] = {
        vec = Vector(-1.3,-0.5,0),
        size = Vector(0,0,0),
    },
    ["ValveBiped.Bip01_Spine2"] = {
        vec = Vector(2.5,-4,0),
        size = -Vector(0.1,0.1,0.1)
    }
}

DonatItem_PlayerModelEasyReg("models/b21/rei_ayanami_edit.mdl","Tactical Rey Ayanami","","epic",{
    xp = 10000,
    raryType = "legendary",
    [4] = {
        name = "Headwear",
        max = 1
    },
    [5] = {
        name = "HeadSet",
        max = 1
    },
    [8] = {
        name = "Bottom",
        max = 2
    },
    [9] = {
        name = "Glasses",
        max = 3
    },
    [10] = {
        name = "Vest",
        max = 1
    },
    [11] = {
        name = "Backpack",
        max = 1
    },
    [12] = {
        name = "Mask",
        max = 1
    },
    [14] = {
        name = "NVG Grip",
        max = 1
    },
    [15] = {
        name = "NVG",
        max = 2
    }
},
{
    [1] = 1,
    [4] = 1,
    [5] = 1,
    [8] = 2,
    [9] = 3,
    [10] = 1,
    [11] = 1,
    [12] = 1,
    [13] = 1,
    [14] = 1,
    [15] = 2
})
ViewArmorOffsetByModel["models/b21/rei_ayanami_edit.mdl"] = {
    ["ValveBiped.Bip01_Head1"] = {
        vec = Vector(-1.3,-0.5,0),
        size = Vector(0,0,0),
    },
    ["ValveBiped.Bip01_Spine2"] = {
        vec = Vector(2.2,-1,0),
        size = -Vector(0.1,0.1,0.1)
    }
}

DonatItem_PlayerModelEasyReg("models/sheepylord/megumi/megumi_pm.mdl","Megumi","","legendary",{
    xp = 10000,
    raryType = "legendary",
    [1] = {
        name = "Belt",
        max = 1
    },
    [4] = {
        name = "Cat Ears",
        max = 1
    },
    [7] = {
        name = "Hat",
        max = 1
    },
    [8] = {
        name = "Neck",
        max = 1
    }
},{
    [1] = 1,
    [7] = 1,
    [8] = 1
})
ViewArmorOffsetByModel["models/sheepylord/megumi/megumi_pm.mdl"] = {
    ["ValveBiped.Bip01_Head1"] = {
        vec = Vector(-1.3,-0.5,0),
        size = Vector(0.05,0.05,0),
    },
    ["ValveBiped.Bip01_Spine2"] = {
        vec = Vector(3.2,-2,0),
        size = -Vector(0.25,0.1,0.1)
    }
}

DonatItem_PlayerModelEasyReg("models/dih/Lappland_Refined_Horrormare.mdl","Refined Horrormare","","rary")

DonatItem_PlayerModelEasyReg("models/captainbigbutt/vocaloid/shadow_miku_append_competitive.mdl","Shadow Miku Append","","legendary",{
    xp = 10000,
    raryType = "legendary",
    [2] = {
        name = "Hair",
        max = 2
    },
    [3] = {
        name = "Append",
        max = 1
    }
},{
    [2] = 2,
    [3] = 1
})
ViewArmorOffsetByModel["models/captainbigbutt/vocaloid/shadow_miku_append_competitive.mdl"] = {
    ["ValveBiped.Bip01_Head1"] = {
        vec = Vector(-1.3,-0.5,0),
        size = Vector(0.05,0.05,0),
    },
    ["ValveBiped.Bip01_Spine2"] = {
        vec = Vector(1,-4,0),
        size = -Vector(0.1,0.1,0.1)
    }
}

DonatItem_PlayerModelEasyReg("models/captainbigbutt/vocaloid/shadow_miku_append.mdl","Shadow Miku","","epic",{
    xp = 10000,
    raryType = "legendary",
    [2] = {
        name = "Hair",
        max = 1
    },
},{
    [2] = 1,
})
ViewArmorOffsetByModel["models/captainbigbutt/vocaloid/shadow_miku_append.mdl"] = {
    ["ValveBiped.Bip01_Head1"] = {
        vec = Vector(-1.3,-0.5,0),
        size = Vector(0.05,0.05,0),
    },
    ["ValveBiped.Bip01_Spine2"] = {
        vec = Vector(1,-4,0),
        size = -Vector(0.1,0.1,0.1)
    }
}

DonatItem_PlayerModelEasyReg("models/sazuma/lelouch.mdl","Пидорас","Чёрный лавилас","epic",{
    xp = 100,
    raryType = "epic",
    [0] = {
        name = "Пикап плащ (всё тёлки твои!)",
        max = 1
    },
    [1] = {
        name = "Глаз гипноза (загепнотизируй тёлку на соитие!)",
        max = 1
    }
},{
    [0] = 1
})
ViewArmorOffsetByModel["models/sazuma/lelouch.mdl"] = {
    ["ValveBiped.Bip01_Head1"] = {
        vec = Vector(-1.5,0.6,0),
        size = -Vector(0.1,0.1,0.1),
    },
    ["ValveBiped.Bip01_Spine2"] = {
        vec = Vector(2.7,4.5,0),
        size = -Vector(0.4,0.1,0.1)
    }
}
