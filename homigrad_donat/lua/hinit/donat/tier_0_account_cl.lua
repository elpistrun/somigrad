--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_donat/lua/hinit/donat/tier_0_account_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad_donat\\lua\\hinit\\donat\\tier_0_account_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Panel = ScoreboardPages[101] or {list = {}}
ScoreboardPages[101] = Panel

Panel.Name = "account"

local corner = 8
local colorRed = Color(255,27,27)
local color_gold = Color(255,255,0)

Panel.SelectPage = Panel.SelectPage or 1

function Panel.Open(frame)
    Panel.Panel = frame

    AccountSteamID64 = LocalPlayer():GetNWString("AccountSteamID","")

    if AccountSteamID64 == "" then 
        AccountSteamID64 = LocalPlayer():SteamID64()
    else
        AccountSteamID64 = util.SteamIDTo64(AccountSteamID64)
    end
    
    if DonatInventoryNotification then
        DonatInventory_ShowNewItems(DonatInventoryNotification,nil,function()
            DonatInventoryNotification = nil
            InventoryNotificationManager.Clear()
        end)
    end
    
    function frame:Draw(w,h)
        local k = 1 - (ScoreboardPages[101].number - 1 - ScoreboardFrame.scrollPanel.lerpY)

        surface.SetDrawColor(0,0,0,150 * k)
        surface.DrawRect(0,0,w,h)
        
        DrawBlurByPanel(5 * k,self)
    end
    
    local pagesHorizontal = oop.CreatePanel("v_scrollpage",frame):ad(function(self,w,h) self:setSize(w * 0.9,h * 0.85):setPos(w/2-self:W()/2,h/2-self:H()/2) end)
    pagesHorizontal:SetHorizontal(true)

    local navButtons = oop.CreatePanel("v_scrollnav",frame):ad(function(self,w,h) self:setSize(pagesHorizontal:W(),40):setPos(pagesHorizontal.x,pagesHorizontal.y - self:H()) end)
    navButtons:SetHighlightSide("bottom",nil,true)
    navButtons:SetupDrawStyle("whitebox")
    
    for i,page in pairs(Panel.list) do
        local panel = pagesHorizontal:Add()
        page.panel = panel

        local butt = navButtons:Add(L(page.Name),function()
            pagesHorizontal:Set(i)
            Panel.SelectPage = i

            if not panel.benOpen then
                panel.benOpen = true

                page.Open(panel)
            end
        end)
        butt:SetupDrawStyle("white_gradient"); butt.gradientSide = "bottom"; butt.font = "HS.18"

        function butt:DrawOver(w,h)
            local notifications = page.GetNotifications and page.GetNotifications() or 0

            if notifications <= 0 then return end

            surface.SetFont("H.18")
            local tw,th = surface.GetTextSize(notifications)

            DisableClipping(true)
            draw.RoundedBox(6,-corner,-corner,th + corner,th + corner,colorRed,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            draw.SimpleText(notifications,"H.12",1,0)
            DisableClipping(false)
        end
    end

    if Panel.SelectPage then
        navButtons:Set(Panel.SelectPage,tue)
        pagesHorizontal:Set(Panel.SelectPage,true)

        local page = Panel.list[Panel.SelectPage]
        page.panel.benOpen = true
        page.Open(page.panel)
    end

    local color1 = Color(20,20,20)
    local color2 = Color(34,35,35)

    function pagesHorizontal:DrawOver(w,h)
        draw.Frame(0,0,w,h,cframe1,cframe2)

        DisableClipping(true)
        local balance = BalanceData[AccountSteamID64]
        if balance then
            draw.SimpleText("Balance: " .. DonatXPGetText(balance.money or 0),"HS.18",4,h + 8,nil,nil)
            draw.SimpleText("Donat Balance: " .. DonatXPGetText(balance.moneyDonat or 0),"HS.18",4,h + 32,color_gold,nil)
        end
        DisableClipping(false)
    end
end

