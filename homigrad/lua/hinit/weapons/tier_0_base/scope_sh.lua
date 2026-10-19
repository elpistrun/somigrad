--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/weapons/tier_0_base/scope_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hinit/weapons/tier_0_base/tier_0_sh.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:143
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

-- "addons\\homigrad\\lua\\hinit\\weapons\\tier_0_base\\scope_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Get("hg_wep")
if not SWEP then return end

SWEP.lerpScope = 0

function SWEP:IsScopePre() return true end

function SWEP:IsScope()
	local ply = self:GetOwner()
	if not IsValid(ply) then return false end
	if ply:GetNWBool("fake") or ply.Fake or IsValid(ply:GetNWEntity("Ragdoll")) or IsValid(ply:GetNWEntity("FakeRagdoll")) then return false end

	if self:IsLocal() then
		if not self:CanFight() then return false end

		if ply:KeyDown(IN_ATTACK2) and not ply:GetNWBool("Suiciding") then return self:IsScopePre() end
	else
		return self:GetNWBool("IsScope")
	end

	return false
end

SWEP:Event_Add("Think","Scope",function(self,owner)
	if not self:IsLocal() or owner:IsNPC() then return end

	local scope = self:IsScope()

	if SERVER then
		self:SetNWBool("IsScope",scope)
	elseif self:IsLocal() then
		if self.oldScope ~= scope then
			self.oldScope = scope

			SoundEmit(scope and (self.ZoomInSound or "homigrad/player/deploy1.wav") or (self.ZoomOutSound or "homigrad/player/holster2.wav"),70,1,125,owner:GetPos())
		end
	end
end)
