--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/weapons/tier_1_content/pistol/r8_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad\\lua\\hinit\\weapons\\tier_1_content\\pistol\\r8_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Reg("wep_r8","wep_glock")
if not SWEP then return end

SWEP.PrintName 				= "R8"

------------------------------------------

SWEP.IsRevolver = true

SWEP.Primary.ClipSize		= 8
SWEP.Primary.DefaultClip	= 8
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "pistol"
SWEP.Shell = false

SWEP.Primary.Cone = 0
SWEP.Primary.Spread = 0.001
SWEP.Primary.Damage = 50
SWEP.Primary.Force = 140
SWEP.Primary.Wait = 1 / 8

SWEP.Primary.Sound = "arccw_go/revolver/revolver-1_01.wav"
SWEP.Primary.SoundFar = "arccw_go/revolver/revolver-1_distant.wav"
SWEP.EmptySound = "arccw_go/revolver/revolver_hammer.wav"

SWEP.WorldModel				= "models/weapons/arccw_go/v_pist_r8.mdl"

SWEP.HoldTypeReload = "revolver"

SWEP.vbwPos = Vector(-4,12,2)
SWEP.vbwAng = Angle(-90,0,0)

SWEP.dwsItemPos = Vector(-18.4,4,3)
SWEP.dwsItemFOV = -12.5

SWEP.wmVector = Vector(-12,6.8,-6)
SWEP.wmAngle = Angle(-7,0,180 + 7)

SWEP.MuzzlePos = Vector(2,0,-0)
SWEP.MuzzleAng = Angle(0.6,-1,0)
SWEP.CameraPos = Vector(-20,0,-0.15)
SWEP.CR_Scope = 4

SWEP.Reload1 = "arccw_go/glock18/glock_clipout.wav"
SWEP.Reload2 = "arccw_go/glock18/glock_clipin.wav"
SWEP.Reload3 = "arccw_go/glock18/glock_slideback.wav"
SWEP.Reload4 = "arccw_go/glock18/glock_sliderelease.wav"

SWEP.FakeVec1 = Vector(4,-9,-10)

SWEP.DeploySound = "arccw_go/revolver/revolver_draw.wav"

SWEP.BoltBone = false
SWEP.BoltMul = 2

SWEP.ClipBone = false

SWEP.eyeSprayH = 8
SWEP.eyeSprayLerp = 0.9

SWEP.CHandUp = 28
SWEP.CHandHoldUp = 0.35

SWEP.CHandRight = 1
SWEP.CHandHoldRight = 0.1

function SWEP:GetCHandUp(value)
    return math.ease.InSine(value) + math.max(math.ease.InElastic(value) - 0.3,0)
end

function SWEP:GetCHandRight(value) return value * self.randAbs end

function SWEP:PrimaryCustomAttack()
    if self.attackStart then return end

    self.attackStart = CurTime() + 0.1

    local ply = self:GetOwner()

    if SERVER then
        sound.EmitNET(ply:EntIndex(),"arccw_go/revolver/revolver_prepare.wav",nil,nil,nil,ply:GetPos())
        net.SendOmit(ply)
    else
        sound.Emit(ply:EntIndex(),"arccw_go/revolver/revolver_prepare.wav",nil,nil,nil,ply:GetPos())
    end
end

SWEP.HammerBone = "v_weapon.hammer"

SWEP:Event_Add("Init","Attack Pre",function(self)
    self.lerpHammer = 0
    self.lerpCylinder = 0
end)

if CLIENT then
    net.Receive("r8 shoot",function()
        local wep = LocalPlayer():GetActiveWeapon()

        if IsValid(wep) and not wep.attackWas then
            wep:Attack()
        end

        wep.attackWas = nil--;c;c;c
    end)
else
    util.AddNetworkString("r8 shoot")
end

SWEP:Event_Add("Think","Attack Pre",function(self)
    if self.attackStart then
        if self:GetOwner():KeyDown(IN_ATTACK) then
            if self.attackStart < CurTime() then
                self.attackStart = nil

                /*if SERVER then
                    net.Start("r8 shoot")
                    net.Send(self:GetOwner())
                end*/

                self.attackWas = true

                self:Attack()
            end
        else
            self.attackStart = nil
        end
    end

    if CLIENT then
        local gun = self:GetGun()

        local k = math.max((self.attackStart or 0) - CurTime(),0) / 0.1

        self.lerpHammer = LerpFT(k > 0 and 0.25 or 0.95,self.lerpHammer,k > 0 and 1 or 0)

        -- LookupBone returns nil -- it does not throw -- when the model has no such bone,
        -- and ManipulateBoneAngles(nil,Angle) then errors with "bad argument #1 to
        -- 'ManipulateBoneAngles' (number expected, got nil)" straight out of this Think
        -- event. The client-side gun model (SWEP:GetGun -- self.wm, or the weapon itself
        -- when that is not valid yet) does not always carry the CS:GO style
        -- `v_weapon.hammer` this SWEP names. Skip the frame instead of erroring.
        local hammer = gun:LookupBone(self.HammerBone)

        if hammer then gun:ManipulateBoneAngles(hammer,Angle(0,0,-45 * self.lerpHammer)) end
    end
end)

SWEP.ReloadMatrix = nil

SWEP.ReloadMatrix = {
	[0] = function(self)
		local owner = self:GetOwner()
		owner:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD,owner:IsFlagSet(FL_ANIMDUCKING) and ACT_MP_RELOAD_CROUCH or ACT_MP_RELOAD_STAND,true)
	end,
	[1] = function(self)
	end
}

function SWEP:ShootEffect(pos,dir)
    local color = Color(255,225,125)

    self:ShootLight(pos,dir,color)
    self:ShootEffect_Manual(pos,dir,color,{
        flashScale = 3,
        gasTimeScale = 3.5,
        gasSideScale = 1.5,
        gasForwardScale = 2
    })
end
