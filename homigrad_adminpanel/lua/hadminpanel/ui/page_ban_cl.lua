--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_adminpanel/lua/hadminpanel/ui/page_ban_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:11 <
]]

-- "addons\\homigrad_adminpanel\\lua\\hadminpanel\\ui\\page_ban_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
AdminPanelPages[4] = AdminPanelPages[4] or {}
local Page = AdminPanelPages[4]

Page.Name = "ap_ui_ban"

function Page.CanOpen()
    return LocalPlayer():HasSuccess("ban_list")
end

local function OnClick(steamid,callback)
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

    menu:AddOption(L("ap_ui_delete_from_table"),function() callback()end)
    menu:AddOption(L("open_profile"),function() gui.OpenURL("https://steamcommunity.com/profiles/" .. util.SteamIDTo64(steamid) .. "/") end)

    menu:Open()
end

local iconSize = 56
local empty = {}

local function createPage(page,nameTable,onclick)
    local scrollPanelWho = oop.CreatePanel("v_scrollpanel",page):ad(function(self,w,h) self:setSize(w/4,h - 70):setPos(0,70) end)
    function scrollPanelWho:Draw(w,h)
        surface.SetDrawColor(64,64,128,16)
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(64,64,128,32)
        draw.GradientLeft(0,0,w,h)
    end

    local scrollPanel = oop.CreatePanel("v_scrollpanel",page):ad(function(self,w,h) self:setPos(scrollPanelWho:W(),70):setSize(w - scrollPanelWho:W(),h - 70) end)
    scrollPanel:CreateVBar()
    scrollPanel.scrolling = 200
    function scrollPanel:Draw(w,h)
        surface.SetDrawColor(64,64,128,16)
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(64,64,128,32)
        draw.GradientLeft(0,0,w,h)
    end
    
    scrollPanelWho:LinkScrollPanel(scrollPanel)

    local playersListWho = oop.CreatePanel("v_avatarlist",scrollPanelWho)
    playersListWho:Setup(iconSize)
    playersListWho:SetScrollPanel(scrollPanelWho)

    local playersList = oop.CreatePanel("v_avatarlist",scrollPanel)
    playersList:Setup(iconSize)
    playersList:SetScrollPanel(scrollPanel)

    local searchCaller = oop.CreatePanel("v_textentry",page):ad(function(self,w,h) self:setSize(scrollPanelWho:W(),30):setPos(0,40) end)
    searchCaller:SetPlaceholderText(L("ap_ui_find_caller"))
    local filterCaller = ""
    function searchCaller:OnChange()
        filterCaller = self:GetValue()
        timer.Create("filterCaller",0.1,1,function()
            page:Update()
        end)
    end

    local searchSteamID = oop.CreatePanel("v_textentry",page):ad(function(self,w,h) self:setSize(playersList:W()/2,30):setPos(w - self:W(),40) end)
    searchSteamID:SetPlaceholderText(L("ap_ui_find_steamid32"))
    local filterSteamID = ""
    function searchSteamID:OnChange()
        filterSteamID = self:GetValue()
        timer.Create("filterSteamID",0.1,1,function()
            page:Update()
        end)
    end

    local count = 0

    function page:Draw(w,h)
        surface.SetDrawColor(175,175,255,55)
        surface.DrawRect(0,0,w,40)
        surface.SetDrawColor(175,175,255,255)

        local wScroll = playersListWho:W()
        draw.GradientRight(0,0,wScroll,40)
        draw.GradientLeft(wScroll,0,w - wScroll,40)

        draw.SimpleText(L("ap_ui_db_count",count),"HS.18",20,20,nil,nil,TEXT_ALIGN_CENTER)
        draw.SimpleText(L("ap_ui_caller"),"HS.18",(iconSize + iconSize * 0.25 + wScroll)/2,20,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        draw.SimpleText(L("ap_ui_user"),"HS.18",wScroll + (w - wScroll + iconSize + iconSize * 0.25)/2,20,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        draw.SimpleText(L("ap_ui_reason"),"HS.18",w - 20 - iconSize * 0.25,20,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
        draw.SimpleText(L("ap_ui_start"),"HS.18",wScroll + iconSize + iconSize * 0.25 * 3 + 20,20,nil,nil,TEXT_ALIGN_CENTER)
        draw.SimpleText(L("ap_ui_start_endless"),"HS.18",wScroll + iconSize * 0.25 * 3 + 20 + (w - wScroll)* 0.25,20,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    function page:Update()
        playersList:Clear()
        playersListWho:Clear()
        
        count = table.Count(_G[nameTable] or empty)
        
        local list = {}

        for steamid,info in pairs(_G[nameTable] or {}) do
            list[#list + 1] = {steamid,info}
        end

        table.sort(list,function(a,b) return a[2].create > b[2].create end)

        for i,info in pairs(list) do
            local steamid = info[1]
            info = info[2]

            local who = info.who or ""

            if filterCaller != "" and not string.find(who,filterCaller) then continue end
            if filterSteamID != "" and steamid != filterSteamID then continue end
            
            local profile = Profiles[who]

            local butt

            if profile then
                butt = playersListWho:AddPanel(i,profile.name,profile.avatar,profile.avatarFrame,profile.background,profile.backgroundOpacity)
            else
                butt = playersListWho:AddPanel(i,"Ё","https://i.pinimg.com/736x/bb/f4/a2/bbf4a268dda92662c5fc4f2608e01a25.jpg","","https://i.pinimg.com/736x/ef/32/bd/ef32bd57d627bdca8dd40e5e357bd6de.jpg")
            end

            function butt:Draw(w,h)
                local info = _G[nameTable][steamid]
                if not info then return end//xd
        
                surface.SetDrawColor(0,0,0,100)
                surface.DrawRect(0,0,w,h)
            end
            
            //

            local profile = Profiles[steamid]

            local butt

            if profile then
                butt = playersList:AddPanel(i,profile.name,profile.avatar,profile.avatarFrame,profile.background,profile.backgroundOpacity)
            else
                butt = playersList:AddPanel(i,nil,nil,nil,steamid)
            end
            
            local reason = info.reason or ""

            if utf8.len(reason) > 40 then
                reason = utf8.sub(reason,1,40) .. "..."
            end

            function butt:Draw(w,h)
                local info = _G[nameTable][steamid]
                if not info then return end//xd
        
                surface.SetDrawColor(0,0,0,100)
                surface.DrawRect(0,0,w,h)
        
                draw.SimpleText(os.date("%d.%m.%Y",info.create) .. "","HS.18",h/2,h/2,nil,nil,TEXT_ALIGN_CENTER)
                local time

                if info.time == 0 or info.time == "permament" then
                    time = "permament"
                else
                    local lessTime = info.create + info.time - os.time()
                    if lessTime <= 0 then
                        time = L("ap_ui_less")
                    else
                        time = AdminPanel_GetTimeText(info.time) .. " / " .. AdminPanel_GetTimeText(lessTime)
                    end
                end

                draw.SimpleText(time,"HS.18",w * 0.25,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                
                if time != "permament" then
                    local k = 1 - (info.create + info.time - os.time()) / info.time

                    surface.SetDrawColor(255,255,255,255)
                    surface.DrawRect(0,0,w * k,2)
                end

                draw.SimpleText(reason,"HS.18",w-h/2,h/2,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)

                self:DrawTip(info.reason .. "\n" .. (info.info or ""),1)
            end

            function butt:OnClick() onclick(steamid) end
        end
    end
end

function Page.Open(frame)
    local scrollNav = oop.CreatePanel("v_scrollnav",frame):ad(function(self,w,h) self:setSize(w,40) end)
    scrollNav:SetHighlightSide("bottom",nil,true)

    local scrollPage = oop.CreatePanel("v_scrollpage",frame):ad(function(self,w,h) self:setSize(w,h - 40):setPos(0,40) end)
    scrollPage:SetHorizontal(true)

    scrollNav:Add("Bans",function() scrollPage:Set(1) end):SetupDrawStyle("white_gradient").font = "HS.18"
    local pageBan = scrollPage:Add()
    frame.pageBan = pageBan

    createPage(pageBan,"AdminPanelBanList",function(steamid)
        OnClick(steamid,function() RunConsoleCommand("ulx_cmd","unban",steamid) end)
    end)

    scrollNav:Add("Gag",function() scrollPage:Set(2) end):SetupDrawStyle("white_gradient").font = "HS.18"
    local pageGag = scrollPage:Add()
    frame.pageGag = pageGag

    createPage(pageGag,"AdminPanelGagList",function(steamid)
        OnClick(steamid,function() RunConsoleCommand("ulx_cmd","ungag",steamid) end)
    end)

    scrollNav:Add("Mute",function() scrollPage:Set(3) end):SetupDrawStyle("white_gradient").font = "HS.18"
    local pageMute = scrollPage:Add()
    frame.pageMute = pageMute

    createPage(pageMute,"AdminPanelMuteList",function(steamid)
        OnClick(steamid,function() RunConsoleCommand("ulx_cmd","unmute",steamid) end)
    end)

    function frame:Update()
        pageBan:Update()
        pageGag:Update()
        pageMute:Update()
    end

    frame:Update()
end

if Initialize then RunConsoleCommand("adminpanel_menu") end

event.Add("AP Ban List Sync","UI",function()
    if IsValid(adminpanel_menu) and IsValid(adminpanel_menu[4].pageBan) then adminpanel_menu[4].pageBan:Update() end
end)

event.Add("AP Gag List Sync","UI",function()
    if IsValid(adminpanel_menu) and IsValid(adminpanel_menu[4].pageGag) then adminpanel_menu[4].pageGag:Update() end
end)

event.Add("AP Mute List Sync","UI",function()
    if IsValid(adminpanel_menu) and IsValid(adminpanel_menu[4].pageMute) then adminpanel_menu[4].pageMute:Update() end
end)
