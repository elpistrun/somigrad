--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_1/oop/vgui/tier_0/tip_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad_core/lua/shlib/tier_1/oop/vgui/tier_0/tier_0_cl.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_1\\oop\\vgui\\tier_0\\tip_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local PANEL = oop.Get("v_panel")
if not PANEL then return end

local corner = 4
local value,valueParse,start = nil,nil,0

function SetTip(text)
    if value == text then return end

    value = text
    valueParse = markup.Parse(text,math.max(ScrW() / 4,400))
end

function PANEL:DrawTip(text,delay) 
    if not self:IsHovered() then return end
    
    value = SetTip(text)
    start = RealTime() + 0.1

    return true
end

hook.Add("PostRenderVGUI","TIP",function()
    if start < RealTime() then return end

    local mx,my = gui.MousePos()

    my = my - valueParse:GetHeight() - corner
    mx = mx + corner

    surface.SetDrawColor(20,20,20)
    surface.DrawRect(mx - corner,my - corner,valueParse:GetWidth() + corner*2,valueParse:GetHeight() + corner*2)
    valueParse:Draw(mx,my)
end)
