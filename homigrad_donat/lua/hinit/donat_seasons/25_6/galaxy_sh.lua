--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_donat/lua/hinit/donat_seasons/25_6/galaxy_sh.lua <
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

-- "addons\\homigrad_donat\\lua\\hinit\\donat_seasons\\25_6\\galaxy_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
DonatItem_PlayerModelEasyReg("models/player/gspace.mdl","GalaxySpace","","epic",{
    [-1] = {
        name = "Space",
        max = 4
    }
})


DonatItem_PlayerModelEasyReg("models/player/galaxyman/galaxyman.mdl","GalaxyMan","","legendary")

DonatItem_PlayerModelEasyReg("models/player/galaxyman/galaxyman_blue.mdl","GalaxyMan Blue","","rary")
DonatItem_PlayerModelEasyReg("models/player/galaxyman/galaxyman_green_blue.mdl","GalaxyMan Green Blue","","rary")
DonatItem_PlayerModelEasyReg("models/player/galaxyman/galaxyman_red.mdl","GalaxyMan Red","","rary")
DonatItem_PlayerModelEasyReg("models/player/galaxyman/galaxyman_yellow.mdl","GalaxyMan Yellow","","rary")

DonatCasesClasses["galaxy"] = {
    raryType = "rary",

    model = "models/kali/props/cases/hard case c.mdl",
    name = "Galaxy Models",
    desc = "Сезоный кейс, не будет продаватся с 1 июля",

    subMaterial0 = "models/gspace/galaxy_purple",

    modelVec = Vector(-40,-2,-9),
    modelAng = Angle(15,20,0),

    modelLockVec = Vector(13,0,9.6),
    modelLockAng = Angle(0,90,90),

    keyName = "Galaxy Models",
    modelKey = "models/jaggedsprings/key1.mdl",
    modelKeyVec = Vector(90,2,-3),
    modelKeyAng = Angle(90 + 45,90,90),

    casino = {
        [6] = {
            {class = "playermodel",model = "models/player/gspace.mdl"},
        },
        [10] = {
            {class = "playermodel",model = "models/player/galaxyman/galaxyman.mdl"},
        },
        [100] = {
            {class = "playermodel",model = "models/player/galaxyman/galaxyman_blue.mdl"},
            {class = "playermodel",model = "models/player/galaxyman/galaxyman_green_blue.mdl"},
            {class = "playermodel",model = "models/player/galaxyman/galaxyman_red.mdl"},
            {class = "playermodel",model = "models/player/galaxyman/galaxyman_yellow.mdl"}
        }
    }
}
