--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/weapons/halflife/ar2_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad\\lua\\hinit\\weapons\\halflife\\ar2_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Reg("wep_ar2","wep_m14")
if not SWEP then return end

SWEP.PrintName 				= "AR2"
SWEP.Instructions           = "\n13 выстрелов в секунду\n40 Урона\n0.01 Разброс"
SWEP.Category 				= L("weapon_category_hl2")

------------------------------------------

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "rifle"
SWEP.Primary.AmmoDWR        = "ar2"

SWEP.Primary.Cone = 0
SWEP.Primary.Spread = 0.01
SWEP.Primary.Damage = 40
SWEP.Primary.Force = 140
SWEP.Primary.Wait = 1 / 9

SWEP.Primary.Sound = "weapons/ar2/fire1.wav"
SWEP.Primary.SoundPitch = 75
SWEP.Primary.SoundFar = {"arccw_go/scar20/scar20_distant_01.wav","arccw_go/scar20/scar20_distant_02.wav","arccw_go/scar20/scar20_distant_03.wav"}

SWEP.HoldType = "ar2"

SWEP.DeployTime = 0.5

SWEP.Slot					= 2
SWEP.SlotPos				= 0

SWEP.WorldModel				= "models/weapons/w_irifle.mdl"

SWEP.vbwPos = Vector(-6,-2,0)
SWEP.vbwAng = Angle(0,0,0)

SWEP.dwsItemPos = Vector(-6.7,0,-3)
SWEP.dwsItemAng = Angle(0,180,0)

SWEP.wmVector = Vector(15,0,-1.2)
SWEP.wmAngle = Angle(180 - 5,6.5,180)

SWEP.MuzzlePos = Vector(0,0.85,-1.7)
SWEP.MuzzleAng = Angle(0,0,0)

SWEP.CameraPos = Vector(-30,0,5)
SWEP.CR_Scope = 1
SWEP.CRL_Scope = 0.25

SWEP.Reload1 = "arccw_go/m4a1/m4a1_clipout.wav"
SWEP.Reload2 = "weapons/arccw/ar2_reload_rotate.wav"
SWEP.Reload3 = "weapons/arccw/ar2_reload_push.wav"
SWEP.Reload4 = "arccw_go/m4a1/m4a1_cliphit.wav"

SWEP.BoltBone = false
SWEP.BoltMul = 2

SWEP.ClipBone = false

SWEP.FakeAng = Angle(0,180,0)
SWEP.FakeVec1 = Vector(20,-1.25,4)
SWEP.FakeVec2 = Vector(8,-3,0)

SWEP.DeploySound = "arccw_go/m4a1/m4a1_draw.wav"

SWEP.eyeSprayH = 2.5
SWEP.eyeSpraySinW = 0.2

SWEP.ScopeSensitivity = 1

SWEP.ScopeLerp = 0.2
SWEP.ScopeLerpOut = 0.25

function SWEP:ShootEffect(pos,dir)
    local color = Color(125,125,255)

    self:ShootLight(pos,dir,color)
    self:ShootEffect_Manual(pos,dir,color,{
        gasTimeScale = 2.5,
        gasSideScale = 2.75,
        gasForwardScale = 3
    })
end


--

SWEP.HSM = "models/weapons/arccw_go/atts/barska.mdl"
SWEP.HSP = false

SWEP.HSSize = 20
SWEP.HSBone = "holosight"
SWEP.HSMagnification = 2

SWEP.HSVec = Vector(-19,-0.51,3.95)
SWEP.HSAng = Angle(0,0,4.3)

SWEP.HSCameraVec = Vector(0,0,1.2)
SWEP.HSCameraForward = -5
SWEP.HSZoom = false

SWEP.ScopeSetToMuzzlePos = false
SWEP.ScopeImersiveView = 0.9
SWEP.ScopeSensitivity = 1

local circle = Material("mat_jack_smallarmstracer_front")
local circle2 = Material("mat_jack_gmod_shinesprite")

local glow = Material("particle/particle_glow_03_additive")

function SWEP:DrawHS()
    surface.SetAlphaMultiplier(math.Clamp(ScopeLerp * 2,0,1))

    local pos = self.hsm:GetPos():Add(self.HSCameraVec:Clone():Rotate(self.hsm:GetAngles())):ToScreen()

    local cx,cy = scrw / 2,scrh / 2 + 4

    local dx,dy = cx - pos.x,cy - pos.y
    dx = dx * Lerp(math.abs(dx) / 200,0,1)
    dy = dy * Lerp(math.abs(dy) / 200,0,1)

    local x,y = cx + dx,cy + dy

    local len = math.Distance(cx,cy,x,y)

    local hss = math.min(scrw,scrh) / 40
    hss = hss - len / 4

    hss = hss * (BodyCamMode and 0.40 or 1)--criiiiiiiiiing

    local r = math.cos((x + y) * 10)
    len = len / 4

    local lenx = math.Distance(cx,0,x,0) * 2
    local leny = math.Distance(cy,0,y,0) * 2

    surface.SetMaterial(circle2)
    surface.SetDrawColor(255,0,0,15 + r * 25 + len * 10)

    surface.DrawTexturedRectRotated(x,y,hss * (2 + r * 2 + len),hss * 0.2,r * 360)
    surface.DrawTexturedRectRotated(x,y,hss * (2 + r * 2 + len),hss * 0.2,r + r * 360 * 2)

    surface.SetMaterial(glow)
    surface.SetDrawColor(255,0,0,25)
    surface.DrawTexturedRectRotated(x,y,hss / 2,hss / 2,0)
    surface.SetDrawColor(255,0,0,5)
    surface.DrawTexturedRectRotated(x,y,hss * 3,hss * 3,0)

    surface.SetDrawColor(255,0,0,1)
    surface.DrawTexturedRectRotated(x,y,hss * 12,hss * 12,math.Rand(-360,360))

    hss = hss / 2

    surface.SetMaterial(circle)
    surface.SetDrawColor(255,0,0)
    surface.DrawTexturedRectRotated(x,y,hss - lenx,hss - leny,0,0,0)

    surface.SetAlphaMultiplier(1)
end
