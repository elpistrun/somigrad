--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/metabolism/water_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\metabolism\\water_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
ArmorListClasses["Ballon O2"] = {
    PrintName = "Ballon O2",
    mdl = "models/props_junk/propanecanister001a.mdl",
    slots = {
        back = 0.25,
    },
    def = {},
    bon = "ValveBiped.Bip01_Spine2",
    siz = Vector(0.6,0.6,1.4),
    pos = Vector(4,1,0),
    ang = Angle(90,0,0),
    wgt = 10,
    dur = 75,
    ent = "ent_jack_gmod_ezarmor_ballon_o2",
    gayPhysics = true
}

if Initialize then Armor_Registry() end

if SERVER then return end

local black = Color(0,0,0)


hook.Add("RenderScreenspaceEffects","Impulse",function()
    if not LocalPlayer():Alive() then return end

    if LocalPlayer():GetNWBool("HeadInWater")  then
	    DrawToyTown(1,ScrH())
    end
end)

event.Add("DSP","Water",function()
    local ply = LocalPlayer()
    if ply:Alive() and ply:GetNWBool("HeadInWater") then return 14,false end
end)

hook.Add("HUDPaint","O2",function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end

    local o2 = ply:GetNWFloat("o2",1)

    surface.SetDrawColor(0,0,0,125 * (1 - o2))
    surface.DrawRect(0,0,ScrW(),ScrH())

    local size = ScrH() * (1 - o2)

    draw.GradientUp(0,0,ScrW(),size)
end)
