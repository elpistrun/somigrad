--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/levels/_special/construct/modules/rules_cl.lua <
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

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\levels\\_special\\construct\\modules\\rules_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Panel = {}
ScoreboardPages[12] = Panel

Panel.Name = "rules"

function Panel.CanOpen(frame)
    return roundActiveName == "level_construct"
end

function Panel.Open(frame)
    local html = oop.CreatePanel("v_html",frame):ad(function(self,w,h) self:setSize(w * 0.8,h * 0.9):setPos(w / 2 - self:W() / 2,h / 2 - self:H() / 2) end)
    html:OpenURL("https://docs.google.com/document/d/1Mrbqb2Hh4kitbSbRp0GwtFfV7XUYiFp_sbJbPJ5Hpn8/edit?usp=sharing")
end

event.Add("Setup World","Rules Construct",function()
    if roundActiveName ~= "level_construct" then return end

    timer.Simple(0,function() OpenTab():SelectPage(12) end)
end)
