--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_donat/lua/hinit/donat/inventory/inventory_notification_cl.lua <
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

-- "addons\\homigrad_donat\\lua\\hinit\\donat\\inventory\\inventory_notification_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
InventoryNotificationManager = Create_NotificationManager_AboutSteamID64("donat_inventory_notification",function(body)
    DonatInventoryNotification = body

    if IsValid(ScoreboardPages[101].Panel) then
        if event.Call("Should Show DonatInventory Notification") == false then return end//крутка кейсов

        DonatInventory_ShowNewItems(DonatInventoryNotification,nil,function()
            DonatInventoryNotification = nil
            InventoryNotificationManager.Clear()
        end)
    end
end)

function DonatInventory_ShowNewItems(items,title,callbackEnd,soundName)
    if not items then return end

    local frame = VguiCreateBlackScreen("donat_inventory_notification")
    local start = RealTime()
    local panel = oop.CreatePanel("v_panel",frame)

    local function getK() return math.ease.OutQuint(1 - math.max(start + 0.3 - RealTime(),0) / 0.3) end

    local startPage = 1

    function panel:Step()
        local k = getK()

        self:setSize(frame:W() * k,frame:H() * k):setPos(frame:W()/2-self:W()/2,frame:H()/2-self:H()/2)
        self:InvalidateChildren()
    end

    function panel:Draw(w,h)
        local k = getK()

        surface.SetAlphaMultiplier(k)
        draw.SimpleText(title or L("donat_ui_new_items"),(k <= 0.5 and "HS.12") or (k <= 0.75 and "HS.18") or "HS.45",w/2,h * 0.15,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        if start - RealTime() + 5 <= 0 then
            draw.SimpleText(L("donat_ui_new_items_desc"),(k <= 0.5 and "HS.12") or (k <= 0.75 and "HS.12") or "HS.18",w/2,h * 0.15 + 45,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end
    end

    function panel:DrawOver(w,h)
        surface.SetAlphaMultiplier(1)
    end

    function frame:OnMouse(key,value)
        if not value then return end

        startPage = startPage + 1
        
        if title then frame:Close() end

        if not items[startPage] then
            frame:Close()
            if callbackEnd then callbackEnd() end
        else
            start = RealTime()
            frame:Update(items[startPage])
        end
    end

    function frame:Update(list)
        panel:Clear()

        local x,y = 0,0
        local width = frame:W() * 0.8
        local height = frame:H() * 0.8
        local iconSize = width/12
        
        local WIDTH = 0

        local raryData

        function frame:DrawContent(w,h)
            local k = getK()
            local color = raryData[1]
            surface.SetDrawColor(color.r,color.g,color.b,25)
            surface.SetBG(raryData[4])

            surface.DrawRect(0,0,w,h)
            draw.BG2(0,0,w,h)

            surface.SetDrawColor(color.r,color.g,color.b,128)
            local size = h + h * 0.5 * math.cos(RealTime())
            draw.GradientDown(0,h - size + 1,w,size)

            k = math.ease.InCirc(math.max(start + 1 - RealTime(),0))

            surface.SetDrawColor(color.r + 75,color.g + 75,color.b + 75,128 * k)
            local size = h * k * 3
            draw.GradientDown(0,h - size + h * 0.3,w,size)
        end
        
        local raryType = 5

        for i,item in pairs(list) do
            item = DonatItem_Create(item,item)
            raryType = math.min(raryType,DonatItemsRaryDataIndex[item:GetRaryType()])

            local X,Y = x,y

            x = x + 1
            WIDTH = math.max(x,WIDTH)
            if iconSize * (x + 1) > width then
                x = 0
                y = y + 1
            end
            
            local icon = oop.CreatePanel("v_panel",panel):ad(function(self,w,h)
                local k = getK()
                self:setSize(iconSize * k,iconSize * k):setPos(self:W()*X + (w - self:W()*WIDTH)/2,self:H()*Y + (h - self:H()*y)/2)
            end)

            function icon:Draw(w,h)
                item:DrawIcon(w,h,self)
            end
        end

        raryData = DonatItemsRaryData[DonatItemsRaryDataIndexToName[raryType]]
        
        SurfaceSoundEmit(soundName or raryData[8],0.4)
    end

    frame:Update(items[startPage])

    frame:LinkMouse(panel)
end

if Initialize and DonatInventoryNotification then
    DonatInventory_ShowNewItems(DonatInventoryNotification,nil,function()
        DonatInventoryNotification = nil
        InventoryNotificationManager.Clear()
    end)
end
