--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_donat/lua/hinit/donat/freedrop/freedrop_ui_cl.lua <
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

-- "addons\\homigrad_donat\\lua\\hinit\\donat\\freedrop\\freedrop_ui_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
ScoreboardPages[101].list[5] = ScoreboardPages[101].list[5] or {}
local Page = ScoreboardPages[101].list[5]

Page.Name = "Free Drop"

local colorBlack = Color(0,0,0)
local colorWhite = Color(255,255,255)

// Applies a claimed day: marks it done, starts the cooldown and hands the rewards over.
// The donat backend that used to answer "freedrop_sync" is not part of this pack -- no
// net.Receive("freedrop_sync") exists anywhere in the server files -- so nothing ever
// answered the claim, which left `freedrop_sync_wait` stuck true and every later click
// bailed out at the guard: "click and nothing happens". So the claim is applied locally.
// It is not persistent: the day/cooldown state dies with the session until that backend
// is restored.
local function FreeDropClaim(data,day,steamid64,hasMegasponsor)
    data.complete[day] = true
    data.completeTime = os.time()

    local inventory = DonatInventoryList[steamid64]
    local inventoryFor = {steamid64}

    // the shop and the trade window read BalanceData[AccountSteamID64], which is not
    // necessarily the same key as the one FreeDropData uses
    if AccountSteamID64 and AccountSteamID64 ~= steamid64 then
        inventoryFor[#inventoryFor + 1] = AccountSteamID64
    end

    local balances = {}

    for _,key in ipairs(inventoryFor) do balances[#balances + 1] = BalanceData[key] end

    if not inventory then return end

    local id = 0

    for _ in pairs(inventory) do id = id + 1 end

    local given = 0

    // money is currency, not a backpack item -- crediting the balance is what makes the
    // reward show up in the shop/trade HUD instead of nowhere
    local function credit(field,amount)
        for _,balance in ipairs(balances) do
            balance[field] = (balance[field] or 0) + amount
        end
    end

    local function give(items)
        for _,item in pairs(items or {}) do
            if item.class == "money" then
                credit("money",item.money or 0)
                given = given + 1 continue
            end

            if item.class == "money_donat" then
                credit("moneyDonat",item.money or 0)
                given = given + 1 continue
            end

            id = id + 1

            inventory[id] = DonatItem_Create(item,item)

            given = given + 1
        end
    end

    give(FreeDropConfig[day])

    if hasMegasponsor then give(FreeDropConfigAdded[day]) end

    // let the rest of the client UI react the same way it would on a real server sync
    event.Call("Free Drop Sync",steamid64,inventory)
end

function Page.Open(frame)
    Page.panel = frame

    local iconSize
    local scrollPanel = oop.CreatePanel("v_scrollpanel",frame)
    scrollPanel:CreateHBar()
    scrollPanel:ad(function(self,w,h) self:setSize(w,h) iconSize = (math.floor(h/2) - 30 - self.hbar:H())/4 end)
    scrollPanel.scrolling = iconSize * 2
    
    function frame:Update()
        scrollPanel:Clear()

        local steamid64 = LocalPlayer():SteamID64()
        local data = FreeDropData[steamid64]

        // no server sync in this pack, so make sure the "completed days" table exists
        data.complete = data.complete or {}

        local lastDayComplete = #data.complete + 1

        // A missing completeTime means the player never claimed a day, so nothing is
        // on cooldown. Using "(data.completeTime or 0)" here put every single day on an
        // 18h lock forever, which is why clicking any day did nothing.
        local lastClaimTime = data.completeTime or 0
        local isDelay = lastClaimTime > 0 and lastClaimTime + FreeDropTimeDelay > os.time()

        local corner = 16

        local hasMegasponsor = LocalPlayer():HasSuccess("donat_boost")

        function scrollPanel:DrawOver(w,h)
            if not hasMegasponsor then
                surface.SetDrawColor(0,0,0,25)
                surface.DrawRect(0,h/2,w,h/2 - self.hbar:H())
                surface.SetDrawColor(0,0,0,100)
                surface.SetBG("points90")    
                draw.BG2(0,h/2,w,h/2 - self.hbar:H())

                draw.SimpleText(L("donat_ui_freedrop_not_boost"),"HS.25",w/2,h/2 + h/2/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            end

            local time = lastClaimTime > 0 and lastClaimTime + FreeDropTimeDelay - os.time() or 0

            // no frame:Update() here -- this runs from inside Draw, and Update rebuilds
            // the whole panel tree, so it used to re-enter itself every single frame
            if time <= 0 then return end

            local text = L("donat_ui_less_time",DonatGetTimeLess(time))
            draw.SimpleText(text,"HS.18",corner,h - corner/2 - self.hbar:H(),colorWhite,nil,TEXT_ALIGN_BOTTOM)
        end

        local panelTitle = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setSize(w,30):setPos(0,h/2) end)
        function panelTitle:Draw(w,h)
            surface.SetDrawColor(0,0,0)
            surface.DrawRect(0,0,w,h)

            draw.SimpleText(L("donat_ui_fredrop_added"),"H.18",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

            draw.Frame(0,0,w,h,cframe1,cframe2)
        end

        for day,items in pairs(FreeDropConfig) do
            local isComplete = data.complete[day]
            local canComplete = not isDelay and day == lastDayComplete
            local panel = oop.CreatePanel("v_panel",scrollPanel):ad(function(self,w,h) self:setSize(iconSize,panelTitle.y):setPos(self:W() * (day - 1),0) end)
            local panelAddedX2 = oop.CreatePanel("v_panel",scrollPanel):ad(function(self,w,h) self:setSize(iconSize,h - panelTitle.y - panelTitle:H()):setPos(self:W() * (day - 1),panelTitle.y + panelTitle:H()) end)
            
            if canComplete then panel:SetCursor("hand") end
            
            freedrop_sync_wait = nil
            function panel:OnMouse(key,value)
                if not canComplete or not value or freedrop_sync_wait then return end

                freedrop_sync_wait = true

                // keep asking the server, it may exist on some other deployment
                net.Start("freedrop_sync")
                    net.WriteString(tostring(day))
                net.SendToServer()

                // nothing here answers that message, so claim locally instead of
                // stalling on a reply that never comes
                FreeDropClaim(data,day,steamid64,hasMegasponsor)

                freedrop_sync_wait = nil
                timer.Remove("freedrop_sync_wait")

                // FreeDropClaim fires "Free Drop Sync", which already rebuilds the page
                frame:Update()

                SurfaceSoundEmit("homigrad/vgui/csgo_ui_button_rollover_large.wav",0.5)
            end

            local dayTitleHeight = 30 + scrollPanel.hbar:H()

            function panel:Draw(w,h)
                if canComplete and day == lastDayComplete then
                    surface.SetDrawColor(125,125,125,128)
                    draw.GradientUp(0,0,w,h + h * 0.5 * math.cos(RealTime()))

                    surface.SetDrawColor(255,255,255)
                    surface.DrawRect(0,0,w,dayTitleHeight)

                    draw.SimpleText(L("donat_ui_freedrop_day",day),"H.18",w/2,dayTitleHeight/2,colorBlack,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                else
                    surface.SetDrawColor(0,0,0,255)
                    draw.GradientUp(0,0,w,h)

                    surface.SetDrawColor(0,0,0)
                    surface.DrawRect(0,0,w,dayTitleHeight)
                    draw.SimpleText(L("donat_ui_freedrop_day",day),"H.18",w/2,dayTitleHeight/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                end

                draw.Frame(0,0,w,dayTitleHeight,cframe1,cframe2)
                draw.Frame(0,0,w,h,cframe1,cframe2)
            end

            function panel:DrawOver(w,h)
                if isComplete then
                    surface.SetDrawColor(0,0,0,100)
                    surface.DrawRect(0,dayTitleHeight,w,h)
                    surface.SetDrawColor(0,0,0,200)
                    surface.SetBG("points5")
                    draw.BG2(0,dayTitleHeight,w,h)
                end
            end

            for i,item in pairs(items) do
                item = DonatItem_Create(item,item)

                local icon = oop.CreatePanel("v_panel",panel):ad(function(self,w,h) self:setSize(w,w):setPos(0,dayTitleHeight + self:H() * (i - 1)) end)
                if isComplete then icon.IsHovered = function() end end
                if canComplete then
                    icon:SetCursor("hand")
                    panel:LinkMouse(icon)
                end
                function icon:Draw(w,h) item:DrawIcon(w,h,self,"H.12") end
            end

            //

            local canComplete = canComplete
            local isComplete = isComplete
            
            if not hasMegasponsor then
                canComplete = false
                isComplete = true
            end

            if canComplete then
                panelAddedX2:SetCursor("hand")
                panelAddedX2.OnMouse = panel.OnMouse
            end

            function panelAddedX2:Draw(w,h)
                if canComplete and day == lastDayComplete then
                    surface.SetDrawColor(125,125,125,128)
                    draw.GradientUp(0,0,w,h + h * 0.5 * math.cos(RealTime()))
                else
                    surface.SetDrawColor(0,0,0,255)
                    draw.GradientUp(0,0,w,h)
                end

                draw.Frame(0,0,w,h,cframe1,cframe2)
            end

            function panelAddedX2:DrawOver(w,h)
                if isComplete then
                    surface.SetDrawColor(0,0,0,100)
                    surface.DrawRect(0,0,w,h)
                    surface.SetDrawColor(0,0,0,200)
                    surface.SetBG("points5")
                    draw.BG2(0,0,w,h)
                end
            end

            for i,item in pairs(FreeDropConfigAdded[day]) do
                item = DonatItem_Create(item,item)

                local icon = oop.CreatePanel("v_panel",panelAddedX2):ad(function(self,w,h) self:setSize(w,w):setPos(0,self:H() * (i - 1)) end)
                if isComplete then icon.IsHovered = function() end end
                if canComplete then
                    icon:SetCursor("hand")
                    panelAddedX2:LinkMouse(icon)
                end
                function icon:Draw(w,h) item:DrawIcon(w,h,self,"H.12") end
            end
        end
    end

    frame:Update()
end

event.Add("Free Drop Sync","UI",function(steamid64,inventory)
    if freedrop_sync_wait then
        freedrop_sync_wait = nil

        //SurfaceSoundEmit("homigrad/vgui/csgo_ui_contract_seal.wav",0.8)
        
        timer.Remove("freedrop_sync_wait")
    end

    if IsValid(Page.panel) and Page.panel.Update then Page.panel:Update() end
end)

if Initialize then OpenTab() end

