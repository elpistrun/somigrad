--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/hinit/devtools/radarhack_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad_core\\lua\\hinit\\devtools\\radarhack_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
net.Receive("RadarHack_stream",function()
    DataBase:Read({token = net.ReadString(),callback = function(res)
        RadarHackScreenShoot = util.JSONToTableUnLimit(res.body)
    end})
end)

local green = Color(0,255,0)

local function drawText(x,y,text)
    surface.SetFont("H.12")

    local tw,th = surface.GetTextSize(text)
    surface.SetTextColor(255,255,255)
    surface.SetTextPos(x,y)
    surface.SetDrawColor(0,0,0)
    surface.DrawRect(x,y,tw,th)
    surface.DrawText(text)
end

local Distance = 4000
local Hide = false
local old

hook.Add("HUDPaint","RadarHack",function()
    if not LocalPlayer():GetNWBool("EverythingWallHackAccess") then return end

    local y = ScrH()

    drawText(0,y - 24,"Hold H and rotate whellmouse to change distance")
    drawText(0,y - 12,"Press J to disable hud")

    local y = ScrH() / 2

    local active =input.IsButtonDown(KEY_J)

    if old ~= active then
        old = active

        if active then
            Hide = not Hide
        end
    end

    if Hide then
        drawText(0,y,"EverythingWallHack Disabled")

        return
    end

    for i,info in pairs(RadarHackScreenShoot) do
        if info[2]:Distance(EyePos()) > Distance then continue end

        local pos = info[2]:ToScreen()
        if not pos.visible then continue end

        draw.SimpleText(info[1],"HS.12",pos.x,pos.y,info[3],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    drawText(0,y,"EverythingWallHack Enabled")
    drawText(0,y + 12,"Distance: " .. Distance)

    if input.IsButtonDown(KEY_H) then
        Distance = Distance + wheel * 100
    end
end)

AdminPanel_Command_Registry("radarhack",{"bool"},"game",nil,"rcon")
