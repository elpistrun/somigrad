--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_donat/lua/hinit/donat/inventory/items/tier_1/crafter/tier_0_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
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
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad_donat\\lua\\hinit\\donat\\inventory\\items\\tier_1\\crafter\\tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ITEM = DonatItem_Reg("crafter",{"base","base_use"},true)
if not ITEM then return INCLUDE_BREAK end

ITEM.type = "3_icons"

function ITEM:GetCountUse()
    return self.data.countUse or 100
end

function ITEM:GetPrintName()
    return "Крафтер"
end

function ITEM:GetDesc()
    return "Объеденяет несколько предметов и делает из них совершено другой предмет"
end

function ITEM:GetRaryType()
    return "common"
end

function ITEM:CanReceive() return false end

function ITEM:CanCraft(inputList,inventoryList)
    local needList = {}
    local aviableList = {}

    for i,inputItem in pairs(inputList) do
        needList[i] = inputItem
    end

    for id,item in pairs(inventoryList) do
        for i,inputItem in pairs(needList) do
            if inputItem.class != item.class then continue end

            local equial = true

            for k,v in pairs(inputItem) do
                if k == "class" then continue end
                if item.data[k] != v then equial = false break end
            end

            if equial then
                aviableList[i] = item
                needList[i] = nil

                break
            end
        end
    end

    return needList,aviableList
end

if SERVER then return end

function ITEM:DrawObject(w,h,panel,desc)
    local mdl = self:GetCSMByID("models/props_se/workshop/vise.mdl")

    self:OpenScene(w,h,panel,20)
        mdl:SetPos(Vector(60,-1,-4))
        mdl:SetAngles(Angle(-15,90 + 45,0))
        mdl:DrawModel()
    self:CloseScene(w,h,panel)

    self:DrawCountUse(w,h,panel,desc)
end

local selectCategory

local colorBlack = Color(0,0,0,245)
local colorWhite = Color(255,255,255,245)

local wait

function ITEM:CreateDescPanel(panel)
    local butt = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(w,h/3) end)
    butt:SetupDrawStyle("white") butt.text = "СКРАФТИТЬ" butt.font = "HS.45"
    
    function butt.OnClick()
        local frame = VguiCreateBlackScreen("crafter")

        local panel = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setSize(w * 0.9,h * 0.8):setPos(w/2-self:W()/2,h/2-self:H()/2) end)
        function panel:DrawOver(w,h) draw.Frame(0,0,w,h,cframe1,cframe2) end

        function frame:DrawContent(w,h)
            draw.SimpleText("КРАФТЕР","HS.45",w/2,panel.y/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end

        local panelItem = oop.CreatePanel("v_donat_item_panel",panel):ad(function(self,w,h) self:setSize(w * (1/3.33),h):setPos(w - self:W(),0) end)
        panelItem.descPanel.type = "shop"

        local selectItem,selectItemAnchor
        local selectCraft,selectCraftAnchor

        function panelItem:DrawOver()
            local item = selectItem or selectItemAnchor

            if item then
                self:SetItemEx(item)
                selectItem = nil
            else
                local craft = selectCraft or selectCraftAnchor

                self:SetItemEx(craft and craft.outputItem)
                selectCraft = nil
            end
        end

        local scrollNav = oop.CreatePanel("v_scrollnav",panel):ad(function(self,w,h) self:setSize(w - panelItem:W(),60) end)
        scrollNav:SetHighlightSide("bottom",nil,true)
        scrollNav:SetupDrawStyle("whitebox")

        local panelPage = oop.CreatePanel("v_scrollpanel",panel):ad(function(self,w,h) self:setPos(0,scrollNav:H()):setSize((w - panelItem:W())/2,h - self.y) end)
        panelPage.scrolling = 300
        panelPage:CreateVBar()

        local panelCraft = oop.CreatePanel("v_panel",panel):ad(function(self,w,h) self:setPos(panelPage:W(),scrollNav:H()):setSize((w - panelItem:W() - self.x),h - self.y) end)

        local panelTitle = oop.CreatePanel("v_panel",panelCraft):ad(function(self,w,h) self:setSize(w,60) end)
        function panelTitle:Draw(w,h)
            local craft = selectCraft or selectCraftAnchor

            if not craft then
                draw.SimpleText("Выберите рецепт","HS.25",w/2,15,nil,TEXT_ALIGN_CENTER)

                return
            end

            draw.SimpleText(craft.name,"HS.25",w/2,15,nil,TEXT_ALIGN_CENTER)
        end

        local buttonCraft = oop.CreatePanel("v_button",panelCraft):ad(function(self,w,h) self:setSize(w,60):setPos(0,h - self:H()) end)
        local titleHBar = 40
        
        //

        local panelNeedItems = oop.CreatePanel("v_panel",panelCraft):ad(function(self,w,h) self:setPos(0,panelTitle:H()):setSize(w,h/2 - self.y) end)
        function panelNeedItems:Draw(w,h)
            surface.SetDrawColor(0,0,0)
            draw.GradientLeft(0,0,w,titleHBar)
            draw.SimpleText("Предметы на входе","HS.18",w/2,titleHBar/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            draw.Frame(0,0,w,titleHBar,cframe1,cframe2)
        end

        local scrollNeedItems = oop.CreatePanel("v_scrollpanel",panelNeedItems):ad(function(self,w,h) self:setPos(0,titleHBar):setSize(w,h - self.y) end)
        scrollNeedItems.scrolling = 300
        scrollNeedItems:CreateVBar()
        local iconSize = math.floor(scrollNeedItems:H() / 3)
        
        local old
        function scrollNeedItems:Step()
            local craft = selectCraft or selectCraftAnchor
            if not craft then selectItemAnchor = nil return end

            if old == craft then return end
            old = craft

            self:Clear()

            local x,y = 0,0

            for i,item in pairs(craft.input) do
                item = DonatItem_Create(item,item)
                local icon = oop.CreatePanel("v_button",self):ad(function(self) self:setSize(iconSize,iconSize) end)
                icon:setPos(x,y)
                x = x + iconSize
                if x + iconSize > self:W() then
                    x = 0
                    y = y + iconSize
                end
                function icon:Draw(w,h)
                    if self:IsHovered() then
                        selectItem = item
                        panelItem:SetItemEx(item)
                    end

                    item:DrawIcon(w,h,self,"H.12")
                end
                function icon:OnClick()
                    selectItemAnchor = item
                    panelItem:SetItemEx(item)
                end
            end
        end

        //

        local panelOutputItems = oop.CreatePanel("v_panel",panelCraft):ad(function(self,w,h) self:setPos(0,panelNeedItems.y + panelNeedItems:H()):setSize(w,h - self.y - buttonCraft:H()) end)
        function panelOutputItems:Draw(w,h)
            surface.SetDrawColor(0,0,0)
            draw.GradientLeft(0,0,w,titleHBar)
            draw.SimpleText("Предметы на выходе","HS.18",w/2,titleHBar/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            draw.Frame(0,0,w,titleHBar,cframe1,cframe2)
        end

        local scrollOutputItems = oop.CreatePanel("v_scrollpanel",panelOutputItems):ad(function(self,w,h) self:setPos(0,titleHBar):setSize(w,h - self.y) end)
        scrollOutputItems.scrolling = 300
        scrollOutputItems:CreateVBar()

        local old
        function scrollOutputItems:Step()
            local craft = selectCraft or selectCraftAnchor
            if not craft then selectItemAnchor = nil return end

            if old == craft then return end
            old = craft

            self:Clear()
            
            local x,y = 0,0

            for i,item in pairs(craft.output) do
                item = DonatItem_Create(item,item)
                local icon = oop.CreatePanel("v_button",self):ad(function(self,w,h) self:setSize(iconSize,iconSize) end)
                icon:setPos(x,y)
                x = x + iconSize
                if x + iconSize > self:W() then
                    x = 0
                    y = y + iconSize
                end
                function icon:Draw(w,h)
                    if self:IsHovered() then
                        selectItem = item
                        panelItem:SetItemEx(item)
                    end

                    item:DrawIcon(w,h,self,"H.12")
                end
                function icon:OnClick()
                    selectItemAnchor = item
                    panelItem:SetItemEx(item)
                end
            end
        end

        //

        function buttonCraft.Draw(_,w,h)
            local k = (self.errorStart or 0) - RealTime() + 1
            
            if k > 0 then
                buttonCraft:SetIsNotClickable(true)

                surface.SetDrawColor(255,0,0,75)
                surface.DrawRect(0,0,w,h)

                surface.SetDrawColor(255,0,0,200)
                draw.GradientDown(0,0,w,h)

                draw.SimpleText(tostring(self.error),"H.25",w/2,h/2,colorBlack,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

                return
            end

            local craft = selectCraft or selectCraftAnchor

            if not craft then
                buttonCraft:SetIsNotClickable(false)

                surface.SetDrawColor(125,125,125,75)
                surface.DrawRect(0,0,w,h)

                surface.SetDrawColor(125,125,125,200)
                draw.GradientDown(0,0,w,h)

                return
            end

            local needList,aviableList = self:CanCraft(craft.input,DonatInventoryList[LocalPlayer():SteamID64()])

            if table.Count(needList) != 0 then
                buttonCraft:SetIsNotClickable(true)

                surface.SetDrawColor(255,0,0,75)
                surface.DrawRect(0,0,w,h)

                surface.SetDrawColor(255,0,0,200)
                draw.GradientDown(0,0,w,h)

                draw.SimpleText("Недостаточно предметов","H.25",w/2,h/2,colorBlack,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            else
                buttonCraft:SetIsNotClickable(false)

                surface.SetDrawColor(0,255,0,75)
                surface.DrawRect(0,0,w,h)

                surface.SetDrawColor(0,255,0,200)
                draw.GradientDown(0,0,w,h)

                draw.SimpleText("СОЗДАТЬ","H.25",w/2,h/2,buttonCraft:IsHovered() and colorWhite or colorBlack,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            end
        end

        function buttonCraft.OnClick()
            //if wait then return end
            wait = nil
            
            self:StartUserCommand("craft")
            net.WriteString(selectCraftAnchor.id)
            net.SendToServer()
        end

        local categories = {}

        for id,craft in pairs(DonatCraftList) do
            categories[craft.category] = categories[craft.category] or {}
            categories[craft.category][id] = craft
        end

        function panelPage:SetCategory(name)
            local iconSize = math.floor(self:W() / 4)

            self:Clear()

            selectCategory = name

            if not name then return end//lol4ik

            local x,y = 0,0

            for id,craft in SortedPairs(categories[name]) do
                local outputItem = craft.output[1]
                outputItem = DonatItem_Create(outputItem,outputItem)

                craft.outputItem = outputItem
                craft.id = id

                local icon = oop.CreatePanel("v_button",self):ad(function(self,w,h) self:setSize(iconSize,iconSize) end)
                icon:setPos(x,y)

                function icon:Draw(w,h)
                    if self:IsHovered() then
                        selectCraft = craft
                        panelItem:SetItemEx(outputItem)
                    end

                    outputItem:DrawIcon(w,h,self)
                end

                function icon:OnClick()
                    selectCraftAnchor = craft
                    selectItemAnchor = nil
                    panelItem:SetItemEx(outputItem)
                end

                x = x + iconSize

                if x + iconSize > self:W() then
                    x = 0
                    y = y + iconSize
                end
            end
        end


        for name in SortedPairs(categories) do
            local butt = scrollNav:Add(name,function() panelPage:SetCategory(name) end)
            butt:SetupDrawStyle("white_gradient")

            if not selectCategory then
                butt:OnClick()
            elseif selectCategory == name then
                butt:OnClick()
            end
        end
    end
end

function ITEM:InputUserCommandPost()
    wait = nil
end
