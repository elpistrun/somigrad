--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/levels/_special/construct/init_tier_0_sh.lua <
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

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\levels\\_special\\construct\\init_tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Level = oop.Reg("level_construct","level_base",true)
if not Level then return INCLUDE_BREAK end

AdminPanel_Command_Registry("c_save",{},nil,nil,"rcon")
AdminPanel_Command_Registry("c_wipe",{},nil,nil,"rcon")
AdminPanel_Command_Registry("c_ignoreq",{"players^","bool"},nil,nil,"rcon")

Level.CantRandom = true
function Level:CanRandomNext() return false end
function Level:RandomForce() return false end

function Level:PlayerModelApply() return true end

Level.JModNoTeams = true
Level.enableDamageSpawnEnt = true
Level.CanPlayerOne = true
Level.noTwo = true

Level.UseConstruct = true
Level.DisableGib = true
Level.DisableWH = true
Level.DisableCenter = true

Level.DelayDeadLootBox = 60
Level.RoundTime = 999999999999 * 60
Level.RespawnDelay = 10

CupboardDistance = 400

Level.red = {"Игрок",Color(75,175,255),
    models = Level.StandardPlayerModels
}

Level.teamEncoder = {
    [1] = "red"
}

function Level:GetTeamName(ply)
    if not IsValid(ply) then return "Игрок", Color(75,175,255) end
    if ply:Team() == 1002 then
        return "Наблюдатель", Color(150,150,150)
    end
    return "Игрок", Color(75,175,255)
end

Level.LoadScreenTime = 5

function Level:DrawScreen(lply,k)
    local name,color = self:GetTeamName(lply)
    local w,h = ScrW(),ScrH()
    draw.DrawText("Ты: " .. tostring(name),"H.25",w / 2,h / 2,cname,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    draw.DrawText("Construct","H.45",w / 2,h / 8,cblue,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    draw.DrawText("Строй свои базы и укрепления!","H.25",w / 2,h / 1.2,cgray,TEXT_ALIGN_CENTER)
end

if SERVER then
    function Level:CanUseContextMenu(ply) return ply:HasSuccess("construct_access") end

    function Level:Start()
        if Homigrad_ResetLighting then
            Homigrad_ResetLighting()
        end
    end

    function Level:PlayerDeath(ply)
        ply:SetNWFloat("DeadStart", CurTime())
        ply:SetNWFloat("DeathStart", CurTime())
        local delay = self.RespawnDelay or 10
        ply:SetNWFloat("DeathWait", CurTime() + delay)
    end

    return
end

function Level:CanUseContextMenu() return true end

function Level:Sync(data)
    if data and data.roundTime then
        roundTime = data.roundTime
    end
end

local gray = Color(122,122,122,255)
local staticWhite = Color(255,255,255)
local white = Color(255,255,255)

function Level:DrawRoundTime(time)
    local mins = math.floor((time or 0) / 60)
    local secs = math.floor((time or 0) % 60)
    if secs < 10 then secs = "0" .. secs end
    draw.SimpleText(tostring(mins) .. ":" .. secs,"H.18",ScrW() / 2,ScrH() - 25,showRoundInfoColor or white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
end

function Level:HUDPaint(k)
    self:DrawLoadScreen()
    self:DrawRequestTeam()
    self:DrawTeams()

    local lply = LocalPlayer()

    local rt = roundTime or (999999999999 * 60)
    local rts = roundTimeStart or CurTime()
    local time = math.max(math.Round((rts + rt) - CurTime()), 0)

    self:DrawRoundTime(time)

    if lply:Team() == 1002 or lply:Alive() then return end

    local time = lply:GetNWFloat("DeathWait",0) - CurTime()

    /*if Construct.DisableSpectate(LocalPlayer()) then
        local k = math.Clamp(CurTime() - (DeathStartTime or 0),0,1)

        surface.SetDrawColor(0,0,0,250 * k)
        surface.DrawRect(0,0,ScrW(),ScrH())

        local dmgTab = DeathDmgTab

        if dmgTab then
            local att = dmgTab.att

            if IsValid(att) then
                local boneName = ""
            
                if dmgTab.bone and dmgTab.bone ~= 0 then
                    boneName = " в " .. tostring(ReasonsDeathBoneMsg[lply:GetBoneName(dmgTab.bone)])
                end

                draw.SimpleText("Тебя убил '" .. tostring(att) .. "'" .. boneName,"ChatFont",ScrW() / 2,75,staticWhite,TEXT_ALIGN_CENTER)
            end

            local wep = dmgTab.wep

            if IsValid(wep) and wep ~= att then
                draw.SimpleText("Из " .. (wep.PrintName or tostring(wep)),"ChatFont",ScrW() - 75,75,staticWhite,TEXT_ALIGN_RIGHT)
            end

            for i,reason in pairs(dmgTab.reasons) do
                draw.SimpleText(ReasonsDeathMsg[reason] or reason,"ChatFont",75,75 + 25 * i,staticWhite)
            end
        end
    end*/

    if CLIENT then
        local function CreateConstructRespawnFont(mul)
            mul = mul or ScreenSize or 1
            surface.CreateFont("ConstructRespawnFont", {
                font = "Arial",
                size = math.max(12, math.Round(25 * 0.75 * mul)),
                weight = 3000,
                bold = true
            })
        end
        CreateConstructRespawnFont()
        event.Add("Screen Size", "ConstructRespawnFont_Init", CreateConstructRespawnFont)
    end

    if GetGlobalVar("StopGame") then return end
    
    if time > 0 then
        draw.SimpleText(L("spawn_from_second",math.max(math.ceil(time), 1)),"ConstructRespawnFont",ScrW() / 2,ScrH() / 2 - 200,staticWhite,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    elseif not IsValid(lply:GetNWEntity("HeSpectateOn")) or IsSpectate == 2 then
        local wantSpawn = input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT) or lply:KeyDown(IN_ATTACK) or lply:KeyDown(IN_ATTACK2)
        if wantSpawn and (lply.nextConstructRespawnNet or 0) < CurTime() then
            lply.nextConstructRespawnNet = CurTime() + 1
            net.Start("Construct respawn")
            net.SendToServer()
        end

        draw.SimpleText(L("click_for_spawn"),"ConstructRespawnFont",ScrW() / 2,ScrH() / 2 - 200,staticWhite,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
end

function Level:PaintContentIcon(self,w,h)
    if LocalPlayer():GetNWBool("IgnoreQ") or self.ValidList[self:GetSpawnName()] then return end

    surface.SetDrawColor(0,0,0,125)
    surface.DrawRect(4,4,w - 8,h - 8)
end

net.Receive("Construct global chat",function()
    local ply = net.ReadEntity()
    local text = net.ReadString()

    chat.AddText(Color(255,125,0),"[//] ",Color(255,255,255),ply:Nick(),": " ..text)
end)

net.Receive("Construct team chat",function()
    local ply = net.ReadEntity()
    local text = net.ReadString()

    chat.AddText(Color(0,255,0),"[**] ",Color(255,255,255),ply:Nick(),": " ..text)
end)

local vecZero = Vector(0.01,0.01,0.01)

Level.DisableSpectate = function(ply,view)
    /*if roundTime <= CurTime() or GetGlobalBool("Stopgame") or not GetGlobalBool("DisableSpectate") or ply:Team() == 1002 then return false end

    if not view then return true end

    local rag = ply:GetNWEntity("RagdollDeath")
    if not IsValid(rag) then return end

    local headBone = rag:LookupBone("ValveBiped.Bip01_Head1")
    local head = headBone and rag:GetBoneMatrix(headBone)

    if head then
        view.vec = head:GetTranslation()
        local ang = head:GetAngles()
        ang:Add(Angle(0,0,-90))

        view.vec:Add(Vector(2.5,0,-3):Rotate(ang))
        rag:ManipulateBoneScale(headBone,vecZero)

        view.ang = ang
    else

    end--wtf?*/

    return false
end

