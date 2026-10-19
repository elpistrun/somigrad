--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_donat/lua/hinit/donat/inventory/inventory_ui_cl.lua <
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

-- "addons\\homigrad_donat\\lua\\hinit\\donat\\inventory\\inventory_ui_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
ScoreboardPages[101].list[3] = ScoreboardPages[101].list[3] or {}
local Page = ScoreboardPages[101].list[3]

Page.Name = "donat_ui_inventory"

local sendCMD = function(steamid64,args)
    net.Start("donat_inventory_sync")
    net.WriteString(steamid64 or LocalPlayer():SteamID64())
    net.WriteTable(args)
    net.SendToServer()
end

local colorRed = Color(255,0,0)

local EditItem,EditItemID

local categoryNameSave

function Page.Open(frame)
    Page.panel = frame

    local inventoryList = DonatInventoryList[AccountSteamID64]

    local selectItemID
    local selectItemAnchorID

    local panelItem = oop.CreatePanel("v_donat_item_panel",frame):ad(function(self,w,h) self:setSize(w * (1/3.3),h):setPos(w - self:W(),0) end)
    panelItem:SetInventory(inventoryList)

    //

    local navPanel = oop.CreatePanel("v_scrollnav",frame):ad(function(self,w,h) self:setSize(w - panelItem:W(),50) end)
    navPanel:SetHighlightSide("bottom",nil,true)
    navPanel:SetupDrawStyle("whitebox")

    local pagesPanel = oop.CreatePanel("v_scrollpage",frame):ad(function(self,w,h)
        self:setPos(0,navPanel:H()):setSize(navPanel:W(),h - self.y)
    end)

    pagesPanel:SetHorizontal(true)
    
    function pagesPanel:Draw(w,h)
        panelItem:SetItem(selectItemAnchorID)
    end

    local panelAdminPanel
    local openAdminPanel = function(callback)
        if IsValid(panelAdminPanel) then panelAdminPanel:Remove() end
        panelAdminPanel = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setSize(pagesPanel:W(),pagesPanel:H()/2):setPos(pagesPanel.x,h - self:H()) end)
        function panelAdminPanel:Draw(w,h)
            surface.SetDrawColor(0,0,0,100)
            surface.DrawRect(0,0,w,h)
            DrawBlurByPanel(5,self)
            draw.Frame(0,0,w,h,cframe1,cframe2)
        end

        local close = oop.CreatePanel("v_button",panelAdminPanel):ad(function(self,w,h) self:setSize(50,50):setPos(16,h - 16 - 50) end)
        close:SetupDrawStyle("white"); close.text = "CLOSE"; close.font = "HS.12"
        function close:OnClick() if callback then callback() end panelAdminPanel:Remove() end

        return panelAdminPanel
    end

    //

    local categories = {}

    local iconSize = 128

    for name,categoryName in SortedPairs(DonatCategories) do
        local page = pagesPanel:Add()
        local scrollPanel = oop.CreatePanel("v_scrollpanel",page):setDSize(1,1)
        scrollPanel.canvasPanel:AddFlexParent()
        scrollPanel:CreateVBar()
        scrollPanel.scrolling = 256

        local i = #pagesPanel.canvasPanel:GetChildren()
        local butt = navPanel:Add(L(categoryName),function() pagesPanel:Set(i) categoryNameSave = name end)
        butt:SetupDrawStyle("white_gradient"); butt.gradientSide = "bottom"; butt.font = "HS.18"

        categories[name] = scrollPanel

        scrollPanel:ad(function(self,w,h)
            iconSize = math.floor(w / 6) - self.vbar:W()/w
        end)

        if categoryNameSave == name then
            navPanel:Set(i)
            pagesPanel:Set(i)
        end
    end

    local OpenEditItem = function()
        local panel = openAdminPanel(function() EditItem = nil EditItemID = nil end)
                            
        local textEntry = oop.CreatePanel("v_textentry",panel):ad(function(self,w,h) self:setSize(w,h - 50 - 32) end)
        textEntry:SetMultiline(true)
        textEntry:SetText(tostring(EditItem or ""))

        local error = not util.JSONToTableUnLimit(EditItem or "{}")

        function textEntry:DrawOver(w,h)
            if error then
                draw.SimpleText("ERROR JSON","H.12",0,0,colorRed)
            end
        end

        function textEntry:OnChange()
            EditItem = self:GetText()
            error = not util.JSONToTableUnLimit(EditItem,true)
        end

        local send = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(50,50):setPos(w - 16 - self:W(),h - 16 - 50) end)
        send:SetupDrawStyle("white"); send.text = "SUMBIT"; send.font = "HS.12"
        function send:OnClick()
            if error then return end
            sendCMD(AccountSteamID64,{"set",EditItemID,util.JSONToTableUnLimit(EditItem)})
            EditItem = nil
            EditItemID = nil
            panel:Remove()
        end
    end

    function frame:Update()
        for name,page in pairs(categories) do
            page:Clear()

            local x,y = 0,0
            for _,item in pairs(DonatItem_GetSortTable(inventoryList,name)) do
                local id = item.id
                
                local X,Y = x,y
                
                local icon = oop.CreatePanel("v_button",page):ad(function(self,w,h) self:setSize(iconSize,iconSize):setPos(X,Y) end)
                
                x = x + icon:W()
                
                if x + iconSize > page:W() then
                    x = 0
                    y = y + iconSize
                end

                icon.soundDown = nil

                function icon:Draw(w,h)
                    item:DrawIcon(w,h,self)
                    
                    if self:IsHovered() then
                        panelItem:SetItem(id)
                    end

                    if selectItemID == id then
                        surface.SetDrawColor(255,255,255)
                        surface.DrawRect(0,h - 1,w,1)
                    end

                    if Outfit_GetPlayerModelID(AccountSteamID64) == id then
                        surface.SetDrawColor(255,255,255)
                        draw.GradientDown(0,h - 4,w,3)
                        
                        draw.SimpleText("Экипипрован","HS.18",w/2,8,nil,TEXT_ALIGN_CENTER)
                    end
                end
                function icon:OnClick(key)
                    if key == MOUSE_RIGHT and LocalPlayer():HasSuccess("donat_moderate") then
                        local menu = DermaMenu()
                        menu:AddOption("Edit",function()
                            EditItem = util.TableToJSON(DonatInventoryData[AccountSteamID64][id],true)
                            EditItemID = id

                            OpenEditItem(id,item,AccountSteamID64)
                        end)
                        menu:AddOption("Clone",function() sendCMD(AccountSteamID64,{"clone",id}) end)
                        menu:AddOption("Delete",function() sendCMD(AccountSteamID64,{"remove",id}) end)
                        menu:Open()
                    end
                    
                    if key == MOUSE_LEFT then
                        selectItemAnchor = item
                        selectItemAnchorID = id
                    end
                end
                if EditItemID == id then OpenEditItem(id,item,steamid64) end
            end
        end

        if selectItemID then panelItem:SetItem(selectItemID,true) end
    end

    if LocalPlayer():HasSuccess("donat_moderate") then
        local addItem = oop.CreatePanel("v_button",frame):ad(function(self,w,h) self:setSize(50,50):setPos(16,h - 50 - 16) end)
        addItem:SetupDrawStyle("white"); addItem.text = "+"; addItem.font = "HS.45"
        function addItem:OnClick()
            local panel = openAdminPanel()

            local itemsList = oop.CreatePanel("v_scrollpanel",panel):ad(function(self,w,h) self:setSize(w,h - 50 - 32) end)
            itemsList:CreateVBar()
            itemsList.canvasPanel:AddFlexParent()
            itemsList.scrolling = 200

            for class,item in pairs(DonatItemClasses) do
                if item[2].doNotShowInUI then continue end

                item = util.tableCopy(item[1])
                item.data = {}
                
                local icon = oop.CreatePanel("v_button",itemsList):ad(function(self,w,h) self:setSize(160,160) end):AddByFlex()
                function icon:Draw(w,h) item:DrawIcon(w,h,self) end
                function icon:OnClick() sendCMD(AccountSteamID64,{"add",class}) end
            end
        end
    end

    frame:Update()
end

event.Add("Donat Inventory Sync","UI",function(steamid64,inventory)
    if IsValid(Page.panel) and Page.panel.Update then Page.panel:Update() end
end)

function DonatInventory_NetButton(butt,globalName,callback,delay)
    function butt:OnClick()
        if _G[globalName] then return end
        if callback() == false then return end

        timer.Create(globalName,delay or 1,1,function()
            local butt = _G[globalName]
            _G[globalName] = nil
            if IsValid(butt) then butt:SetIsNotClickable(false) end
            chat.AddText(Color(255,0,0),"Попробуйте ещё-раз " .. globalName .. " has timeout")
        end)

        self.startTime = RealTime()
        
        _G[globalName] = self
        butt:SetIsNotClickable(true)
    end
    butt:SetIsNotClickable(_G[globalName] and true or false)
end

function DonatInventory_NetButtonHas(globalName,callback)
    local butt = _G[globalName]

    if butt then
        timer.Remove(globalName)

        _G[globalName] = nil
        if IsValid(butt) then butt:SetIsNotClickable(false) end

        callback(butt)

        return true
    end
end

if Initialize then OpenTab() end

