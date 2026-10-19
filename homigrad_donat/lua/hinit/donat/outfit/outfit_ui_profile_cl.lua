--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_donat/lua/hinit/donat/outfit/outfit_ui_profile_cl.lua <
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

-- "addons\\homigrad_donat\\lua\\hinit\\donat\\outfit\\outfit_ui_profile_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
ScoreboardPages[101].list[1] = ScoreboardPages[101].list[1] or {}
local Page = ScoreboardPages[101].list[1]

Page.Name = "donat_ui_profile"

local black = Color(0,0,0)

Page.Wating = nil

CreateClientConVar("hg_rpc_profile","0",true,true)

function Page.Open(frame)
    Page.panel = frame

    function frame:DrawOver(w,h)
        
        if Page.Wating then
            if not Page.WatingStart then Page.WatingStart = RealTime() end
            if RealTime() - Page.WatingStart > 1.2 then
                Page.Wating = false
                Page.WatingStart = nil
                self:SetMouseInputEnabled(true)
            else
                surface.SetDrawColor(0,0,0,100)
                DrawBlurByPanel(5,frame)
                DrawLoading(w/2,h/2,h/4)
                self:SetMouseInputEnabled(false)
            end
        else
            Page.WatingStart = nil
        end
    end
    
    function frame:Update()
        self:Clear()

        local ply = LocalPlayer()
        local name = ply:Name()

        local iconSize = 80
        local corner = iconSize * 0.1
        
        local avatar = oop.CreatePanel("v_avatarlist",frame):ad(function(self,w,h) self:setSize(w - corner,iconSize + iconSize * 0.33):setPos(corner,corner) end)
        avatar:Setup(iconSize)
        ScoreboardAddPlayerHTML(avatar,ply,{
            drawDiscordProfile = true,
            dontDrawMute = true,
            dontDrawAlive = true,
            dontDrawTeam = true
        })

        local panelSettings = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setPos(0,avatar.y + avatar:H() + corner * 2):setSize(w,h - self.y) end)
        function panelSettings:Draw(w,h)
            local H = 50
            surface.SetDrawColor(175,175,255)
            surface.DrawRect(0,0,w,H)
            draw.SimpleText(L("donat_ui_profile_settings"),"H.25",w/2,H/2,black,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            draw.Frame(0,0,w,H,cframe1,cframe2)
        end

        local y = 50
        local addBlock = function(text,H)
            local Y = y
            local panel = oop.CreatePanel("v_panel",panelSettings):ad(function(self,w,h) self:setSize(w,H):setPos(0,Y) end)
            y = y + panel:H()
            function panel:Draw(w,h)
                surface.SetDrawColor(255,255,255,5)
                surface.DrawRect(0,0,w,1)
                surface.SetDrawColor(125,125,125,25)
                draw.GradientLeft(0,0,w,h)
                draw.SimpleText(text,"HS.18",30,30,nil,nil,TEXT_ALIGN_CENTER)
            end
            return panel
        end

        local function checkSuccess(panel,success,success2)
            if not LocalPlayer():HasSuccess(success) and (not success2 or not LocalPlayer():HasSuccess(success2)) then
                panel:SetMouseInputEnabled(false)
                function panel:DrawOver(w,h)
                    surface.SetDrawColor(0,0,0,200)
                    surface.DrawRect(0,0,w,h)
                    draw.SimpleText(L("ap_ui_need_access",AdminPanelRole_GetName(AdminPanelRole_GetSuccessNeedRole("ProfileChangeColor") or "NULL")),"HS.25",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                end

                return false
            end

            return true
        end

        local profile = OutfitData[AccountSteamID64]

        local switch = oop.CreatePanel("v_switch",addBlock(L("donat_ui_profile_hide_role"),60)):ad(function(self,w,h) self:setSize(h * 2,h):setPos(w - self:W(),0) end)
        function switch:OnValue(value) RunConsoleCommand("hg_dontshowmyperms",value and 1 or 0) end
        switch:SetValue(GetConVar("hg_dontshowmyperms"):GetBool())

        local switch = oop.CreatePanel("v_switch",addBlock(L("donat_ui_profile_hide_discord"),60)):ad(function(self,w,h) self:setSize(h * 2,h):setPos(w - self:W(),0) end)
        function switch:OnValue(value) RunConsoleCommand("hg_dontshowmydiscord",value and 1 or 0) end
        switch:SetValue(GetConVar("hg_dontshowmydiscord"):GetBool())

        local steamPoster = addBlock(L("donat_ui_profile_steam_poster"),60)
        checkSuccess(steamPoster,"ProfileSteamBackground")
        local switch = oop.CreatePanel("v_switch",steamPoster):ad(function(self,w,h) self:setSize(h * 2,h):setPos(w - self:W(),0) end)
        function switch:OnValue(value) Page.Wating = true RunConsoleCommand("hg_profile_showsteambackground",value and 1 or 0) end
        switch:SetValue(profile.backgroundSteam)

        local backgroundOpacity = addBlock(L("donat_ui_profile_poster_opacity"),60)
        checkSuccess(backgroundOpacity,"ProfileSteamBackground","ProfileChangeBackground")
        local slider = oop.CreatePanel("v_slider",backgroundOpacity):ad(function(self,w,h) self:setSize(w/2.5,h):setPos(w - self:W(),0) end)
        slider:SetMin(0)
        slider:SetMax(1)
        slider:SetValue(profile.backgroundOpacity or 0)
        slider.round = 100
        function slider:OnValue(value)
            timer.Create("hg_profile_color",0.3,1,function()
                Page.Wating = true
                RunConsoleCommand("hg_profile_background_opacity",value)
            end)
        end

        local backgroundY = addBlock(L("donat_ui_profile_poster_y"),60)
        checkSuccess(backgroundY,"ProfileSteamBackground","ProfileChangeBackground")
        local slider = oop.CreatePanel("v_slider",backgroundY):ad(function(self,w,h) self:setSize(w/2.5,h):setPos(w - self:W(),0) end)
        slider:SetMin(0)
        slider:SetMax(1)
        slider.round = 100
        slider:SetValue(profile.backgroundY or 0)
        
        function slider:OnValue(value)
            timer.Create("hg_profile_color",0.3,1,function()
                Page.Wating = true
                RunConsoleCommand("hg_profile_background_y",value)
            end)
        end


        local backgroundPoster = addBlock(L("donat_ui_profile_poster"),90)
        if checkSuccess(backgroundPoster,"ProfileChangeBackground") then
            function backgroundPoster:DrawOver(w,h)
                if profile.backgroundContentType == "image/gif" and not ply:HasSuccess("ProfileBackgroundAnimated") then
                    surface.SetDrawColor(255,0,0)
                    draw.GradientRight(w/2 + 1,0,w/2,60)
                    draw.SimpleText(L("donat_ui_profile_poster_anim_need_access",AdminPanelRole_GetName(AdminPanelRole_GetSuccessNeedRole("ProfileBackgroundAnimated") or "NULL")),"HS.18",w - h/2,30,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
                end
            end
        end

        local textEntry = oop.CreatePanel("v_textentry",backgroundPoster):ad(function(self,w,h) self:setSize(w,h - 60):setPos(w - self:W(),h-self:H()) end)
        textEntry:SetPlaceholderText("URL Image")
        textEntry:SetValue(profile.background or "")
        function textEntry:OnEnter()
            if GetConVar("hg_profile_background"):GetString() == self:GetValue() then return end
            Page.Wating = true

            Homigrad_RulesPublishContent("hg_rpc_profile",function()
                RunConsoleCommand("hg_profile_background",self:GetValue())
            end)
        end

        local color = addBlock(L("color"),200)
        checkSuccess(color,"ProfileChangeColor")

        local mixer = oop.CreatePanel("v_colormixer",color):ad(function(self,w,h) self:setSize(w,h - 60):setPos(0,h - self:H()) end)
        mixer:SetPalette(false)
        mixer:SetAlphaBar(false)

        local colorProfile = profile.color
        if colorProfile then mixer:SetColor(Color(colorProfile[1],colorProfile[2],colorProfile[3])) end

        function mixer:ValueChanged(color)
            timer.Create("hg_profile_color",0.3,1,function()
                Page.Wating = true

                RunConsoleCommand("hg_profile_color",util.TableToJSON({color.r,color.g,color.b}))
            end)
        end

        local switch = oop.CreatePanel("v_switch",color):ad(function(self,w,h) self:setSize(120,60):setPos(w - self:W(),0) end)
        function switch:OnValue(value)
            local color = mixer:GetColor()
            Page.Wating = true

            RunConsoleCommand("hg_profile_color",value and util.TableToJSON({color.r,color.g,color.b}) or "")
        end
        switch:SetValue(GetConVar("hg_profile_color"):GetString() != "")
    end

    frame:Update()
end

event.Add("Outfit Sync","Profile UI",function(steamid64,inventory)
    Page.Wating = false
    if IsValid(Page.panel) and Page.panel.Update then Page.panel:SetMouseInputEnabled(true) Page.panel:Update() end
end)

cvars.CreateReplicateOption("hg_profile_color","",nil,nil,nil,true)
cvars.CreateReplicateOption("hg_profile_background","",nil,nil,nil,true)
cvars.CreateReplicateOption("hg_profile_showsteambackground","",nil,nil,nil,true)
cvars.CreateReplicateOption("hg_profile_background_opacity","",nil,nil,nil,true)
cvars.CreateReplicateOption("hg_profile_background_y","",nil,nil,nil,true)

CreateClientConVar("hg_profile_background_version","0")

if Initialize then OpenTab() end
