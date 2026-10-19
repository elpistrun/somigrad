--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/base_glide/hudtarget_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hinit/base_glide/tier_0_sh.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad\\lua\\hinit\\base_glide\\hudtarget_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Get("base_glide")
if not ENT then return end

function ENT:HUDTarget(_,k)
    if LocalPlayer():InVehicle() then return false end

    surface.SetAlphaMultiplier(k)

    local w,h = ScrW(),ScrH()

    if self:GetIsLocked() then
        draw.SimpleText(L("car_lock_by",self:GetNWString("LockerOwnerName")),"HS.18",w / 2,h / 2 - 50 * (1 - k),nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    else
        draw.SimpleText(L("car_enter"),"HS.18",w / 2,h / 2 - 50 * (1 - k),nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    surface.SetAlphaMultiplier(1)
end
