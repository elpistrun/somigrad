--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_1/oop/vgui/tier_0/style_cl.lua <
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

-- "addons\\homigrad_core\\lua\\shlib\\tier_1\\oop\\vgui\\tier_0\\style_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local PANEL = oop.Get("v_panel")
if not PANEL then return end

PANEL.styles = {}
PANEL.initDrawStyle = "dark"

function PANEL:SetDrawStyle(name,data)
    self.styles[name] = data

    if data.Construct then data.Construct(self) end
end

local blacklist = {
    ["PreDraw"] = true,
    ["Draw"] = true,
    ["DrawOver"] = true
}

function PANEL:SetupDrawStyle(name)
    local style = self.styles[name]
    if not style then return end

    for k,v in pairs(style) do
        if blacklist[k] then continue end
        
        self[k] = v
    end

    local preDraw = style.PreDraw
    local draw = style.Draw
    local drawOver = style.DrawOver

    self.Draw = function(self,w,h)
        if preDraw then preDraw(self,w,h) end
        if draw then draw(self,w,h) end
        if drawOver then drawOver(self,w,h) end
    end

    if IsValid(self) then
        self.setDrawStyle = name

        if style.Init then style.Init(self,style) end
    else
        self.initDrawStyle = name
    end
    
    return self
end

PANEL:Event_Add("Init","SetupDrawStyle",function(self)
    if self.initDrawStyle then self:SetupDrawStyle(self.initDrawStyle) end
end,5)
