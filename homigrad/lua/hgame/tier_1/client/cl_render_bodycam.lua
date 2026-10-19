--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/client/cl_render_bodycam.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\client\\cl_render_bodycam.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
cvars.CreateOption("hg_bodycam_dsp","1",function(value)
    if tonumber(value) <= 0 then
        //if IsValid(LocalPlayer()) then LocalPlayer():SetDSP(0) end
        BodyCamModeDSP = nil
    else
        BodyCamModeDSP = true
    end
end,0,1)

BodyCamMode = nil

function BodyCamOpen()
    BodyCamMode = true
    DisableCameraWeapons = true

    local w,h = ScrW(),ScrH()
    local mat = Material("mats_jack_gmod_sprites/vignette.png")

    local rtScreen = GetRenderTarget("rtScreen" .. w .. h,w,h)
    local screen = GetRenderTarget("bodycam" .. w .. h,w,h)

    local rtMat = Material("pp/rt")
    rtMat:SetTexture("$basetexture",rtScreen)
    
    local scopeMat = Material("pp/copy")
    scopeMat:SetTexture("$basetexture",screen)

    if IsValid(BodyCamModel) then BodyCamModel:Remove() end
    BodyCamModel = ClientsideModel("models/weapons/arccw_go/atts/acog_hsp.mdl")

    local mdl = BodyCamModel
    mdl:SetNoDraw(true)
    mdl:SetMaterial("pp/copy")

    hook.Add("Render Grab","BodyCam",function(view)
        view.fov = view.fov + 15

        hook.Run("Render Pre",view)

        local w,h = ScrW(),ScrH()
        render.PushRenderTarget(rtScreen)
            render.RenderView(view)
            cam.Start2D()
                hook.Run("BodyCam HUDPaint",view)
                hook.Run("RenderScreenspaceEffects")
            cam.End2D()
        render.PopRenderTarget()

        cam.Start2D()
           render.PushRenderTarget(screen,w * 0,h * 0,w * 1,h * 1)
                surface.SetDrawColor(255,0,0)
                surface.DrawRect(0,0,w,h)

                surface.SetMaterial(rtMat)
                surface.DrawTexturedRectRotated(w / 2,h / 2,w,h,0)
            render.PopRenderTarget()

            surface.SetDrawColor(0,0,0)
            surface.DrawRect(0,0,w,h)
        cam.End2D()

        local size = Vector(1,3,1.5)

        local calc = view.calc
        local forwardDiff = calc.forwardDiff or Vector()
        local angDiff = calc.angDiff or Angle()

        cam.Start3D(Vector(-size[1] * 3,-0.02,-0.0027),Angle(),125,0,0,w,h,0.01,10000)
            mdl:SetPos(Vector(1 * size[1],-0.02,-1.285 * size[3]):Add(forwardDiff / 5))
            mdl:SetAngles(angDiff / 1000)

            local Mat = Matrix()
            Mat:Scale(size)
            mdl:EnableMatrix("RenderMultiply",Mat)

            render.SuppressEngineLighting(true)
            render.SetColorModulation(1,1,1)
            mdl:DrawModel()
            render.SuppressEngineLighting(false)
        cam.End3D()

        CamReset()
        cam.End3D()

        cam.Start2D()
            local w,h = ScrW(),ScrH()
            render.RenderHUD(0,0,w,h)--ebat

            surface.SetMaterial(mat)
            surface.SetDrawColor(255,255,255,255)
            surface.DrawTexturedRectRotated(w / 2,h / 2,w * 1.5,h * 1.5,0)
        cam.End2D()

        return true
    end)

    local footPos = Vector()
    local footStart = 0

    local velScope = Vector()
    local vecScope = Vector()

    local vecHead

    local down = 0
    
    local ScopeLerpOld = 0

    local recoil,recoilStart,recoilFast = 0,0,0

    event.Add("PreCalcView","BodyCam Weapons",function(ply,view)
        view.forceMovement = true
        view.forceSmooth = true
    end)

    local oldAng
    local k = 0

    local foot,footSet,footAbs = 0,0,0
    local shake,shakeSet = 0,0
    local lerpSide = 0

    local Equip = 0

    local side,sideSet = 0,0

    event.Add("PreCalcView","BodyCam",function(ply,view)
        if not ply:Alive() or GetViewEntity() ~= ply then return end

        if ply:InVehicle() then
            return
        end

        local ang = view.ang

        local body = ply:LookupBone("ValveBiped.Bip01_Spine4")
        if not body then return end--wtf

        body = ply:GetBoneMatrix(body)
        if not body then return end

        side = LerpFT(0.2,side,sideSet)
        local old = ang:Clone()
        ang[2] = body:GetAngles()[2] + side
        local diff = ang - old
        diff:Normalize()

        ang[2] = ang[2] - diff[2] / 4

        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) then sideSet = 0 return end

        if wep.IsDeployed and not wep:IsDeployed() then
            shakeSet = shakeSet + 1.25
            lerpSide = lerpSide + 20
        end

        if wep.IsHolstered and wep:IsHolstered() then
            sideSet = 0
        else
            if wep.FakeVec2 then
                sideSet = 25 + math.cos(CurTime() * 0.25)
            elseif wep.FakeVec1 then
                sideSet = -30 + math.cos(CurTime() * 0.25)
            else
                sideSet = 0
            end
        end
    end,-1)

    event.Add("PreCalcView","BodyCam",function(ply,view)
        local ang = view.ang

        if not oldAng then oldAng = ang:Clone() end

        local dang = ang - oldAng
        dang:Normalize()

        k = math.Clamp(k + dang[2] / 2,-15,15)

        ang[3] = ang[3] - k

        oldAng = ang:Clone()

        view.imersiveL = 0.01
        view.imersiveSetL = 0.75

        local vec = view.vec

        foot = LerpFT(0.2,foot,footSet)
        footSet = LerpFT(0.1,footSet,0)

        ang[3] = ang[3] + foot * 2 * footAbs

        local diff = view.angDiff
        if diff then
            diff = diff[2] + diff[1]
            diff = diff * 2
            
            shakeSet = shakeSet + diff
            shake = LerpFT(0.1,shake,math.Rand(shakeSet * 0.9,shakeSet * 1.1))
            shakeSet = LerpFT(0.5,shakeSet,0)

            lerpSide = lerpSide + view.angDiff[2]
            lerpSide = LerpFT(0.25,lerpSide,0)

            local diff = ScopeLerpOld - ScopeLerp
            shakeSet = shakeSet + diff * 75
            lerpSide = lerpSide + diff * 4
            ScopeLerpOld = ScopeLerp

            ang[3] = ang[3] - shake * math.Clamp(lerpSide,-1,1) * math.sin(CurTime() * 20)
        end
    end,3)

    event.Add("Footstep","BodyCam",function(ply,pos,f)
        if ply ~= LocalPlayer() then return end
    
        footSet = footSet + 1

        footAbs = f == 1 and 1 or -1
    end,-1)
end

function BodyCamClose()
    //if IsValid(LocalPlayer()) then LocalPlayer():SetDSP(0) end

    BodyCamMode = nil
    BodyCamForce = nil
    DisableCameraWeapons = nil

    hook.Remove("Render Grab","BodyCam")
    event.Remove("PreCalcView","BodyCam Weapons",0)
    event.Remove("PreCalcView","BodyCam",3)
    event.Remove("PreCalcView","BodyCam",-1)
    event.Remove("Footstep","BodyCam",-1)
end

local hg_bodycam_enable

hook.Add("Think","BodyCamForce",function()
    local result = hook.Run("BodyCam")
    if result then
        BodyCamForce = true

        if not BodyCamMode then BodyCamOpen() end
    else
        BodyCamForce = nil

        if hg_bodycam_enable then
            if LocalPlayer():Alive() then
                if not BodyCamMode then BodyCamOpen() end
            else
                //if BodyCamMode then BodyCamClose() end
            end
        else
            if BodyCamMode then BodyCamClose() end
        end
    end

    //if BodyCamMode and GetConVar("hg_bodycam_dsp"):GetBool() then LocalPlayer():SetDSP(55) end
end)

event.Add("DSP","BodyCUM",function()
    if BodyCamMode and GetConVar("hg_bodycam_dsp"):GetBool() then return 55 end
end,-2)

cvars.CreateOption("hg_bodycam_enable","0",function(value)
    if BodyCamForce then return end

    if tonumber(value) > 0 then
        hg_bodycam_enable = true
        
        BodyCamOpen()
    else
        hg_bodycam_enable = false
        
        BodyCamClose()
    end
end,0,1)

local lightnes,lightnesSet = 0,0
local delay = 0

local setX,setY
local r,g,b,num

local ReadPixel = render.ReadPixel
local CapturePixels = render.CapturePixels
local SysTime = SysTime

local function calculate()
    local size = math.ceil(scrh / 2)
    local scrw,scrh = scrw,scrh
    
    if delay < CTime then
        delay = CTime + math.Rand(0.1,0.15)

        if not setX then
            setX = size
            setY = size

            x = 0
            y = 0
            r,g,b = 0,0,0
            num = 0

            CapturePixels()--из за этого лагает ;c
        end

        local start = SysTime() + 1 / 100--am wtf

        while true do
            if not setX then break end

            x = x + 1
            if x > setX then setX = nil break end

            while true do
                y = y + 1
                if y > setY then setX = nil break end

                local r2,g2,b2 = ReadPixel(scrw / 2 + (x - size / 2),scrh / 2 + (y - size / 2))

                r = r + r2
                g = g + g2
                b = b + b2

                num = num + 1

                if start < SysTime() then return end
            end
        end

    
        r,g,b = r / num,g / num,b / num

        lightnesSet = (r + g + b) / 3 / 255
    end
end

local tab = {
	[ "$pp_colour_addr" ] = 0,
	[ "$pp_colour_addg" ] = 0,
	[ "$pp_colour_addb" ] = 0,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] = 1,
	[ "$pp_colour_colour" ] = 1,
	[ "$pp_colour_mulr" ] = 0,
	[ "$pp_colour_mulg" ] = 0,
	[ "$pp_colour_mulb" ] = 0
}

hook.Add("BodyCam HUDPaint","Effects",function(view)
    calculate()

    lightnes = LerpFT(lightnes < lightnesSet and 0.025 or 0.1,lightnes,lightnesSet)
    
    local lightnes = math.min(lightnes / 0.4,1)

    lightnes = math.min(lightnes / 0.9,1) 

    local dark = 1 - lightnes

    DrawSharpen(4 - dark / 2,0.1 + dark / 10)
	DrawBloom(0.5,0.25 + dark / 2,9 + dark * 12,9 + dark * 12,1,1,1,1,1)

    tab["$pp_colour_contrast"] = 1 + dark * 2
    tab["$pp_colour_brightness"] = -0.03 * dark
    
	DrawColorModify(tab)

   -- draw.SimpleText(lightnes,"ChatFont",ScrW() / 2,ScrH() - 150,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

    local len = view.calc.angDiff

    if len then
        len = (math.abs(len[1]) + math.abs(len[2])) / 2
    else
        len = 0
    end
    
    DrawMotionBlur(0.8,0.1 + math.max(len / 1.5,0.6),0.009)
end)

event.Add("Suppress","BodyCam",function(k) if BodyCamMode then return 0 end end)

hook.Add("Should Draw Screenspace","BodyCam",function() if BodyCamMode then return false end end)
