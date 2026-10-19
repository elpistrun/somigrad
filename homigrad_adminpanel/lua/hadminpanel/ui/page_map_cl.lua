--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_adminpanel/lua/hadminpanel/ui/page_map_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:11 <
]]

-- "addons\\homigrad_adminpanel\\lua\\hadminpanel\\ui\\page_map_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
AdminPanelPages[3] = AdminPanelPages[3] or {}
local Page = AdminPanelPages[3]

Page.Name = "ap_ui_map"

function Page.CanOpen()
    return LocalPlayer():HasSuccess("command_map")
end

local accessCategories = {
    ["jb"] = "JailBreak",
    ["jail"] = "JailBreak",
    ["ba"] = "JailBreak",
    ["deathrun"] = "DeathRun",

    ["gm"] = "Game",
    ["de"] = "Game",
    ["cs"] = "Game",

    ["d1"] = "HalfLife",
    ["d2"] = "HalfLife",
    ["d3"] = "HalfLife",
}

local textH = 20

//RTVDrawIcon рассчитан на превьюшки из внешней БД, локальному списку они не нужны
local function DrawMapIcon(x,y,w,h,map,info)
    surface.SetDrawColor(0,0,0,128)
    surface.DrawRect(x,y,w,h)

    surface.SetDrawColor(125,125,125,64)
    draw.GradientDown(x + 1,y + h - textH + 1,w - 2,textH)

    draw.Frame(x,y,w,h,cframe1,cframe2)

    draw.SimpleText(map,"HS.12",x + w/2,y + h - textH/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
end

function Page.Open(frame)
    local scrollNav = oop.CreatePanel("v_scrollnav",frame):ad(function(self,w,h) self:setSize(300,h) end)
    scrollNav:SetHighlightSide("right",nil,75);

    local page = oop.CreatePanel("v_scrollpanel",frame):ad(function(self,w,h) self:setPos(scrollNav:W(),0):setSize(w - self.x,h) end)
    page:CreateVBar()
    page.canvasPanel:AddFlexParent()
    page.scrolling = 200

    local iconSize = math.floor(page:W()/6) - 2

    function page:Select(list)
        self:Clear()

        for map,info in SortedPairs(list) do
            local icon = oop.CreatePanel("v_button",page):ad(function(self,w,h) self:setSize(iconSize,iconSize + 20) end):AddByFlex()
        
            function icon:Draw(w,h)
                if MapsBlocked and MapsBlocked[map] then
                    surface.SetDrawColor(255,0,0,64)
                    surface.DrawRect(0,0,w,h)

                    surface.SetDrawColor(0,0,0,255)
                    draw.GradientDown(0,0,w,h)
                end

                DrawMapIcon(0,0,w,h,map,info)
                if self:IsHovered() then
                    surface.SetDrawColor(255,255,255,5)
                    surface.DrawRect(0,0,w,h)
                end

                if MapsBlocked and MapsBlocked[map] then
                    surface.SetDrawColor(255,0,0,5)
                    surface.DrawRect(0,0,w,h)
                    
                    draw.SimpleText("ЗАКРЫТО","HS.18",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                end
            end
            function icon:OnClick(key)
                if key == MOUSE_LEFT then
                    VParametrAgree(L("ap_ui_realy_want_change_map"),function()
                        RunConsoleCommand("ulx_cmd","map",map)
                    end)
                else
                    RunConsoleCommand("ulx_cmd","map_block",map,not (MapsBlocked and MapsBlocked[map]) and 1 or 0)
                end
            end
        end
    end

    function frame:Update()
        scrollNav:Clear()

        local categories = {}

        for name,info in SortedPairs(MapList or {}) do
            local split = string.Split(name,"_")
    
            local category = accessCategories[split[1]] or "other"
            
            categories[category] = categories[category] or {}
            categories[category][name] = info
        end
    
        //категории "other" может не быть - берём первую существующую
        if not Page.SelectCategory or not categories[Page.SelectCategory] then
            Page.SelectCategory = nil

            for category in SortedPairs(categories) do Page.SelectCategory = category break end
        end

        for category,list in SortedPairs(categories) do
            local butt = scrollNav:Add(category,function() page:Select(list) Page.SelectCategory = category end)
            butt:SetupDrawStyle("white_gradient"); butt.font = "HS.25"

            if Page.SelectCategory == category then page:Select(list) scrollNav:Set(#scrollNav.buttons) end
        end
    end

    frame:Update()
end

event.Add("Map List Sync","UI",function()
    if IsValid(adminpanel_menu) and IsValid(adminpanel_menu[3]) and adminpanel_menu[3].Update then adminpanel_menu[3]:Update() end
end)

event.Add("Map Blocked Sync","UI",function()
    if IsValid(adminpanel_menu) and IsValid(adminpanel_menu[3]) and adminpanel_menu[3].Update then adminpanel_menu[3]:Update() end
end)

if Initialize then RunConsoleCommand("adminpanel_menu") end
