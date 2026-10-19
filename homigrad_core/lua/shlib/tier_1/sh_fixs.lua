--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_1/sh_fixs.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_1\\sh_fixs.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
if SERVER then
    event.Add("Player Think 1","HasGodMode Rep",function(ply) ply:SetNWBool("HasGodMode",ply:HasGodMode()) end)
    hook.Add("UpdateAnimation","RemoveNoclipLayer",function(ply,event,data) ply:RemoveGesture(ACT_GMOD_NOCLIP_LAYER) end)
else
    FindMetaTable("Player").HasGodMode = function(self) return self:GetNWBool("HasGodMode") end
end
