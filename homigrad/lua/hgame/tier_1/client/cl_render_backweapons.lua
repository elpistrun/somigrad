--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/client/cl_render_backweapons.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\client\\cl_render_backweapons.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local clone = Vector(0,0,0)
local vecZero,angZero = Vector(0,0,0),Angle(0,0,0)

local RifleOffset = Vector(-8,-4,-2)
local RifleAng = Angle(0,0,-20)

local PistolOffset = Vector(8,-9,-8)
local PistolAng = Angle(-80,0,0)

local Offset,Ang = Vector(0,0,0),Angle(0,0,0)

local function remove(wep,ent) ent:Remove() end

local LocalPlayer = LocalPlayer
local GetViewEntity = GetViewEntity

local vecFull = Vector(1,1,1)

local function GetMatrix(ent)
    local bone = ent:LookupBone("ValveBiped.Bip01_Spine2")
    if not bone then return end

    matrix = GetBoneMatrix(ent,bone)
    if not matrix then return end
    
    local spinePos,spineAng = matrix:GetTranslation(),matrix:GetAngles()

    local bone = ent:LookupBone("ValveBiped.Bip01_Pelvis")
    if not bone then return end
    
    matrix = GetBoneMatrix(ent,bone)
    local pelvisPos,pelvisAng = matrix:GetTranslation(),matrix:GetAngles()

    local sUp,sRight,sForward = spineAng:Up(),spineAng:Right(),spineAng:Forward()
    local pUp,pRight,pForward = pelvisAng:Up(),pelvisAng:Right(),pelvisAng:Forward()

    return spinePos,spineAng,sUp,sRight,sForward,pelvisPos,pelvisAng,pUp,pRight,pForward
end

local Mat = Matrix()

DrawPlayerBackWeapons = function(weapons,ent,isWorld,tag)
    tag = (tag or "") .. tostring(ent) .. (ent.id or "")

    local spinePos,spineAng,sUp,sRight,sForward,pelvisPos,pelvisAng,pUp,pRight,pForward = GetMatrix(ent)
    if not spinePos then return end

    local i = 0

    ::start::

    i = i + 1
    
    local wep = weapons[i]
    if not wep then return end
    if not wep.vbw then goto start end

    local worldMdl = wep.WorldModel
    if not worldMdl then goto start end

    -- A weapon has to opt in with .vbw, but that alone is not enough to be drawable here:
    -- the pass below wants hg_wep_base's InitWorldModel and Render. salat_base (the whole
    -- weapons/ addon, 31 guns) sets vbw = true and a WorldModel while deriving from plain
    -- weapon_base, so it has neither. One such gun in the loadout made the call further
    -- down throw, which aborted this pass mid-way and left carried weapons drawn with no
    -- position at all -- the vertical, oversized, detached-looking gun.

    local localPos,localAng,pistol
    local func = wep.vbwFunc

    if func then
        localPos,localAng,pistol = func(wep,ply,ent)

        Offset:Set(pelvisPos)
        Ang:Set(pelvisAng)

        clone:Set(localPos):Rotate(Ang)

        Ang:RotateAroundAxis(pUp,localAng[1]):RotateAroundAxis(pRight,localAng[2]):RotateAroundAxis(pForward,localAng[3])
    else
        pistol = wep.vbwPistol or not wep.FakeVec2

        if pistol then
            localPos = wep.vbwPos or PistolOffset
            localAng = wep.vbwAng or PistolAng

            Offset:Set(pelvisPos)
            Ang:Set(pelvisAng)

            clone:Set(localPos):Rotate(Ang)

            Ang:RotateAroundAxis(pUp,localAng[1]):RotateAroundAxis(pRight,localAng[2]):RotateAroundAxis(pForward,localAng[3])
        else
            localPos = wep.vbwPos or RifleOffset
            localAng = wep.vbwAng or RifleAng

            Offset:Set(spinePos)
            Ang:Set(spineAng)
            
            clone:Set(localPos):Rotate(Ang)

            Ang:RotateAroundAxis(sUp,localAng[1]):RotateAroundAxis(sRight,localAng[2]):RotateAroundAxis(sForward,localAng[3])
        end
    end
    
    local mdl

    if wep.InitWorldModel then
        mdl = wep:InitWorldModel("back" .. (tag or ""),isWorld)
    else
        -- Same client-side model InitWorldModel would have built, so the weapon still
        -- shows up on the back instead of being skipped or, worse, aborting the pass.
        mdl = CSMById(worldMdl,tostring(wep) .. worldMdl .. "back" .. (tag or ""),isWorld)
    end

    if not mdl then goto start end

    if not isWorld then
        mdl:SetNoDraw(true)
    end

    mdl:SetPos(Offset:Add(clone))
    mdl:SetAngles(Ang)
    mdl:SetupBones()

    -- Render is hg_wep_base's, and is only "draw it"; salat_base has no such method
    if wep.Render then wep:Render(mdl) else mdl:DrawModel() end

    goto start
end

local DrawPlayerBackWeapons = DrawPlayerBackWeapons

cvars.CreateOption("hg_draw_backweapons","1",function(value)
    if tonumber(value) > 0 then
        event.Add("PlayerDraw","BackWeapons",function(ply,tag,link,isWorld)
            if isWorld and ply:GetPos():Distance(EyePos()) > 512 then return end
            if ply == LocalPlayer() and not ply:ShouldDrawLocalPlayer() and not (ply.InFake and ply:InFake()) then return end

            local hasLink = link
            link = link or ply
            
            local weapons = link:GetWeapons() or {}
            local activeWeapon = link:GetActiveWeapon()

            for i,wep in pairs(weapons) do
                if activeWeapon == wep then table.remove(weapons,i) break end
            end

            if not tag or hasLink then
                local result = event.Call("View Back Weapon",link,weapons)
                if result == false then return end
                weapons = result or weapons
            end

            DrawPlayerBackWeapons(weapons,ply,not tag and true or false,"world" .. (tag or ""))
        end,10)
    else
        event.Remove("PlayerDraw","BackWeapons",10)
    end
end)
