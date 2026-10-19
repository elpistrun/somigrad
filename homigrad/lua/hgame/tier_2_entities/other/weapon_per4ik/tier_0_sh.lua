--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/other/weapon_per4ik/tier_0_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\other\\weapon_per4ik\\tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Reg("weapon_per4ik","hg_wep_base",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.Base                   = "weapon_base"

SWEP.PrintName 				= L("weapon_per4ik")
SWEP.Author 				= "Homigrad"
SWEP.Category 				= L("weapon_category_item")

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Wait		    = 0
SWEP.Primary.Ammo			= "none"

SWEP.Slot					= 3
SWEP.SlotPos				= 3
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP.WorldModel				= "models/weapons/custom/pepperspray.mdl"

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

SWEP.dwsItemAng = Angle(0,180,0)
SWEP.dwsItemPos = Vector(-0.4,0,0)
SWEP.dwsItemFOV = -11

SWEP.vbw = true
SWEP.vbwPistol = true
SWEP.vbwPos = Vector(-6,-3,1)
SWEP.vbwAng = Angle(-40,-0,-90)
SWEP.vbwModelScale = Vector(0.9,0.9,0.9)

SWEP.itemType = "other"

SWEP.EnableTransformModel = true

SWEP.wmVector = Vector(3,2,1)
SWEP.wmAngle = Angle(-90 + 5,180 - 5,6)

SWEP.Primary.Automatic = false

SWEP.DeployTime = 0.6

local red = Color(255,0,0)

function SWEP:AnimationBonesPlayer(rag,ft,time)
    -- same reason as SmoothHand: read DeployStart through GetDeployStart so the ten second
    -- placeholder cannot reach InBounce/sin, and clamp before easing -- these curves are
    -- only defined on [0,1].
    local anim = math.max(self:GetDeployStart(time) - time + 0.5,0)
    anim = math.Clamp(anim / 0.5,0,1)

    local anim2 = math.sin(anim * 3.14 * 5)

    anim = math.ease.InBounce(anim)

    rag:AddBoneAng("rforearm",Angle(20,-35,-5):Mul(anim2))
    rag:AddBoneAng("rupperarm",Angle(0,25,-20):Mul(anim))
    
    local anim = math.max(self:GetNWFloat("StartAnim") - time + 0.2,0) / 0.2

    if anim > 0 then
        local animBone = math.sin(anim * 3.14 * 1)

        if not self:GetNWBool("Empty")  then
            rag:AddBoneAng("rhand",Angle(15,0,-4):Mul(animBone))
            rag:AddBoneAng("rforearm",Angle(0,-5,0):Mul(animBone))
            rag:AddBoneAng("rupperarm",Angle(0,5,0):Mul(animBone))
        else
            local animBone = math.sin(math.max(anim - 0.5,0) / 0.5 * 3.14 * 1)

            rag:AddBoneAng("rhand",Angle(10,0,-4):Mul(animBone))
            rag:AddBoneAng("rforearm",Angle(0,-2,0):Mul(animBone))
            rag:AddBoneAng("rupperarm",Angle(0,2,0):Mul(animBone))

            return
        end

        if CLIENT then
            if not IsValid(self.emitterParticles) then
                self.emitterParticles = ParticleEmitterLight(self:GetPos())
            end

            self.emitterParticles:SetPos(self:GetPos())

            if (self.emitterParticles.delay or 0) < time then
                self.emitterParticles.delay = time + 1 / 60

                local pos,ang = rag:Eye()
                
                local Pos,Ang = self:GetTransformFromRagdoll(rag)

                -- the hold bone can be missing this frame (see render/util_sh.lua); the
                -- smoke is not worth an error every frame
                if not Pos then return end

                local part = self.emitterParticles:Add(ParticleMatSmoke[math.random(1,#ParticleMatSmoke)],Pos + Vector(0,-math.Rand(2,5.5),5):Rotate(Ang))
                if part then
                    part:SetDieTime(math.Rand(0.4,0.5))
                
                    part:SetStartAlpha(200)
                    part:SetEndAlpha(0)

                    part:SetColor(math.random(200,225),0,0)
                    part:SetStartSize(math.Rand(4,5))
                    part:SetEndSize(math.Rand(35,40))
            
                    part:SetGravity(Vector(0,0,-15))
                    part:SetVelocity(Vector(math.Rand(290,300),0,0):Rotate(ang))
                    
                    part:SetCollide(true)
                    part:SetCollideCallback(function(_,hitPos,hitNormal)
                        local trace = util.QuickTrace(hitPos + hitNormal,hitPos - hitNormal * 2)
                        if not trace.Hit or IsValid(trace.Entity) or trace.HitTexture == "**displacement**" then return end
                        
                        local vec = render.GetLightColor(hitPos)
                        util.DecalEx(part:GetMaterial(),game.GetWorld(),hitPos,hitNormal,Color(255 * math.Clamp(vec[1] * 5,0,1),0,0,25),0.1,0.1)
                        part:Remove()
                    end)

                    part:SetBounce(0)
                end
            end
        else
            self:Attack(rag,ft,time)
        end
    else
        if CLIENT then
            if IsValid(self.emitterParticles) then
                self.emitterParticles:Finish()
                self.emitterParticles = nil
            end
        end
    end
end

if SERVER then return end

hook.Add("RenderScreenspaceEffects","EyesBlind",function()
    local ply = GetViewEntity()
    if not IsValid(ply) then return end

    if hook.Run("Should Draw Screenspace") == false then return end

    local k = math.Clamp(ply:GetNWFloat("EyesBlind",0) - CurTime(),0,10) / 10
    if k <= 0 then return end

    RenderScreenspaceEffects_DrawBlur(k)
end)
