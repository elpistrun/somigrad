--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_donat/lua/hinit/donat/outfit/outfit_ui_cl.lua <
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

-- "addons\\homigrad_donat\\lua\\hinit\\donat\\outfit\\outfit_ui_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
ScoreboardPages[101].list[4] = ScoreboardPages[101].list[4] or {}
local Page = ScoreboardPages[101].list[4]

Page.Name = "donat_ui_outfit"

function Page.Open(frame)
    Page.panel = frame

    local selectItemID
    local selectItemAnchorID

    local avatar = oop.CreatePanel("v_playermodel",frame):ad(function(self,w,h) self:setSize(w * (1/3.2),h) end)
    avatar.fovMax = 25
    avatar.cameraFOV = 25
    avatar.cameraPos = Vector(125,0,5)

    function avatar:PreDraw(w,h)
        surface.SetDrawColor(0,0,0,128)
        draw.GradientDown(0,0,w,h)
    end

    function avatar:DrawOver(w,h)
        local item = avatar:GetSelectItem()
        if not item then return end

        draw.SimpleText(item:GetPrintName(),"HS.45",w/2,h*0.05,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    local panel = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setPos(avatar:W(),0):setSize(w - self.x,h) end)
    local navPanel = oop.CreatePanel("v_scrollnav",panel):ad(function(self,w,h) self:setSize(w,40) end)
    navPanel:SetHighlightSide("bottom",nil,true)
    navPanel:SetupDrawStyle("whitebox")

    local pages = oop.CreatePanel("v_scrollpage",panel):ad(function(self,w,h) self:setPos(0,navPanel:H()):setSize(w,h - self.y) end)
    pages:SetHorizontal(true)

    local presetsPage = pages:Add()
    local butt = navPanel:Add(L("donat_ui_presets"),function() navPanel:Set(1) pages:Set(1) Page.SelectPage = 1 presetsPage:Open() end)
    butt:SetupDrawStyle("white_gradient") butt.gradientSide = "bottom"; butt.font = "HS.18"
    Page.OpenPresets(presetsPage,avatar)

    local butt = navPanel:Add(L("donat_ui_models"),function() navPanel:Set(2) pages:Set(2) Page.SelectPage = 2 end)
    butt:SetupDrawStyle("white_gradient") butt.gradientSide = "bottom"; butt.font = "HS.18"
    local modelsPage = pages:Add()

    local butt = navPanel:Add("Bodygroups",function() navPanel:Set(3) pages:Set(3) Page.SelectPage = 3 end)
    butt:SetupDrawStyle("white_gradient") butt.gradientSide = "bottom"; butt.font = "HS.18"
    local bodygroupPage = pages:Add()
    Page.OpenBodygroup(bodygroupPage,avatar)

    local panel = pages:Add()
    local scrollPanel = oop.CreatePanel("v_scrollpanel",modelsPage):ad(function(self,w,h) self:setSize(w,h) end)
    scrollPanel:CreateVBar()
    scrollPanel.canvasPanel:AddFlexParent()

    local iconSize

    scrollPanel:ad(function(self,w,h)
        iconSize = math.floor(w / 7) - self.vbar:W()/12
    end)

    scrollPanel.scrolling = iconSize * 2
    

    function avatar:SelectItem(id)
        if id == selectItemID then return end
        selectItemID = id

        if id then
            avatar:SetModel(avatar:GetSelectItem().data.model)
        end

        bodygroupPage:SelectAvatar(selectItemID)
        presetsPage:SelectAvatar(selectItemID)
    end

    function avatar:GetSelectItem()
        return DonatInventoryList[AccountSteamID64][selectItemID]
    end

    local hoverItem
        
    function modelsPage:Update()
        scrollPanel:Clear()

        if not DonatInventoryList[AccountSteamID64][selectItemID] then
            avatar:SelectItem()
        end

        for _,item in pairs(DonatItem_GetSortTable(DonatInventoryList[AccountSteamID64],"1_models")) do
            local id = item.id

            local icon = oop.CreatePanel("v_button",scrollPanel):ad(function(self,w,h) self:setSize(iconSize,iconSize) end):AddByFlex()
            function icon:Draw(w,h)
                item:DrawIcon(w,h,self)
                if self:IsHovered() then hoverItem = id end
                if selectItemAnchorID == id or selectItemID == id then
                    surface.SetDrawColor(255,255,255)
                    surface.DrawRect(0,h - 1,w,1)
                end

                if OutfitData[AccountSteamID64].playermodel and OutfitData[AccountSteamID64].playermodel.itemID == id then
                    surface.SetDrawColor(255,255,255)
                    surface.DrawRect(0,h - 1,w,1)
                end
            end

            function icon:OnClick()
                selectItemAnchorID = id
                avatar:SelectItem(selectItemAnchorID)
            end

            if not selectItemAnchorID then
                selectItemAnchorID = Outfit_GetPlayerModelID(AccountSteamID64) or id
                avatar:SelectItem(selectItemAnchorID)
            end
        end
    end

    function scrollPanel:Draw()
        avatar:SelectItem(hoverItem or selectItemAnchorID)
        hoverItem = nil
    end
    
    function frame:Update()
        modelsPage:Update()
    end

    frame:Update()

    if Page.SelectPage then
        if Page.SelectPage == 2 then presetsPage:Open() end
        
        navPanel:Set(Page.SelectPage,true)
        pages:Set(Page.SelectPage,true)
    end
end

event.Add("Donat Inventory Sync","Models UI",function(steamid64,inventory)
    if IsValid(Page.panel) and Page.panel.Update then Page.panel:Update() end
end)

if Initialize then OpenTab() end
