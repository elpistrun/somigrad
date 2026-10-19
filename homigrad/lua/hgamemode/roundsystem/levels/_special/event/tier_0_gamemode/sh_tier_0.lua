--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/levels/_special/event/tier_0_gamemode/sh_tier_0.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
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

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\levels\\_special\\event\\tier_0_gamemode\\sh_tier_0.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Level = oop.Reg("level_event","level_base",true)
if not Level then return INCLUDE_BREAK end

Level.CantRandom = true
function Level:CanRandomNext() return false end

Level.teamEncoder = {
    [1] = "red"
}

Level.red = {"Игрок",Color(75,175,255),
    models = Level.StandardPlayerModels
}

function Level:GetTeamName(ply)
    if not IsValid(ply) then return "Игрок", Color(75,175,255) end
    if ply:Team() == 1002 then
        return "Наблюдатель", SpectatorGray or Color(150,150,150)
    end
    local eventGroup = ply.eventGroup
    if eventGroup and eventGroup.name then
        return eventGroup.name, eventGroup.color or Color(75,175,255)
    end
    return "Игрок", Color(75,175,255)
end

Level.LoadScreenTime = 5

function Level:DrawScreen(lply,k)
    local name,color = self:GetTeamName(lply)
    local w,h = ScrW(),ScrH()
    draw.DrawText("Ты: " .. tostring(name),"H.25",w / 2,h / 2,cname,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    draw.DrawText("Event","H.45",w / 2,h / 8,cblue,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    draw.DrawText("Слушай указания ведущего события!","H.25",w / 2,h / 1.2,cgray,TEXT_ALIGN_CENTER)
end

function Level:CanUseContextMenu(ply) return Event_CanAccess(ply,EventCanHelpHiredAdmins) end
function Level:CanUseSpawnMenu(ply) return Event_CanAccess(ply,EventCanHelpHiredAdmins) end

if SERVER then return end

function Level:HUDPaint(white2)
    self:DrawLoadScreen()
    self:HUDCursor()

    local lply = LocalPlayer()
    if IsValid(lply) and lply:Alive() and lply:Team() ~= 1002 then
        local tName, tColor = self:GetTeamName(lply)
        draw.SimpleText("Группа: " .. tostring(tName),"HS.18",25,ScrH() - 30,tColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_BOTTOM)
    end

    if not LocalPlayer():Alive() then
        local group = LocalPlayer().eventGroup

        if IsSpectate == 1 and group and group.spawnTime >= 0 then
            local time = math.floor(LocalPlayer():GetNWFloat("DeathStart",0) + group.spawnTime - CurTime())
            
            local text

            if time < 0 then
                text = L("click_for_spawn")

                if input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT) then
                    net.Start("event_respawn")
                    net.SendToServer()
                end
            else
                text = L("spawn_from_second",time)
            end

            draw.SimpleText(text,"HS.18",ScrW() / 2,ScrH() * 0.25,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end
    end
end

local empty = {}

function Level:ScoreboardSort(sort,teams)
    local SORT = {}

    local players = player.GetAll()

    for id,group in pairs(EventGroups or empty) do
        for i,ply in pairs(players) do
            if not group.list[ply:SteamID()] then continue end

            SORT[id] = SORT[id] or {
                alive = {},
                dead = {}
            }
            
            local tbl = SORT[id][ply:Alive() and "alive" or "dead"]
            tbl[#tbl + 1] = ply

            players[i] = nil
        end
    end

    SORT[#SORT + 1] = {
        alive = {},
        dead = {}
    }

    local lastSort = SORT[#SORT]

    for i,ply in pairs(players) do
        local tbl = lastSort[ply:Alive() and "alive" or "dead"]
        tbl[#tbl + 1] = ply
    end

    for _,list in pairs(SORT) do
        for i,ply in pairs(list.alive) do sort[#sort + 1] = ply end
        for i,ply in pairs(list.dead) do sort[#sort + 1] = ply end
    end
end
