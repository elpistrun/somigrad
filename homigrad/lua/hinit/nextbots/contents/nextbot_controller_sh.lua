--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/nextbots/contents/nextbot_controller_sh.lua <
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

-- "addons\\homigrad\\lua\\hinit\\nextbots\\contents\\nextbot_controller_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local CLASS = player.RegClass("nextbot_controller")
if not CLASS then return end

function CLASS:Off()
    if CLIENT then return end

end

function CLASS:On()
    if CLIENT then return end

    self:KillSilent()
    self:SetNWEntity("Controll",NULL)
end

if SERVER then
    util.AddNetworkString("nextbot_controller")
    
    net.Receive("nextbot_controller",function(len,ply)
        ply:PlayerClassEvent("SetControll",net.ReadEntity())
    end)

    function CLASS:SetControll(ent)
        local old = self:GetNWEntity("Controll")
        if IsValid(old) then
            old:SetNWEntity("Controller",NULL)
        end

        self:SetNWEntity("Controll",ent or NULL)
        if IsValid(ent) then ent:SetNWEntity("Controller",self) end
    end

    function CLASS:Think()
        local ent = self:GetNWEntity("Controll")

        if not IsValid(ent) then return end
    end
end

local tr = {
    mask = MASK_SHOT
}

local function getControll(ply)
    if ply.PlayerClassName ~= "nextbot_controller" then return end
    local ent = ply:GetNWEntity("Controll")
    return IsValid(ent) and ent
end

local wheel2 = 125

event.Add("PreCalcView","Nextbot Controller",function(ply,view)
    local ent = getControll(ply)
    if not ent then return end
    
    wheel2 = math.max(wheel2 - wheel * 25,0)

    tr.start = ent:GetPos()
    tr.endpos = tr.start:Clone():Sub(view.ang:Forward():Mul(wheel2)):Add(Vector(0,0,ent.SpriteSize / 2))
    tr.filter = ent

    view.vec = util.TraceLine(tr).HitPos

    return view
end,-21)

event.Add("Move","NextBot Controller",function(ply,mv)
    local ent = getControll(ply)
    if not ent then return end

    local move = Vector()

	if mv:KeyDown(IN_FORWARD) then move:Add(Vector(1,0,0)) end
	if mv:KeyDown(IN_BACK) then move:Add(Vector(-1,0,0)) end
	if mv:KeyDown(IN_MOVERIGHT) then move:Add(Vector(0,-1,0)) end
	if mv:KeyDown(IN_MOVELEFT) then move:Add(Vector(0,1,0)) end

	move:Rotate(ply:EyeAngles())

	mv:SetOrigin(ent:GetPos())

    if SERVER then
        ent.ControllMove = move:Mul(1024)

        if mv:KeyDown(IN_JUMP) then
            if not ent:AttemptJumpAtTarget() and ent:IsOnGround() then
                ent.loco:SetJumpHeight(1000)
                ent.loco:Jump()
                ent.loco:SetJumpHeight(300)
                ent.loco:SetGravity(1000)

                ent:EmitSound(ent.JumpSound,350,100)
            end
        end

        ent.SuppresControll = mv:KeyDown(IN_ATTACK)

        if mv:KeyDown(IN_RELOAD) then ent.GoAway = CurTime() + 1 end
    end

	return true
end,-1)

local yellow = Color(255,255,0)
local backup = 0

local black = Color(0,0,0,125)
local white = Color(255,255,255)

hook.Add("Lock R Spectate","Nextbot",function() return getControll(LocalPlayer()) end)

function CLASS:HUDPaint()
    local ply = LocalPlayer()
    local ent = self:GetNWEntity("Controll")

    IsSpectate = 3

    if SpecEnt then
        SpecEnt = nil
        RunConsoleCommand("hg_spectate")
    end

    local w,h = ScrW(),ScrH()

    local attack1 = ply:KeyDown(IN_ATTACK)

    if not IsValid(ent) then
        local tr = ply:EyeTrace()
        local pos = tr and tr.HitPos

        local close

        if pos then
            for ent in pairs(g_nextbots) do
                if not IsValid(ent) then g_nextbots[ent] = nil continue end

                if pos:Distance(ent:GetPos()) <= 200 and not IsValid(ent:GetNWEntity("Controller")) then close = ent break end
            end
        end

        if IsValid(close) then
            draw.SimpleText("На прицеле " .. tostring(close.PrintName) .. "!","H.18",w / 2,150,yellow,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

            if attack1 then
                net.Start("nextbot_controller")
                net.WriteEntity(close)
                net.SendToServer()
            end

        else
            draw.SimpleText("Наведись на того, кем ты бы хотел управлять.","H.18",w / 2,150,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end
    else
        if ply:KeyDown(IN_DUCK) then
            backup = backup + 1 * FrameTime()

            local k = math.Clamp(backup / 1,0,1)
            local size = w * 0.25

            draw.SimpleText("Выходим" .. string.rep(".",CurTime() % 3),"H.18",w / 2,h / 2 + 25,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            draw.RoundedBox(0,w / 2 - size / 2,h / 2 + 50,size,25,black)
            draw.RoundedBox(0,w / 2 - size / 2,h / 2 + 50,size * k,25,white)

            if k >= 1 then
                net.Start("nextbot_controller")
                net.SendToServer()
            end
        else
            backup = 0
        end

        draw.SimpleText(ent:GetNWString("State") == "GoAway" and "Ты прячишся" or attack1 and "Автоматическое управление" or "Ручное управление","H.18",w / 2,h - 100,attack1 and yellow or white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
end
