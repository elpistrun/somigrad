--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/client/scoreboard/pages/gamemode/tier_0_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
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

-- "addons\\homigrad\\lua\\hgamemode\\client\\scoreboard\\pages\\gamemode\\tier_0_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
ScoreboardPages[4] = ScoreboardPages[4] or {list = {}}

local Panel = ScoreboardPages[4]
Panel.Name = "gamemode"

function Panel.Open(frame)
    local pagesHorizontal = oop.CreatePanel("v_scrollpage",frame):ad(function(self,w,h) self:setSize(w * 0.85,h * 0.85):setPos(w/2-self:W()/2,h/2-self:H()/2) end)
    pagesHorizontal:SetHorizontal(true)

    local navButtons = oop.CreatePanel("v_scrollnav",frame):ad(function(self,w,h) self:setSize(pagesHorizontal:W(),40):setPos(pagesHorizontal.x,pagesHorizontal.y - self:H()) end)
    navButtons:SetHighlightSide("bottom")
    navButtons:SetupDrawStyle("whitebox")

    for i,page in pairs(Panel.list) do
        local panel = pagesHorizontal:Add()
        page.panel = panel
        page.Open(panel)

        local butt = navButtons:Add(L(page.Name),function() pagesHorizontal:Set(i) Panel.selectPage = i end)
        butt:SetupDrawStyle("white_gradient"); butt.gradientSide = "bottom"; butt.font = "HS.18"
    end

    if Panel.selectPage then
        pagesHorizontal:Set(Panel.selectPage,true)
        navButtons:Set(Panel.selectPage)
    end
end

if Initialize then OpenTab() end
