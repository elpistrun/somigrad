--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_donat/lua/hinit/donat/missions/mission_ui_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad_donat\\lua\\hinit\\donat\\missions\\mission_ui_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
ScoreboardPages[101].list[6] = ScoreboardPages[101].list[6] or {}
local Page = ScoreboardPages[101].list[6]

Page.Name = "donat_ui_mission"

local sendCMD = function(steamid,args)
    net.Start("mission_sync")
    net.WriteString(steamid64 or LocalPlayer():SteamID64())
    net.WriteTable(args)
    net.SendToServer()
end

local colorRed = Color(255,0,0)
local EditItem,EditItemID

function Page.Open(frame)
    Page.panel = frame

    local listCategory = oop.CreatePanel("v_scrollnav",frame):ad(function(self,w,h) self:setSize(math.max(w * 0.2,200),h) end)
    listCategory:SetHighlightSide("right",nil,frame:H()/12)
    listCategory:SetupDrawStyle("whitebox")

    local scrollPage = oop.CreatePanel("v_scrollpage",frame):ad(function(self,w,h) self:setPos(listCategory:W(),0):setSize(w - self.x,h) end)
    scrollPage:SetHorizontal(false)

    local adminPanel
    local function createAdminPanel(callback)
        if IsValid(adminPanel) then adminPanel:Remove() end

        adminPanel = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setSize(w,h * 0.3):setPos(0,h - self:H()) end)
        function adminPanel:Draw(w,h)
            surface.SetDrawColor(0,0,0,100)
            surface.DrawRect(0,0,w,h)
            DrawBlurByPanel(5,self)
        end

        local close = oop.CreatePanel("v_button",adminPanel):ad(function(self,w,h) self:setSize(50,50):setPos(16,h - 16 - 50) end)
        close:SetupDrawStyle("white"); close.text = "CLOSE"; close.font = "HS.12"
        function close:OnClick() if callback then callback() end adminPanel:Remove() end
        close:SetZPos(5)
        
        return adminPanel
    end

    local OpenEditItem = function()
        local panel = createAdminPanel(function() EditItem = nil EditItemID = nil end)
        local textEntry = oop.CreatePanel("v_textentry",panel):ad(function(self,w,h) self:setSize(w,h - 32 - 50) end)
        textEntry:SetMultiline(true)
        textEntry:SetValue(EditItem)
        
        local error
        function textEntry:DrawOver(w,h)
            if error then draw.SimpleText("ERROR JSON","HS.12",0,0,colorRed) end
        end

        function textEntry:OnChange()
            EditItem = self:GetText()
            error = not util.JSONToTableUnLimit(EditItem)
        end

        local send = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(50,50):setPos(w - self:W() - 16,h - self:H() - 16) end)
        send:SetupDrawStyle("white"); send.text = "SUMBIT"; send.font = "HS.12"
        function send:OnClick() sendCMD(AccountSteamID64,{"set",EditItemID,util.JSONToTableUnLimit(EditItem)}) end
    end

    if LocalPlayer():HasSuccess("donat_moderate") then
        local butt = oop.CreatePanel("v_button",frame):ad(function(self,w,h) self:setSize(50,50):setPos(16,h - self:H() - 16) end)
        butt:SetupDrawStyle("white"); butt.text = "+"; butt.font = "HS.45"

        function butt:OnClick()
            butt:Create()
        end

        function butt:Create()
            local panel = createAdminPanel(function() end)
            local scrollPanel = oop.CreatePanel("v_scrollpanel",panel):ad(function(self,w,h) self:setSize(w,h) end)
            scrollPanel:CreateVBar()
            scrollPanel.canvasPanel:AddFlexParent()

            for class,mission in pairs(MissionItemClasses) do
                local icon = oop.CreatePanel("v_button",scrollPanel):ad(function(self,w,h) self:setSize(160,160) end):AddByFlex()
                icon.text = class; icon.font = "HS.25"

                function icon:OnClick()
                    sendCMD(AccountSteamID64,{"add",class})
                end
            end
        end
    end

    function frame:Update()
        local category = {}

        for id,mission in pairs(MissionList[AccountSteamID64]) do
            if not category[mission.Category] then category[mission.Category] = {} end

            category[mission.Category][id] = mission
        end

        listCategory:Clear()
        scrollPage:Clear()
        
        for category,list in SortedPairs(category) do
            local page = scrollPage:Add()
            local butt = listCategory:Add(category,function() scrollPage:Set(page.id) Page.CategoryPageSelect = page.id end)
            butt.font = "H.18"

            if Page.CategoryPageSelect == page.id then
                scrollPage:Set(page.id,true)
                listCategory:Set(page.id,true)
            end

            local categoryInfo = MissionCategories[category]

            function butt:Draw(w,h)
                local raryData = DonatItemsRaryData[categoryInfo.raryType]
                local color = raryData[1]
                surface.SetDrawColor(color.r,color.g,color.b,100)
                surface.DrawRect(0,0,w,h)
                surface.SetDrawColor(color.r,color.g,color.b,200)
                draw.GradientLeft(0,0,w,h)

                draw.GradientLeft(0,0,w + w * 0.25 * (math.cos(CurTime())),h)

                draw.SimpleText(L(categoryInfo.name),"H.25",w/2,h/2,raryData[2],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

                draw.Frame(0,0,w,h,cframe1,cframe2)
            end

            local listPanel = oop.CreatePanel("v_scrollpanel",page):ad(function(self,w,h) self:setSize(w,h) end)
            listPanel:CreateVBar()
            listPanel.scrolling = math.ceil(listPanel:H() / 6) * 2

            local i = 0
            for id,mission in SortedPairs(list) do
                local I = i
                i = i + 1
                local icon = oop.CreatePanel("v_panel",listPanel):ad(function(self,w,h) self:setSize(w,math.ceil(listPanel:H() / 6)):setPos(0,self:H() * I) end)
                
                local butt = oop.CreatePanel("v_button",icon):ad(function(self,w,h) self:setSize(w * 0.125,h / 4):setPos(8,h - self:H() - 8) end)
                butt:SetupDrawStyle("white_gradient"); butt.text = L("donat_ui_mission_not_complete"); butt.font = "HS.18"
                function butt:OnClick()
                    mission:Collect()
                end
                butt:SetIsNotClickable(true)

                local canWork = mission:CanWork()
                local lock = not canWork or mission.data.complete

                if mission.data.canComplete then
                    if mission.data.complete then
                        butt.text = L("donat_ui_mission_completed")
                        butt.gradientSide = "bottom"
                    else
                        butt:SetIsNotClickable(false)
                        butt.text = L("donat_ui_mission_can_complete")
                        butt.gradientSide = "bottom"
                    end
                end

                function icon:Draw(w,h)
                    mission:DrawIcon(w,h,self,butt)
                end

                function icon:DrawOver(w,h)
                    if lock then
                        surface.SetDrawColor(0,0,0,175)
                        surface.DrawRect(0,0,w,h)

                        if not canWork then
                            draw.SimpleText(L("donat_ui_mission_not_work_gamemode"),"HS.25",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                        end
                    end
                end

                function icon:OnMouse(key,value)
                    if value and LocalPlayer():HasSuccess("donat_moderate") and key == MOUSE_RIGHT then
                        local menu = DermaMenu()
                        menu:AddOption("Edit",function()
                            EditItem = util.TableToJSON(MissionData[AccountSteamID64][id],true)
                            EditItemID = id
        
                            OpenEditItem()
                        end)
                        menu:AddOption("Delete",function() sendCMD(AccountSteamID64,{"remove",id}) end)
                        menu:Open()
                    end
                end
                if EditItemID then OpenEditItem() end

                local listItems = oop.CreatePanel("v_panel",icon):ad(function(self,w,h) self:setSize(w/2,h - 28):setPos(w/2,28) end)
                function listItems:Draw(w,h)
                    surface.SetDrawColor(0,0,0,100)
                    surface.DrawRect(w/2,0,w/2,h)
                    draw.GradientRight(0,0,w/2,h)
                end

                for i,item in pairs(mission:GetItems()) do
                    local I = i
                    local iconItem = oop.CreatePanel("v_panel",listItems):ad(function(self,w,h) self:setSize(h,h):setPos(w - self:H() * I,0) end)
                    item = DonatItem_Create(item,item)

                    if lock then iconItem.IsHovered = function() end end
                    
                    function iconItem:Draw(w,h)
                        item:DrawIcon(w,h,self,"H.12")
                    end
                end

            end
        end

    end

    frame:Update()
end

event.Add("Mission Sync","UI",function(steamid64,data)
    if IsValid(Page.panel) and Page.panel.Update then Page.panel:Update() end
end)

if Initialize then OpenTab() end
