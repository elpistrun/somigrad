--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/levels/_special/event/tier_1_system/panel/nav/1teams_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
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

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\levels\\_special\\event\\tier_1_system\\panel\\nav\\1teams_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
EventPanel_Pages[1] = {}
local Panel = EventPanel_Pages[1]
Panel.Name = "event_team"

local function sendCmd(args)
    net.Start("event_team")
    net.WriteTable(args)
    net.SendToServer()
end

function Panel.Create(frame)
    local playerInTeam = oop.CreatePanel("v_players",frame):ad(function(self,w,h) self:setSize(w * 0.5 - 30,h - 90):setPos(30,60) end)
    playerInTeam:CreateVBar()
    playerInTeam:Setup(64)

    function playerInTeam:OnClick(key,info)
        sendCmd({"remove",info.id})
    end

    local players = oop.CreatePanel("v_players",frame):ad(function(self,w,h) self:setSize(w * 0.5 - 30,h - 90):setPos(w * 0.5,60) end)
    players:CreateVBar()
    players:Setup(64)
    
    function players:OnClick(key,info)
        sendCmd({"add",info.id})
    end

    function players:DrawPanel(w,h,panel,info)
        local ply = player.GetBySteamID(info.id)
        if not IsValid(ply) then return end//не ебёт

        ScoreboardDrawPlayer(ply,w,h,{dontDrawMute = true,dontDrawTime = true,dontDrawPing = true,dontDrawTeam = true,dontDrawAlive = true})
    end

    function playerInTeam:DrawPanel(w,h,panel,info)
        local ply = player.GetBySteamID(info.id)
        if not IsValid(ply) then return end

        ScoreboardDrawPlayer(ply,w,h,{dontDrawMute = true,dontDrawTime = true,dontDrawPing = true,dontDrawTeam = true,dontDrawAlive = true})
    end

    function frame:Update()
        playerInTeam:Clear()
        players:Clear()

        if not Event_Claimed or not Event_Claimed.owner then return end
        local owner = Event_Claimed.owner

        for i,ply in pairs(player.GetAll()) do
            if owner.steamid == ply:SteamID() or (Event_Claimed.friends and Event_Claimed.friends[ply:SteamID()]) then continue end
            
            players:AddPlayer(ply)
        end

        playerInTeam:AddPanel(owner.steamid,owner.name,owner.avatar,owner.avatarFrame,owner.background)

        for steamid,info in pairs(Event_Claimed.friends or {}) do
            playerInTeam:AddPanel(steamid,info.name,info.avatar,info.avatarFrame,info.background)
        end
    end

    frame:Update()

    function frame:Draw(w,h)
        draw.SimpleText(L("event_you_team"),"HS.25",playerInTeam.x + playerInTeam:W() / 2,30,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        draw.SimpleText(L("event_players"),"HS.25",players.x + players:W() / 2,30,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
end

event.Add("Event Claimed Info Updated","Team",function()
    EventPanel_Update(1)
end)
