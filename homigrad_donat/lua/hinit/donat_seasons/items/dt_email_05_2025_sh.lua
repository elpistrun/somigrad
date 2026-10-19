--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_donat/lua/hinit/donat_seasons/items/dt_email_05_2025_sh.lua <
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

-- "addons\\homigrad_donat\\lua\\hinit\\donat_seasons\\items\\dt_email_05_2025_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ITEM = DonatItem_Reg("icon_email_05_2025","base")
if not ITEM then return end

ITEM.type = "3_icons"
ITEM.cantTrade = true

function ITEM:GetDesc()
    return "Выдано тем кто успел получить самое первое письмо Марта 2025 года!\nНельзя обменять"
end

function ITEM:GetPrintName()
    return "Март 2025"
end

function ITEM:GetRaryType()
    return "legendary"
end
//

function ITEM:DrawObject(w,h,panel,desc)
    local mdl,create = CSMById("models/captainbigbutt/skeyler/hats/zhat.mdl",tostring(self))
    if create then mdl:SetNoDraw(false) end

    self:OpenScene(w,h,panel,10)
        mdl:SetAngles(Angle(30,0,0))
        mdl:SetPos(Vector(0,-1,0))
        mdl:DrawModel()
    self:CloseScene(w,h,panel)
end
