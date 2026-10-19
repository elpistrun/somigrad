--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_2_world/sound/sound_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_2_world\\sound\\sound_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
FilterSND = {}
FilterFunctionSND = function(ent) return not (ent:IsPlayer() or ent:IsRagdoll() or FilterSND[ent] or GetViewEntity() == ent) end

local listSnd = {}

clientSoundEmiters = clientSoundEmiters or {}

local hg_sound_dsp
cvars.CreateOption("hg_sound_dsp","1",function(value)
    hg_sound_dsp = tonumber(value or 0) > 0

    if not util.Is64Bit() and hg_sound_dsp ~= 0 then RunConsoleCommand("hg_sound_dsp","0") end
end,0,1)

local vecZero = Vector()
local max,min = math.max,math.min

local IsValid = IsValid
local table_remove = table.remove
local tonumber,TypeID,TYPE_STRING = tonumber,TypeID,TYPE_STRING
local timer_Simple,SoundDuration = timer.Simple,SoundDuration

soundEmitters = soundEmitters or {}
local soundEmitters = soundEmitters

function sound.CreateEmit(pos)
    local ent = ClientsideModel("models/hunter/plates/plate.mdl")
    ent:SetNoDraw(true)

    soundEmitters[ent] = RealTime() + 5

    if pos then ent:SetPos(pos) end
    
    return ent
end

function sound.TimeoutEmit(ent)
    soundEmitters[ent] = RealTime() + 5
end

soundVirtualEntities = soundVirtualEntities or {}
local soundVirtualEntities = soundVirtualEntities

function sound.GetEmitEntity(entIndex)
    ent = soundVirtualEntities[entIndex]

    if not IsValid(ent) then
        ent = sound.CreateEmit()
        ent.virtual = true

        soundVirtualEntities[entIndex] = ent
    end

    soundEmitters[ent] = RealTime() + 5//убирает таймер до удаления объект

    return ent
end

hook.Add("Think","SoundEmitters",function()
    local time = RealTime()

    for ent,t in pairs(soundEmitters) do
        if not IsValid(ent) then soundEmitters[ent] = nil continue end

        if time > t then soundEmitters[ent] = nil ent:Remove() end
    end
end)//саси хуй рубат и source

local CreateEmit = sound.CreateEmit

local skipsnd = 4

soundEmittersList = {}
local soundEmittersList = soundEmittersList

function SoundEmit(sndName,level,volume,pitch,pos,dsp,chan)//суть в том что-бы удалять старые звуки и давать проход новым, может быть минусом если в разных позициях произойдут события
    if istable(sndName) then sndName = sndName[math.random(#sndName)] end
    if not isstring(sndName) then return end

    local list = soundEmittersList[sndName]

    if not list then
        list = {}
        
        soundEmittersList[sndName] = list
    end

    local count = #list
    local firstEmit = list[1]

    if count >= skipsnd then
        if IsValid(firstEmit) then
            firstEmit:StopSound(sndName)
            firstEmit:Remove()
        end
        
        list[1] = nil

        local i = 1

        while i <= count do
            i = i + 1

            list[i - 1] = list[i]
        end
    end

    local ent = CreateEmit()
    ent:SetPos(pos,true)
    ent:EmitSound(sndName,level,pitch,volume,chan,SND_DO_NOT_OVERWRITE_EXISTING_ON_CHANNEL,dsp)

    list[#list + 1] = ent


    return ent
end

function SoundEmitEntity(ent,sndName,level,volume,pitch,pos,dsp,chan)
    if istable(sndName) then sndName = sndName[math.random(#sndName)] end
    if not isstring(sndName) then return end

    if not IsValid(ent) then
        if pos then SoundEmit(sndName,level,volume,pitch,pos,dsp,chan) end//4к нахуй g102

        return
    end

    ent:EmitSound(sndName,level,pitch,volume,chan,SND_DO_NOT_OVERWRITE_EXISTING_ON_CHANNEL,dsp)
end
// флаг SND_DO_NOT_OVERWRITE_EXISTING_ON_CHANNEL не робит кстате ваще, ток если это ui звуки.. рубат и сурс пидор, что и следоволо ожидать, что и в очередной раз подтверждает.

function sound.Emit(ent,sndName,level,volume,pitch,pos,dsp,filter,chan,src)
    if not InitNET then return end

    if istable(sndName) then sndName = sndName[math.random(#sndName)] end
    if not isstring(sndName) then return end

    pitch = pitch or 100
    volume = volume or 1
    chan = chan or CHAN_AUTO
    level = level or 75
    
    ent = TypeID(ent) == TYPE_NUMBER and Entity(ent) or ent
    
    pos = pos or ent:GetPos()
    local DSP

    if TypeID(dsp) == TYPE_STRING then
        DSP = DSP_LEVEL0
        dsp = tonumber(dsp)
    else
        if hg_sound_dsp then
            filter = filter or {}
            
            if TypeID(filter) == TYPE_ENTITY then filter = {[filter] = true} end//mdem

            if ent then filter[ent] = true end
            filter[GetViewEntity()] = true

            DSP = sound.GetDSP(pos,filter)
    
            if not DSP then
                if level >= 100 then DSP = DSP_LEVEL2 else return end
            end
    
            //if DSP ~= DSP_LEVEL0 then volume = volume / 3 end
        else
            DSP = DSP_LEVEL0
        end
    end

    dsp = DSP == DSP_LEVEL0 and dsp or DSP

    local cooldown = pos:Distance(EyePos()) * UNITS_TO_METERS / SOUNDSPEED

    if TypeID(ent) == TYPE_ENTITY then
        if cooldown < 0.1 then
            SoundEmitEntity(ent,sndName,level,volume,pitch,src or pos,dsp,chan)
        else
            timer.GameSimple(cooldown,SoundEmitEntity,ent,sndName,level,volume,pitch,src or pos,dsp,chan)
        end
    else
        if cooldown < 0.1 then
            SoundEmit(sndName,level,volume,pitch,src or pos,dsp,chan)
        else
            timer.GameSimple(cooldown,SoundEmit,sndName,level,volume,pitch,src or pos,dsp,chan)
        end
    end//THIS IS TOTALY CRING

    return ent
end

net.Receive("sound",function(packet)
    if not InitNET then return end
    
    local packet = net.ReadTable()

    local ent = packet[1]
    local pos = packet[6]

    if TypeID(ent) == TYPE_NUMBER then ent = Entity(ent) end

    if not ent or not IsValid(ent) then
        if not pos then return end//игра дерьмо
        
        ent = nil
    end

    sound.Emit(ent,packet[2],packet[3],packet[4],packet[5],pos,packet[7],packet[8],packet[9])
end)

function SurfaceSoundEmit(snd,volume,pitch)
    if istable(snd) then snd = snd[math.random(#snd)] end
    if not isstring(snd) then return end
    LocalPlayer():EmitSound(snd,75,pitch,volume)
end

net.Receive("sound surface",function()
    local snd,level,volume,pitch = net.ReadString(),tonumber(net.ReadString()),tonumber(net.ReadString()),tonumber(net.ReadString())
    if not isstring(snd) or snd == "" then return end
    LocalPlayer():EmitSound(snd,level,pitch,volume)
end)

/*hook.Add("HUDPaint","gg",function()
    if LocalPlayer():KeyDown(IN_ATTACK2) then 
        setPos = EyePos()
        setDir = setPos + EyeAngles():Forward() * 500
    end

    print(tracePenetrationToEndPos(setPos,setDir,LocalPlayer()))
end)*/

concommand.Add("hg_sound_clearsoundemiters",function()
    local count = 0

    for ent in pairs(clientSoundEmiters) do
        if IsValid(ent) then ent:Remove() count = count + 1 end

        clientSoundEmiters[ent] = nil--shut up
    end

    print(count)
end)

local oldDSP = 0
local delay = 0.1

hook.Add("Think","z_DSP",function()
    local time = RealTime()

    local dsp,fast = event.Call("DSP")

    if delay > RealTime() then return end

    if dsp ~= oldDSP then
        oldDSP = dsp

        LocalPlayer():SetDSP(dsp or 0,fast)
    end
end,2)

//

