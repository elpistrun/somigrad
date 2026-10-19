--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/levels/_special/construct/modules/list_valid_sh.lua <
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

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\levels\\_special\\construct\\modules\\list_valid_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Level = oop.Get("level_construct")
if not Level then return end

Level.ValidList = {}

Level.weapons_list = {}
local weapons_list = Level.weapons_list

local function unpack(v,bool)
    if TypeID(v) == TYPE_TABLE then
        Level.ValidList[v[1]] = v
        weapons_list[v[1]] = bool
    else
        Level.ValidList[v] = true
        weapons_list[v] = bool
    end
end

for i,v in pairs({

    
}) do unpack(v,true) end

/*for i,v in pairs({
    "weapon_kabar",
    "weapon_bat",
    "weapon_hg_sleagehammer",
    "weapon_hg_kitknife",
    "weapon_hg_crowbar",
    "weapon_hg_metalbat",
    "weapon_hg_shovel",
    "weapon_hg_fireaxe",
    "weapon_police_bat",
    "melee_knife",
    "weapon_t",
    "weapon_hg_hatchet",
    "weapon_pipe",
    "weapon_hg_fubar"
}) do unpack(v,true) end*/

for i,v in pairs({
    "gmod_camera",
    "gmod_physgin",
    "gmod_toolgun",

    {"ent_spawnpoint",nil,2},
    "ent_storage",
    "keypad",

    {"ent_cupboard",nil,1},

    "gmod_sent_vehicle_fphysics_gaspump_diesel",
    "gmod_sent_vehicle_fphysics_gaspump_electric",
    "gmod_sent_vehicle_fphysics_gaspump",

    /*{"ent_jack_gmod_ezteleportradio",nil,1},
    {"ent_jack_gmod_ezaidradio",nil,1},

    "ent_jack_gmod_ezsolargenerator",
    "ent_jack_gmod_ezfuellantern"*/
}) do unpack(v) end

for class,ent in pairs(scripted_ents.GetList()) do
    if string.find(class,"ent_jack_gmod_ezarmor_") then unpack({class,0},true) end
end

/*for i,v in pairs({
    "sim_fphys_pwtrabant",
    "sim_fphys_pwtrabant02",
    "sim_fphys_pwvan",
    "sim_fphys_pwvolga",
    "sim_fphys_pwzaz",
    "sim_fphys_pwavia",
    "sim_fphys_pwgaz52",
    "sim_fphys_pwhatchback",
    "sim_fphys_pwliaz",
    "sim_fphys_pwmoskvich",
    "sim_fphys_conscriptapc",
    "sim_fphys_van"
}) do unpack(v) end*/

for i,v in pairs({
    "remover",
    "camera",
    "colour",
    "material",
    "shareprops",
    "precision",
    "keypad_willox",
    "fading_door",
    "prop_door",
    "weld",
    "button",
    --"light",
   -- "lamp",

    "streamradio",
    "prtcamera",
    "textscreen",
    "ledscreen",
}) do unpack(v) end

hook.Add("Content Icon Paint","Construct",function(panel,w,h)
    if not TableLevel().UseConstruct or LocalPlayer():GetNWBool("IgnoreQ") then return end

    if not TableLevel().ValidList[panel:GetSpawnName()] or (GetGlobalBool("lootbox") and weapons_list[panel:GetSpawnName()]) then
        surface.SetDrawColor(0,0,0,125)
        surface.DrawRect(5,5,w - 10,h - 10)

        draw.SimpleText("Запрещено","ChatFont",w / 2,h / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
end,2)

/*if SERVER then
    local poss = {}
    for i,ent in pairs(ents.FindByClass("serverside_model")) do
        poss[#poss + 1] = ent:GetPos()

        ent:Remove()
    end
    
    util.AddNetworkString("gg")

    net.Start("gg")
    net.WriteTable(poss)
    net.Broadcast()
else
    net.Receive("gg",function()
        for i,pos in pairs(net.ReadTable()) do
            print(pos  )
            debugoverlay.Sphere(pos,3,10)
        end
    end)
end*/
