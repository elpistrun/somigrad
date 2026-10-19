--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/client/scoreboard/pages/settings/tier_0_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
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

-- "addons\\homigrad\\lua\\hgamemode\\client\\scoreboard\\pages\\settings\\tier_0_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Panel = {}
ScoreboardPages[10] = Panel

Panel.Name = "settings"

local SetDrawColor,DrawRect = surface.SetDrawColor,surface.DrawRect

SettingsPages = SettingsPages or {}
SettingsPage = SettingsPage or 1

function Panel.Open(frame)
    local panel = oop.CreatePanel("v_panel",frame):setDSize(0.85,0.85)
    panel:setPos(frame:W() / 2 - panel:W() / 2,frame:H() / 2 - panel:H() / 2)

    function panel:Draw(w,h)
        SetDrawColor(0,0,0,100)
        DrawRect(0,0,w,h)

        DrawBlurByPanel(5,self)
    end

    for i,page in pairs(SettingsPages) do
        local butt = oop.CreatePanel("v_button",panel)
        butt.text = L(page.Name)

        function butt:OnMouse(key,value)
            if value then panel:SelectPage(i) return end
        end

        page.butt = butt
    end

    panel:ad(function(self,w,h)
        for i,page in pairs(SettingsPages) do
            local butt = page.butt

            butt:setSize(250 * ScreenSize,40 * ScreenSize):setPos(butt:W() * (i - 1),0)
        end
    end)

    panel.lerpX = 0
    
    function panel:DrawOver(w,h)
        SetDrawColor(255,255,255,75)
        DrawRect(self.lerpX,40 * ScreenSize,250 * ScreenSize,2)

        self.lerpX = LerpFT(0.4,self.lerpX,250 * ScreenSize * (SettingsPage - 1))
    end
    
    local panelPage = oop.CreatePanel("v_scrollpanel",panel):ad(function(self,w,h) self:setSize(w,h - 40 * ScreenSize):setPos(0,40 * ScreenSize) end)
    panelPage:CreateVBar()
    panelPage.scrolling = 200

    function panelPage:AddCategory(name)
        local panelCat = oop.CreatePanel("v_panel",panelPage)
        panelCat.blocks = {}

        function panelCat:Draw(w,h)
            SetDrawColor(0,0,0,125)
            draw.GradientLeft(0,0,w * 2,40)

            draw.SimpleText(name,"HS.25",10,40 / 2,nil,nil,TEXT_ALIGN_CENTER)
        end

        self.categories[#self.categories + 1] = panelCat

        panelCat:ad(function(self,w,h)
            local _,h = self:ChildrenSize()
            self:setSize(w,h)

            local y = 0

            for i,panelCat in pairs(panelPage.categories) do
                if not IsValid(panelCat) then continue end
                
                panelCat.y = y
                y = y + panelCat:H()
            end
        end)--dam.....

        function panelCat:AddBlock(h,class)
            local panel = oop.CreatePanel(class or "v_panel",panelCat)
            panelCat.blocks[#panelCat.blocks + 1] = panel

            panel:ad(function(self,w)
                self:setSize(w,h * ScreenSize)

                local y = 40

                for i,block in pairs(panelCat.blocks) do
                    if not IsValid(block) then continue end
                    
                    block.y = y
                    y = y + block:H()
                end
            end)

            panel.lerpHover = 0
            panel.textX = 0
            panel.text2X = 0

            function panel:Draw(w,h)
                SetDrawColor(125,125,125,25)
                draw.GradientLeft(0,0,w * (0.25 + self.lerpHover * 0.5),h)

                if self.text then
                    draw.SimpleText(self.text,"HS.18",15 + self.textX,h / 2,nil,nil,TEXT_ALIGN_CENTER)
                end

                if self.text2 then
                    draw.SimpleText(self.text2,"HS.18",w - 15 - self.text2X,h / 2,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
                end
            end

            function panel:DrawOver(w,h)
                draw.Frame(-1,0,w + 2,h,cframe1,cframe2)

                local isHover = self:IsHovered()

                if not isHover then
                    for i,child in pairs(self:GetChildren()) do
                        if child:IsHovered() then isHover = true break end
                    end
                end

                self.lerpHover = LerpFTLess(0.45,self.lerpHover,isHover and 1 or 0,0.001)
            end

            return panel
        end

        function panelCat:AddSwitch(text,convar,invert,text2)
            local block = self:AddBlock(40)
            block.text = text
            block.text2 = text2

            local switch = oop.CreatePanel("v_switch",block):ad(function(self,w,h) self:setSize(100 * ScreenSize,h):setPos(w - self:W(),0) block.text2X = self:W() end)

            -- GetConVar returns nothing for a convar that was never created, and these pages
            -- ask for options whose module may not be in the pack: "Ragdoll always E" wants
            -- hg_fake_always_e, which is created by hgame/tier_1/fake/cl_fake.lua -- a folder
            -- that is empty right now -- so indexing the nil returned nothing but took the
            -- whole settings page down when it opened ("AddSwitch - tier_0_cl.lua:162:
            -- attempt to index a nil value"). Show the switch as off, and still let it run
            -- the command, so it comes back to life on its own once the convar exists.
            local cv = GetConVar(convar)

            switch:SetValue(cv and cv:GetFloat() > 0 or false)
            if invert then switch:SetValue(not switch.on) end

            function switch:OnValue(value)
                RunConsoleCommand(convar,(value and (invert and 0 or 1) or (invert and 1 or 0)))
            end
        end

        function panelCat:AddText(text,text2)
            local block = self:AddBlock(40)
            block.text = text
            block.text2 = text2
        end

        function panelCat:AddSlider(text,convar,invert,text2,round,change,min,max)
            local block = self:AddBlock(40)
            block.text = text
            block.text2 = text2

            local slider = oop.CreatePanel("v_slider",block):ad(function(self,w,h) self:setSize((w / 4) * ScreenSize,h):setPos(w - self:W(),0) block.text2X = self:W() - 15 end)

            local convar = GetConVar(convar)

            if convar then
                local min,max = min or convar:GetMin() or 0,max or convar:GetMax() or 1

                slider:SetMax(max)
                slider:SetMin(min)
                slider:SetValue(convar:GetFloat())
                slider.round = round or 100

                function slider:OnValue(value)
                    RunConsoleCommand(convar:GetName(),self:GetValue())
                    
                    if change then change(tonumber(self:GetValue())) end
                end
            end
        end

        return panelCat
    end

    function panel:SelectPage(i)
        SettingsPage = i

        local page = SettingsPages[SettingsPage]

        panelPage.canvasPanel:Clear()
        panelPage.categories = {}

        page.Open(panelPage)

        panelPage:SetScrollX(0,true)
        panelPage:SetScrollY(0,true)
    end

    panel:SelectPage(SettingsPage)
end

if Initialize and LocalPlayer():SteamID() == "STEAM_0:1:215196702" then OpenTab() end
