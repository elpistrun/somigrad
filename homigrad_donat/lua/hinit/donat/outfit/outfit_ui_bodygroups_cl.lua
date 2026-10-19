--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_donat/lua/hinit/donat/outfit/outfit_ui_bodygroups_cl.lua <
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

-- "addons\\homigrad_donat\\lua\\hinit\\donat\\outfit\\outfit_ui_bodygroups_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
ScoreboardPages[101].list[4] = ScoreboardPages[101].list[4] or {}
local Page = ScoreboardPages[101].list[4]

local colorBodyGroupEmpty = Color(0,0,0,75)
local colorRed = Color(255,0,0)

function Page.OpenBodygroup(page,avatar)
    Page.panelBodygroups = page
    
    local selectItem,selectItemID
    local bodygroupsSelected
    local itemsUpdageSelected

    local iconSize
    local panelTitle = oop.CreatePanel("v_panel",page):ad(function(self,w,h) self:setSize(w*0.5,h) end)
    local bodygroupList = oop.CreatePanel("v_scrollpanel",panelTitle):ad(function(self,w,h) self:setPos(0,50):setSize(w,h - self.y) end)

    bodygroupList:CreateVBar()
    bodygroupList.scrolling = 200

    function bodygroupList:Update()
        bodygroupsSelected = {}

        bodygroupList:Clear()
        if not selectItem then return end

        local info = selectItem:GetModelInfo()

        local i = 0
        for x = -1,info.bodygroupsMax do
            local info = info.bodygroups[x]
            if not info then continue end
            
            local I = i
            i = i + 1

            local panelTitle = oop.CreatePanel("v_panel",bodygroupList):ad(function(self,w,h) self:setSize(w,40 + 50):setPos(0,self:H() * I) end)
            local panel = oop.CreatePanel("v_panel",panelTitle):ad(function(self,w,h) self:setSize(w,h-40):setPos(0,40) end)
            local slider = oop.CreatePanel("v_slider",panel):ad(function(self,w,h) self:setSize(w,60):setPos(0,h/2-self:H()/2) end)
            slider.round = 1
            slider:SetMin(0)
            slider:SetMax(#info)
            slider:SetValue(0)

            function panelTitle:Draw(w,h)
                surface.SetDrawColor(0,0,0,100)
                surface.DrawRect(0,0,w,40)
                draw.GradientLeft(0,0,w,40)

                draw.SimpleText(L(info[slider:GetValue()].name),"HS.25",8,20,nil,nil,TEXT_ALIGN_CENTER)
            end

            function slider:OnValue(value)
                if value == 0 then bodygroupsSelected[x] = nil else bodygroupsSelected[x] = value end
                
                selectItem:SetBodygroup(x,value,avatar.mdl)
            end

            //slider:OnValue(math.random(1,#info))
        end
    end

    function panelTitle:Draw(w,h)
        surface.SetDrawColor(0,0,0,100)
        surface.DrawRect(0,0,w,50)
        draw.GradientDown(0,0,w,50)

        draw.SimpleText(L("donat_ui_select_bodygroups"),"HS.25",w/2,25,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    //Upgrade

    local iconSize
    local upgradeSide = oop.CreatePanel("v_panel",page):ad(function(self,w,h) self:setPos(bodygroupList:W(),0):setSize(w - self.x,h) iconSize = math.floor((self:W()*0.85)/4) end)
    local panelTitle = oop.CreatePanel("v_panel",upgradeSide):ad(function(self,w,h) self:setSize(w,50) end)

    function panelTitle:Draw(w,h)
        surface.SetDrawColor(0,0,0,100)
        surface.DrawRect(0,0,w,h)
        draw.GradientDown(0,0,w,h)

        draw.SimpleText(L("donat_ui_need_xp"),"HS.25",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    local listUpgrades = oop.CreatePanel("v_panel",upgradeSide):ad(function(self,w,h) self:setSize(w,h*0.4 - panelTitle:H()):setPos(0,panelTitle:H()) end)
    local itemsNeedForUpgrade = oop.CreatePanel("v_button",upgradeSide):ad(function(self,w,h) self:setSize(w*0.85,iconSize):setPos(w/2-self:W()/2,listUpgrades.y + listUpgrades:H() + iconSize * 2) end)
    function itemsNeedForUpgrade:Draw(w,h)
        surface.SetDrawColor(0,0,0,100)
        surface.DrawRect(0,0,w,h)
    end

    local itemsForUpgrade = oop.CreatePanel("v_scrollpanel",upgradeSide):ad(function(self,w,h)
        self:setSize(itemsNeedForUpgrade:W() + 10,iconSize * 2):setPos(itemsNeedForUpgrade.x,itemsNeedForUpgrade.y - self:H())
    end)
    itemsForUpgrade:CreateVBar()
    itemsForUpgrade.scrolling = iconSize * 1
    itemsForUpgrade.canvasPanel:AddFlexParent()

    local progressPanel = oop.CreatePanel("v_panel",upgradeSide):ad(function(self,w,h) self:setSize(w*0.8,70):setPos(w/2 - self:W()/2,h-self:H()-(w/2 - self:W()/2)/2)  end)

    //

    local NeedXP = 0
    local itemsUpdageSelectedXP = 0

    function listUpgrades:Draw(w,h)
        if not selectItem then return end

        local info = selectItem:GetModelInfo()

        local i = 0
        local size = 40
        
        NeedXP = 0

        for x,y in pairs(bodygroupsSelected) do
            local infoBodygroup = info.bodygroups[x][y]

            local Y = i * size

            local raryData = DonatItemsRaryData[infoBodygroup.raryType]
            local color,colorText = raryData[1],raryData[2]
            surface.SetDrawColor(color.r,color.g,color.b,64)
            surface.DrawRect(0,Y,w,size)

            surface.SetDrawColor(color.r,color.g,color.b,255)
            draw.GradientLeft(0,Y,w,size)

            draw.SimpleText(L(infoBodygroup.name),"H.25",15,Y + size/2,colorText,nil,TEXT_ALIGN_CENTER)

            local data = selectItem.data
            local subX = data.bodygroups and data.bodygroups[x] and data.bodygroups[x][y] or 0

            local xp = infoBodygroup.xp - subX
            if xp > 0 then
                NeedXP = NeedXP + xp
                draw.SimpleText(DonatXPGetText(xp) .. " xp","H.25",w/2,Y + size/2,colorText,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            else
                draw.SimpleText(L("donat_ui_upgraded"),"H.25",w/2,Y + size/2,colorText,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            end
            i = i + 1
        end
    end

    function itemsForUpgrade:Draw(w,h)
        draw.Frame(0,0,w,h,cframe2,cframe1)
    end

    function itemsForUpgrade:Update()
        itemsUpdageSelected = {}
        self:Reconstruct()
    end

    function itemsForUpgrade:Reconstruct()
        self:Clear()

        itemsUpdageSelectedXP = 0

        for id,item in pairs(itemsUpdageSelected) do
            itemsUpdageSelectedXP = itemsUpdageSelectedXP + item:GetInfo().xp
        end

        for _,item in pairs(DonatItem_GetSortTable(DonatInventoryList[AccountSteamID64],"2_accessories")) do
            if item.class != "bodygroup" then continue end
            if table.HasValue(itemsUpdageSelected,item) then continue end

            local icon = oop.CreatePanel("v_button",self):ad(function(self,w,h) self:setSize(iconSize,iconSize) end):AddByFlex()
            function icon:Draw(w,h) item:DrawIcon(w,h,self,"H.12") end
            function icon:OnClick()
                if #itemsUpdageSelected >= 4 then return end

                SurfaceSoundEmit("homigrad/vgui/csgo_ui_store_select.wav",0.25,120)

                table.insert(itemsUpdageSelected,item)
                itemsForUpgrade:Reconstruct()
            end
        end

        self:InvalidateChildren(true)
    end

    for i = 1,4 do
        local icon = oop.CreatePanel("v_button",itemsNeedForUpgrade):ad(function(self,w,h) self:setSize(h,h):setPos(h * (i - 1),0) end)

        function icon:Draw(w,h)
            local item = itemsUpdageSelected[i]

            if not item then
                surface.SetBG("points50")
                surface.SetDrawColor(0,0,0,100)
                draw.BG2(2,2,w - 4,h - 4)
                draw.Frame(0,0,w,h,cframe2,cframe1)

                draw.SimpleText("BODY","H.25",w/2,h/2 - 25,colorBodyGroupEmpty,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                draw.SimpleText("GROUP","H.25",w/2,h/2 + 25,colorBodyGroupEmpty,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            else
                item:DrawIcon(w,h,self,"H.12")
            end
        end

        function icon:OnClick()
            if itemsUpdageSelected[i] then
                SurfaceSoundEmit("homigrad/vgui/csgo_ui_store_select.wav",0.25,90)

                table.remove(itemsUpdageSelected,i)
                itemsForUpgrade:Reconstruct()
            end
        end
    end

    page.progressPanel = progressPanel
    progressPanel.startYellow = 0

    local yellowWidth = 0

    function progressPanel:Draw(w,h)
        surface.SetDrawColor(0,0,0,75)

        local width,height = w * 0.8,10
        local corner = 16
        surface.DrawRect(0,h/2-height/2,width - corner,height)

        if NeedXP != 0 then 
            draw.SimpleText(DonatXPGetText(NeedXP) .. " xp","HS.18",w*0.8 - corner,0,nil,TEXT_ALIGN_RIGHT)

            local width = width * math.min(itemsUpdageSelectedXP / NeedXP,1)
            surface.SetDrawColor(255,255,255,100)
            surface.DrawRect(0,h/2-height/2,width - corner,height)
            yellowWidth = width

            if donat_inventory_model_bodygroup_time then
                local animK = 1 - math.max(donat_inventory_model_bodygroup_time - RealTime(),0)
                local width = width * animK
                surface.SetDrawColor(255,255,0,200)
                surface.DrawRect(0,h/2-height/2,width - corner,height)
                surface.SetDrawColor(255,255,125,255)
                draw.GradientRight(0,h/2-height/2,width - corner,height)
            end

            if itemsUpdageSelectedXP - NeedXP > 0 then
                draw.SimpleText("лишнее " .. DonatXPGetText(itemsUpdageSelectedXP - NeedXP) .. " xp","HS.18",0,h,colorRed,nil,TEXT_ALIGN_BOTTOM)
            end
        end

        local animK = math.max(self.startYellow - RealTime())
        if animK > 0 then
            local width = self.yellowWidth
            surface.SetDrawColor(255,255,190,255 * animK)
            surface.DrawRect(0,h/2-height/2,width - corner,height)
        end

        draw.SimpleText(DonatXPGetText(itemsUpdageSelectedXP) .. " xp","HS.18")
    end
    local butt = oop.CreatePanel("v_button",progressPanel):ad(function(self,w,h) self:setSize(w * 0.2,h):setPos(w-self:W(),0) end)
    butt:SetupDrawStyle("white"); butt.text = "Upgrade"; butt.font = "HS.18"
    DonatInventory_NetButton(butt,"donat_inventory_model_bodygroup",function()
        local list = {}
        for i,item in pairs(itemsUpdageSelected) do
            list[#list + 1] = item.id
        end

        if #list == 0 or NeedXP <= 0 then return false end
        
        SurfaceSoundEmit("homigrad/vgui/item_sticker_apply_confirm.wav",0.5)
        donat_inventory_model_bodygroup_time = RealTime() + 1

        progressPanel.yellowWidth = yellowWidth

        selectItem:SendUpgrade(list,bodygroupsSelected)
    end,3)

    //

    function page:SelectAvatar(itemID)
        selectItemID = itemID
        selectItem = itemID and DonatInventoryList[AccountSteamID64][itemID]
        selectItem = util.tableCopy(selectItem)

        bodygroupList:Update()
        itemsForUpgrade:Update()
    end

    itemsForUpgrade:Update()

    function page:Update()//когда обновляется данные об инвентаре
        selectItem = selectItemID and DonatInventoryList[AccountSteamID64][selectItemID]
        selectItem = util.tableCopy(selectItem)

        itemsForUpgrade:Update()
    end
end

donat_inventory_model_bodygroup = nil

event.Add("Donat Inventory Sync","Bodygroup UI",function(steamid64,inventory)
    local result = DonatInventory_NetButtonHas("donat_inventory_model_bodygroup",function(butt)
        butt:SetIsNotClickable(true)

        timer.Simple(math.max(donat_inventory_model_bodygroup_time - RealTime(),0) + 0.05,function()
            donat_inventory_model_bodygroup_time = nil
            butt:SetIsNotClickable(false)

            SurfaceSoundEmit("homigrad/vgui/item_drop3_rare.wav",0.5)

            if IsValid(Page.panelBodygroups) then
                local progressPanel = Page.panelBodygroups.progressPanel
                progressPanel.startYellow = RealTime() + 1
                Page.panelBodygroups:Update()
            end
        end)
    end)

    if result then return end

    if IsValid(Page.panelBodygroups) then Page.panelBodygroups:Update() end
end)

if Initialize then OpenTab() end

