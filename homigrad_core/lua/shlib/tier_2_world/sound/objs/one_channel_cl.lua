--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_2_world/sound/objs/one_channel_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_2_world\\sound\\objs\\one_channel_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local OBJ = oop.Reg("sound_onechannel","lib_event")
if not OBJ then return end

local hg_sound_dsp_change
cvars.CreateOption("hg_sound_dsp_change","1",function(value)
    hg_sound_dsp_change = tonumber(value or 0) > 0

    if not util.Is64Bit() and hg_sound_dsp_change ~= 0 then RunConsoleCommand("hg_sound_dsp_change","0") end
end,0,1)

local list = sound.listPoint

OBJ:Event_Add("Construct","Objects",function(class)
    for id,point in pairs(list) do
        for k,v in pairs(class[1]) do point[k] = v end
    end
end)

function OBJ:IsValid() return not self.remove end
function OBJ:IsPlaying() return self.snd and self.snd:IsPlaying() end

function OBJ:Stop()
    self.stop = true
    self:StopSND()
end

function OBJ:Play()
    self.stop = nil

    local time = RealTime()

    if self.deleteTime and self.deleteTime < time then
        self:Remove()

        return
    end

    if self.restartTime and (self.start or 0) < time then
        self.start = time + self.restartTime

        self:PlaySND()

        return true
    end

    if not self:IsPlaying() then self:PlaySND() return true end
end

function OBJ:StopSND()
    if self.snd then
        self.snd:Stop()
        self.snd = nil
    end

    if self.model then
        if IsValid(self.model) then self.model:Remove() end
        self.model = nil
    end
end

local SysTime = SysTime

function OBJ:SetParent(value)
    if IsValid(self.parent) then self.parent:RemoveCallOnRemove("stopSND_onechannel" .. self.id) end

    self.parent = value

    if self.parent then
        self.parent:CallOnRemove("stopSND_onechannel" .. self.id,Stop,self)

        self.model:SetPos(self.parent:GetPos() + self.parent:OBBCenter())
        self.model:SetParent(self.parent)
    else
        if IsValid(self.model) then self.model:SetParent(NULL) end
    end
end

function OBJ:PlaySND()
    self:StopSND()

    self.playStart = RealTime()

    local model = ClientsideModel("models/hunter/plates/plate.mdl")
    self.model = model
    model:SetNoDraw(true)

    if self.parent then
        model:SetPos(self.parent:GetPos() + self.parent:OBBCenter())
        model:SetParent(self.parent)
    end

    local snd = CreateSound(self.model,self.sndPath)
    self.snd = snd
    self.oldDSP = nil
    snd:SetSoundLevel(self.level)
    snd:PlayEx(0,100)

    self:Think(EyePos())
end

function OBJ:Remove()
    if self.remove then return end

    self:Stop()
    self.remove = true
    
    list[self.id] = nil
end

local developer = GetConVar("developer")
local clamp = math.Clamp

local white = Color(255,255,255,0)

function OBJ:Think(eyePos)
    local pos
    local parent = self.parent

    if not IsValid(parent) then self:Remove() return end
    if self.stop then return end
  
    self:Play()

    if not IsValid(self) then return end--ufff

    pos = (self.pos and self.pos:Clone()) or (parent:GetPos():Add(parent:OBBCenter()))
    self._pos = pos

    if hg_sound_dsp_change then
        if (self.delayTrace or 0) < CurTime() then
            self.delayTrace = CurTime() + 0.25

            local func = self.CalculateDSP

            local filter = self.filter
            filter[parent] = true

            if func then
                self.dsp = func(self,pos,filter)
            else
                local pen = sound.Trace(pos,1024,16,filter)

                if pen <= 0.025 then
                    self.dsp = 0
                else
                    self.dsp = 14
                end
            end
        end

        if not self.dsp then
            self.volumeTrue = 0

            self:Apply()

            return
        end
    end

    local disFadeout = self.disFadeout

    if disFadeout == -1 then
        self.volumeTrue = self.volume
    else
        local dir = (eyePos - pos)

        local dis = dir:Length()
        local disEnd = self.dis

        local k = 1 - clamp(dis / disEnd,0,1)

        local disK = self.disK

        if k < disK then
            k = k / disK

            self.volumeTrue = k * self.volume
            dis = dis - disFadeout * (1 - k)
        else
            self.volumeTrue = self.volume
        end

        dir:Normalize()
        dir:Mul(dis)

        pos:Add(dir)
    end

    if self.fadeStart then
        local k = (self.fadeStart + self.fadeDelay - SysTime()) / self.fadeDelay

        self.volumeTrue = self.volumeTrue * k
        
        if k <= 0 then
            self.remove = nil
            self:Remove()

            return
        end
    end

    self:Apply()
end

local random = math.random

function OBJ:Apply()
    local snd = self.snd

    self.model:SetPos(self._pos)

    local snd = self.snd
    
    if hg_sound_dsp_change and self.dsp ~= self.oldDSP then
        self.oldDSP = self.dsp

        snd:SetDSP(self.dsp)
    end

    snd:ChangePitch(self.pitch * 100,0)
    snd:ChangeVolume(self.volumeTrue)
end

function OBJ:FadeOut(value)
    self.remove = true

    self.fadeStart = SysTime()
    self.fadeDelay = value
end
