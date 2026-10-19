--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_donat/lua/hinit/donat/outfit/outfit_ui_presets_cl.lua <
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

-- "addons\\homigrad_donat\\lua\\hinit\\donat\\outfit\\outfit_ui_presets_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
ScoreboardPages[101].list[4] = ScoreboardPages[101].list[4] or {}
local Page = ScoreboardPages[101].list[4]

local empty = {}

function Page.OpenPresets(page,avatar)
    Page.panelPresets = page

    local selectItem

    local bodygroupsSelected
    local bodygroupsList = oop.CreatePanel("v_scrollpanel",page):ad(function(self,w,h) self:setSize(w*0.6,h - 80) end)
    bodygroupsList:CreateVBar()
    bodygroupsList.canvasPanel:AddFlexParent()
    bodygroupsList.scrolling = 300

    local accessoriesList = oop.CreatePanel("v_scrollpanel",page):ad(function(self,w,h) self:setSize(w-bodygroupsList:W(),h - 80):setPos(bodygroupsList:W(),0) end)
    accessoriesList:CreateVBar()
    accessoriesList.scrolling = 300
    accessoriesList.canvasPanel:AddFlexParent()
    
    function accessoriesList:Draw(w,h)
        draw.SimpleText("что-то тут будет","HS.45",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    local sliders

    function page:SelectAvatar(itemID)
        selectItem = avatar:GetSelectItem()
        bodygroupsSelected = {}
        bodygroupsList:Clear()

        if not selectItem then return end

        local info = selectItem:GetModelInfo()
        local equipBodygroups = selectItem.data.equipBodygroups or empty

        for x = -1,info.bodygroupsMax do
            selectItem:SetBodygroup(x,0,avatar.mdl)
        end

        sliders = {}

        local y = 0
        for x = -1,info.bodygroupsMax do
            local info = info.bodygroups[x]
            if not info then continue end

            local Y = y
            local panelTitle = oop.CreatePanel("v_panel",bodygroupsList):ad(function(self,w,h) self:setSize(w,40 + 50) end):AddByFlex()
            local panel = oop.CreatePanel("v_panel",panelTitle):ad(function(self,w,h) self:setSize(w,h-40):setPos(0,40) end)
            local slider = oop.CreatePanel("v_slider",panel):ad(function(self,w,h) self:setSize(w,60):setPos(0,h/2-self:H()/2) end)
            slider.round = 1
            slider:SetMin(0)
            slider:SetMax(#info)
            slider:SetValue(0)

            sliders[x] = slider

            function panelTitle:Draw(w,h)
                if self.error then
                    surface.SetDrawColor(255,0,0,100)
                    surface.DrawRect(0,0,w,40)
                    surface.SetDrawColor(255,0,0,255)
                    draw.GradientRight(0,0,w,40)

                    draw.SimpleText(L("donat_ui_not_access"),"HS.25",w -  16,20,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
                else
                    surface.SetDrawColor(0,0,0,100)
                    surface.DrawRect(0,0,w,40)
                    draw.GradientLeft(0,0,w,40)
                end

                draw.SimpleText(L(info[slider:GetValue()].name),"HS.25",16,20,nil,nil,TEXT_ALIGN_CENTER)
            end

            function slider:OnValue(value)
                panelTitle.error = nil
                bodygroupsSelected[x] = nil

                selectItem:SetBodygroup(x,value,avatar.mdl)

                if value != 0 then
                    if not info[value] or not selectItem.data.bodygroups or not selectItem.data.bodygroups[x] or (selectItem.data.bodygroups[x][value] or 0) < info[value].xp then
                        panelTitle.error = true
                        return
                    end

                    bodygroupsSelected[x] = value
                end
            end

            if equipBodygroups[x] then
                slider:SetValue(equipBodygroups[x])
                slider:OnValue(equipBodygroups[x])
            end

            //slider:OnValue(math.random(1,#info[x]))
        end

        if info.colorable then
            local panel = oop.CreatePanel("v_panel",bodygroupsList):ad(function(self,w,h) self:setSize(w,w/4) end):AddByFlex()
            function panel:Draw(w,h)
                surface.SetDrawColor(0,0,0,100)
                surface.DrawRect(0,0,w,40)
                draw.GradientLeft(0,0,w,40)

                draw.SimpleText(L("donat_ui_outfit_color"),"HS.25",16,20,nil,nil,TEXT_ALIGN_CENTER)
            end
            local colorMixer = oop.CreatePanel("v_colormixer",panel):ad(function(self,w,h) self:setSize(w/2,h - 40):setPos(w/2-self:W()/2,40) end)
            colorMixer:SetPalette(false)
            colorMixer:SetAlphaBar(false)
            colorMixer:SetColor(selectItem and selectItem.data and selectItem.data.color or Color(255,255,255))

            function colorMixer.ValueChanged(_,color)
                avatar.mdlColor = Vector(color.r / 255,color.g / 255,color.b / 255)
            end

            local color = colorMixer:GetColor()
            avatar.mdlColor = Vector(color.r / 255,color.g / 255,color.b / 255)
        end
    end

    function page:Open()
        if not sliders or not selectItem then return end

        local info = selectItem:GetModelInfo()

        for x = -1,info.bodygroupsMax do
            local slider = sliders[x]
            if not slider then continue end

            local value = selectItem:GetBodygroup(x,avatar.mdl)
            value = selectItem:BodygroupToReal(x,value)

            slider:SetValue(value)
            slider:OnValue(value)
        end
    end

    local butt = oop.CreatePanel("v_button",page):ad(function(self,w,h) self:setSize(200,50):setPos(16,h - self:H() - 16) end)
    butt:SetupDrawStyle("white_gradient"); butt.gradientSide = "left"; butt.text = L("donat_ui_outfit_play"); butt.font = "HS.18"
    DonatInventory_NetButton(butt,"donat_inventory_outfit",function()
        if not selectItem then return end
        net.Start("donat_inventory_outfit")
        net.WriteString(tostring(selectItem.id))
        net.SendToServer()

        butt:SetIsNotClickable(true)
        SurfaceSoundEmit("homigrad/vgui/csgo_ui_store_select.wav",0.5)
    end)

    local buttEquip = oop.CreatePanel("v_button",page):ad(function(self,w,h) self:setSize(200,50):setPos(w - self:W() - 16,h - self:H() - 16) end)
    buttEquip:SetupDrawStyle("white_gradient"); buttEquip.gradientSide = "bottom"; buttEquip.text = L("donat_ui_outfit_model"); buttEquip.font = "HS.18"
    DonatInventory_NetButton(buttEquip,"donat_inventory_model_outfit",function()
        if not selectItem then return end
        selectItem:SendOutfit(bodygroupsSelected,avatar.mdlColor:ToColor())
        SurfaceSoundEmit("homigrad/vgui/csgo_ui_store_select.wav",0.5)
    end)

    local buttUnEquip = oop.CreatePanel("v_button",page):ad(function(self,w,h) self:setSize(200,50):setPos(32 + self:W(),h - self:H() - 16) end)
    buttUnEquip:SetupDrawStyle("white_gradient"); buttUnEquip.gradientSide = "right"; buttUnEquip.text = L("donat_ui_outfit_remove"); buttUnEquip.font = "HS.18"
    DonatInventory_NetButton(buttUnEquip,"donat_inventory_model_unequip",function()
        net.Start("donat_inventory_outfit")
        net.SendToServer()

        buttUnEquip:SetIsNotClickable(true)
        SurfaceSoundEmit("homigrad/vgui/csgo_ui_store_select.wav",0.5)
    end)
    buttUnEquip:SetIsNotClickable(donat_inventory_model_unequip or not Outfit_GetPlayerModelID(AccountSteamID64) and true or false)
    
    //

    function page:Update()
        butt:SetIsNotClickable(false)
        buttEquip:SetIsNotClickable(false)
        buttUnEquip:SetIsNotClickable(not Outfit_GetPlayerModelID(AccountSteamID64) and true or false)
    end
end

event.Add("Donat Inventory Sync","Presets UI",function(steamid64,inventory)
    DonatInventory_NetButtonHas("donat_inventory_model_outfit",function()
        SurfaceSoundEmit("physics/body/body_medium_impact_soft" .. math.random(1,3) .. ".wav",0.5,255)
        chat.AddText(L("donat_outfit_has_been"))
    end)
    
    if IsValid(Page.panelPresets) then Page.panelPresets:Update() end
end)


event.Add("Outfit Sync","Presets UI",function(steamid64,inventory)
    DonatInventory_NetButtonHas("donat_inventory_outfit",function()
        SurfaceSoundEmit("homigrad/vgui/panorama/case_unlock_immediate_01.wav",0.5,255)
        chat.AddText(L("donat_outfit_has_equip"))
    end)

    DonatInventory_NetButtonHas("donat_inventory_model_unequip",function()
        SurfaceSoundEmit("homigrad/vgui/panorama/case_unlock_immediate_01.wav",0.5,255)
        chat.AddText(L("donat_outfit_has_remove"))
    end)
    
    if IsValid(Page.panelPresets) then Page.panelPresets:Update() end
end)

if Initialize then OpenTab() end

