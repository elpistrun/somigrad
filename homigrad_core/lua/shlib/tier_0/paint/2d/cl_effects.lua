--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_0/paint/2d/cl_effects.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_0\\paint\\2d\\cl_effects.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local blurMaterial = Material('pp/bokehblur')

function RenderScreenspaceEffects_DrawBlur(k)
    render.UpdateScreenEffectTexture()
    blurMaterial:SetTexture("$BASETEXTURE", render.GetScreenEffectTexture())
    blurMaterial:SetTexture("$DEPTHTEXTURE", render.GetResolvedFullFrameDepth())
    blurMaterial:SetFloat("$size",(k * 300) ^ 0.5)
    blurMaterial:SetFloat("$focus", 1)
    blurMaterial:SetFloat("$focusradius", 1)
    render.SetMaterial(blurMaterial)
    render.DrawScreenQuad()
end
