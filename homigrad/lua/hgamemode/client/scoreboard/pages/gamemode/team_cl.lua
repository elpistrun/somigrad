--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/client/scoreboard/pages/gamemode/team_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
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

-- "addons\\homigrad\\lua\\hgamemode\\client\\scoreboard\\pages\\gamemode\\team_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
ScoreboardPages[4].list[1] = ScoreboardPages[4].list[1] or {}
local Panel = ScoreboardPages[4].list[1]

Panel.Name = "team"

local empty = {}

function Panel.Open(frame)
    local level = TableLevel()
    local teamEncoder = level.teamEncoder or empty
    local max = table.Count(teamEncoder)

    local w,h = ScrW(),ScrH()
    local panel = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setSize(325 * max * ScreenSize,655 * ScreenSize):setPos(w / 2 - self:W() / 2,h / 2 - self:H() / 2) end)

    function panel:Draw(w,h)
        surface.SetDrawColor(15,15,15,100)
        surface.DrawRect(0,0,w,h)

        DrawBlurByPanel(6,self)

        draw.Frame(0,0,w,h,cframe1,cframe2)
    end

    function frame:Draw(w,h)
        draw.SimpleText(L("select_team"),"HS.25",w / 2,panel.y/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
    
    local num = 0

    for i,name in pairs(teamEncoder) do
        local team = level[name]
        if not team then continue end

        local col = team[2]

        num = num + 1
        local numm = num

        local butt = oop.CreatePanel("v_panel",panel):ad(function(self,w,h)
            local x = 10

            for i,child in pairs(panel:GetChildren()) do
                child:setSize(w / max - (i == 1 and 20 or 0),h - 20):setPos(x,10)
                x = x + child:W()
            end
        end)
        
        local copy = {}
        for k,v in pairs(team) do copy[k] = v end
        team = copy
        
        local func = TableLevel().TeamTab_Team
        if func then func(team) end

        butt.hovered = 0
        butt.down = 0

        local list = {}

        local fakePly = Create_Player_Fake(nil,"vgui_team")

        local function setup(team)
            local class = table.Random(team.classes or {})

            local mdlpath,bodygroups = level.GetModel((class and class.models) or team.models)
            
            fakePly:SetModel(mdlpath)
            fakePly:SetBodygroups(bodygroups)
            fakePly:SetColor(col)

            local main_weapon = (class and class.main_weapon) or team.main_weapon
            local wepMain = main_weapon and main_weapon[math.random(1,#main_weapon)]
            if wepMain then fakePly:AddWeapon(wepMain) end

            local secondary_weapon = (class and class.secondary_weapon) or team.secondary_weapon
            local wepSecondary = secondary_weapon and secondary_weapon[math.random(1,#secondary_weapon)]
            if wepSecondary then fakePly:AddWeapon(wepSecondary) end

            for i,class in pairs((class and class.weapons) or team.weapons or empty) do fakePly:AddWeapon(class) end
            for i,armor in pairs((class and class.armors) or team.armors or empty) do fakePly:AddArmor(level.GetArmor(armor,col)) end

            function fakePly:DrawModel(mdl)           
                if max == 2 then
                    mdl:SetRenderAngles(Angle(0,i == 2 and 2 or -2,0))
                else
                    mdl:SetRenderAngles(Angle(0,0,0))
                end

                mdl:DrawModel()
            end
        end

        setup(team)

        function butt:Draw(w,h)
            surface.SetDrawColor(15,15,15,75)
            surface.DrawRect(0,0,w,h)
    
            draw.Frame(0,0,w,h,cframe1,cframe2)

            local isMyTeam = i == LocalPlayer():Team()

            self.hovered = LerpFT(0.25,self.hovered,not isMyTeam and self:IsHovered() and 1 or 0)
            self.down = LerpFT(0.5,self.down,not isMyTeam and self:IsDown() and 1 or 0)

            surface.SetDrawColor(col.r,col.g,col.b,25 + self.hovered * 55)
            
            local size = h / 1.25 + h / 3 * math.cos(CurTime())
            draw.GradientDown(0,h - size,w,size)

            if isMyTeam then
                surface.SetDrawColor(0,0,0,175)
                surface.DrawRect(0,0,w,h)
                
                surface.SetDrawColor(255,255,255,175)
                surface.DrawRect(0,h - 1,w,1)
            end

            self:EnableScissor()
            fakePly:Draw(self,w,h,-self.hovered - 5)
            self:DisableScissor()
            
            draw.SimpleText(L(team[1]),"HS.18",w / 2,h - 25,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

            surface.SetDrawColor(255,255,255,self.down * 2)
            surface.DrawRect(0,0,w,h)
        end

        function butt:OnMouse(key,value)
            if not value then return end

            net.Start("want change team")
            net.WriteString(tostring(i))
            net.SendToServer()
        end
    end

    local butt = oop.CreatePanel("v_button",frame):ad(function(self,w,h) self:setSize(325* ScreenSize,50 * ScreenSize):setPos(w / 2 - self:W() / 2,h - (h - panel.y - panel:H())/2-self:H()/2) end)
    butt.text = L("spectator")
    butt.font = "HS.18"

    function butt:OnMouse(key,value)
        if not value then return end

        net.Start("want change team")
        net.WriteString("1002")
        net.SendToServer()
    end
end

net.Receive("want change team",function()
    CloseTab()

    surface.PlaySound("buttons/blip1.wav")

    timer.Simple(0.1,function()
        local ply = LocalPlayer()

        ply:ChatPrint(L("you_select_team",L(ply:GetTeamStatus() or "spectators")))
    end)--pizsed
end)

concommand.Add("hg_showteam",function()
    if not ScoreboardStatus then OpenTab() end
    
    ScoreboardFrame:SelectPage(4)
end)

if Initialize then OpenTab() end
