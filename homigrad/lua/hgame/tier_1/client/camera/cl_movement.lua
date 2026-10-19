--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/client/camera/cl_movement.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\client\\camera\\cl_movement.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local foot,footSet = 0,0
local footSide,footSideSet = 0,0

local footPos,footPosSet = Vector(),Vector()

local velSet = Vector()
local vel = Vector()
local sideLerp = 0

local limit = 1
CameraLand,CameraLandSet = Vector(),Vector()

local sprint = 0

local pith = 0
local velLenght = 0

event.Add("PreCalcView","Movement",function(ply,view)
    if VRMODSELFENABLED or not view.forceMovement and (not ply:Alive()) then return end
    local mt = ply:GetMoveType()
    if mt == MOVETYPE_NOCLIP or mt == MOVETYPE_OBSERVER or (ply.GetNWBool and ply:GetNWBool("noclip",false)) or (ply.GetFlags and bit.band(ply:GetFlags(),8) ~= 0) or ply:EyeMode() then
        sideLerp = 0
        pith = 0
        foot = 0
        footSet = 0
        return
    end

    local vec = view.vec or view.origin
    local ang = view.ang or view.angles
    if not vec or not ang then return end

    foot = LerpFT(0.2,foot,footSet)
    footSet = LerpFT(0.025,footSet,0)

    footSide = LerpFT(0.25,footSide,footSideSet)

    local k = view.mulMovement or 1
    
    //

    footPos:LerpFT(0.2,footPosSet)
    footPosSet:LerpFT(0.2)

    vec:Add(footPos * k)
    
    ang[1] = ang[1] + 2 * foot * k
    ang[3] = ang[3] + foot * footSide / 1 + math.cos(RealTime() * 0.25) * k

    local diff = (ply:GetVelocity():Angle() - ang)
    diff:Normalize()

    //

    local v = CalcSideK(diff[2])
    v = v * math.Clamp(ply:GetVelocity():Length() / 512,0,1) * k
    sideLerp = LerpFT(0.25,sideLerp,v)
    ang[3] = ang[3] - 15 * sideLerp

    //

    velSet:LerpFT(0.8,ply:GetVelocity():Div(55))
    vel:LerpFT(0.1,velSet)
    vel:Clamp(-limit,limit,-limit,limit,-limit,limit)
    vec:Add(vel * (1 - ScopeLerp * 0.95))

    pith = LerpFT(0.5,pith,vel[3])
    ang[1] = ang[1] + pith * 25
    
    vel[3] = 0--fuck you!
    
    //

    sprint = LerpFT(0.1,sprint,ply:IsOnGround() and ply:IsSprinting() and math.min(ply:GetVelocity():Length() / ply:GetRunSpeed(),1) or 0)
    velLenght = LerpFT(0.25,velLenght,vel:Length() / 300)
    view.fov = view.fov + 5 * sprint + velLenght
    
    vec:Add(Vector(1,0,0):Rotate(ang):Mul(1))

    //

    vec:Add(CameraLand:Clone():Clamp(-10,10,-10,10,-10,10))

    ang[1] = ang[1] + CameraLand:Length() / 2
    ang[3] = ang[3] + CameraLand:Length() * footSide / 3

    CameraLand:LerpFT(0.1,CameraLandSet)
    CameraLandSet:LerpFT(0.75)
end,1)

local Rand = math.Rand

event.Add("Footstep","Camera",function(ply,pos,_footSide)
    if ply ~= LocalPlayer() then return end

    if _footSide == 0 then _footSide = -1 end

    footSideSet = _footSide
    
    local sprint = ply:IsSprinting()

    footPosSet = EyeAngles():Right() * -footSideSet + Vector(0,0,2)
    footPosSet:Mul(sprint and 2 or 1)

    footSet = sprint and 2.5 or 1
end,-1)


event.Add("Landing","Camera",function(ply,inWater,onFloat,speed)
    if ply ~= LocalPlayer() then return end

    CameraLandSet:Add(ply:GetVelocity():Div(6))
end,-1)
