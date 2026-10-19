--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/armor/ent_armor_base/tier_0_sh.lua <
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

-- "addons\\homigrad\\lua\\hgame\\tier_1\\armor\\ent_armor_base\\tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("ent_armor_base","base_entity",true)
if not ENT then return INCLUDE_BREAK end

ENT.Author = "Jackarunda & 0oa"
ENT.NoSitAllowed = true
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.JModEZstorable = true

ENT.itemType = "armor"

if SERVER then return end

function ENT:Draw() self:DrawModel() end

local white = Color(255,255,255)

function ENT:HUDTarget(ent,k,w,h)
	white.a = 255 * k
	local anim = (50 * (1 - k))

	draw.SimpleText(self.PrintName,"H.18",w / 2,h / 2 + 25 * k + anim,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
end

function ENT:DrawInv(item,w,h,butt)
	local icon = isfunction(EntityIcon) and EntityIcon(item.spawnname)
	local hov = (butt and butt.hovered) or 0
	local size = h - 14 + hov * 5

	if icon and not icon:IsError() then
		surface.SetMaterial(icon)
		surface.SetDrawColor(255,255,255)
		surface.DrawTexturedRect(w / 2 - size / 2 + 1,h / 2 - size / 2 + 1,size,size)
		return true
	elseif self.WorldModel then
		local x,y = butt:LocalToScreen()
		DrawWeaponSelectionEX(self,x,y,w,h - 13,true,-hov * 1)
		return true
	end
	return false
end

