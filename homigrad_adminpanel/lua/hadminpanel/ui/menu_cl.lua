--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_adminpanel/lua/hadminpanel/ui/menu_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:11 <
]]

-- "addons\\homigrad_adminpanel\\lua\\hadminpanel\\ui\\menu_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
AdminPanel_Command_Create("menu",nil,function()
    RunConsoleCommand("adminpanel_menu")
end)

AdminPanelPages = AdminPanelPages or {}

concommand.Add("adminpanel_menu",function()
    if IsValid(adminpanel_menu) then adminpanel_menu:Remove() end

    adminpanel_menu = VguiCreateBlackScreen("adminpanel")

    local scrollnav = oop.CreatePanel("v_scrollnav",adminpanel_menu):ad(function(self,w,h) self:setPos(w*0.05,h*0.05):setSize(w - w * 0.05 * 2,50) end)
    scrollnav:SetHighlightSide("bottom",nil,true)

    local scrollpage = oop.CreatePanel("v_scrollpage",adminpanel_menu):ad(function(self,w,h) self:setPos(scrollnav.x,scrollnav.y + scrollnav:H()):setSize(scrollnav:W(),h - self.y - h * 0.05) end)
    scrollpage:SetHorizontal(true)
    scrollpage.Lerp = 1

    function scrollpage:Draw(w,h)
        surface.SetDrawColor(0,0,0,100)
        surface.DrawRect(0,0,w,h)
        
        draw.Frame(0,0,w,h,cframe1,cframe2)
    end

    local pages = {}
    
    function adminpanel_menu:Update()
        for i,page in pairs(AdminPanelPages) do
            if page.CanOpen and page.CanOpen() != pages[i] then RunConsoleCommand("adminpanel_menu") return end
        end

        for i,page in pairs(scrollpage.pages) do
            if page.Update then page:Update() end
        end 
    end

    function adminpanel_menu:SelectPage(i,force)
        local page = AdminPanelPages[i]
        local panel = adminpanel_menu[i]

        //страница может быть недоступна по правам - тогда её панели просто нет
        if not page or not panel then return end

        AdminPanelPage = i

        local number = AdminPanelPages[i].number
        scrollpage:Set(number,force)
        scrollnav:Set(number,force)

        if not panel.isOpen then
            panel.isOpen = true
            page.Open(panel)
        end
    end

    function adminpanel_menu:Build()
        scrollnav:Clear()
        scrollpage:Clear()

        for i in pairs(AdminPanelPages) do adminpanel_menu[i] = nil end

        for i,page in SortedPairs(AdminPanelPages) do
            if page.CanOpen and not page.CanOpen() then pages[i] = false continue end
            pages[i] = true

            local panel = scrollpage:Add()
            adminpanel_menu[i] = panel
            AdminPanelPages[i].number = #scrollpage.pages

            local butt = scrollnav:Add(L(page.Name or i),function()
                adminpanel_menu:SelectPage(i)
            end)
            butt:SetupDrawStyle("white_gradient"); butt.font = "HS.25"
        end
    end

    adminpanel_menu:Build()

    //если страница из прошлого открытия сейчас недоступна - берём первую доступную
    if not AdminPanelPage or not adminpanel_menu[AdminPanelPage] then
        AdminPanelPage = nil

        for i in SortedPairs(AdminPanelPages) do
            if adminpanel_menu[i] then AdminPanelPage = i break end
        end
    end

    if AdminPanelPage then adminpanel_menu:SelectPage(AdminPanelPage,true) end
end)

concommand.Add("menu",function()
    RunConsoleCommand("adminpanel_menu")
end)

if Initialize then RunConsoleCommand("adminpanel_menu") end

event.Add("AP Roles Sync","UI",function()
    if IsValid(adminpanel_menu) then adminpanel_menu:Update() end
end)

event.Add("AP Roles Inherit Sync","UI",function()
    if IsValid(adminpanel_menu) then adminpanel_menu:Update() end
end)

event.Add("AP Roles List Sync","UI",function()
    if IsValid(adminpanel_menu) then adminpanel_menu:Update() end
end)

event.Add("AP Player Sync","UI",function(ply)
    if ply != LocalPlayer() then return end

    if IsValid(adminpanel_menu) then adminpanel_menu:Update() end
end)
