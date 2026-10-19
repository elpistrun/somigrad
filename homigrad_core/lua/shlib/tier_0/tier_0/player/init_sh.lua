--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_0/tier_0/player/init_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_0\\tier_0\\player\\init_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local CurTime,FrameTime = CurTime,FrameTime
local player_GetAll = player.GetAll
local event_Call = event.Call

local Time,Frame,i,tbl,ply

hook.Add("Think","!Think",function()
    event.Call("Think")
end)

event.Add("Think","Players",function()
    if CLIENT and not InitNET then return end--shut the fuck up
    
    Time,Frame = CurTime(),FrameTime()

    i = 0
    tbl = player_GetAll()

    ::loop::

    i = i + 1

    ply = tbl[i]
    if not ply then return end

    if ply.init then event_Call("Player Think",ply,Time,Frame) end

    goto loop
end,1)--dem

event.Add("Player Think","Time",function(ply,time,frame)
    if (ply.delay01 or 0) < time then
        ply.delay01 = time + 0.1

        event_Call("Player Think 0.1",ply,time,frame)
    end

    if (ply.delay025 or 0) < time then
        ply.delay025 = time + 0.25

        event_Call("Player Think 0.25",ply,time,frame)
    end

    if (ply.delay1 or 0) < time then
        ply.delay1 = time + 1

        event_Call("Player Think 1",ply,time,frame)
    end
end)

hook.Add("Move","SHLib",function(ply,mv)
    if not ply.init then return true end

    return event_Call("Move",ply,mv)
end)

hook.Add("SetupMove","SHLib",function(ply,mv,cmd)
    if not ply.init then return true end

    return event_Call("SetupMove",ply,mv,cmd)
end)

hook.Add("FinishMove","SHLib",function(ply,mv)
    if not ply.init then return true end

    return event_Call("FinishMove",ply,mv)
end)

hook.Add("PlayerFootstep","SHLib",function(ply,pos,foot,snd,volume,filter)
    if not ply:Alive() then return true end
    
    return event_Call("Footstep",ply,pos,foot,snd,volume,filter)
end)

hook.Add("OnPlayerHitGround","SHLib",function(...) return event_Call("Landing",...) end)
hook.Add("OnPlayerJump","SHLib",function(ply,speed) return event_Call("Jump",ply,speed) end)

event.Add("Player Spawn","RemoveDecals",function(ply)
	ply:RemoveAllDecals()--нихуя не работает ;c;c;c;;c;c;c
end)

NOTIFY_GENERIC = 0
NOTIFY_ERROR = 1
NOTIFY_UNDO = 2
NOTIFY_HINT = 3
NOTIFY_CLEANUP = 4--lmao

local PLAYER = FindMetaTable("Player")
if not HPlayerName then HPlayerName = PLAYER.Name end
function PLAYER:Name() return self:GetNWString("Nick",HPlayerName(self)) end
PLAYER.Nick = PLAYER.Name

if not HPlayerAlive then HPlayerAlive = PLAYER.Alive end
function PLAYER:Alive()
    if not IsValid(self) then return false end
    if self.isDead or self:GetNWBool("isDead",false) or self:GetNWBool("FakeDeath",false) then
        return false
    end
    if self:Health() <= 0 then
        return false
    end
    if not self:GetNWBool("Alive",true) then
        return false
    end
    if HPlayerAlive then
        local ok,res = pcall(HPlayerAlive,self)
        if ok and res == false then return false end
    end
    return true
end

local skip = {}

gameevent.Listen("player_connect")
hook.Add("player_connect","!SHLIB",function(data)
    local result = event.Call("player_connect",data)

    if result == false then
        skip[data.userid] = true
    end
end)

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect","!SHLIB",function(data)
    local ply = Player(data.userid)
    if IsValid(ply) then event.Call("Player Leave",ply) end

    if skip[data.userid] then
        skip[data.userid] = nil
        return
    end
    
    return event.Call("player_disconnect",data)
end)

//

local PLAYER = FindMetaTable("Player")//fucking stupid bot rubat pidoras

if not HSteamID then HSteamID = PLAYER.SteamID end
if not HSteamID64 then HSteamID64 = PLAYER.SteamID64 end


function PLAYER:SteamID() return self:IsBot() and "STEAM_0:0:" .. self:UserID() or HSteamID(self) end
function PLAYER:SteamID64() return self:IsBot() and util.SteamIDTo64("STEAM_0:0:" .. self:UserID()) or HSteamID64(self) end
