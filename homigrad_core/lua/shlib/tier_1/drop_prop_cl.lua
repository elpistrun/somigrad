--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_1/drop_prop_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_1\\drop_prop_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local function Draw(self)
    local k = (self.Start + 4 - CurTime()) / 4
    if k <= 0 then timer.Simple(0,function() if IsValid(self) then self:Remove() end end) return end

    render.SetBlend(k)
    self:DrawModel()
    render.SetBlend(1)
end

function DropProp(mdl,scale,pos,ang,vel,angvel)
    local mdl = ents.CreateClientProp(mdl)
    if not IsValid(mdl) then return end

    mdl:SetPos(pos)
    mdl:SetAngles(ang)
    mdl:Spawn()

    local phys = mdl:GetPhysicsObject()
    if not IsValid(phys) then mdl:Remove() return end

    mdl:SetModelScale(scale or 1)

    phys:SetMass(1)
    phys:SetVelocity(vel)
    phys:SetAngleVelocity(angvel)
    phys:Wake()

    /*mdl.Start = CurTime()
    mdl.RenderOverride = Draw*/

    mdl:DestroyShadow()

    return mdl
end

