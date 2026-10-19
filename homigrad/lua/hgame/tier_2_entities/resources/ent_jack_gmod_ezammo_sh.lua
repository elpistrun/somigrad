--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/resources/ent_jack_gmod_ezammo_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\resources\\ent_jack_gmod_ezammo_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("ent_jack_gmod_ezammo",{"ent_resource_base"})
if not ENT then return end

ENT.PrintName = "Ammo Box"
ENT.IconOverride = "materials/ez_resource_icons/ammo.png"

ENT.Spawnable = true

ENT.WorldModel = "models/jmod/items/BoxJRounds.mdl"
ENT.WorldMaterial = "models/mat_jack_gmod_ezammobox"
ENT.WorldMass = 50

ENT.ImpactNoise1 = "Metal_Box.ImpactHard"
ENT.ImpactNoise2 = "Weapon.ImpactSoft"

ENT.BreakNoise = "Metal_Box.Break"
ENT.DontRagdollUse = true

local ShellEffects = {"RifleShellEject", "PistolShellEject", "ShotgunShellEject"}

ENT.InventoryIcon = Material("ez_resource_icons/ammo.png")

ENT.InvCountLimit = 100

if SERVER then
	function ENT:UseEffect(pos, ent)
		for i = 1, 30 do
			timer.Simple(i / 200, function()
				local Eff = EffectData()
				Eff:SetOrigin(pos)
				Eff:SetAngles((VectorRand() + Vector(0, 0, 1)):GetNormalized():Angle())
				Eff:SetEntity(ent)
				util.Effect(table.Random(ShellEffects), Eff, true, true)
			end)
		end
	end

    function ENT:OnInit()
        self:SetInvCount(100)
    end

	function ENT:Use(ply)
        if self.removed then return end
        
        if not ply:KeyDown(IN_WALK) then
            self:Pickup(ply)
            
            return
        end

		local wep = ply:GetActiveWeapon()
        if not IsValid(wep) then return end

        local ammoType = wep:GetPrimaryAmmoType()

        ply:GiveAmmo(30,ammoType)
        self:SetInvCount(self:GetInvCount() - 10)

        if self:GetInvCount() <= 0 then self.removed = true self:Remove() end

        self:UseEffect(self:GetPos(),self)
	end
elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()

		/*JMod.HoloGraphicDisplay(self, Vector(1, 5, 9), Angle(-90, 0, 90), .04, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.AMMO, self:GetResource(), nil, 0, 0, 200, false)
		end)*/
	end
end
