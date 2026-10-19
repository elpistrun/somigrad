--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_1/oop/vgui/tier_0/flex_cl.lua <
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

-- "addons\\homigrad_core\\lua\\shlib\\tier_1\\oop\\vgui\\tier_0\\flex_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local PANEL = oop.Get("v_panel")
if not PANEL then return end

function PANEL:AddFlexParent()
    self:ad(function(self,w,h)
        self.flexPointX = 0
        self.flexPointY = 0
        self.flexMaxY = 0

        local whitelist = {}

        for _,child in pairs(self:GetChildren()) do
            whitelist[child] = true
        end

        self.flexWhitelist = whitelist
    end)
end

function PANEL:AddByFlex()
    self:ad(function(self,w,h)
        local parent = self:GetParent()

        if not parent.flexWhitelist[self] then
            self:setPos(self.setFlexPointX or 0,self.setFlexPointY or 0)
            
            return
        end

        parent.flexWhitelist[self] = nil

        if parent.flexPointX + self:W() > parent:W() then
            parent.flexPointX = 0
            parent.flexPointY = parent.flexPointY + parent.flexMaxY
            parent.flexMaxY = 0
        end

        parent.flexMaxY = math.max(parent.flexMaxY,self:H())

        self.setFlexPointX = parent.flexPointX or 0
        self.setFlexPointY = parent.flexPointY or 0
        self:setPos(self.setFlexPointX,self.setFlexPointY)
        
        parent.flexPointX = parent.flexPointX + self:W()
    end)

    return self
end
