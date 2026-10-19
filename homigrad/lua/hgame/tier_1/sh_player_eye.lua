--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/sh_player_eye.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\sh_player_eye.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local PLAYER = FindMetaTable("Player")

local vecZero,angZero = Vector(),Angle()

local FrameNumber = FrameNumber
local TraceLine,TraceHull = util.TraceLine,util.TraceHull
local abs,max,min = math.abs,math.max,math.min

local tr = {}

local size = Vector(8,8,0)

function PLAYER:EyeTraceNoWall(pos,filter,mask)
    local tr = {}
    tr.start = self:EyePos()
    local dir = (tr.start - pos):GetNormalized()

    tr.endpos = pos
    tr.filter = filter or self
    tr.mins = -size
    tr.maxs = size
    tr.mask = mask

    local result = TraceHull(tr)

    return vecZero + result.HitPos + result.HitNormal * 2,result.Hit
end

local validClass = {
    weapon_physgun = true,
    gmod_tool = true,
    gmod_camera = true,
    weapon_rpg = true,
    weapon_slam = true
}

if CLIENT then
    CreateClientConVar("hg_firstperson_body","1",true,false,"Draw player body in first person (1 = enabled, 0 = classic firstperson)")
end

function PLAYER:EyeMode()
    local mt = self:GetMoveType()
    if not self:Alive() or (((mt == MOVETYPE_NOCLIP or mt == MOVETYPE_OBSERVER or (self.GetNWBool and self:GetNWBool("noclip",false)) or (self.GetFlags and bit.band(self:GetFlags(),8) ~= 0)) and not IsValid(self:GetVehicle()))) then return true end

    if CLIENT then
        local cvar = GetConVar("hg_firstperson_body")
        if cvar and cvar:GetInt() == 0 then return true end
    end

    local wep = self:GetActiveWeapon()
    if IsValid(wep) then
        if wep.FirstView then return true end
        if validClass[wep:GetClass()] then return true end
        local hold = wep.GetHoldType and wep:GetHoldType()
        if hold == "rpg" or hold == "camera" then return true end
        --if string.sub(wep:GetClass(),1,5) == "arccw" then return true end
    end
    
    if not ActiveLevel then return end

    local func = ActiveLevel.EyeDefault
    if func then return func(ActiveLevel,self) end
end

EyeOffsetByModel = EyeOffsetByModel or {}

local hook_Run = hook.Run

local function proccess(self)
    local isVR = false//vrmod.IsPlayerInVR(self)

    if self:EyeMode() then
        if isVR then
            return vrmod.GetHMDPos(self),vrmod.GetHMDAng(self)
        end
        
        return self:EyePos(),self:EyeAngles()
    end

    local ent = self:GetNWEntity("Ragdoll")
    if not IsValid(ent) then ent = self:GetNWEntity("DeathRagdoll") end
    if not IsValid(ent) then ent = self:GetNWEntity("FakeRagdoll") end
    ent = IsValid(ent) and ent

    local ang = isVR and vrmod.GetHMDAng(self) or self:EyeAngles()
    local pos,hit

    local dontTraceWall

    local setting = EyeOffsetByModel[self:GetModel()] or {}

    if ent then
        local head = ent:LookupBone("ValveBiped.Bip01_Head1")
        head = head and ent:GetBoneMatrix(head)
  
        if head then
            local ang = head:GetAngles()

            pos = head:GetTranslation():Add((setting[2] or Vector(4,0,0)):Clone():Rotate(ang))

            dontTraceWall = true
        else
            return self:EyePos(),self:EyeAngles()
        end
    else
        eye = self:LookupAttachment("eyes")--xd
        eye = eye and self:GetAttachment(eye)

        if eye then
            local ang = eye.Ang

            pos = eye.Pos

            pos:Add((setting[1] or Vector(4,0,0)):Clone():Rotate(ang))
        else
            return self:EyePos(),self:EyeAngles()
        end
    end

    local filter = function(entHit) return entHit ~= self and entHit ~= ent and entHit:GetClass() ~= "prop_dynamic" end

    if not dontTraceWall then
        pos,hit = self:EyeTraceNoWall(pos,filter)
    end

    self.eyeTraceHit = hit

    tr.start = pos
    tr.endpos = pos + ang:Forward():Mul(32000)
    tr.filter = filter
    tr.mask = MASK_SOLID

    tr = TraceLine(tr)
    self.eyeTrace = tr
    self.eyeTraceDis = tr.HitPos:Distance(pos)

    if not isVR then ang[3] = 0 end

    return pos,ang
end

function PLAYER:Eye(forceSet)
    local wep = self:GetActiveWeapon()

    local frameNumber = FrameNumber()

    if not forceSet and self.eyeNumber == frameNumber then
        return self.eyePos:Clone(),self.eyeAng:Clone(),self.eyeTraceHit
    end

    self.eyeNumber = frameNumber

    local pos,ang = proccess(self)

    self.eyePos = pos
    self.eyeAng = ang

    event.Call("Eye Change",ply,pos,ang)

    return pos:Clone(),ang:Clone(),self.eyeTraceHit
end

local Copy = util.tableCopy

function PLAYER:EyeTrace(dis)
    local wep = self:GetActiveWeapon()

    if self:EyeMode() then
        local trace = self:GetEyeTrace()

        return not dis and trace or (trace.HitPos:Distance(self:EyePos()) <= dis and trace)
    end

    self:Eye()

    if dis and (self.eyeTraceDis or 0) > dis then return end

    local tbl = Copy(self.eyeTrace)
    if not tbl then return end
    
    tbl.HitPos = tbl.HitPos:Clone()
    tbl.HitNormal  = tbl.HitNormal:Clone()
    tbl.Normal  = tbl.Normal:Clone()

    return tbl
end

PlayerDisUse = 75

function PLAYER:IsLookOn(ent,dis)
    local tr = self:EyeTrace(dis or PlayerDisUse)
    
    return tr and tr.Entity == ent
end

function PLAYER:EyeTraceShoot(dis,returnTbl)
    local pos,ang = self:Eye()

    local tr = {
        start = pos,
        endpos = pos + ang:Forward():Mul(dis),
        filter = self,
        mask = MASK_SHOT
    }
    
    if returnTbl then return tr end

    tr = util.TraceLine(tr)

    return tr.HitPos:Distance(pos) <= dis and tr
end

--

function CalcSideK(yaw)
    local v = yaw

    if v > 0 then
        if v >= 90 then
            v = v - 90
        else
            v = 90 - v
        end

        v = 1 - v / 90
    else
        v = -v

        if v >= 90 then
            v = v - 90
        else
            v = 90 - v
        end

        v = 1 - v / 90

        v = -v
    end

    return v
end

/*
local min,max = math.min,math.max
local hook_Run = hook.Run

event.Add("Player Think","Side Move",function()
    if hook_Run("Should Side Spine") == false then ply.side = 0 return end

    ply.side = LerpFT(0.25,ply.side or 0,ply:GetNWFloat("Side",0))
end)

event.Add("Player Draw","Side Move",function(ply)
    local side = ply.side

    if SERVER then
        local wep = ply:GetActiveWeapon()
        ply:SetNWBool("SideAr2",ply:GetNWFloat("Side") ~= 0 and wep.HoldType == "ar2")
    end

    local boneClavicle = ply:LookupBone("ValveBiped.Bip01_R_Clavicle")
    local boneHand = ply:LookupBone("ValveBiped.Bip01_R_Hand")

    if ply:GetNWBool("SideAr2") and side ~= 0 then
        if side > 0 then
            ply.rclavicle:Add(Angle(-20 * side,0,0))
            ply.rhand:Add(Angle(-20 * side,0,0))
        else
            ply.rclavicle:Add(Angle(0,0,-20 * side))
            ply.rhand:Add(Angle(-20 * side,0,0))
        end
    end
end)

hook.Add("CalcMainActivity","Side",function(ply,vel)
    if not ply:GetNWBool("SideAr2") then return end

    return ACT_IDLE,ply:LookupSequence("idle_ar2")
end)

if CLIENT then
    local hg_autoside_inalt = CreateClientConVar("hg_autoside_inalt","0",true)

    local presL,presR
    
    local CMoveData = FindMetaTable("CUserCmd")
    
    function CMoveData:RemoveKeys(keys)
        local newbuttons = bit.band(self:GetButtons(),bit.bnot(keys))
    
        self:SetButtons(newbuttons)
    end
    
    hook.Add("StartCommand","Side Auto",function(ply,cmd)
        if not hg_autoside_inalt:GetBool() then return end
    
        if not ply:KeyDown(IN_WALK) then
            if presL then presL = nil RunConsoleCommand("-leftside") end
            if presR then presR = nil RunConsoleCommand("-rightside") end
    
            return
        end
    
        if cmd:KeyDown(IN_MOVELEFT) then
            if not presL then
                presL = true
    
                RunConsoleCommand("+leftside")
            end
    
            if not cmd:KeyDown(IN_SPEED) then
                cmd:RemoveKey(IN_MOVELEFT)
                cmd:SetSideMove(0)
            else
                cmd:RemoveKey(IN_SPEED)
                cmd:SetSideMove(-25)
            end
        else
            if presL then
                presL = nil
    
                RunConsoleCommand("-leftside")
            end
        end
    
    
        if cmd:KeyDown(IN_MOVERIGHT) then
            if not presR then
                presR = true
    
                RunConsoleCommand("+rightside")
            end
    
            if not cmd:KeyDown(IN_SPEED) then
                cmd:RemoveKey(IN_MOVERIGHT)
                cmd:SetSideMove(0)
            else
                cmd:RemoveKey(IN_SPEED)
                cmd:SetSideMove(25)
            end
        else
            if presR then
                presR = nil
    
                RunConsoleCommand("-rightside")
            end
        end
    end)

    return
end

event.Add("Player Think","Sides",function(ply)
    local set = (ply.leftSide and -1 or 0) + (ply.rightSide and 1 or 0)

    ply:SetNWFloat("Side",LerpFT(0.25,ply:GetNWFloat("Side",0),set))

    if set == 0 and ply:GetNWFloat("Side",0) <= 0.1 then ply:SetNWFloat("Side",0) end
end)

concommand.Add("+leftside",function(ply) ply.leftSide = true end)
concommand.Add("-leftside",function(ply) ply.leftSide = false end)

concommand.Add("+rightside",function(ply) ply.rightSide = true end)
concommand.Add("-rightside",function(ply) ply.rightSide = false end)*/

if SERVER then
    hook.Add("DoPlayerDeath","SaveEyePos",function(ply)
        local pos,ang = ply:Eye()
        ply.doDeathEyePos = pos
    end)

    event.Add("Player Death","Set DoDeath EyePos",function(ply)
        ply:SetPos(ply.doDeathEyePos or ply:GetPos())
    end)

    hook.Add("PlayerSilentDeath","Set EyePos",function(ply)
        ply:SetPos(ply.doDeathEyePos or ply:GetPos())
    end)
end
