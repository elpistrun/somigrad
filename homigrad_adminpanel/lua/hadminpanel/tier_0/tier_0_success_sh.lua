--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_adminpanel/lua/hadminpanel/tier_0/tier_0_success_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:11 <
]]

-- "addons\\homigrad_adminpanel\\lua\\hadminpanel\\tier_0\\tier_0_success_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
AdminPanelSuccess = AdminPanelSuccess or {}
AdminPanelSuccessCategory = AdminPanelSuccessCategory or {}

function AdminPanelSuccessReg(name,desc,category)
    category = category or "other"
    desc = desc or "no desc"
    
    local old = AdminPanelSuccess[name]
    
    if old and AdminPanelSuccessCategory[old.category] then
        AdminPanelSuccessCategory[old.category][name] = nil
    end

    AdminPanelSuccess[name] = AdminPanelSuccess[name] or {}
    
    local success = AdminPanelSuccess[name]
    success.desc = desc or success.desc
    success.category = category or success.category

    AdminPanelSuccessCategory[category] = AdminPanelSuccessCategory[category] or {}//FOR UI
    AdminPanelSuccessCategory[category][name] = AdminPanelSuccess[name]

    return AdminPanelSuccess[name]
end

//

function AdminPanel_GetTimeText(value)
    if value == "permament" then return "постоянно" end

    if value >= 60 * 60 * 24 * 30 then
        return math.floor(value / 60 / 60 / 24 / 30) .. " " .. L("months")
    elseif value >= 60 * 60 * 24 then
        return math.floor(value / 60 / 60 / 24) .. " " .. L("days")
    elseif value >= 60 * 60 then
        return math.floor(value / 60 / 60) .. " " .. L("hours")
    elseif value >= 60 then
        return math.floor(value / 60) .. " " .. L("minutes")
    else
        return math.floor(value) .. " " .. L("seconds")
    end
end

function AdminPanel_GetTime(time)
    time = tostring(time)
    local endPrefix = string.sub(time,#time,#time)
    local timeLess = tonumber(string.sub(time,1,#time - 1))

    if endPrefix == "s" then
        time = timeLess
    elseif endPrefix == "M" then
        time = timeLess * 60
    elseif endPrefix == "h" then
        time = timeLess * 60 * 60
    elseif endPrefix == "d" then
        time = timeLess * 60 * 60 * 24
    elseif endPrefix == "w" then
        time = timeLess * 60 * 60 * 24 * 7
    elseif endPrefix == "m" then
        time = timeLess * 60 * 60 * 24 * 31
    elseif endPrefix == "y" then
        time = timeLess * 60 * 60 * 24 * 365//капяо
    else
        if tonumber(time) <= 0 then 
            time = 0
        else
            time = tonumber(time)
        end
    end

    return time
end

