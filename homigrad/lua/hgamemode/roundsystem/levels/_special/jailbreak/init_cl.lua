--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/levels/_special/jailbreak/init_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hgamemode/roundsystem/levels/_special/jailbreak/init_tier_0_sh.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:143
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

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\levels\\_special\\jailbreak\\init_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Level = oop.Get("level_jailbreak")
if not Level then return end

local color = Color(165,165,165)

function Level:GetTeamName(ply)
    local teamID = ply:Team()

    if teamID == 2 then
        teamID = self.teamEncoder and self[self.teamEncoder[teamID]]
        if not teamID then return end

        return teamID[1],teamID[2]
	elseif teamID == 1 then
        local rank = self:GetRank(ply)
        if not rank then return "Уволен",color end

        return rank[1],rank[2]
    end
end

function Level:Scoreboard_Status(ply)
	if not LocalPlayer():Alive() or LocalPlayer():Team() == 1002 then return end

    if ply:Alive() then return "live",ScoreboardGreen else return "dead",ScoreboardRed,ScoreboardRed end
end

--

local white = Color(255,255,255)
local whitePoint = Color(255,255,255)
local point
local pointStart = 0
local old

local circlePos,circleAngle

local circleMat = Material("vgui/loading-rotate")

function Level:HUDPaint(k)
    if #team.GetPlayers(1) == 0 then
        draw.SimpleText(L("jailbreak_minonect"),"HS.25",ScrW() / 2,ScrH() / 2 - 250,nil,TEXT_ALIGN_CENTER)
    elseif #team.GetPlayers(2) == 0 then
        draw.SimpleText(L("jailbreak_minonet"),"HS.25",ScrW() / 2,ScrH() / 2 - 250,nil,TEXT_ALIGN_CENTER)
    end

    local lply = LocalPlayer()

    if lply:Team() == 1 then
        if lply:Alive() then
            local trace = lply:GetEyeTrace()
            local active = input.IsMouseDown(MOUSE_MIDDLE)

            if old ~= active then
                old = active

                if active then
                    local ent = trace.Entity
                    if IsValid(ent) and ent:GetClass() == "func_door" then
                        net.Start("jailbreak_door")
                        net.WriteEntity(ent)
                        net.SendToServer()
                    else
                        net.Start("jailbreak_point")
                        net.WriteVector(trace.HitPos)
                        net.SendToServer()
                    end
                end
            end
        end
    else
        old = false
    end

    local k = math.max(pointStart + 5 - CurTime(),0) / 5

    if k > 0 then
        local pos = point:ToScreen()

        whitePoint.a = 255 * k
        draw.SimpleText(".","HS.25",pos.x,pos.y,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        draw.SimpleText(pointName,"HS.12",pos.x,pos.y + 25,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
end

net.Receive("jailbreak_point",function()
    point = net.ReadVector()
    pointName = net.ReadString()
    pointStart = CurTime()
end)

local Panel = {}
ScoreboardPages[13] = Panel

Panel.Name = "rules"

function Panel.CanOpen(frame)
    return roundActiveName == "level_jailbreak"
end

function Panel.Open(frame)
    local html = oop.CreatePanel("v_html",frame):ad(function(self,w,h) self:setSize(w * 0.9,h * 0.9):setPos(w / 2 - self:W() / 2,h / 2 - self:H() / 2) end)
    
    function html:Paint()
        if not html.open then html.open = true html:OpenURL("https://homigrad.com/wiki/gamemodes/special/jailbreak/?lang=ru") end
    end
end

event.Add("Setup World","Rules Construct",function()
    if roundActiveName ~= "level_construct" then return end

    timer.Simple(0,function() OpenTab():SelectPage(13) end)
end)

event.Add("Setup World","Rules Jailbreak",function()
    if roundActiveName ~= "level_jailbreak" then return end

    timer.Simple(0,function() OpenTab():SelectPage(13) end)
end)
