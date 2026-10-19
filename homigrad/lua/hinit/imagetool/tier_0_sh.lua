--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/imagetool/tier_0_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad\\lua\\hinit\\imagetool\\tier_0_sh.lua"
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


ImageTool = ImageTool or {}
ImageTool._INFORMATION = ImageTool._INFORMATION or {
    _TITLE = "Image Tool",
    _DESCRIPTION = "This system allows you to create Pictures on your map.",
    _AUTHOR = "Selenter",
    _VERSION = 0.1
}

ImageTool.path = "imagetool" -- путь к папке хранения
ImageTool.prefix = "[ImageTool]" -- Префикс для сообщений в чате

ImageTool.cacheMaterials = ImageTool.cacheMaterials or {} -- Закешированные материалы
ImageTool.requestList = ImageTool.requestList or {} -- Все запросы на сайты
ImageTool.notifyErr = ImageTool.notifyErr or {} -- Сайты которые выдают ошибки
ImageTool.imageList = ImageTool.imageList or {} -- Список картинок которые отображаются в мире

ImageTool.config = "config.txt" -- файл с конфигом
ImageTool.history = "history.txt" -- файл с иторией

-- Создаем каталог с картинками
file.CreateDir(ImageTool.path)
file.CreateDir(ImageTool.path .. "/" .. game.GetMap())


