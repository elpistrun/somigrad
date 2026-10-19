--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/base_glide/tier_0_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad\\lua\\hinit\\base_glide\\tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("base_glide","base_entity",true)
if not ENT then return INCLUDE_BREAK end

if not ENT:InheritFromScriptedEnt("base_glide") then return INCLUDE_BREAK end

ENT.BypassEngineCamera = true

Glide.List = Glide.List or {}

local handle = ENT.Initialize
function ENT:Initialize()
    handle(self)

    Glide.List[self] = true
end

local handle = ENT.OnRemove
function ENT:OnRemove()
    handle(self)

    Glide.List[self] = nil
end

hook.Remove("HUDDrawTargetID", "Glide.HUDDrawTargetID")

