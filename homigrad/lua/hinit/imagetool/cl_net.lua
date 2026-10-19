--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/imagetool/cl_net.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad\\lua\\hinit\\imagetool\\cl_net.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
--[[
        © AsterionStaff 2022.
        This script was created from the developers of the AsterionTeam.
        You can get more information from one of the links below:
            Site - https://asterion.games
            Discord - https://discord.gg/CtfS8r5W3M
        
        developer(s):
            Selenter - https://steamcommunity.com/id/selenter

        ——— Chop your own wood and it will warm you twice.
]]--


-- Получаем новую картинку
net.Receive("image.SendImage", function()
    local length = net.ReadUInt(32)
    local id = net.ReadUInt(32)
    local data = net.ReadData(length)

    local uncompressed = util.Decompress(data)
    local info = util.JSONToTable(uncompressed)

    ImageTool.imageList[id] = info -- Добавляем

    if ImageTool:IsUsesTool(LocalPlayer()) then
        LocalPlayer():ChatPrint(ImageTool.prefix .. " Image was added successfully! (ID: " .. id .. ")")
    end
end)

-- Удаляем картинку
net.Receive("image.RemoveImage", function()
    local id = net.ReadUInt(32)

    ImageTool.imageList[id] = nil -- Удаляем

    if ImageTool:IsUsesTool(LocalPlayer()) then
        LocalPlayer():ChatPrint(ImageTool.prefix .. " Image has been successfully deleted! (ID: " .. id .. ")")
    end
end)

-- Удаляем все картинки
net.Receive("image.RemoveImageAll", function()
    for id in pairs(ImageTool:GetImages()) do
        ImageTool.imageList[id] = nil -- Удаляем
    end

    if ImageTool:IsUsesTool(LocalPlayer()) then
        LocalPlayer():ChatPrint(ImageTool.prefix .. " All pictures have been removed from the world!")
    end
end)

-- Сохраняем картинку в истории
net.Receive("image.SaveImage", function()
    local url = net.ReadString()

    local history = ImageTool:GetHistory() or {}

    -- Если такой url уже есть в истории, то не сохраняем
    for k, v in ipairs(history) do
        if v == url then
            return
        end
    end

    table.insert(history, url)
    ImageTool:SaveHistory(history)

    ImageTool:LoadingHistory()
end)
