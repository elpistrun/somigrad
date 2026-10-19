--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/levels/homicide/init_tier_0_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\levels\\homicide\\init_tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Level = oop.Reg("level_homicide","level_base",true)
if not Level then return INCLUDE_BREAK end

AdminPanel_Command_Registry("homicide_sett",{"players^"},"game")
AdminPanel_Command_Registry("homicide_get",{},"game")

function Level:RandomOften() return math.random(1,2) == 2 end

Level.red = {"innocent",Color(122,122,122),models = Level.StandardPlayerModels}
Level.teamEncoder = {
	[1] = "red"
}

Level.LevelRoundsNext = 2
Level.ShouldSpawnLoot = true
Level.PropBreakLoot = true

local roundTypes = {
    [1] = {
        name = "State of Emergency",
        playsnd = "snd_jack_hmcd_disaster.mp3"
    },
    [2] = {
        name = "Standard",
        playsnd = "snd_jack_hmcd_shining.mp3"
    },
    [3] = {
        name = "Gun-Free Zone",
        playsnd = "snd_jack_hmcd_panic.mp3"
    },
    [4] = {
        name = "Wild West",
        playsnd = "snd_jack_hmcd_wildwest.mp3"
    },
}

Level.ColorRed = Color(255,0,0)
Level.ColorBlue = Color(0,0,255)

if SERVER then return end

local empty = {}

function Level:Sync(data)
    for i,ply in pairs(player.GetAll()) do
        ply.roleT = false
        ply.roleCT = false
    end

    for i,ply in pairs(data.traitors or empty) do ply.roleT = true end
    for i,ply in pairs(data.inoccent or empty) do ply.roleCT = true end

    roundType = data.roundType
end

function Level:GetTeamName(ply)
    local lply = LocalPlayer()

    -- 1. Show LocalPlayer their own role
    if ply == lply then
        if lply.roleT then
            return "traitor", Level.ColorRed
        elseif lply.roleCT then
            return "Невиновный", Level.ColorBlue
        else
            return "innocent", Level.red[2]
        end
    end

    -- 2. Traitors see other traitors in TAB
    if IsValid(lply) and lply.roleT and ply.roleT then
        return "traitor", Level.ColorRed
    end

    -- 3. The blue innocent is visible to everyone as Невиновный
    if ply.roleCT then
        return "Невиновный", Level.ColorBlue
    end

    -- 4. During active round, traitors and ordinary innocents display as innocent (Невиновный)
    local isRoundRunning = roundActive or (roundTimeStart and CurTime() - roundTimeStart < (roundTime or 300))
    if isRoundRunning and ((IsValid(lply) and lply:Alive() and not lply.isDead) or (IsValid(ply) and ply:Alive() and not ply.isDead)) then
        return "innocent", Level.red[2]
    end

    if ply.roleT then return "traitor", Level.ColorRed end
    if ply.roleCT then return "Невиновный", Level.ColorBlue end

    local teamID = ply:Team()
    if teamID <= 3 then
        return "innocent", Level.red[2]
    end
end

local black = Color(0,0,0,255)

function Level:HUDPaint_Spectate(spec)
    --local name,color = homicide.GetTeamName(spec)
    --draw.SimpleText(name,"H.25",ScrW() / 2,ScrH() - 150,color,TEXT_ALIGN_CENTER)
end

function Level:Scoreboard_Status(ply)
    local lply = LocalPlayer()
    if (IsValid(lply) and lply:Alive()) or (IsValid(ply) and ply:Alive()) then
        return "innocent",ScoreboardSpec
    end
end

Level.LoadScreenTime = 6

function Level:DrawScreen(lply,k)
    local name,color = self:GetTeamName(lply)

    local w,h = ScrW(),ScrH()

    draw.DrawText(L("you",L(name)),"H.25",w / 2,h / 2,cname,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    draw.DrawText(L("level_homicide"),"H.45",w / 2,h / 8,cblue,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    local typeInfo = roundTypes[roundType]
    if typeInfo then
        draw.DrawText(typeInfo.name,"H.25",w / 2,h / 5,cblue,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    if lply.roleT then
        if roundType == 4 then
            draw.DrawText("Wild West: У вас револьвер R8 и скрытное оружие. Убейте всех!","H.25",w / 2,h / 1.2,cred,TEXT_ALIGN_CENTER)
        else
            draw.DrawText(L("homicide_loadscreen_roleT"),"H.25",w / 2,h / 1.2,cred,TEXT_ALIGN_CENTER)
        end
    elseif lply.roleCT then
        if roundType == 4 then
            draw.DrawText("Wild West: У вас есть револьвер R8, нейтрализуйте предателя!","H.25",w / 2,h / 1.2,cblue,TEXT_ALIGN_CENTER)
        else
            draw.DrawText(L("homicide_loadscreen_roleCT"),"H.25",w / 2,h / 1.2,cblue,TEXT_ALIGN_CENTER)
        end
    else
        draw.DrawText(L("homicide_loadscreen"),"H.25",w / 2,h / 1.2,cgray,TEXT_ALIGN_CENTER)
    end
end

local colorRed = Color(255,0,0)

function Level:HUDPaint(k)
    local lply = LocalPlayer()
    local name,color = self:GetTeamName(lply)

    self:DrawLoadScreen()
    self:DrawCenter()
  
    if roundTimeStart and roundTime then
        local time = math.Round(roundTimeStart + roundTime - CurTime())
        if time > 0 then
            local acurcetime = string.FormattedTime(time,"%02i:%02i")
            acurcetime = L("police_come",acurcetime)

            draw.SimpleText(acurcetime,"H.18",ScrW() / 2,ScrH() - 25,showRoundInfoColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end
    end

    local lply_pos = lply:GetPos()
    local isTraitor = lply.roleT
    local isSpectator = lply:Team() == 1002 or not lply:Alive()

    -- Teammate display: strictly for traitors seeing fellow traitors (hidden for innocents)
    if isTraitor or isSpectator then
        for i,ply in pairs(player.GetAll()) do
            if ply == lply or not ply:Alive() then continue end
            if isTraitor and not ply.roleT then continue end

            local color = ply.roleT and self.ColorRed or (isSpectator and ply.roleCT and self.ColorBlue)
            if not color then continue end

            local pos = ply:GetPos()
            local dis = lply_pos:Distance(pos)

            local k = math.max(1 - dis / 800,0)

            local scrPos = pos:ToScreen()
            if not scrPos.visible then continue end
            
            if Vector(scrPos.x,scrPos.y,0):Distance(Vector(ScrW()/2,ScrH()/2,0)) <= 128 / math.max(dis / 512,1) and util.VisibleEntity(EyePos(),ply,LocalPlayer()) then k = 1 end

            color = color:Clone()
            color.a = 255 * k

            draw.SimpleText(ply:Nick(),"H.18",scrPos.x,scrPos.y,color,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end
    end

    if not lply.roleT or (lply:Alive() and lply:GetNWBool("Otrub")) then return end

    local trace = lply:EyeTrace(PlayerDis)
    local ent = trace.Entity
    
    if IsValid(ent) and ent:GetNWBool("Poison") then
        local pos = ent:GetPos():Add(ent:OBBCenter()):ToScreen()

        draw.SimpleText(L("object_is_poison"),"HS.12",pos.x,pos.y,colorRed,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    self:DrawTTTButtons()
    self:DrawScan()
end

function Level:VBWHide(ply,list)
    if ply:Team() == 1002 then return end

    local blad = {}

    for i = 1,#list do
        local wep = list[i]
        if wep.itemType == "weaponSecondary" then continue end

        blad[#blad + 1] = wep
    end--ufff

    return blad
end

function Level:Scoreboard_DrawLast(ply)
    if LocalPlayer():Team() ~= 1002 and LocalPlayer():Alive() then return false end
end

function Level:End() self:StartWinnerVGUI(roundDataEnd and roundDataEnd.winnerVGUI) end
