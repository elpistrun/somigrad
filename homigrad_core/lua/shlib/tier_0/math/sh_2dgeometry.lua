--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_0/math/sh_2dgeometry.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_0\\math\\sh_2dgeometry.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
function math.boxinbox(x1,y1,w1,h1,x2,y2,w2,h2)
    return
        ((x2 + w2 >= x1 or x2 >= x1) and x2 <= x1 + w1) and
        ((y2 + h2 >= y1 or y2 >= y1) and y2 <= y1 + h1)
end

function math.pointinbox(x1,y1,x2,y2,w2,h2)
    return
        (x1 > x2 and x1 < x2 + w2) and 
        (y1 > y2 and y1 < y2 + h2)
end

/*if SERVER then return end

hook.Add("HUDPaint","Test",function()
    local box = {
        x = 512,
        y = 512,
        w = 25,
        h = 25
    }

    local box2 = {
        x = 0,
        y = 0,
        w = 25,
        h = 25
    }

    box2.x = gui.MouseX()
    box2.y = gui.MouseY()

    if math.boxinbox(box.x,box.y,box.w,box.h,box2.x,box2.y,box2.w,box2.h) then
        surface.SetDrawColor(0,255,0)
    else
        surface.SetDrawColor(255,255,255)
    end

    surface.DrawRect(box.x,box.y,box.w,box.h)
    surface.DrawRect(box2.x,box2.y,box2.w,box2.h)
end)*/
