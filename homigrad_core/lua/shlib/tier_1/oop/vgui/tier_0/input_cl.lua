--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_1/oop/vgui/tier_0/input_cl.lua <
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

-- "addons\\homigrad_core\\lua\\shlib\\tier_1\\oop\\vgui\\tier_0\\input_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local PANEL = oop.Get("v_panel")
if not PANEL then return end

PanelInputMouse = PanelInputMouse or {}
PanelInputKeyboard = PanelInputKeyboard or {}

PANEL:Event_Add("Init","Input",function(self)
    self.mouse = {}
    self.keyboard = {}
end,-1)

function PANEL:OnMousePressed(key)
    self.mouse[key] = true
    PanelInputMouse[self] = true

    if self.OnMouse then self:OnMouse(key,true) end
    self:Event_Call("Mouse",key,true)
end

function PANEL:OnMouseReleased(key,outside)
    local value = self.mouse[key]

    if self.OnMouseOut then self:OnMouseOut(key,outside) end
    self:Event_Call("MouseOut",key,outside)

    if not value then return end

    self.mouse[key] = nil

    if self.OnMouse then self:OnMouse(key,false) end
    self:Event_Call("Mouse",key,false)
end

--

function PANEL:OnKeyCodePressed(key)
    self.keyboard[key] = true
    PanelInputKeyboard[self] = true

    if self.OnKey then self:OnKey(key,true) end
    self:Event_Call("Key",key,true)
end

function PANEL:OnKeyCodeReleased(key,outside)
    if not self.keyboard[key] then return end
    self.keyboard[key] = nil
    
    if self.OnKey then self:OnKey(key,false) end
    self:Event_Call("Key",key,false)
end

function PANEL:OnMouseWheeled(wheel)
    //if (self.wheelDelay or 0) > RealTime() then return end
    //self.wheelDelay = RealTime() + 1 / 60
    
    if self.OnWheel then self:OnWheel(wheel) end
    self:Event_Call("Wheel",wheel)
end

hook.Add("Think","Panel Input",function()
    for panel in pairs(PanelInputMouse) do
        if not IsValid(panel) then PanelInputMouse[panel] = nil continue end

        for key in pairs(panel.mouse) do
            if not input.IsMouseDown(key) then panel:OnMouseReleased(key,true) end
        end
    end

    for panel in pairs(PanelInputKeyboard) do
        if not IsValid(panel) then PanelInputKeyboard[panel] = nil continue end

        for key in pairs(panel.keyboard) do
            if not input.IsKeyDown(key) then panel:OnKeyCodeReleased(key,true) end
        end
    end
end)

function PANEL:IsDown()
    for key in pairs(self.mouse) do return true end

    return false
end

function PANEL:GetMousePos()
    local x,y = self:LocalToScreen(0,0)

    return mousex - x,mousey - y
end

local function step(panel,x,y)
    local parent = panel:GetParent()

    if IsValid(parent) then
        return step(parent,x + panel.x,y + panel.y)
    else
        return x,y
    end
end

function PANEL:GetGlobalPos()
    return step(self,0,0)
end

function PANEL:LinkMouse(panel)
    panel.OnMousePressed = function(_,key,value) self:OnMousePressed(key,value) end
    panel.OnMouseReleased = function(_,key,value) self:OnMouseReleased(key,value) end

    panel.OnMouseWheeled = function(_,value) self:OnMouseWheeled(value) end
end
