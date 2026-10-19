--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/ammo_base/ammo_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hgame/tier_2_entities/ammo_base/tier_0_sh.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\ammo_base\\ammo_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
HomigradAmmo = {}

for _,ammo in pairs({
    {
        name = "rifle",
        dmgtype = DMG_BULLET, 
        tracer = TRACER_LINE,
        plydmg = 40,
        npcdmg = 40,
        force = 200,
        maxcarry = 120,
        minsplash = 10,
        maxsplash = 5,

        Material = "models/hmcd_ammobox_556",
        Scale = 1.2,

		Icon = Material("vgui/hud/hmcd_round_556")
    },
    {
        name = "pistol",
        dmgtype = DMG_BULLET, 
        tracer = TRACER_LINE,
        plydmg = 25,
        npcdmg = 25,
        force = 200,
        maxcarry = 120,
        minsplash = 10,
        maxsplash = 5,

		Material = "models/hmcd_ammobox_9",
        Scale = 0.8,

		Icon = Material("vgui/hud/hmcd_round_9")
    },
    {
        name = "buckshot",
        dmgtype = DMG_BULLET, 
        tracer = TRACER_LINE,
        plydmg = 25,
        npcdmg = 25,
        force = 200,
        maxcarry = 120,
        minsplash = 10,
        maxsplash = 5,

        Material = "models/hmcd_ammobox_12",
        Scale = 1.1,

		Icon = Material("vgui/hud/hmcd_round_12")
    },
    {
        name = "ar2altfire",
        dmgtype = DMG_BULLET, 
        tracer = TRACER_LINE,
        plydmg = 25,
        npcdmg = 25,
        force = 200,
        maxcarry = 120,
        minsplash = 10,
        maxsplash = 5,

        Material = "models/hmcd_ammobox_6",
        Scale = 1.1,

		Model = "models/Items/combine_rifle_ammo01.mdl",

        dwsItemPos = Vector(0,0,-6.5),
        dwsItemAng = Angle(0,90,0),
        dwsItemFOV = -10,
    },
    {
        name = "RPG_Round",
        dmgtype = DMG_BLAST,
        tracer = TRACER_NONE,
        plydmg = 100,
        npcdmg = 100,
        force = 1000,
        maxcarry = 6,

        minsplash = 10,
        maxsplash = 5,

        Model = "models/weapons/w_missile_closed.mdl",

        dwsItemFOV = -3,
        dwsItemAng = Angle(90,-45,0),
    },
    {
        name = "smg1",
        dmgtype = DMG_BLAST,
        tracer = TRACER_NONE,
        plydmg = 40,
        npcdmg = 40,
        force = 200,
        maxcarry = 120,

        minsplash = 10,
        maxsplash = 5,

        Icon = Material("vgui/hud/hmcd_round_38"),
        Materials = "models/hmcd_ammobox_38"
    },
}) do HomigradAmmo[ammo.name] = ammo end

for name,v in pairs(HomigradAmmo) do
    game.AddAmmoType(v)
    if CLIENT then language.Add(v.name .. "_ammo",v.name) end

    local ent = {} 
    ent.Base = "ammo_base"

    ent.PrintName = v.name
    ent.AmmoType = v.name
    ent.AmmoMax = v.maxcarry
    ent.AmmoCount = ent.AmmoMax
    ent.Icon = v.Icon

    ent.Category = "Патроны"
    ent.Spawnable = true

    ent.WorldMaterial = v.Material
    ent.WorldScale = v.Scale
    ent.WorldColor = v.Color
    ent.WorldModel = v.Model or "models/props_lab/box01a.mdl"

    ent.dwsItemPos = v.dwsItemPos or Vector(0,0,0)
    ent.dwsItemAng = v.dwsItemAng or Angle(-90,0,0)
    ent.dwsPos = v.dwsPos or Vector(100,0,0)
    ent.dwsItemFOV = v.dwsItemFOV or -10

    scripted_ents.Register(ent,"ent_ammo_" .. v.name)
end

hook.Add("Initialize","Homigrad Ammo",function()
    timer.Simple(1,function() game.BuildAmmoTypes() end)
end)
