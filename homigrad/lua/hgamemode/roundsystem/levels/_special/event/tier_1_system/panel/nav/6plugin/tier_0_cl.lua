--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/levels/_special/event/tier_1_system/panel/nav/6plugin/tier_0_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
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

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\levels\\_special\\event\\tier_1_system\\panel\\nav\\6plugin\\tier_0_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
EventPanel_Pages[6] = {}
local Panel = EventPanel_Pages[6]
Panel.Name = "event_plugins"

function Panel.Create(frame)
    EventPanel_PluginSetPage = EventPanel_PluginSetPage or 1

    local list = oop.CreatePanel("v_scrollnav",frame):ad(function(self,w,h) self:setSize(300,h) end)
    list:SetHighlightSide("right")
    list.WideButton = 50

    local pagelists = oop.CreatePanel("v_scrollpage",frame):ad(function(self,w,h) self:setPos(list:W(),0):setSize(w - list:W(),h) end)
    pagelists:SetHorizontal(false)

    for name,plugin in SortedPairs(EventPluginsClasses) do
        if name == "base" then continue end

        local page = pagelists:Add()
        local id = #pagelists.pages
        
        page.plugin = plugin
        plugin.page = page
        
        for k,v in pairs(plugin) do page[k] = v end

        page.listUpdate = {}

        function page:Update()
            for i,panel in pairs(page.listUpdate) do panel:Update() end
        end

        page:AddEditBool("enabled")

        list:Add(L(plugin.PrintName or name),function()
            EventPanel_PluginSetPage = id
            pagelists:Set(id)
        end)

        if plugin.Create then plugin:Create(page) end
    end

    pagelists:Set(EventPanel_PluginSetPage)
    list:Set(EventPanel_PluginSetPage)
end

event.Add("Event Plugin Sync","UI",function(plugin)
    if plugin.page and IsValid(plugin.page) then plugin.page:Update() end
end)
