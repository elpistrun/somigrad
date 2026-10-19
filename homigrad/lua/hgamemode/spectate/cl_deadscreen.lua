--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/spectate/cl_deadscreen.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\spectate\\cl_deadscreen.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local deathData = false

local lifeTime = RealTime()

event.Add("Player Spawn","Death Screen",function(ply)
    if ply ~= LocalPlayer() then return end

    lifeTime = RealTime()

    deathData = false
end)

local function startDeathScreen(data)
    deathData = data

    deathData.start = RealTime()
    deathData.type = data.type or "default"
    deathData.delay = data.delay or 4

    deathData.shake = 1
    deathData.shakeX = 0
    deathData.shakeY = 0
    deathData.randomX = math.Rand(-1,1)
    deathData.randomY = math.Rand(-1,1)

    deathData.lifeTime = RealTime() - lifeTime

    if LocalPlayer():IsOnGround() then
        deathData.look = EyePos()
    end

    deathData.startPos = EyePos()
    deathData.startAng = EyeAngles()

    surface.PlaySound("homigrad/vgui/csgo_ui_crate_open.wav")

    if deathData.type == "headshoot" then
        deathData.shake = deathData.shake * 4
        
        for i = 1,3 do LocalPlayer():EmitSound("homigrad/headshoot.wav") end
    end
end

local function deathScreenActive()
    if not deathData then return false end

    local k = (deathData.start + deathData.delay - RealTime()) / deathData.delay

    return math.Clamp(k,0,1)
end

local vecZero = Vector(0.01,0.01,0.01)

local setAng = Angle()

event.Add("PreCalcView","Death Screen",function(ply,view)
    local time = RealTime()

    local k = deathScreenActive()
    if not k then return end

    local ent = ply:GetEntity()

    if not ply:Alive() then//lol??
        if deathData.ragdollEntIndex and deathData.ragdollEntIndex > 0 then
            ent = Entity(deathData.ragdollEntIndex)
        else
            ent = nil
        end
    end

    if not IsValid(ent) then
        ent = ply:GetNWEntity("FakeRagdoll")
        if not IsValid(ent) then ent = ply:GetNWEntity("DeathRagdoll") end
        if not IsValid(ent) then ent = ply:GetRagdollEntity() end
    end

    view.vec = deathData.startPos:Clone()
    view.ang = deathData.startAng:Clone()

    if IsValid(ent) then
        local head = ent:LookupBone("ValveBiped.Bip01_Head1")

        if head then
            ent:SetHeadScale(true)

            local matrix = ent:GetBoneMatrix(head)

            if matrix then
                view.vec = matrix:GetTranslation()
                view.ang = matrix:GetAngles()

                view.ang:RotateAroundAxis(view.ang:Up(),90)
                view.ang:RotateAroundAxis(view.ang:Right(),180)
                view.ang:RotateAroundAxis(view.ang:Forward(),90)
            end
        end
    end

    
    deathData.shakeX = math.Rand(-1,1) * deathData.shake
    deathData.shakeY = math.Rand(-1,1) * deathData.shake

    view.ang:Rotate(Angle(deathData.shakeY,deathData.shakeX,math.Rand(-0.5,0.5)):Mul(deathData.shake * 20))
    view.ang:Add(Angle(deathData.randomY,deathData.randomX,0):Mul(15))

    deathData.shake = LerpFT(0.075,deathData.shake,0)

    if deathData.look then
        //view.ang:Lerp((1 - k) * 0.5,(deathData.look - view.pos):Angle())
    end

    SpectateVec = view.vec
    
    setAng = view.ang

    return view
end,-2)

hook.Add("CreateMove","Death Screen",function(cmd)
    if not deathScreenActive() then return end

    if deathData.start - RealTime() + 3 <= 0 and cmd:GetButtons() > 0 then
        deathData = nil
    end
    
    cmd:ClearButtons()
    cmd:ClearMovement()

    cmd:SetViewAngles(Angle(setAng[1],setAng[2],0))//никогда не задавайте 3 значение блядь

    return false
end)

event.Add("Screen Size","Death Screen Fonts",function(mul)
	surface.CreateFont("Death75",{
		font = "Arial",
		size = math.ceil(75 * mul),
		weight = 1100,
        blursize = 50
	})
end)

hook.Add("HUDPaint","Death Screen",function()
    local k = deathScreenActive()
    if not k then return end

    local k2 = k

    k = 1 - k
    k = math.min(k * 1,1)

    surface.SetDrawColor(0,0,0,255 * k)

    local size = ScrH() * k

    local w,h = ScrW(),ScrH()
    
    draw.GradientUp(0,0,w,size)
    draw.GradientUp(0,0,w,size)
    draw.GradientDown(0,w - size,w,size + 1)

    surface.SetDrawColor(0,0,0,200 * k)
    surface.DrawRect(0,0,w,h)

    surface.SetDrawColor(0,0,0,255 * k)
    surface.SetBG("points50")
    draw.BG2(0,0,w,h)

    draw.SimpleText(L("death"),"Death75",w / 2 - deathData.shakeX * 6 * (w * 0.05),h / 2 - deathData.shakeY * 6 * (h * 0.05) + 15 * ScreenSize,Color(255,255,255,25),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    draw.SimpleText(L("death"),"HS.45",w / 2 - deathData.shakeX * 6 * (w * 0.05),h / 2 - deathData.shakeY * 6 * (h * 0.05),nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

    surface.SetAlphaMultiplier(math.ease.InOutCubic(math.min(k,1)))

    local time = math.floor(deathData.lifeTime)

    if time < 60 then
        time = L("death_second",time)
    elseif time < 60 * 60 then
        time = L("death_minutes_seconds",math.floor(time / 60),time % 60)
    else
        time = L("death_hour_minutes_seconds",math.floor(time / 60 / 60),math.floor((time / 60) % 60),time % 60)
    end
    
    draw.SimpleText(L("death_lifetime",time),"HS.25",w / 2 - deathData.shakeX * (w * 0.05),h / 2 - deathData.shakeY * (h * 0.05) + h * 0.25,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

    if k == 1 then
        draw.SimpleText(L("death_canrespawn"),"HS.25",w / 2 - deathData.shakeX * (w * 0.05),h / 2 - deathData.shakeY * (h * 0.05) + h * (0.25 + 0.25 / 2),nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    if deathData.mainReasonDeath then
        draw.SimpleText(deathData.mainReasonDeath,"HS.25",w / 2 - deathData.shakeX * (w * 0.05),h / 2 - deathData.shakeY * (h * 0.05) - h * 0.25,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    if deathData.distance then
        draw.SimpleText(L("death_distance",math.floor(deathData.distance)),"HS.18",w / 2 - deathData.shakeX * (w * 0.05),h / 2 - deathData.shakeY * (h * 0.05) - h * 0.25 + 30 * ScreenSize,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    if deathData.reasons then
        local y = 0

        for reason in pairs(deathData.reasons) do
            if reason ~= "unkown" and reason ~= "brokenneck" and reason ~= "impulse" then
                draw.SimpleText(L("deadreason_" .. reason),"HS.18",w * 0.05 - deathData.shakeX * (w * 0.05),h / 2 - deathData.shakeY * (h * 0.05) - h * 0.25 + y,nil,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

                y = y + 25 * ScreenSize
            end
        end
    end

    surface.SetAlphaMultiplier(1)

    surface.SetDrawColor(0,0,0,15 * k)
    surface.SetBG("points50")
    draw.BG2(0,0,w,h)
end)

concommand.Add("TEStdead",function()
    startDeathScreen({
        type = "headshoot",
        lifeTime = 42,
        mainReasonDeath = "Тестовая смерть",
        reasons = { head = true, headExplode = true }
    })
end)

concommand.Add("testdead",function()
    startDeathScreen({
        type = "default",
        lifeTime = 42,
        mainReasonDeath = "Тестовая смерть",
        reasons = {}
    })
end)

event.Add("Player Death","Death Screen",function(ply,dmgTab)
    if ply ~= LocalPlayer() then return end

    local type = "default"

    if dmgTab.reasons and (dmgTab.reasons["head"] or dmgTab.reasons["headExplode"]) then
        type = "headshoot"
    end

    local boneName = ""
    if dmgTab.boneName then
        boneName = " " .. L("in") .. " " .. L("in_" .. dmgTab.boneName)
    end

    local wepName = ""
    if dmgTab.wepName then
        wepName = " " .. L("kill_by_wep") .. " " .. dmgTab.wepName
    end

    local mainReasonDeath = ""
    local killerName = dmgTab.killedTargetName or (IsValid(dmgTab.killedTarget) and dmgTab.killedTarget:IsPlayer() and dmgTab.killedTarget:Name()) or (IsValid(dmgTab.att) and dmgTab.att:IsPlayer() and dmgTab.att:Name()) or "Unknown"

    if dmgTab.killedBy == "player" then
        mainReasonDeath = L("by_kill") .. " " .. killerName .. boneName .. wepName
    elseif dmgTab.killedBy == "npc" then
        mainReasonDeath = L("by_kill_npc") .. " " .. (dmgTab.killedTargetName or dmgTab.killedTarget or "NPC") .. boneName .. wepName
    elseif dmgTab.killedBy == "object" then
        mainReasonDeath = L("by_kill_object") .. " " .. (dmgTab.killedTargetName or dmgTab.killedTarget or "Object") .. boneName .. wepName
    end
    
    startDeathScreen({
        type = type,
        ragdollEntIndex = dmgTab.ragEntIndex,
        mainReasonDeath = mainReasonDeath,
        reasons = dmgTab.reasons,
        distance = dmgTab.distance
    })
end)

