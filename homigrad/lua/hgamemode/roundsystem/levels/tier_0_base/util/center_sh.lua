--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/levels/tier_0_base/util/center_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hgamemode/roundsystem/levels/tier_0_base/tier_0_sh.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\levels\\tier_0_base\\util\\center_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Level = oop.Get("level_base")
if not Level then return end

function Level.KCenter(pos,point)
	local dis

	for i,point in pairs(point) do
		local dis2 = math.min(math.max(pos:Distance(point.pos) / (point.dis or 0) - 0.95,0) / 0.05,1)
        if not dis then dis = dis2 continue end
        
	    if dis2 < dis then dis = dis2 end
	end

	return dis
end

if SERVER then return end

local grtodown = Material( "vgui/gradient-u" )
local grtoup = Material( "vgui/gradient-d" )
local grtoright = Material( "vgui/gradient-l" )
local grtoleft = Material( "vgui/gradient-r" )

local red = Color(255,0,0)

function Level:DrawCenter()
    local lply = LocalPlayer()
    
    if not PointsList.center or not lply:Alive() then return end

    local point = PointsList.center.list
    if not point or #point == 0 then return end
    
    local dis = self.KCenter(lply:GetPos(),point)

    local w,h = ScrW(),ScrH()
    local k = 1 - math.cos(CurTime() * 2) / 6
    k = k * dis

    surface.SetAlphaMultiplier(k)

    surface.SetMaterial(grtodown)
    surface.SetDrawColor(128,0,0,64)
    surface.DrawTexturedRect(0,0,w,h * k)

    surface.SetMaterial(grtoup)
    surface.SetDrawColor(128,0,0,64)
    surface.DrawTexturedRect(0,h - h * k,w,h * k + 1)

    surface.SetMaterial(grtoright)
    surface.SetDrawColor(128,0,0,64)
    surface.DrawTexturedRect(0,0,w * k / 2,h)

    surface.SetMaterial(grtoleft)
    surface.SetDrawColor(128,0,0,64)
    surface.DrawTexturedRect(w - w * k / 2,0,w * k / 2 + 1,h)

    draw.SimpleText("ЗАПРЕТНАЯ ЗОНА","HS.45",w / 2,h / 2 - h * 0.15,red,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

    surface.SetAlphaMultiplier(1)
end
