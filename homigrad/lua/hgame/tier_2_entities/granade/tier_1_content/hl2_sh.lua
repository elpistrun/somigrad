--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/granade/tier_1_content/hl2_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\granade\\tier_1_content\\hl2_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Reg("wep_gnade_hl2","wep_gnade_base")
if not SWEP then return end

SWEP.PrintName = L("wep_gnade_hl2")

SWEP.WorldModel = "models/weapons/w_grenade.mdl"

SWEP.Granade = "ent_gnade_hl2"

SWEP.dwsItemFOV = -12
SWEP.dwsItemPos = Vector(0,0,-5)

SWEP.EnableTransformModel = true

SWEP.wmVector = Vector(5,2,2)
SWEP.wmAngle = Angle(0,180,0)

SWEP.TimeDetonate = 4

if SERVER then
    function SWEP:ArmThink()
        self.nextpip = self.nextpip or CurTime()

		if self.nextpip + math.max(1 * (math.max(self.TimeStart + self.TimeDetonate - CurTime(),0) / self.TimeDetonate),0.1) <= CurTime() then
            self.nextpip = CurTime()

			sound.Emit(self:EntIndex(),"weapons/grenade/tick1.wav",75,1,100,self:GetPos())
		end
    end
else
	local GlowSprite = Material("particle/fire")
    local red = Color(255,0,0,255)

	function SWEP:DrawWorldModelPost()
		self:DrawModel()

        if self:GetNWBool("Arm") then
            render.SetMaterial(GlowSprite)
            render.DrawSprite(self:GetPos():Add(self:GetUp():Mul(10)),12 + math.Rand(-1,1),12 + math.Rand(-1,1),red)
        end
	end
end

SWEP.ExplosiveClass = "explosive_hl2"
