--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/inv/tier_0_object/cl/tier_0_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\inv\\tier_0_object\\cl\\tier_0_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
Inv.panels = Inv.panels or {}
local panels = Inv.panels

Inv.list = Inv.list or {}

net.Receive("inv open",function()
    local inv = net.ReadTable()
    local id = inv.id

    Inv.list[id] = inv

    local panel = panels[id]

    if IsValid(panel) then
        if panel.closed then
            panel:Remove()
        else
            panel:UpdateInv(inv)

            return
        end
    end

    panels[id] = hook.Run("Inv Create",inv,inv.class,inv.type)

    InvPanelsUpdate()
end)

net.Receive("inv close",function()
    local id = net.ReadString()

    Inv.list[id] = nil

    local panel = panels[id]

    hook.Run("Inv Close",id,panel)

    if IsValid(panel) then
        panel:Close()
        panel.closed = true
    end
end)

for id,inv in pairs(Inv.list) do
    if not IsValid(inv.parent) then Inv.list[id] = nil end
end

net.Receive("inv error",function()
    local id = net.ReadInt(8)
    local x,y = net.ReadInt(8),net.ReadInt(8)

    local panel = panels[id]
    
    if IsValid(panel) then
        panel:Error(x,y)
    end
end)

local panels = Inv.panels

function InvPanelsUpdate()
    for id,panel in pairs(panels) do
        if not IsValid(panel) then panels[id] =nil continue end
        if panel.Update then panel:Update() end--wtf
    end
end

hook.Add("Think","Inv Panels",InvPanelsUpdate)

function InvPanelsReCreate()
    for id,inv in pairs(Inv.list) do
        if IsValid(panels[id]) then panels[id]:Remove() end

        panels[id] = hook.Run("Inv Create",inv,inv.class,inv.type)
    end
end

//if Initialize then InvPanelsReCreate() end
