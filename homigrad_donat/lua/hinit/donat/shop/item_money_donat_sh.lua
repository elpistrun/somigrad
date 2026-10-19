--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_donat/lua/hinit/donat/shop/item_money_donat_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad_donat\\lua\\hinit\\donat\\shop\\item_money_donat_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ITEM = DonatItem_Reg("money_donat","base")
if not ITEM then return end

ITEM.type = "accessories"

function ITEM:GetDesc()
    return "Бутафория"
end

function ITEM:GetPrintName()
    return tostring(self.data.money or 0)
end

function ITEM:GetRaryType()
    local money = self.data.money or 0

    if money <= 200 then
        return "uncommon"
    elseif money < 1000 then
        return "rary"
    else
        return "legendary"
    end
end

//

local colorYellow = Color(255,255,0)

function ITEM:DrawObject(w,h,panel,desc)
    local mdl = self:GetCSMByID("models/jmod/resources/ingot001.mdl")

    self:OpenScene(w,h,panel,40)
        render.SetColorModulation(2,2,0.5)
        mdl:SetAngles(Angle(0,90,90) + Angle(0,-10,-20))
        mdl:SetPos(Vector(80,0,-2))
        mdl:DrawModel()
        render.SetColorModulation(1,1,1)
    self:CloseScene(w,h,panel)
end

//https://soundcloud.com/diklordefenil/ne-prichyom-karakuli-slump-chuchu
