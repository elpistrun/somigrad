--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/client/scoreboard/tier_0_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\client\\scoreboard\\tier_0_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
ScoreboardPages = ScoreboardPages or {}
ScoreboardPage = ScoreboardPage or 1

local SetDrawColor,DrawRect = surface.SetDrawColor,surface.DrawRect

ScoreboardButtons = ScoreboardButtons or {}

local Update

local lerpY = 0

ScoreboardClose = 0

function OpenTab()
    RemoveTab()
    if not InitNET then return end
    
    ScoreboardStatus = true
    gui.EnableScreenClicker(true)

    local frame = oop.CreatePanel("v_frame"):setDSize(1,1)
    frame:SetMouseInputEnabled(true)
    frame:SetZPos(1)
    //frame:MakePopup()
    frame:SetKeyBoardInputEnabled(false)
    
    ScoreboardFrame = frame
    ScoreboardClose = 0
    ScoreboardButtons = {}
    
    local scrollPanel = oop.CreatePanel("v_panel",frame):setDSize(1,1)
    scrollPanel.lerpY = 0
    frame.scrollPanel = scrollPanel

    local panelButtons = oop.CreatePanel("v_panel",frame)
    ScoreboardPanelButtons = panelButtons
    panelButtons.Paint = nil

    function frame:UpdateButtons()
        for i,butt in pairs(ScoreboardButtons) do
            if IsValid(butt) then butt:Remove() end

            ScoreboardButtons[i] = nil
        end
        
        for i,page in pairs(ScoreboardPages) do
            if page.CanOpen and not page.CanOpen() then continue end

            local button = oop.CreatePanel("v_button",panelButtons)
            button.text = L(page.Name)
            button.i = #ScoreboardButtons
            button:ad(function(self) self:setSize(64 * ScreenSize,64 * ScreenSize):setPos(0,self.i * self:H()) end)
            
            function button:OnMouse(key,value)
                if not value then return end

                frame:SelectPage(i)
            end

            ScoreboardButtons[#ScoreboardButtons + 1] = button
            button.page = i
            page.number = #ScoreboardButtons
        end

        self:SelectPage(ScoreboardPage)
    end

    panelButtons:ad(function(self) self:setSize(self:ChildrenSize()):setPos(frame:W() - self:W(),frame:H() / 2 - self:H() / 2) end)

    if not ScoreboardPages[ScoreboardPage] then ScoreboardPage = 1 end

    function panelButtons:PaintOver(w,h)
        DisableClipping(true)
        
        SetDrawColor(255,255,255,25)
    
        local h = 64 * ScreenSize
        local corner = 2
    
        lerpY = math.Round(LerpFT(0.5,lerpY,-h * (1 - ScoreboardPages[ScoreboardPage].number)) * 10) / 10
    
        local x,y = -2 - corner,lerpY
        DrawRect(x,y,corner,h)
        
        SetDrawColor(75,75,75,15)
        draw.GradientRight(0,y,h,h)

        DisableClipping(false)
    end

    local old

    function frame:SelectPage(i)
        ScoreboardPage = i

        local page = ScoreboardPages[ScoreboardPage]
        if not page.CanOpen or page.CanOpen() then

        else
            ScoreboardPage = 1
        end

        if not IsValid(page.panel) then
            local panelPage = oop.CreatePanel("v_panel",scrollPanel):ad(function(self) self:setSize(frame:W(),frame:H()):setPos(0,self:H() * (page.number - 1)) end)
            page.panel = panelPage
            page.Open(panelPage)
        end

        if old ~= ScoreboardPage then
            local page = ScoreboardPages[old or 0]
            if page and page.Hovered then page.Hovered(false) end
            
            old = ScoreboardPage

            page = ScoreboardPages[ScoreboardPage]
            if page.Hovered then page.Hovered(true) end

            if ScoreboardPage ~= 2 and IsValid(InvPanelOther) and not InvPanelOther.closed then
                InvPanelOther:Close()
            end
        end
    end


    frame:UpdateButtons()
    scrollPanel:ad(function(self) self:setSize(frame:W(),frame:H() * #ScoreboardButtons) end)
    scrollPanel.lerpY = ScoreboardPages[ScoreboardPage].number - 1
    frame:SelectPage(ScoreboardPage)

    Update()

    return ScoreboardFrame
end

function RemoveTab()
    gui.EnableScreenClicker(false)
    ScoreboardStatus = nil

    local page = ScoreboardPages[ScoreboardPage]
    if page and page.Hovered then page.Hovered(false,true) end

    for i,page in pairs(ScoreboardPages) do
        page.panel = nil//удаляется в след тике
    end

    if IsValid(ScoreboardPanelButtons) then ScoreboardPanelButtons:Remove() end
    if IsValid(ScoreboardFrame) then ScoreboardFrame:Remove() end
end

function CloseTab()
    ScoreboardStatus = false

    gui.EnableScreenClicker(false)
end

Update = function()
    if not IsValid(ScoreboardPanelButtons) or ScoreboardStatus == nil then ScoreboardStatus = nil return end

    ScoreboardClose = LerpFT(0.5,ScoreboardClose,ScoreboardStatus == false and 0 or 1)
    
    if ScoreboardClose >= 0.95 then
        ScoreboardClose = 1
    elseif ScoreboardClose <= 0.05 then
        ScoreboardClose = 0
    end

    local scrw,scrh = VGUIScreenSize()
    
    local panelButtons = ScoreboardPanelButtons
    panelButtons:SetX(scrw - panelButtons:W() + panelButtons:W() * 2 * (1 - ScoreboardClose))

    local scrollPanel = ScoreboardFrame.scrollPanel
    
    scrollPanel:SetX(-scrw * 2 * (1 - ScoreboardClose))

    if ScoreboardPages[ScoreboardPage] and ScoreboardPages[ScoreboardPage].number then
        scrollPanel.setY = ScoreboardPages[ScoreboardPage].number - 1
        scrollPanel.lerpY = LerpFT(0.5,scrollPanel.lerpY,scrollPanel.setY)
        scrollPanel.y = -ScrH() * scrollPanel.lerpY
    end

    if ScoreboardStatus == false then
        if ScoreboardClose == 0 then RemoveTab() end
    end

    if not gui.IsConsoleVisible() and not IsValid(vgui.GetKeyboardFocus()) then
        for i = 1,5 do
            if input.IsButtonDown(_G["KEY_" .. i]) then if ScoreboardButtons[i] then ScoreboardFrame:SelectPage(ScoreboardButtons[i].page) end end
        end
    end
end

hook.Add("Think","Scoreboard",Update)

hook.Add("ScoreboardShow","HomigradOpenScoreboard",function()
    if ScoreboardStatus == true then
        CloseTab()
    elseif ScoreboardStatus == nil then
	    OpenTab()
    end

	return false
end)

hook.Add("ScoreboardHide","HomigradHideScoreboard",function()
    return false
end)

//if Initialize then OpenTab() end

local white = Color(255,255,255)
local yellow = Color(255,255,0)

local graph = {}

hook.Add("HUDPaint","Scoreboard",function()
    SetDrawColor(0,0,0,150 * ScoreboardClose)
    DrawRect(0,0,scrw,scrh)

    white.a = 25 * ScoreboardClose

    draw.SimpleText("SOMIGRAD.SU","H.45",scrw / 2,scrh / 2,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

    if ScoreboardClose > 0 then
        showRoundInfo = RealTime() + 2.5
    end

    /*local sft = engine.ServerFrameTime()
    
    local tick = math.Round(1 / sft)
  
    local w = 512

    graph[#graph + 1] = tick

    if #graph > w then
        table.remove(graph,1)
    end

    surface.SetDrawColor(0,255,0)

    for i = 1,#graph do
        surface.DrawRect(i,scrh - graph[i],1,graph[i])
    end*/

    local start = GetGlobalVar("Addon Version Start",0)
    local new =  GetGlobalVar("Addon Version",start)

    if start == new then
        draw.SimpleText("somigrad.su " ..  GetGlobalVar("Addon Version",0) .. " commit.","HS.12",scrw,scrh,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_BOTTOM)
    else
        draw.SimpleText("somigrad.su aviable new " ..  GetGlobalVar("Addon Version",0) .. " commit, curret " .. start,"HS.12",scrw,scrh,yellow,TEXT_ALIGN_RIGHT,TEXT_ALIGN_BOTTOM)
    end
end)

