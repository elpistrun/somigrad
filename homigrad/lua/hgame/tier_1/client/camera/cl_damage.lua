--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/client/camera/cl_damage.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\client\\camera\\cl_damage.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local screenShake = 0
local punchAngK = 0
local puncAng = Angle()

local Rand = math.Rand

net.Receive("you get damage",function()
    local dmgTab = net.ReadTable()
    local dmg = dmgTab.dmg

    if dmgTab.isExplosive then
        screenShake = math.min(screenShake + dmg,2)
    end

    punchAngK = punchAngK + 1

    dmg = dmg / 10

    local addAng = dmgTab.pos and (dmgTab.pos - EyePos()):Angle():Div(10):Mul(dmg) or Angle(Rand(-dmg,dmg),Rand(-dmg,dmg))
    addAng:Div(1 + LocalPlayer():GetNWFloat("painlosing") * 40)
    
    event.Call("Camera Shake Damage",addAng)
    
    puncAng = puncAng:Add(addAng)
end)

event.Add("PreCalcView","Damage",function(ply,view)
    local vec = view.vec or view.origin
    local ang = view.ang or view.angles

    punchAngK = LerpFT(0.1,punchAngK,0)
    screenShake = LerpFT(0.1,screenShake,0)

    if vec then
        vec:Add(Vector(Rand(-screenShake,screenShake),Rand(-screenShake,screenShake),Rand(-screenShake,screenShake)))
    end
    if ang then
        ang:Add(puncAng * punchAngK)
        ang[3] = ang[3] + puncAng[2] * punchAngK
    end

    puncAng:LerpFT(0.1)
end)
