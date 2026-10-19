--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_adminpanel/lua/hadminpanel/ui/page_warn_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:11 <
]]

-- "addons\\homigrad_adminpanel\\lua\\hadminpanel\\ui\\page_warn_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
AdminPanelPages[5] = AdminPanelPages[5] or {}
local Page = AdminPanelPages[5]

Page.Name = "Варны"

function Page.CanOpen()
    return LocalPlayer():HasSuccess("warn_list")
end

local iconSize = 64

local function OnClick(steamid)
    local steamProfile = Profiles[util.SteamIDTo64(steamid)]

    local menu = DermaMenu()
    menu:AddOption(L("copy_steamid"),function()
        chat.AddText(steamid)
        SetClipboardText(steamid)
    end)

    if steamProfile then
        menu:AddOption(L("copy_nickname"),function()
            chat.AddText(steamProfile.name)
            SetClipboardText(steamProfile.name)
        end)
    end

    menu:AddOption(L("open_profile"),function() gui.OpenURL("https://steamcommunity.com/profiles/" .. util.SteamIDTo64(steamid) .. "/") end)

    menu:Open()
end

function Page.Open(frame)
    local panel = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setSize(w,h) end)

    local scrollPage = oop.CreatePanel("v_scrollpage",panel):ad(function(self,w,h) self:setPos(0,40):setSize(w,h - self.y) end)
    scrollPage:SetHorizontal(true)

    local listPlayers = oop.CreatePanel("v_scrollpanel",scrollPage:Add()):ad(function(self,w,h) self:setSize(w,h) end)
    listPlayers:CreateVBar()
    listPlayers.canvasPanel:AddFlexParent()

    local listWarns = scrollPage:Add()

    function listWarns:SetChoice(steamid)
        self.choice = steamid

        self:Update()
    end

    function listWarns:Update()
        self:Clear()

        if not self.choice then
            scrollPage:Set(1)
            
            return
        end

        local buttBack = oop.CreatePanel("v_button",self):ad(function(self,w,h) self:setSize(w,60) end)
        buttBack:SetupDrawStyle("white"); buttBack.text = "Назад"; buttBack.font = "HS.25"
        function buttBack:OnClick() listWarns:SetChoice() end

        scrollPage:Set(2)

        local scrollPanel = oop.CreatePanel("v_scrollpanel",self):ad(function(self,w,h) self:setPos(0,buttBack:H()):setSize(w,h - self.y) end)
        scrollPanel:CreateVBar()
        
        local list = AdminPanelWarnList[self.choice].list

        local avatar = oop.CreatePanel("v_avatarlist",scrollPanel):ad(function(self,w,h) self:setSize(w * 0.3,iconSize * 0.25 + #list * (iconSize + iconSize * 0.25)) end)
        avatar:Setup(iconSize)

        listWarns.avatar = avatar

        for i = 1,#list do
            local warnInfo = list[#list - i + 1]
            local steamid = warnInfo.who
            local profile = Profiles[steamid]

            local butt

            if profile then
                butt = avatar:AddPanel(steamid,profile.name,profile.avatar,profile.avatarFrame,profile.background,profile.backgroundOpacity)
            else
                butt = avatar:AddPanel(steamid,nil,nil,nil,who)
            end
            
            function butt:Draw() end
            function butt:OnClick()
                OnClick(steamid)
            end

            local I = i
            local butt = oop.CreatePanel("v_panel",scrollPanel):ad(function(self,w,h) self:setPos(avatar:W(),iconSize * 0.25 + (iconSize + iconSize * 0.25) * (I - 1)):setSize(w - self.x - iconSize * 0.25,iconSize) end)
            function butt:Draw(w,h)
                draw.Frame(0,0,w,h,cframe1,cframe2)

                draw.SimpleText(warnInfo.count,"HS.18",h/2,h/2,nil,nil,TEXT_ALIGN_CENTER)
                draw.SimpleText(os.date("%d.%m.%Y - %H:%M",warnInfo.create),"HS.18",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                draw.SimpleText(warnInfo.reason,"HS.18",w - h/2,h/2,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
            end

            function butt:OnClick()
                OnClick(self.choice)
            end
        end
    end

    function listPlayers:Update()
        self:Clear()
        
        local avatar = oop.CreatePanel("v_avatarlist",self):ad(function(self,w,h) self:setSize(w,iconSize + iconSize * 0.5) end):AddByFlex()
        avatar:Setup(iconSize)
        avatar:SetScrollPanel(listPlayers)

        for steamid,info in pairs(AdminPanelWarnList or {}) do
            
            local profile = Profiles[steamid]

            local butt

            if profile then
                butt = avatar:AddPanel(steamid,profile.name,profile.avatar,profile.avatarFrame,profile.background,profile.backgroundOpacity)
            else
                butt = avatar:AddPanel(steamid,nil,nil,nil,who)
            end

            local count = table.Count(info.list)
            local curretCount = 0

            for i,warnInfo in pairs(info.list) do
                curretCount = curretCount + warnInfo.count
            end

            function butt:Draw(w,h)
                if self:IsHovered() then
                    surface.SetDrawColor(255,255,255,15)
                    surface.DrawRect(0,0,w,h)
                end

                draw.SimpleText(curretCount,"HS.18",h/2,h/2,nil,nil,TEXT_ALIGN_CENTER)
                draw.SimpleText(count,"HS.18",w - h/2,h/2,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
            end

            function butt:OnClick(key)
                if key == MOUSE_RIGHT then
                    OnClick(steamid)
                else
                    listWarns:SetChoice(steamid)
                end
            end
        end
    end

    local count = 0

    function panel:Draw(w,h)
        surface.SetDrawColor(175,175,255,55)
        surface.DrawRect(0,0,w,40)
        surface.SetDrawColor(175,175,255,255)

        draw.GradientRight(0,0,w/2,40)
        draw.GradientLeft(w/2,0,w - w/2,40)

        if scrollPage.setPage == 1 then
            draw.SimpleText(L("ap_ui_db_count",count),"HS.18",20,20,nil,nil,TEXT_ALIGN_CENTER)
            draw.SimpleText("Текущие количество варнов","HS.18",iconSize + iconSize * 0.5 + iconSize/2,20,nil,nil,TEXT_ALIGN_CENTER)
            draw.SimpleText("Имя","HS.18",iconSize * 0.33 + w/2,20,nil,nil,TEXT_ALIGN_CENTER)
            draw.SimpleText("Всего было выдано","HS.18",w - iconSize * 0.33 - iconSize/2,20,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
        else
            local avatar = listWarns.avatar

            draw.SimpleText("Кто выдал","HS.18",avatar:W()/2 - iconSize * 0.25/2,20,nil,nil,TEXT_ALIGN_CENTER)
            draw.SimpleText("Выдано варнов","HS.18",avatar:W() + iconSize/2,20,nil,nil,TEXT_ALIGN_CENTER)
            draw.SimpleText("Дата выдачи","HS.18",avatar:W() + (w - avatar:W())/2,20,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            draw.SimpleText("Причина","HS.18",w - iconSize/2 - iconSize * 0.25,20,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
        end
    end

    function frame:Update()
        listPlayers:Update()
        listWarns:Update()

        count = table.Count(AdminPanelWarnList or {})
    end

    frame:Update()
end

if Initialize then RunConsoleCommand("adminpanel_menu") end

