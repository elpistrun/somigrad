--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/inv/cl_pickup.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\inv\\cl_pickup.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local list = {}

local decay = 5
local startDecay = 0.075

net.Receive("pickup",function()
    msg = {net.ReadString(),tonumber(net.ReadString()),RealTime()}

    local lasgMsg = list[#list]

    if lasgMsg and lasgMsg[1] == msg[1] then//если неск раз подобрали аптечки
        lasgMsg[2] = lasgMsg[2] + msg[2]
        lasgMsg[3] = RealTime()

        return
    end

    list[#list + 1] = msg
end)

if IsValid(PickUpFrame) then PickUpFrame:Remove() end

local weight,height = 150,25

PickUpFrame = oop.CreatePanel("v_panel")
PickUpFrame:SetZPos(-100)

local scrollY = 0

function PickUpFrame:Draw(w,h)
    local time = RealTime()

    self:setSize(weight,math.max(#list * height,height)):setPos(ScrW() - self:W() - 25,ScrH() * 0.2)

    local i = 1

    local count = 0 

    for i,msg in pairs(list) do
        local k = math.min((msg[3] + decay - time) / decay / startDecay,1)

        if k == 1 then count = count + 1 end
    end

    scrollY = LerpFT(0.1,scrollY,count * height)

    while true do
        local msg = list[#list - i + 1]
        if not msg then break end

        local k = math.min((msg[3] + decay - time) / decay / startDecay,1)

        if k <= 0 then table.remove(list,i) continue end

        local y = (i - 1) * height

        y = y - (h - math.Round(scrollY))

        surface.SetDrawColor(35,35,35,255)
        surface.DrawRect(0,y,weight,height)
        
        draw.SimpleText(L(msg[1]),"H.12",5,y + height / 2,nil,nil,TEXT_ALIGN_CENTER)
        draw.SimpleText(msg[2],"H.12",w - 5,y + height / 2,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)

        i = i + 1
    end
end

hook.Add("HUDItemPickedUp","Hide",function() return false end)
hook.Add("HUDWeaponPickedUp","Hide",function() return false end)
hook.Add("HUDAmmoPickedUp","Hide",function() return false end)
