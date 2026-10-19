--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/levels/_special/event/tier_1_system/plan/ui_playertime_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
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
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\levels\\_special\\event\\tier_1_system\\plan\\ui_playertime_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
EventPlayersTime = EventPlayersTime or {}

net.Receive("event_playerstime_read",function()
    local token,rawID = net.ReadString(),net.ReadString()
    local eventID = tonumber(rawID) or rawID

    local parsed = util.JSONToTable(token)
    if parsed ~= nil then
        EventPlayersTime[eventID] = parsed
        local panel = ScoreboardPages and ScoreboardPages[6] and ScoreboardPages[6].panel
        if IsValid(panel) and IsValid(panel.playersTimePanel) and isfunction(panel.playersTimePanel.Update) then
            panel.playersTimePanel:Update()
        end
        return
    end

    if DataBase and isfunction(DataBase.Read) then
        pcall(function()
            DataBase:Read({token = token,callback = function(res)
                EventPlayersTime[eventID] = (res and res.body and util.JSONToTable(res.body)) or {}

                local panel = ScoreboardPages and ScoreboardPages[6] and ScoreboardPages[6].panel
                if IsValid(panel) and IsValid(panel.playersTimePanel) and isfunction(panel.playersTimePanel.Update) then
                    panel.playersTimePanel:Update()
                end
            end})
        end)
    else
        EventPlayersTime[eventID] = {}
        local panel = ScoreboardPages and ScoreboardPages[6] and ScoreboardPages[6].panel
        if IsValid(panel) and IsValid(panel.playersTimePanel) and isfunction(panel.playersTimePanel.Update) then
            panel.playersTimePanel:Update()
        end
    end
end)

function EventPlayersTime_UICreate(frame)
    local backPage = oop.CreatePanel("v_button",frame):ad(function(self,w,h) self:setSize(200,50):setPos(30,30) end)
    backPage:SetupDrawStyle("white_gradient"); backPage.gradientSide = "left"; backPage.text = "BACK"; backPage.font = "HS.25"
    function backPage:OnClick() ScoreboardPages[6].SetPage(1) end

    local players = oop.CreatePanel("v_players",frame):ad(function(self,w,h) self:setPos(30,100):setSize(w - self.x - 30,h - self.y - 30) end)
    players:CreateVBar()
    players:Setup(64)

    local eventID
    
    local count = 0

    function frame:Draw(w,h)
        draw.SimpleText(L("event_playerTime_count",count),"HS.45",w/2,players.y / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    function frame:Update()
        players:Clear()

        local eventObj = ScoreboardPages and ScoreboardPages[6] and ScoreboardPages[6].SelectEvent
        if not eventObj then return end
        eventID = tonumber(eventObj.id) or eventObj.id

        if not EventPlayersTime[eventID] then
            if not frame.requestedPlayersTime or frame.requestedPlayersTime ~= eventID then
                frame.requestedPlayersTime = eventID
                net.Start("event_playerstime_read")
                net.WriteString(tostring(eventID))
                net.SendToServer()
            end
            return
        end

        local list = {}

        for steamid,info in pairs(EventPlayersTime[eventID] or {}) do
            if istable(info) then
                info.steamid = steamid
                list[#list + 1] = info
            end
        end

        table.sort(list,function(a,b) return (a.time or 0) > (b.time or 0) end)

        count = #list

        for i,info in pairs(list) do
            local prof = info.steam_profile or {}
            players:AddPanel(info.steamid,prof.name or info.steamid,prof.avatar or "",prof.avatarFrame or "")
        end
    end

    function players:DrawPanel(w,h,panel,info)
        local timeInfo = (EventPlayersTime[eventID] and EventPlayersTime[eventID][info.id]) or {}

        surface.SetDrawColor(0,0,0,100)
        surface.DrawRect(0,0,w,h)

        draw.SimpleText(info.name or "","HS.18",h/2,h/2,nil,nil,TEXT_ALIGN_CENTER)
        local hours = math.floor(((timeInfo.time or 0) / 3600) * 100) / 100
        draw.SimpleText(hours .. "h","HS.18",w - h/2,h/2,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
    end

    function players:OnClick(key,info)
        SetClipboardText(info.id)
        chat.AddText("Copy: " .. info.id)
    end

    frame:Update()

    local butt = oop.CreatePanel("v_button",frame):ad(function(self,w,h) self:setSize(200,50):setPos(w - self:W() - 30,30) end)
    butt:SetupDrawStyle("white_gradient"); butt.gradientSide = "left"; butt.text = "COPY JSON"; butt.font = "HS.25"
    function butt:OnClick()
        local list = {}
        for steamid in pairs(EventPlayersTime[eventID] or {}) do
            list[#list + 1] = steamid
        end
        SetClipboardText(util.TableToJSON(list))
        chat.AddText("Copy!")
    end
end
