--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/levels/_special/event/tier_1_system/panel/nav/6plugin/0_base/ui_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hgamemode/roundsystem/levels/_special/event/tier_1_system/panel/nav/6plugin/0_base/tier_0_sh.lua:3
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
addons/homigrad_core/lua/shlib/loader.lua:157
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

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\levels\\_special\\event\\tier_1_system\\panel\\nav\\6plugin\\0_base\\ui_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Plugin = EventPlugin_Get("base")
if not Plugin then return end

function Plugin:AddEdit(name,panel)
    panel = panel or self
    local i = #panel:GetChildren()

    local param = oop.CreatePanel("v_parametr",panel):ad(function(self,w,h) self:setSize(w,50):setPos(0,self:H() * i) end)
    param.text = name
    param.font = "HS.25"
    param.GetText = function() return tostring(self.plugin[name]) end
    param.Callback = function(value) self.plugin:SendCMD(name,{value}) end

    return param
end

local green,red = Color(0,255,0),Color(255,0,0)
function Plugin:AddEditBool(name,panel)
    panel = panel or self
    local i = #panel:GetChildren()

    local param = oop.CreatePanel("v_parametr",panel):ad(function(self,w,h) self:setSize(w,50):setPos(0,self:H() * i) end)
    param.text = name
    param.font = "HS.25"
    param.GetText = function() return tostring(self.plugin[name]) end
    param.OnClick = function()
        local value = tostring(self.plugin[name])
        
        if value == "true" then
            value = 0
        else
            value = 1
        end

        self.plugin:SendCMD(name,{value})
    end

    function param.Update()
        local value = tostring(self.plugin[name])
        
        if value == "true" then
            param.color = green
        else
            param.color = red
        end
    end

    param:Update()

    panel.listUpdate[#panel.listUpdate + 1] = param

    return param
end

