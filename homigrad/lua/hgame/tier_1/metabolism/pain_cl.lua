--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/metabolism/pain_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\metabolism\\pain_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local grtodown = Material( "vgui/gradient-u" )
local grtoup = Material( "vgui/gradient-d" )
local grtoright = Material( "vgui/gradient-l" )
local grtoleft = Material( "vgui/gradient-r" )

local ScrW,ScrH = ScrW,ScrH
local math_Clamp = math.Clamp
local k = 0
local k4 = 0
local time = 0

local old

local nigger = Color(0,0,0,255)

local pulseStart = 0

event.Add("DSP","Otrub",function()
    local ply = LocalPlayer()

    if ply:Alive() and ply:GetNWBool("Otrub") then return 16 end
end)

event.Add("Start Round","ResetPainVisuals",function()
    k = 0
end)

hook.Add("PlayerSpawn","ResetPainVisualsSpawn",function(ply)
    if ply == LocalPlayer() then
        k = 0
    end
end)

hook.Add("PreDrawHUD","PainEffect",function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end
    
    local painlosing = ply:GetNWFloat("painlosing",0)

    if painlosing > 0 then
        DrawMotionBlur(0.8,painlosing / 3,0.016)
    end

    local active = ply:GetNWBool("Otrub")

    cam.Start2D()

    render.ClearStencil()

    if active then
        surface.SetDrawColor(0,0,0,255)
        surface.DrawRect(0,0,ScrW(),ScrH())

        local pulse = ply:GetNWFloat("pulse",0)

        if pulse ~= 0 and pulseStart + pulse * 60 < RealTime() then
            pulseStart = RealTime()

            surface.PlaySound("snd_jack_hmcd_heartpound.wav")
        end
    end

    local w,h = ScrW(),ScrH()
    local painVal = ply:GetNWFloat("pain", 0)
    local targetPain = math_Clamp(painVal / 100, 0, 15)
    if targetPain <= 0.01 and k < 0.05 then
        k = 0
    else
        k = Lerp(0.1, k, targetPain)
    end

    if k > 0.001 then
        surface.SetMaterial(grtodown)
        surface.SetDrawColor(0,0,0,255)
        surface.DrawTexturedRect(0,0,w,h * k)

        surface.SetMaterial(grtoup)
        surface.SetDrawColor(0, 0, 0, 255 )
        surface.DrawTexturedRect(0,h - h * k,w,h * k + 1)

        surface.SetMaterial(grtoright)
        surface.SetDrawColor(0,0,0,255)
        surface.DrawTexturedRect(0,0,w * k,h)

        surface.SetMaterial(grtoleft)
        surface.SetDrawColor(0,0,0,255)
        surface.DrawTexturedRect(w - w * k,0,w * k + 1,h)
    end

    cam.End2D()
end)

hook.Add("StartCommand","Fake",function(ply,cmd)
	if not ply:Alive() or not ply:GetNWBool("Otrub") then return end
	
	cmd:ClearButtons()
end)
