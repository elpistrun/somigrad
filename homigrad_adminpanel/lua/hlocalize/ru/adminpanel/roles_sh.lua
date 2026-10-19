--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_adminpanel/lua/hlocalize/ru/adminpanel/roles_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:8 <
]]

-- "addons\\homigrad_adminpanel\\lua\\hlocalize\\ru\\adminpanel\\roles_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local l = LOCALIZE.ru

l.ap_invaid_steamid32 = "Неверный формат SteamID32."
l.ap_invalid_role = "Такой роли не существует."
l.ap_exists_steamid32 = "SteamID32 уже есть в списке."
l.ap_not_exists_steamid32 = "SteamID32 уже нет в списке."

l.ap_invalid_role = "Такой роли нет."
l.ap_error_success_param = "Редактируемые права для этой роли не выданы"
l.ap_error_success_noparam = "Редактируемые права не имеют параметров"
l.ap_invalid_success_param = "Неверное имя параметра"

l.ap_error_edit_general_role = "Нельзя редактировать эту роль"

l.ap_error_role_rename = "Такой роли нет или имена равны"
l.ap_error_inherit = "Нельзя выставлять эту иерархию"


l.ap_role_create = "Создана роль %s"
l.ap_role_delete = "Переименована роль %s в %s"
l.ap_role_inherit = "Изменена иерархия на %s у роли %s"

l.ap_role_user_add = "Выдана роль %s пользователю %s"
l.ap_role_user_remove = "Отобрана роль %s у пользователя %s"

l.ap_invalid_inherit = "Выше %s выставить нельзя."

l.ap_ui_need_access = "ЭТО ДОСТУПНО ТОЛЬКО С %s"
