--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_0/paint/cl_draw_interface.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_0\\paint\\cl_draw_interface.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
hook.Add("Initialize","ScrWscrH",function()
    scrw = ScrW()
    scrh = ScrH()
end)

scrw = ScrW()
scrh = ScrH()

ScreenR = ScrW() / ScrH()

hook.Add("OnScreenSizeChanged","Fuck",function(oldw,oldh,w,h)
    scrw = ScrW()
    scrh = ScrH()

    ScreenR = ScrW() / ScrH()
end)

concommand.Add("hg_fakescreenwh",function(ply,cmd,args)
    scrw = tonumber(args[1] or ScrW()) or ScrW()
    scrh = tonumber(args[2] or ScrH()) or ScrH()
end)

FindMetaTable("Vector").ToScreen2 = function(self)
    local pos = self:ToScreen()

    pos.x = pos.x * (ScrW() / scrw)
    pos.y = pos.y * (ScrH() / scrh)

    return pos
end

local oldX,oldY = gui.MouseX(),gui.MouseY()
local oldFocus = false
local delay = 0

mousedx = 0
mousedy = 0

mousex = 0
mousey = 0

wheel = 0

event.Add("Think","Interface PrePare Input",function()
    IsWindow = not system.HasFocus()

    local x,y = gui.MouseX(),gui.MouseY()
    local focus = system.HasFocus()
    local time = CurTime()

    if oldFocus ~= focus then
        if focus then delay = time + 0.25 end

        InWindowTime = time
        InWindow = focus
        
        hook.Run("Window",focus)

        oldFocus = focus
    end

    if focus and delay < time then
        mousedx = oldX - x
        mousedy = oldY - y

        mousex = x
        mousey = y
    end

    oldX = x
    oldY = y
end,-10)

hook.Add("InputMouseApply","!Interface PrePare Input",function(cmd, x, y, ang)
    if wheel == 0 then wheel = cmd:GetMouseWheel() end
end)//когда vgui открыто он заглатывает хуи в рот, ну сука это пиздец я не хочу цеплдять к каждой панели функцию захвата ебаного колёсиука мышкивыпащльыхвыфх0

hook.Add("PostRender","Reset Interface",function()
    wheel = 0
end)

EntityIconChache = {}

function EntityIcon(name)
    if not name then return nil end
    local mat = EntityIconChache[name]
    if mat == false then return nil end
    if mat then return mat end

    mat = Material("entities/" .. tostring(name) .. ".png", "GAME")
    if mat and not mat:IsError() then
        EntityIconChache[name] = mat
        return mat
    end

    mat = Material("vgui/entities/" .. tostring(name) .. ".png", "GAME")
    if mat and not mat:IsError() then
        EntityIconChache[name] = mat
        return mat
    end

    mat = Material("vgui/entities/" .. tostring(name), "GAME")
    if mat and not mat:IsError() then
        EntityIconChache[name] = mat
        return mat
    end

    EntityIconChache[name] = false
    return nil
end

hook.Add("HUDPaint","Homigrad",function()
    event.Call("HUDPaint",LocalPlayer(),CurTime())
end)

local blurmat = Material("pp/blurscreen")
local UpdateScreenEffectTexture = render.UpdateScreenEffectTexture
local DrawTexturedRect = surface.DrawTexturedRect

function DrawBlur(amount,x,y)
    surface.SetMaterial(blurmat)

    local i = 0

    ::start::
    i = i + 1
   
    blurmat:SetFloat("$blur",(i / 3) * amount)
    blurmat:Recompute()

    x,y = x or 0,y or 0
    
    UpdateScreenEffectTexture()
    DrawTexturedRect(-x,-y,ScrW(),ScrH())

    if i >= amount then return end
    
    goto start
end

function DrawBlurByPanel(amount,panel)
    local x,y = panel:LocalToScreen(0,0)
    DrawBlur(amount,x,y)
end

