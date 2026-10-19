--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/levels/_special/event/tier_1_system/plan/ui_comment_cl.lua <
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

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\levels\\_special\\event\\tier_1_system\\plan\\ui_comment_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
EventComments = EventComments or {}

net.Receive("event_comment_read",function()
    local result = net.ReadString()
    
    if result == "timeout" then
        EventCommentLoadText = ""
        return
    end

    if result == "timeout comment" then
        EventCommentLoadText = "event_comment_send_timeout"
        return
    end

    if result == "younotplay" then
        EventCommentLoadText = "event_comment_younotplay"
        return
    end

    EventCommentLoadText = ""

    local rawID = net.ReadString()
    local eventID = tonumber(rawID) or 0

    local parsed = util.JSONToTable(result)
    if parsed then
        EventComments[eventID] = parsed
        local panel = ScoreboardPages and ScoreboardPages[6] and ScoreboardPages[6].panel
        if IsValid(panel) and IsValid(panel.commentPanel) and isfunction(panel.commentPanel.Update) then
            panel.commentPanel:Update()
        end
    elseif DataBase and isfunction(DataBase.Read) then
        pcall(function()
            DataBase:Read({token = result,callback = function(res)
                EventCommentLoadText = ""
                EventComments[eventID] = util.JSONToTable(res.body) or {}

                local panel = ScoreboardPages and ScoreboardPages[6] and ScoreboardPages[6].panel
                if IsValid(panel) and IsValid(panel.commentPanel) and isfunction(panel.commentPanel.Update) then
                    panel.commentPanel:Update()
                end
            end})
        end)
    else
        EventComments[eventID] = {}
        local panel = ScoreboardPages and ScoreboardPages[6] and ScoreboardPages[6].panel
        if IsValid(panel) and IsValid(panel.commentPanel) and isfunction(panel.commentPanel.Update) then
            panel.commentPanel:Update()
        end
    end
end)

net.Receive("event_comment_add",function()
    local event = ScoreboardPages and ScoreboardPages[6] and ScoreboardPages[6].SelectEvent
    if not event or not event.id then return end

    local panel = ScoreboardPages[6].panel
    if IsValid(panel) and IsValid(panel.commentPanel) then
        panel.commentPanel.requestedComments = nil
    end
    EventComments[event.id] = nil

    net.Start("event_comment_read")
    net.WriteString(tostring(event.id))
    net.SendToServer()
end)

local starMat = Material("homigrad/vgui/models/star.png")

function EventComment_UICreate(frame)
    local EventCommentCount
    
    function frame:Draw(w,h)
        if EventCommentCount then draw.SimpleText(L("event_comment_count",tostring(EventCommentCount)),"HS.45",w/2,50,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end
        draw.SimpleText(L(tostring(EventCommentLoadText)),"HS.45",w - 50,50,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
    end

    local backPage = oop.CreatePanel("v_button",frame):ad(function(self,w,h) self:setSize(200,50):setPos(30,30) end)
    backPage:SetupDrawStyle("white_gradient"); backPage.gradientSide = "left"; backPage.text = "BACK"; backPage.font = "HS.25"
    function backPage:OnClick() ScoreboardPages[6].SetPage(1) end

    local scrollpanel = oop.CreatePanel("v_scrollpanel",frame):ad(function(self,w,h) self:setPos(30,100):setSize(w - 60,h - self.y - 30) end)
    scrollpanel:CreateVBar()
    scrollpanel.scrolling = 225

    local star = Material("homigrad/vgui/models/star.png","smooth")

    local function CreateComment(isEditable,steamid,avatar,avatarFrame,name,callback,setStar,setText,title)
        local panelComment = oop.CreatePanel("v_panel",scrollpanel):ad(function(self,w,h) self:setSize(w,225) end)
        local textEntry,icon

        local nameH = 40

        function panelComment:Draw(w,h)
            surface.SetDrawColor(0,0,0,100)
            surface.DrawRect(0,0,w,h)

            if title then
                draw.SimpleText(title,"HS.25",w/2,textEntry.y / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            end

            draw.SimpleText(name,"HS.25",icon.x + icon:W(),textEntry.y - nameH/2,nil,nil,TEXT_ALIGN_CENTER)
        end
    
        local iconSize = 150
        icon = oop.CreatePanel("v_avataricons",panelComment):ad(function(self,w,h) self:setSize(iconSize,iconSize) end)
    
        local wide = iconSize*0.25*1.3
        local iconSize = iconSize - wide
        icon:Setup(iconSize)
        icon:AddPanel(steamid,avatar,avatarFrame)
    
        textEntry = oop.CreatePanel("v_textentry",panelComment):ad(function(self,w,h) self:setPos(iconSize + wide,wide/2 + nameH):setSize(w - self.x - wide/2,h - wide - 90) end)
        textEntry:SetMultiline(true)
        textEntry:SetPlaceholderText(L("event_comment_placeholder"))
        textEntry:SetValue(setText or "")
        textEntry:SetEditable(isEditable)

        local price = oop.CreatePanel("v_panel",panelComment):ad(function(self,w,h) self:setPos(textEntry.x,textEntry.y + textEntry:H() + wide/4):setSize(w - self.x - wide/2,h - self.y - wide/4) end)
        local selectedStars = setStar or 5
        local old = selectedStars

        function price:Draw(w,h)
            surface.SetDrawColor(0,0,0,100)
            surface.DrawRect(0,0,w,h)

            draw.GradientLeft(0,0,w,h)

            if selectedStars ~= old then
                old = selectedStars

                LocalPlayer():EmitSound("homigrad/vgui/csgo_ui_contract_type" .. math.random(1,10) .. ".wav",75,100,0.5)
            end
        end
        
        for i = 1,5 do
            local I = i
            local star = oop.CreatePanel("v_panel",price):ad(function(self,w,h) self:setSize(h,h):setPos(h * (i - 1),0) end)

            function star:Draw(w,h)
                surface.SetMaterial(starMat)

                local size = h*0.6
                if i <= selectedStars then
                    surface.SetDrawColor(255,255,71)
                else
                    surface.SetDrawColor(125,125,125)
                end

                surface.DrawTexturedRectRotated(h/2,h/2,size,size,isEditable and star:IsHovered() and 15 * math.cos(CurTime() * 15) or 0)

                if isEditable and star:IsHovered() then selectedStars = i end
            end
        end

        local last = price:GetChild(4)
        local text = oop.CreatePanel("v_panel",price):ad(function(self,w,h) self:setPos(last.x + last:W(),0):setSize(w - self.x + self:W(),h) end)

        function text:Draw(w,h)
            draw.SimpleText(selectedStars,"HS.45",h/2,h/2,nil,nil,TEXT_ALIGN_CENTER)
        end

        if isEditable then
            local sended = oop.CreatePanel("v_button",price):ad(function(self,w,h) self:setSize(200,h):setPos(w - self:W(),0) end)
            sended.text = L("event_comment_send"); sended.font = "HS.25"
            
            function sended:OnClick() callback(textEntry:GetValue(),selectedStars) end
        end

        local steamidButt = oop.CreatePanel("v_button",panelComment):ad(function(self,w,h) self:setSize(w / 3,nameH):setPos(w - wide/2 - self:W(),wide/2) end)
        function steamidButt:Draw(w,h)
            draw.SimpleText(steamid,"HS.18",w - h/2,h/2,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
        end
        function steamidButt:OnClick() SetClipboardText(steamid) chat.AddText("Copy: " .. steamid) end

        return panelComment
    end

    function frame:Update()
        scrollpanel:Clear()
        
        local eventObj = ScoreboardPages and ScoreboardPages[6] and ScoreboardPages[6].SelectEvent
        if not eventObj or not eventObj.id then return end
        local eventID = eventObj.id

        if not EventComments[eventID] then
            if not frame.requestedComments or frame.requestedComments ~= eventID then
                frame.requestedComments = eventID
                net.Start("event_comment_read")
                net.WriteString(tostring(eventID))
                net.SendToServer()
                EventCommentLoadText = "Waiting"
            end
            return
        end

        EventCommentLoadText = ""
        EventCommentCount = table.Count(EventComments[eventID])
        
        local y = 0

        local selfSteamID = LocalPlayer():SteamID()
        local selfComment = EventComments[eventID][selfSteamID]

        local myAvatar = (LocalPlayer().GetAvatar and LocalPlayer():GetAvatar()) or ""
        local myAvatarFrame = (LocalPlayer().GetAvatarFrame and LocalPlayer():GetAvatarFrame()) or ""
        local myName = LocalPlayer():Name()

        if selfComment then
            local prof = selfComment.steam_profile or {}
            local panel = CreateComment(true,selfSteamID,prof.avatar or myAvatar,prof.avatarFrame or myAvatarFrame,prof.name or myName,function(text,stars)
                if not text or text:Trim() == "" then return end
                net.Start("event_comment_add")
                net.WriteString(tostring(eventID))
                net.WriteString(tostring(text))
                net.WriteString(tostring(stars or 5))
                net.SendToServer()
                EventCommentLoadText = "Waiting"
            end,selfComment[2] or 5,selfComment[1] or "",L("event_comment_self"))

            y = y + panel:H() + 16
        else
            local panel = CreateComment(true,selfSteamID,myAvatar,myAvatarFrame,myName,function(text,stars)
                if not text or text:Trim() == "" then return end
                net.Start("event_comment_add")
                net.WriteString(tostring(eventID))
                net.WriteString(tostring(text))
                net.WriteString(tostring(stars or 5))
                net.SendToServer()
                EventCommentLoadText = "Waiting"
            end,5,"",L("event_comment_notself"))

            y = y + panel:H() + 16
        end

        for steamid,info in pairs(EventComments[eventID] or {}) do
            if steamid == selfSteamID then continue end
            if not istable(info) then continue end
            local prof = info.steam_profile or {}
            local panel = CreateComment(false,steamid,prof.avatar or "",prof.avatarFrame or "",tostring(prof.name or steamid),nil,info[2] or 5,info[1] or "")
            panel:setPos(0,y)
            
            y = y + panel:H() + 16
        end
    end

    frame:Update()
end

if Initialize then OpenTab() end
