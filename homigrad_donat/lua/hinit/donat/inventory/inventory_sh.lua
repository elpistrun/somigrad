--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_donat/lua/hinit/donat/inventory/inventory_sh.lua <
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

-- "addons\\homigrad_donat\\lua\\hinit\\donat\\inventory\\inventory_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
DonatInventoryData = DonatInventoryData or {}
DonatInventoryList = DonatInventoryList or {}

if CLIENT then
    local manager = Create_SyncDataManager_AboutSteamID64(DonatInventoryData,"Donat Inventory Sync","donat_inventory_sync")
    CreateItems_SyncDataManager_AboutSteamID64("DonatInventory","DonatItem",manager)
end

DonatCategories = {
    ["1_models"] = "donat_ui_category_models",
    ["2_accessories"] = "donat_ui_category_accessories",
    ["3_icons"] = "donat_ui_category_icons",
    ["4_items"] = "donat_ui_category_items",
    ["5_case"] = "Cases"
}

//

DonatItemsRaryData = {
    common = {
        Color(0,0,0),
        Color(255,255,255),
        Color(255,255,255),
        "points50",
        {
            "physics/flesh/flesh_impact_hard2.wav",
            "physics/flesh/flesh_impact_hard3.wav"
        },
        {
            "physics/flesh/flesh_impact_bullet1.wav",
            "physics/flesh/flesh_impact_bullet2.wav",
            "physics/flesh/flesh_impact_bullet3.wav"
        },
        "Обычный",
        "homigrad/vgui/item_drop2_uncommon.wav"
    },
    uncommon = {
        Color(120,225,120),
        Color(0,0,0),
        Color(255,255,255),
        "romb",
        {
            "physics/rubber/rubber_tire_impact_hard1.wav",
            "physics/rubber/rubber_tire_impact_hard2.wav",
            "physics/rubber/rubber_tire_impact_hard3.wav"
        },
        {
            "physics/rubber/rubber_tire_impact_bullet1.wav",
            "physics/rubber/rubber_tire_impact_bullet2.wav",
            "physics/rubber/rubber_tire_impact_bullet3.wav"
        },
        "Необычный",
        "homigrad/vgui/item_drop2_uncommon.wav"
    },
    rary = {
        Color(164,67,233),
        Color(0,0,0),
        Color(255,255,255),
        "box_i",
        {
            "physics/wood/wood_plank_impact_soft1.wav",
            "physics/wood/wood_plank_impact_soft2.wav",
            "physics/wood/wood_plank_impact_soft3.wav"
        },
        {
            "physics/wood/wood_box_impact_bullet1.wav",
            "physics/wood/wood_box_impact_bullet2.wav",
            "physics/wood/wood_box_impact_bullet3.wav",
        },
        "Редкий",
        "homigrad/vgui/item_drop3_rare.wav"
    },
    legendary = {
        Color(248,250,112),
        Color(255,0,0),
        Color(255,0,0),
        "pletanka",
        {
            "physics/glass/glass_bottle_impact_hard1.wav",
            "physics/glass/glass_bottle_impact_hard2.wav",
            "physics/glass/glass_bottle_impact_hard3.wav"
        },
        {
            "physics/glass/glass_pottery_break1.wav",
            "physics/glass/glass_pottery_break2.wav",
            "physics/glass/glass_pottery_break3.wav"
        },
        "Легендарный",
        "homigrad/vgui/item_drop4_mythical.wav"
    },
    epic = {
        Color(76,252,255),
        Color(255,255,0),
        Color(255,255,0),
        "romb_d",
        {
            "physics/metal/metal_box_impact_bullet1.wav",
            "physics/metal/metal_box_impact_bullet2.wav",
            "physics/metal/metal_box_impact_bullet3.wav"
        },
        {
            "physics/metal/metal_chainlink_impact_hard1.wav",
            "physics/metal/metal_chainlink_impact_hard2.wav",
            "physics/metal/metal_chainlink_impact_hard3.wav"
        },
        "Эпичский",
        "homigrad/vgui/item_drop6_ancient.wav"
    }
}

DonatItemsRaryDataIndex = {
    common = 5,
    uncommon = 4,
    rary = 3,
    legendary = 2,
    epic = 1
}

DonatItemsRaryDataIndexToName = {
    "epic",
    "legendary",
    "rary",
    "uncommon",
    "common"
}

function DonatItem_GetSortTable(inventory,sortType)
    local sort = {}

    for id,item in pairs(inventory) do
        if sortType and item.type != sortType then continue end

        local id = DonatItemsRaryDataIndex[item:GetRaryType()] or 0
        sort[id] = sort[id] or {}
        sort[id][#sort[id] + 1] = item
    end

    local result = {}

    for id,list in SortedPairs(sort) do
        table.sort(list,function(a,b) return a:GetPrintName() < b:GetPrintName() end)

        for _,item in pairs(list) do
            result[#result + 1] = item
        end
    end

    return result
end

function DonatXPGetText(xp)
    xp = tostring(xp)
    local text = ""

    for i = 1,math.ceil(#xp / 3) do
        if text == "" then
            text = string.sub(xp,math.max(#xp - 3 * i + 1,0),#xp - 3 * (i - 1))
        else
            text = string.sub(xp,math.max(#xp - 3 * i + 1,0),#xp - 3 * (i - 1)) .. " " .. text
        end
    end

    return text
end

function DonatGetTimeLess(timeAgo)
    local text
    if timeAgo < 60 then
        text = timeAgo .. " " .. L("seconds")
    elseif timeAgo < 60 * 60 then
        text = math.floor(timeAgo / 60) .. " " .. L("minutes")
    elseif timeAgo < 60 * 60 * 24 then
        text = math.floor(timeAgo / (60 * 60)) .. " " .. L("hours")
    else
        text = math.floor(timeAgo / (60 * 60 * 24)) .. " " .. L("days")
    end

    return text
end
