--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/flashlight_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\flashlight_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local color_white = Color(255,255,255,90)
local color_white2 = Color(255,255,255,5)

local hg_best_flashlight

cvars.CreateOption("hg_best_flashlight","1",function(value)
    hg_best_flashlight = tonumber(value)

    DrawFlashlight = function() end//lol
    
    if hg_best_flashlight >= -1 then
        local player_GetAll = player.GetAll
    
        local function create(ent)
            local lamp = ProjectedTexture()
            ent.Flashlight = lamp

            lamp:SetTexture("effects/flashlight001")
            lamp:SetFarZ(900)
            lamp:SetNearZ(1)
            lamp:SetFOV(125)
            lamp:SetEnableShadows(true)
            lamp:AddThink()

            function lamp:Think()
                if (self.render or 0) < RealTime() then self:Remove() end
            end
        end
        
        local function remove(ent)
            if IsValid(ent.Flashlight) then
                ent.Flashlight:Remove()
                ent.Flashlight = nil
            end
        end
        
        local material = Material("sprites/gmdm_pickups/light")
        local angZero = Angle(0,0,0)
        local vecZero = Vector(0,0,0)
        local addPosa = Vector(3,-2,0)
        
        local function DrawPlayer(ply,link)
            local bone = ply:LookupBone("ValveBiped.Bip01_L_Hand")
            local pos,ang

            local dontdrawmdl

            if not link.EyeMode or (not link:EyeMode() and bone) then
                local matrix = ply:GetBoneMatrix(bone)
                if not matrix then return end//lol?
                
                pos,ang = matrix:GetTranslation(),matrix:GetAngles()
            else
                pos,ang = link:EyePos(),link:EyeAngles()

                dontdrawmdl = true
            end

            local wep = link.GetActiveWeapon and link:GetActiveWeapon()
            if not (not IsValid(wep) or wep:GetClass() == "weapon_hands") then dontdrawmdl = true end
            
            DrawFlashlight(ply,pos,ang,link.EyeMode and link:EyeAngles() or ang,dontdrawmdl,hg_best_flashlight == 1 or (hg_best_flashlight == 0 and link == LocalPlayer()))
        end

        DrawFlashlight = function(ent,pos,ang,angEye,dontdrawmdl,best)
            local mdl = CSMById("models/maxofs2d/lamp_flashlight.mdl",tostring(ent) .. "flashlight")
            if not mdl then return end

            mdl:SetAngles(angEye)
            mdl:SetPos(pos + Vector(4,-2,0):Rotate(ang) + Vector(5,0,0):Rotate(angEye))
            
            if best then
                local lamp = ent.Flashlight

                if not IsValid(lamp) then create(ent) lamp = ent.Flashlight end
                lamp:SetPos(mdl:GetPos() + Vector(10,0,0):Rotate(mdl:GetAngles()))
                lamp:SetAngles(mdl:GetAngles())
                lamp:SetBrightness(math.Rand(0.95,1))
                lamp:Update()
                lamp.render = RealTime()
            else
                local tr = {
                    start = pos,
                    endpos = pos + mdl:GetAngles():Forward():Mul(128),
                    filter = ent
                }

                local dlight = DynamicLight(ent:EntIndex())
                dlight.Pos = util.TraceLine(tr).HitPos
                dlight.r = 255
                dlight.g = 255
                dlight.b = 255
                dlight.Brightness = 0.1
        
                dlight.Decay = 1000
                dlight.Size = math.Rand(480,512)
                dlight.DieTime = CurTime() + 0.25
        
                dlight.ignoreLimit = true
                dlight:Spawn()
            end
            
            mdl:SetModelScale(0.5)

            mdl:SetNoDraw(dontdrawmdl)
            if not mdl:GetNoDraw() then mdl:DrawModel() end
        end

        FindMetaTable("Player").DrawFlashlight = Draw

        local function DrawFlash(ply)
            local mdl = ply.mdlFlashlight
        end

        local GetAll = player.GetAll

        event.Add("PlayerDraw","Flashlight",function(ply,tag,link,isWorld)
            link = link or ply
            if not link:GetNWBool("Flashlight") then return end

            DrawPlayer(ply,link)
        end)
    else
        FindMetaTable("Player").DrawFlashlight = function() end
        
        hook.Remove("Think","Flashlight")
        event.Remove("PlayerDraw","Flashlight")
    end
end,-2,1)
