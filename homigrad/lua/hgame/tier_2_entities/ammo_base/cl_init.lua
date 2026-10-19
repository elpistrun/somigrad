--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/ammo_base/cl_init.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hgame/tier_2_entities/ammo_base/tier_0_sh.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\ammo_base\\cl_init.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Get("ammo_base")
if not ENT then return end

function ENT:DrawInv(item,w,h,butt)
	if not self.Icon then
		local x,y = butt:LocalToScreen()
                
		DrawWeaponSelectionEX(self,x,y,w,h - 13,true,-butt.hovered * 1)
	else
		local size = h - 14 + butt.hovered * 5

		surface.SetMaterial(self.Icon)

		surface.SetDrawColor(255,255,255)
		surface.DrawTexturedRect(w / 2 - size / 2 + 1,h / 2 - size / 2 + 1,size,size)	
	end

	draw.SimpleText("x" .. item.count,"InvFont",4,2)
end
