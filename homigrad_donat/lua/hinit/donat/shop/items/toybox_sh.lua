--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_donat/lua/hinit/donat/shop/items/toybox_sh.lua <
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

-- "addons\\homigrad_donat\\lua\\hinit\\donat\\shop\\items\\toybox_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
DonatItemsList.sent_she_fire = {ent = "sent_she_fire",raryType = "common",limitSpawn = 0}
DonatItemsList.sent_she_sleep = {ent = "sent_she_sleep",raryType = "common",limitSpawn = 1}
DonatItemsList.sent_she_target = {ent = "sent_she_target",raryType = "common",limitSpawn = 1}

DonatItemsList.sent_she_petdog = {ent = "sent_she_petdog",raryType = "legendary",limitSpawn = 1}
DonatItemsList.sent_she_mogeko = {ent = "sent_she_mogeko",raryType = "legendary",notInv = true,limitSpawn = 1}

DonatItemsList.sent_she_potion = {ent = "sent_she_potion",raryType = "rary"}

DonatItemsList.sent_she_garden = {ent = "sent_she_garden",raryType = "rary",limitSpawn = 1}

DonatItemsList.sent_she_tray = {ent = "sent_she_tray",raryType = "rary",limitSpawn = 1}
DonatItemsList.sent_she_tick = {ent = "sent_she_tick",raryType = "rary",limitSpawn = 1,notInv = true,spawnFunction = function(ply,ent)
    ent:GetPhysicsObject():EnableMotion(false)
    ent:SetAngles(Angle(0,ply:EyeAngles()[2],0))

    local tr = {
        start = ply:EyePos(),
        endpos = ply:EyePos() + Vector(100,0,0):Rotate(ply:EyeAngles()),
        filter = ply
    }

    tr = util.TraceLine(tr)
    ent:SetPos(tr.HitPos)
end}

DonatItemsList.sent_she_bush = {ent = "sent_she_bush",raryType = "rary",limitSpawn = 1,notInv = true}
//DonatItemsList.sent_she_manhole = {ent = "sent_she_manhole",raryType = "rary",limitSpawn = 1}
DonatItemsList.npc_pig = {ent = "npc_pig",raryType = "rary",notInv = true}

DonatItemsList.sent_she_cirno = {ent = "sent_she_cirno",raryType = "legendary",limitSpawn = 1}

DonatItemsList.sent_she_stove = {ent = "sent_she_stove",raryType = "legendary",limitSpawn = 1}
DonatItemsList.sent_she_garden = {ent = "sent_she_garden",raryType = "legendary",limitSpawn = 1}


