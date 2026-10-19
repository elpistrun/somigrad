--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/drgbase/lua/entities/proj_drg_default/meta.lua <
    > Callstack: addons/drgbase/lua/entities/proj_drg_default/shared.lua:31 <
]]


local entMETA = FindMetaTable("Entity")

if SERVER then

	local old_GetVelocity = entMETA.GetVelocity
	function entMETA:GetVelocity()
		if self.IsDrGProjectile then
			local phys = self:GetPhysicsObject()
			if IsValid(phys) then
				return phys:GetVelocity()
			else return old_GetVelocity(self) end
		else return old_GetVelocity(self) end
	end

	local old_SetVelocity = entMETA.SetVelocity
	function entMETA:SetVelocity(velocity)
		if self.IsDrGProjectile then
			local phys = self:GetPhysicsObject()
			if IsValid(phys) then
				return phys:SetVelocity(velocity)
			else return old_SetVelocity(self, velocity) end
		else return old_SetVelocity(self, velocity) end
	end

end

