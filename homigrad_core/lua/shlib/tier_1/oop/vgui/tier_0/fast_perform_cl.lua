--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_1/oop/vgui/tier_0/fast_perform_cl.lua <
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

-- "addons\\homigrad_core\\lua\\shlib\\tier_1\\oop\\vgui\\tier_0\\fast_perform_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local PANEL = oop.Get("v_panel")
if not PANEL then return end

PANEL:Event_Add("Init","Fast Perform",function(self)
    self.adlist = {}
end,-1)

function PANEL:ad(func)
    self.adlist[#self.adlist + 1] = func

    local parent = self:GetParent()

    func(self,parent:GetWide(),parent:GetTall(),parent)

    return self
end

PANEL:Event_Add("Perform","ad",function(self,w,h)
    local parent = self:GetParent()
    local w,h = parent:GetWide(),parent:GetTall()
    
    for i,func in pairs(self.adlist) do func(self,w,h,parent) end//не стоит изменять размер parent'а
end)

event.Add("Screen Size","Perform Layout",function(new)
    for panel in pairs(vgui.CreatePanels) do
        if not IsValid(panel) then vgui.CreatePanels[panel] = nil continue end
        
        if panel.ConstructLayout then panel:ConstructLayout() end
    end
end)

function VGUIScreenSize()
    local panel = vgui.GetWorldPanel()

    return panel:GetWide(),panel:GetTall()
end

function PANEL:Clear()
    for i,panel in pairs(self:GetChildren()) do
        panel:Remove()
    end
end
