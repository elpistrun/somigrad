--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/inv/game/sh_config.lua <
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

-- "addons\\homigrad\\lua\\hgame\\tier_1\\inv\\game\\sh_config.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
InvDumping_NameValid = { 
    "ent_jack_gmod_ezarmor_eaimbss",
    "ent_jack_gmod_ezarmor_tv115",
    "ent_jack_gmod_ezarmor_6b3tm",
    "ent_jack_gmod_ezarmor_6b515",
    "ent_jack_gmod_ezarmor_arsarmaa18",
    "ent_jack_gmod_ezarmor_banshee",
    "ent_jack_gmod_ezarmor_cryeavs",
    "ent_jack_gmod_ezarmor_m1",
    "ent_jack_gmod_ezarmor_m2",
    "ent_jack_gmod_ezarmor_mmac",
    "ent_jack_gmod_ezarmor_ospreyass",
    "ent_jack_gmod_ezarmor_rbavaf",
    "ent_jack_gmod_ezarmor_strandhogg",
    "ent_jack_gmod_ezarmor_tv110",
    "ent_jack_gmod_ezarmor_tactec",
    "ent_jack_gmod_ezarmor_aacpc",
    "ent_jack_gmod_ezarmor_bagariy",
    "ent_jack_gmod_ezarmor_cpcge",
    "ent_jack_gmod_ezarmor_ospreyprotec",
    "ent_jack_gmod_ezarmor_plateframege",
    "ent_jack_gmod_ezarmor_tagilla",
    "ent_jack_gmod_ezarmor_ttsk",


    "ent_jack_gmod_ezarmor_alphacr",
    "ent_jack_gmod_ezarmor_azimutb",
    "ent_jack_gmod_ezarmor_azimuts",
    "ent_jack_gmod_ezarmor_bankrobber",
    "ent_jack_gmod_ezarmor_beltab",
    "ent_jack_gmod_ezarmor_blackrock",
    "ent_jack_gmod_ezarmor_bssmk1",
    "ent_jack_gmod_ezarmor_commandoblack",
    "ent_jack_gmod_ezarmor_commandotan",
    "ent_jack_gmod_ezarmor_csa",
    "ent_jack_gmod_ezarmor_d3crx",
    "ent_jack_gmod_ezarmor_ideacr",
    "ent_jack_gmod_ezarmor_khamelion",
    "ent_jack_gmod_ezarmor_bearing",
    "ent_jack_gmod_ezarmor_birdeyerig",
    "ent_jack_gmod_ezarmor_m4rscr",
    "ent_jack_gmod_ezarmor_sprofirecon",
    "ent_jack_gmod_ezarmor_tarzan",
    "ent_jack_gmod_ezarmor_thunderbolt",
    "ent_jack_gmod_ezarmor_triton",
    "ent_jack_gmod_ezarmor_chicomcr",
    "ent_jack_gmod_ezarmor_umka",
    "ent_jack_gmod_ezarmor_6h112",
    "ent_jack_gmod_ezarmor_mk3chestrig",
    "ent_jack_gmod_ezarmor_wtrig",

    "ent_jack_gmod_ezarmor_sprofiass"
}

local copy = {}
for _,name in pairs(InvDumping_NameValid) do copy[name] = true end
InvDumping_NameValid = copy

InvBackpack_NameValid = {
    "ent_jack_gmod_ezarmor_6sh118",
    "ent_jack_gmod_ezarmor_beta2bp",
    "ent_jack_gmod_ezarmor_blackjack",
    "ent_jack_gmod_ezarmor_drawbridge",
    "ent_jack_gmod_ezarmor_dufflebag",
    "ent_jack_gmod_ezarmor_f4terminator",
    "ent_jack_gmod_ezarmor_switchblade",
    "ent_jack_gmod_ezarmor_flyyembss",
    "ent_jack_gmod_ezarmor_gunslinger",
    "ent_jack_gmod_ezarmor_gruppa99t20m",
    "ent_jack_gmod_ezarmor_gruppa99t20t",
    "ent_jack_gmod_ezarmor_gruppa99t30b",
    "ent_jack_gmod_ezarmor_gruppa99t30m",
    "ent_jack_gmod_ezarmor_lbt1476a",
    "ent_jack_gmod_ezarmor_sfmp",
    "ent_jack_gmod_ezarmor_daypack",
    "ent_jack_gmod_ezarmor_lolkek3f",
    "ent_jack_gmod_ezarmor_mechanismbp",
    "ent_jack_gmod_ezarmor_birdeyebackpack",
    "ent_jack_gmod_ezarmor_paratus",
    "ent_jack_gmod_ezarmor_piligrim",
    "ent_jack_gmod_ezarmor_pillboxbp",
    "ent_jack_gmod_ezarmor_sanitarbag",
    "ent_jack_gmod_ezarmor_scavbackpack",
    "ent_jack_gmod_ezarmor_attack2",
    "ent_jack_gmod_ezarmor_tacticalslingb",
    "ent_jack_gmod_ezarmor_takedownbbp",
    "ent_jack_gmod_ezarmor_takedownmbp",
    "ent_jack_gmod_ezarmor_transformerbag",
    "ent_jack_gmod_ezarmor_trizip",
    "ent_jack_gmod_ezarmor_tttrooper35",
    "ent_jack_gmod_ezarmor_vkboarmybag",
    "ent_jack_gmod_ezarmor_berkutbp"
}

local copy = {}
for _,name in pairs(InvBackpack_NameValid) do copy[name] = true end
InvBackpack_NameValid = copy

InvCase_NameValid = {
    "ent_jack_gmod_ezarmor_sc_kappa",
    "ent_jack_gmod_ezarmor_sc_gamma",
    "ent_jack_gmod_ezarmor_sc_epsilon",
    "ent_jack_gmod_ezarmor_sc_beta",
    "ent_jack_gmod_ezarmor_sc_alpha"
}

local copy = {}
for _,name in pairs(InvCase_NameValid) do copy[name] = true end
InvCase_NameValid = copy

if SERVER then return end

local mat_bomb,mat_trash = Material("icon16/bomb.png"),Material("icon16/bin_empty.png")

hook.Add("Content Icon Paint Icons","Inventory",function(panel,w,h)
    local name = panel:GetSpawnName()

    if InvDumping_NameValid[name] then
        surface.SetMaterial(mat_bomb)
        surface.SetDrawColor(255,255,255,255)
        surface.DrawTexturedRectRotated(w - 16,16,16,16,0)
    end

    if InvBackpack_NameValid[name] then
        surface.SetMaterial(mat_trash)
        surface.SetDrawColor(255,255,255,255)
        surface.DrawTexturedRectRotated(w - 16,16,16,16,0)
    end
end)

local white = Color(255,255,255)

hook.Add("HUD Target","Inventory",function(ent,k,w,h)
    local name = ent:GetClass()
    local text

    if InvDumping_NameValid[name] then
        surface.SetMaterial(mat_bomb)

        text = "dumping"
    end

    if InvBackpack_NameValid[name] then
        surface.SetMaterial(mat_trash)

        text = "backpack"
    end

    if text then
        local rag = LocalPlayer():GetNWEntity("Ragdoll")
        if IsValid(rag) and ent:GetNWEntity("Parent") == rag then return false end

        white.a = 255 * k
        local anim = (50 * (1 - k))

        draw.SimpleText(L(text),"HS.18",w / 2,h / 2 + 25 * k + anim,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        surface.SetDrawColor(255,255,255,255 * k)
        surface.DrawTexturedRectRotated(w / 2,h / 2 - 25 * k - anim,16,16,0)

        return true
    end
end)

local size = 98
local white = Color(255,255,255)

hook.Add("HUD Target","Weapon",function(ent,k,w,h)
    local obj = weapons.Get(ent:GetClass())
	
    if obj then
        local func = ent.CanHUDTarget
        if func and func(ent) == false then return true end

        surface.SetAlphaMultiplier(k)
        render.SetBlend(k)

        draw.SimpleText(L(obj.PrintName or ent:GetClass()),"HS.18",w / 2,h / 2 + size / 1.25 + (50 * (1 - k)),white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        render.SetBlend(math.min(k * 15,1))
        DrawWeaponSelectionEX(obj,w / 2 - size / 2,h / 2 - size / 2 - (50 * (1 - k)),size,size,true)

        surface.SetAlphaMultiplier(1)
        render.SetBlend(1)

        return true
    end
end)
