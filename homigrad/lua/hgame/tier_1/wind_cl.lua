--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/wind_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\wind_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local k = 0

hook.Add("Think","Wind",function()
    if not WindSound then
        WindSound = CreateSound(LocalPlayer(),"homigrad/wind/woosh0.wav")
    end

    if not WindSound2 then
        WindSound2 = CreateSound(LocalPlayer(),"homigrad/wind/woosh1.wav")
    end

    local ent = LocalPlayer():GetEntity()

    if not LocalPlayer():Alive() or (ent == LocalPlayer() and LocalPlayer():GetNoDraw()) then
        k = 0

        if WindSound:IsPlaying() then WindSound:ChangeVolume(0,0.05) end
        if WindSound2:IsPlaying() then WindSound2:ChangeVolume(0,0.05) end

        return
    end

    k = math.min(ent:GetVelocity():Length() / (ent ~= LocalPlayer() and 1750 or 3000),1)
    k = math.max(k - 0.2,0) / 0.8

    if k <= 0 then
        if WindSound:IsPlaying() then WindSound:ChangeVolume(0,0.05) end
        if WindSound2:IsPlaying() then WindSound2:ChangeVolume(0,0.05) end
    end

    local dot = ent:GetVelocity():GetNormalized()
    dot.z = 0

    local dir = Vector(1,0,0):Rotate(EyeAngles())
    dir.z = 0

    dot = 1 - math.abs(dot:Dot(dir))
    
    local volume = 1 * k
    local pitch = 75 + 45 * k

    if not WindSound:IsPlaying() then
        WindSound:PlayEx(volume,pitch)
    end

    local volume2 = volume * math.abs(dot)

    if not WindSound2:IsPlaying() then
        WindSound2:PlayEx(volume2,pitch)
    end

    WindSound:ChangeVolume(volume - volume2 * 0.6,0.25)
    WindSound:ChangePitch(pitch,0.25)
    
    WindSound2:ChangeVolume(volume2,0.25)
    WindSound2:ChangePitch(pitch,0.25)
end)

event.Add("PreCalcView","Wind",function(ply,view)
    local mt = ply:GetMoveType()
    if mt == MOVETYPE_NOCLIP or mt == MOVETYPE_OBSERVER or (ply.GetNWBool and ply:GetNWBool("noclip",false)) or (ply.GetFlags and bit.band(ply:GetFlags(),8) ~= 0) then return end
    local mul = 15 + 25 * k

    //view.ang = view.ang + Angle(math.cos(CurTime() * mul),math.sin(CurTime() * mul),math.cos(CurTime() * mul/5)/5):Mul(15 * k)
    view.fov = math.min(view.fov + 25 * k,180)
end)
