--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_donat/lua/hinit/donat/outfit/outfit_sh.lua <
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

-- "addons\\homigrad_donat\\lua\\hinit\\donat\\outfit\\outfit_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
if CLIENT then
    OutfitData = OutfitData or {}

    Create_SyncDataManager_AboutSteamID64(OutfitData,"Outfit Sync","outfit_profile_sync")
end

AdminPanelSuccessReg("ProfileChangeBackground",nil,"rights")
AdminPanelSuccessReg("ProfileBackgroundAnimated",nil,"rights")
AdminPanelSuccessReg("ProfileChangeColor",nil,"rights")
AdminPanelSuccessReg("ProfileSteamBackground",nil,"rights")

function Outfit_GetPlayerModelID(steamid64)
    return OutfitData[steamid64] and OutfitData[steamid64].playermodelItemID
end

if CLIENT then
    function Outfit_GetPlayerModel(steamid64)
        return OutfitData[steamid64] and OutfitData[steamid64].playermodelItem
    end

    local empty = {}

    event.Add("Outfit Sync","Outfit Construct",function(steamid64,data)
        if data.playermodelItemData then
            local item = {class = data.playermodelItemData.class}
            item = DonatItem_Create(item,data.playermodelItemData)
            data.playermodelItem = item
        else
            data.playermodelItem = nil
        end

        for i,item in pairs(data.items or empty) do
            item = DonatItem_Create(item,item)
            data.items[i] = item
        end
    end,1)
end
