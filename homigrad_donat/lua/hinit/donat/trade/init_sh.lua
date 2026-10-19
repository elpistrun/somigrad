--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_donat/lua/hinit/donat/trade/init_sh.lua <
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

-- "addons\\homigrad_donat\\lua\\hinit\\donat\\trade\\init_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
TRADE_WAIT = 3
TRADE_DELAY = 30

AdminPanel_Command_Registry("trade",{{type = "player",required = true}},"game")

function DonatItem_CanTrade(item)
    if item.cantTrade then return false end
    if item.CanTrade then return item:CanTrade() end

    return true
end

if SERVER then return end

local function updateTradeList(list)
    local newList = {}

    for item in pairs(list) do
        if not item.id then
            newList[item.class] = {class = item.class,data = item.data}
        else
            newList[item.id] = ""
        end
    end

    net.Start("trade")
    net.WriteString("update list")
    net.WriteTable(newList)
    net.SendToServer()
end

local grayColor = Color(200,200,200,200)
local blackColor = Color(0,0,0,245)

local color_gold = Color(255,255,0)

local function openItemsMenu()
    local frame = oop.CreatePanel("v_donat_itemlist_panel",TRADE_FRAME):ad(function(self,w,h) self:setSize(w * 0.9,h * 0.8):setPos(w/2-self:W()/2,h/2-self:H()/2) end)
    TRADE_FRAME_ITEMS = frame
    frame.create = RealTime()

    function frame:Draw(w,h)
        surface.SetDrawColor(0,0,0,50)
        surface.DrawRect(0,0,w,h)
    end

    function frame:DrawOver(w,h)
        draw.Frame(0,0,w,h,cframe1,cframe2)
    end

    function frame:FilterItem(item)
        if not DonatItem_CanTrade(item) then return false end
    end

    frame.listItems = TRADE_FRAME.itemsPanel.listItems

    function frame:Update()
        updateTradeList(self.listItems)
        TRADE_FRAME.itemsPanel:Update()
    end
end

local function openFrame(playerTrading)
    local AccountSteamID64 = LocalPlayer():SteamID64()
    
    if IsValid(TRADE_FRAME) then TRADE_FRAME:Remove() end
    TRADE_FRAME = VguiCreateBlackScreen("trade")
    local tradeFrame = TRADE_FRAME
    tradeFrame:MakePopup()

    function TRADE_FRAME:OnMouse(key,value)
        if not value then return end

        if not self.closeFrameItemsStart and IsValid(TRADE_FRAME_ITEMS) then
            TRADE_FRAME_ITEMS:SetMouseInputEnabled(false)
            self.closeFrameItemsStart = RealTime()
        else
            self:Close()
        end
    end

    local frame = oop.CreatePanel("v_panel",tradeFrame):ad(function(self,w,h) self:setSize(w * 0.9,h * 0.8):setPos(w/2-self:W()/2,h/2-self:H()/2) end)

    function frame:Draw(w,h)
        surface.SetDrawColor(0,0,0,50)
        surface.DrawRect(0,0,w,h)
    end

    function frame:DrawOver(w,h)
        draw.Frame(0,0,w,h,cframe1,cframe2)
    end

    function tradeFrame:DrawContent(w,h)
        draw.SimpleText("ОБМЕН","HS.45",w/2,frame.y/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        draw.SimpleText("выйти можно нажав на угол экрана","H.18",w/2,h,grayColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)

        local balance = BalanceData[AccountSteamID64]
        if balance then
            draw.SimpleText("Balance: " .. DonatXPGetText(balance.money or 0),"HS.18",frame.x,frame.y + frame:H() + 8,nil,nil)
            draw.SimpleText("Donat Balance: " .. DonatXPGetText(balance.moneyDonat or 0),"HS.18",frame.x,frame.y + frame:H() + 32,color_gold,nil)
        end
    end

    function tradeFrame:Think()
        if self.closeFrameItemsStart then
            local k = 1 - math.max(self.closeFrameItemsStart - RealTime() + 0.05,0) / 0.05
            frame:SetAlpha(255 * k)
            frame:SetVisible(true)

            if IsValid(TRADE_FRAME_ITEMS) then
                TRADE_FRAME_ITEMS:SetAlpha(255 * (1 - k))
            end

            if k == 1 then
                self.closeFrameItemsStart = nil
                
                if IsValid(TRADE_FRAME_ITEMS) then
                    TRADE_FRAME_ITEMS:Remove()
                end
            end
        elseif IsValid(TRADE_FRAME_ITEMS) then
            local k = math.max(TRADE_FRAME_ITEMS.create - RealTime() + 0.05,0) / 0.05

            frame:SetAlpha(255 * k)
            frame:SetVisible(k != 0)
            TRADE_FRAME_ITEMS:SetAlpha(255 * (1 - k))
        end

        self:Step()
    end

    //

    local mePanel = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setSize(w/2,h) end)
    function mePanel:Draw(w,h)
        surface.SetDrawColor(200,200,200,5)
        surface.DrawRect(w - 1,0,1,h)
    end

    local iconSize = mePanel:H() * 0.125

    local avatar = oop.CreatePanel("v_avatarlist",mePanel):ad(function(self,w,h) self:setSize(w,iconSize) end)
    avatar:Setup(iconSize - iconSize * 0.33)
    avatar:AddPlayer(LocalPlayer()).Draw = nil

    local itemsPanel = oop.CreatePanel("v_scrollpanel",mePanel):ad(function(self,w,h) self:setPos(0,avatar:H()):setSize(w,h - self.y - iconSize) end)
    tradeFrame.itemsPanel = itemsPanel
    itemsPanel:CreateVBar()
    itemsPanel.listItems = {}

    local itemSize = math.floor(itemsPanel:W()/7)
    
    local money = DonatItem_Create({class = "money"},{money = 0})
    itemsPanel.listItems[money] = true

    local moneyDonat = DonatItem_Create({class = "money_donat"},{money = 0})
    itemsPanel.listItems[moneyDonat] = true

    function itemsPanel:Update()
        self:Clear()

        local x,y = 0,0

        local list = {}
        for item in pairs(self.listItems) do
            if not item.id then
                table.insert(list,item)
            else
                list[item.id] = item
            end
        end

        for _,item in SortedPairs(DonatItem_GetSortTable(list)) do
            local X,Y = x,y
            
            local icon = oop.CreatePanel("v_button",self):ad(function(self,w,h) self:setSize(itemSize,itemSize):setPos(X,Y) end)
            
            x = x + icon:W()
            if x + itemSize > self:W() then x = 0 y = y + itemSize end

            icon.soundDown = nil

            function icon:Draw(w,h)
                item:DrawIcon(w,h,self)
            end

            function icon.OnClick()
                if item.class == "money" then
                    VParametrEdit(BalanceData[AccountSteamID64].money,item.data.money,function(value)
                        value = tonumber(value)
                        if value <= BalanceData[AccountSteamID64].money then
                            item.data.money = math.max(value,0)

                            updateTradeList(self.listItems)
                        end
                    end,"Сколько хотите положить?")
                elseif item.class == "money_donat" then
                    VParametrEdit(BalanceData[AccountSteamID64].moneyDonat,item.data.money,function(value)
                        value = tonumber(value)
                        if value <= BalanceData[AccountSteamID64].moneyDonat then
                            item.data.money = math.max(value,0)

                            updateTradeList(self.listItems)
                        end
                    end,"Сколько хотите положить?")
                else
                    self.listItems[item] = nil
                    self:Update()

                    updateTradeList(self.listItems)
                end
            end
        end

        local X,Y = x,y
        local buttAdd = oop.CreatePanel("v_button",self):ad(function(self,w,h) self:setSize(itemSize,itemSize):setPos(X,Y) end)
        buttAdd:SetupDrawStyle("white"); buttAdd.font = "HS.25"; buttAdd.text = "+";
        function buttAdd:OnClick() openItemsMenu(itemsMe) end
    end

    itemsPanel:Update()

    local panelChoice = oop.CreatePanel("v_button",mePanel):ad(function(self,w,h) self:setPos(0,itemsPanel.y + itemsPanel:H()):setSize(w,iconSize) end)
    TRADE_FRAME.panelChoice = panelChoice

    local k = 0.2
    function panelChoice:Draw(w,h)
        if self.mode == "ready" then
            k = LerpFT(0.8,k,self:IsHovered() and 0.4 or 0.2)
            surface.SetDrawColor(0,0,0)
            surface.DrawRect(0,0,w,h)
            
            surface.SetDrawColor(0,255,0,200)
            draw.GradientRight(-w*k,0,w*(1 + k),h)
            draw.Frame(0,0,w,h,cframe1,cframe2)

            draw.SimpleText("Я СОГЛАСЕН","H.45",w/2,h/2,blackColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        elseif self.mode == "start" then
            surface.SetDrawColor(0,0,0)
            surface.DrawRect(0,0,w,h)
            
            surface.SetDrawColor(125,125,125,200)
            draw.GradientLeft(0,0,w*(1 + k),h)
            draw.Frame(0,0,w,h,cframe1,cframe2)

            draw.SimpleText(math.floor((self.start - RealTime() + TRADE_WAIT) * 10) / 10 .. "s","H.45",w/2,h/2,blackColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        else
            k = LerpFT(0.8,k,self:IsHovered() and 0.4 or 0.2)
            surface.SetDrawColor(0,0,0)
            surface.DrawRect(0,0,w,h)
            
            surface.SetDrawColor(0,255,0,200)
            draw.GradientRight(-w*k,0,w*(1 + k),h)
            draw.Frame(0,0,w,h,cframe1,cframe2)

            draw.SimpleText("НАЧАТЬ","H.45",w/2,h/2,blackColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end
    end
    function panelChoice:OnClick()
        if self.mode == "ready" then
            self.mode = "none"
        else
            self.mode = "ready"
        end

        net.Start("trade")
        net.WriteString("update state")
        net.WriteString(self.mode)
        net.SendToServer()
    end

    //
    //
    //
    //
    //
    //

    local ourPanel = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setSize(w/2,h):setPos(w/2,0) end)
    function ourPanel:Draw(w,h)
        surface.SetDrawColor(200,200,200,5)
        surface.DrawRect(w - 1,0,1,h)
    end

    local avatar = oop.CreatePanel("v_avatarlist",ourPanel):ad(function(self,w,h) self:setSize(w,iconSize) end)
    avatar:Setup(iconSize - iconSize * 0.33)
    avatar:AddPlayer(playerTrading or LocalPlayer()).Draw = nil

    local itemsPanel = oop.CreatePanel("v_scrollpanel",ourPanel):ad(function(self,w,h) self:setPos(0,avatar:H()):setSize(w,h - self.y - iconSize) end)
    itemsPanel:CreateVBar()
    itemsPanel.listItems = {}
    TRADE_FRAME.ourItemsPanel = itemsPanel

    function itemsPanel:Update()
        self:Clear()

        local x,y = 0,0

        local list = {}
        for item in pairs(self.listItems) do
            if not item.id then
                table.insert(list,item)
            else
                list[item.id] = item
            end
        end

        for _,item in SortedPairs(DonatItem_GetSortTable(list)) do
            local X,Y = x,y
            
            local icon = oop.CreatePanel("v_button",self):ad(function(self,w,h) self:setSize(itemSize,itemSize):setPos(X,Y) end)
            
            x = x + icon:W()
            if x + itemSize > self:W() then x = 0 y = y + itemSize end

            icon.soundDown = nil

            function icon:Draw(w,h)
                item:DrawIcon(w,h,self)
            end
        end
    end

    itemsPanel:Update()

    local panelChoice = oop.CreatePanel("v_button",ourPanel):ad(function(self,w,h) self:setPos(0,itemsPanel.y + itemsPanel:H()):setSize(w,iconSize) end)
    TRADE_FRAME.outPanelChoice = panelChoice

    local k = 0.2

    function panelChoice:Draw(w,h)
        if self.mode == "ready" then
            surface.SetDrawColor(0,0,0)
            surface.DrawRect(0,0,w,h)
            
            surface.SetDrawColor(0,255,0,200)
            draw.GradientLeft(0,0,w*(1 + k),h)
            draw.Frame(0,0,w,h,cframe1,cframe2)

            draw.SimpleText("Я СОГЛАСЕН","H.45",w/2,h/2,blackColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        elseif self.mode == "start" then
            surface.SetDrawColor(0,0,0)
            surface.DrawRect(0,0,w,h)
            
            surface.SetDrawColor(125,125,125,200)
            draw.GradientLeft(0,0,w*(1 + k),h)
            draw.Frame(0,0,w,h,cframe1,cframe2)

            draw.SimpleText(math.floor((self.start - RealTime() + TRADE_WAIT) * 10) / 10 .. "s","H.45",w/2,h/2,blackColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        else
            surface.SetDrawColor(0,0,0)
            surface.DrawRect(0,0,w,h)
            
            surface.SetDrawColor(255,0,0,200)
            draw.GradientLeft(0,0,w*(1 + k),h)
            draw.Frame(0,0,w,h,cframe1,cframe2)

            draw.SimpleText("Я НЕ СОГЛАСЕН","H.45",w/2,h/2,blackColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end
    end
end

net.Receive("trade",function()
    local cmd = net.ReadString()

    if cmd == "open" then
        openFrame(net.ReadEntity())

        function TRADE_FRAME:OnRemove()
            net.Start("trade")
            net.WriteString("close")
            net.SendToServer()
        end
    elseif cmd == "close" then
        if IsValid(TRADE_FRAME) then TRADE_FRAME:Close() end
    elseif cmd == "update list" then
        local list = {}

        for id,item in pairs(net.ReadTable()) do
            item = DonatItem_Create(item,item)
            list[item] = true
        end

        TRADE_FRAME.ourItemsPanel.listItems = list
        TRADE_FRAME.ourItemsPanel:Update()
    elseif cmd == "update state" then
        local outPanelChoice = TRADE_FRAME.outPanelChoice
        outPanelChoice.mode = net.ReadString()

        if outPanelChoice.mode == "reset" then
            TRADE_FRAME.panelChoice.mode = "none"
            outPanelChoice.mode = "none"
        end

        if outPanelChoice.mode == "start" then
            TRADE_FRAME.panelChoice.mode = "start"
            TRADE_FRAME.panelChoice.start = RealTime()

            outPanelChoice.mode = "start"
            outPanelChoice.start = RealTime()
        end
    end
end)
