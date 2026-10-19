--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/metabolism/breath_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\metabolism\\breath_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
event.Add("Player Think","Breath Bone",function(ply)
    local time = ply.breathTime
    if not time then return end

    local delay = ply.breathDelay
    local mode = ply.breathMode

    local anim = (mode == "out" and 1 or 0) - (ply.breathTime - CurTime() + ply.breathDelay) / ply.breathDelay

    anim = math.cos(math.rad(180 * anim))

    if ply:KeyDown(IN_DUCK) then anim = anim / 5 end

    ply.breathAnim = LerpFT(0.8,ply.breathAnim or 0,anim)
end)

event.Add("Bones","Breath",function(ply,link)
    if not link.breathAnim then return end

    ply:AddBoneAng("spine",Angle(0,-link.breathAnim * (1 - link.breathDelay) * 10,0))
end)
