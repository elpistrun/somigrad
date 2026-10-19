--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_donat/lua/hinit/donat_seasons/items/dt_old_sh.lua <
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

-- "addons\\homigrad_donat\\lua\\hinit\\donat_seasons\\items\\dt_old_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ITEM = DonatItem_Reg("icon_old","base")
if not ITEM then return end

ITEM.type = "3_icons"
ITEM.cantTrade = true

function ITEM:GetDesc()
    return "Выдано тем наиграл хотябы раз заходил до появления донат инвентаря\nНу спасибо что хоть зашёл один раз\nНельзя обменять."
end

function ITEM:GetPrintName()
    return "Да я был там!"
end

function ITEM:GetRaryType()
    return "legendary"
end
//

function ITEM:DrawObject(w,h,panel,desc)
    local mdl,create = CSMById("models/foodnhouseholditems/juice.mdl",tostring(self))
    if create then mdl:SetNoDraw(false) end

    self:OpenScene(w,h,panel,18)
        mdl:SetAngles(Angle(-2,-25,0))
        mdl:SetPos(Vector(50,0,4))
        mdl:DrawModel()
    self:CloseScene(w,h,panel)
end
