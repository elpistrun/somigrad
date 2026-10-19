--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/drgbase/lua/weapons/drgbase_weapon/misc.lua <
    > Callstack: addons/drgbase/lua/weapons/drgbase_weapon/shared.lua:25 <
]]


function SWEP:ShootBullet(damage, num_bullets, aimcone)
	local bullet = {}
	bullet.Num = num_bullets
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Spread = Vector(aimcone, aimcone, 0)
	bullet.Tracer	= 1
	bullet.Force = damage/10
	bullet.Damage	= damage
	bullet.AmmoType = "Pistol"
	bullet.Callback = function(ent, tr, dmg)
		dmg:SetAttacker(self:GetOwner())
		dmg:SetInflictor(self)
	end
	self:GetOwner():FireBullets(bullet)
	self:ShootEffects()
end

