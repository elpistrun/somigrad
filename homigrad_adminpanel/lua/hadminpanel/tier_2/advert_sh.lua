--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_adminpanel/lua/hadminpanel/tier_2/advert_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:11 <
]]

-- "addons\\homigrad_adminpanel\\lua\\hadminpanel\\tier_2\\advert_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
if CLIENT then
    AdminPanelAdvertManager = Create_SyncDataManager("AdminPanelAdvert","AP Advert Sync","adminpanel","adminpanel_advert_sync")
end

AdminPanel_Command_Registry("advert_add",
    {
        {type = "string",name = "message"},
        {type = "number",name = "time"},
        {type = "number",name = "r"},
        {type = "number",name = "g"},
        {type = "number",name = "b"},
        {type = "number",name = "id",dontRequired = true}
    },
    "async",
    nil,
    "project"
).UICreate = function(panelCommand,panelCommandRight)
    function panelCommand:Update()
        panelCommand:Clear()

        local y = 0
        
        local function create(id,advert)
            local Y = y
            local panel = oop.CreatePanel("v_panel",panelCommand):ad(function(self,w,h) self:setSize(w,200):setPos(0,Y) end)
            y = y + panel:H()
            local textEntryMessage = oop.CreatePanel("v_textentry",panel):ad(function(self,w,h) self:setSize(w,60) end)
            textEntryMessage:SetMultiline(true)
            textEntryMessage:SetPlaceholderText("message")
            textEntryMessage:SetValue(advert.message or "")

            local textEntryTime = oop.CreatePanel("v_textentry",panel):ad(function(self,w,h) self:setSize(w,30):setPos(0,60) end)
            textEntryTime:SetNumeric(true)
            textEntryTime:SetPlaceholderText("time in seconds")
            if advert.time then textEntryTime:SetValue(advert.time) end

            local mixer = oop.CreatePanel("v_colormixer",panel):ad(function(self,w,h) self:setSize(w - 200,h - 90):setPos(0,90) end)
            mixer:SetAlphaBar(false)
            mixer:SetPalette(false)
            mixer:SetColor(advert.color or Color(255,255,255))

            local send = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setPos(mixer:W(),mixer.y):setSize(w - self.x,40) end)
            send.text = advert.message and "set" or "Added"
            function send:OnClick()
                local color = mixer:GetColor()
                RunConsoleCommand("ulx_cmd","advert_add",textEntryMessage:GetValue() or "null",textEntryTime:GetValue() or 300,color.r,color.g,color.b,id)
            end

            if advert.message then
                local send = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setPos(mixer:W(),mixer.y + 40):setSize(w - self.x,40) end)
                send.text = "Remove"
                function send:OnClick()
                    RunConsoleCommand("ulx_cmd","advert_remove",tostring(id))
                end
            end
        end

        for id,advert in pairs(AdminPanelAdvert) do
            create(id,advert)
        end

        local Y = y
        local panel = oop.CreatePanel("v_panel",panelCommand):ad(function(self,w,h) self:setSize(w,30):setPos(0,Y) end)
        y = y + panel:H()

        function panel:Draw(w,h)
            surface.SetDrawColor(125,125,255,100)
            surface.DrawRect(0,0,w,h)
            draw.SimpleText("NEW","HS.18",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

            draw.Frame(0,0,w,h,cframe1,cfreame2)
        end

        create(#AdminPanelAdvert + 1,{})
    end

    panelCommand:Update()
end

AdminPanel_Command_Registry("advert_remove",{{type = "number",name = "id"}},"async",nil,"project").dontShowGUI = true

if CLIENT then
    event.Add("AP Advert Sync","UI",function()
        if IsValid(adminpanel_menu) then adminpanel_menu.panelCommand:Update() end
    end)
end
