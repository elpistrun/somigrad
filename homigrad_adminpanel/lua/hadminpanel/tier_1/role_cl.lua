--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_adminpanel/lua/hadminpanel/tier_1/role_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:11 <
]]

-- "addons\\homigrad_adminpanel\\lua\\hadminpanel\\tier_1\\role_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local AdminPanelRolesManager = Create_SyncDataManager("AdminPanelRoles","AP Roles Sync","adminpanel","adminpanel_roles_sync")
local AdminPanelRolesInheritManager = Create_SyncDataManager("AdminPanelRolesInherit","AP Roles Inherit Sync","adminpanel","adminpanel_roles_inherit_sync")
local AdminPanelRolesListManager = Create_SyncDataManager("AdminPanelRolesList","AP Roles List Sync","adminpanel","adminpanel_roles_lsit_sync")

event.Add("Profile Sync","Roles",function(steamid,info)
    AdminPanelRolesInheritManager.Queue(function()
        info.roleFirst = AdminPanelRole_GetFirstRole(info.roles)
        info.roleFirstDisplay = AdminPanelRole_GetFirstRoleDisplay(info.roles)

        local ply = player.GetBySteamID(steamid)

        if IsValid(ply) then
            event.Call("AP Player Sync",ply,info.roles)
        end
    end)
end)

local empty = {}
function AdminPanelRole_HasSuccess(ply,successName)
    if not AdminPanelRoles then return false end//WTF go away pidor

    local profile = Profiles[ply:SteamID()]
    
    for name in pairs(profile and profile.roles or empty) do
        if name == "root" then return true end

        local role = AdminPanelRoles[name]
        if role and role.success[successName] then return true end
    end

    local userRole = AdminPanelRoles["user"]
    if userRole and userRole.success[successName] then return true end

    return false
end

-- Чем меньше id в AdminPanelRolesInherit, тем выше роль (GetFirstRole берёт
-- минимальный), поэтому сравнение было перевёрнуто: младшие роли "доминировали".
function AdminPanelRole_HasDominate(caller,target,isEquial)
    if not AdminPanelRoles then return false end//WTF go away pidor

    local callerRole = AdminPanelRole_GetFirstRole(caller.roles or {})
    local targetRole = AdminPanelRole_GetFirstRole(target.roles or {})

    local callerId = callerRole and AdminPanelRolesInheritByName[callerRole]
    local targetId = targetRole and AdminPanelRolesInheritByName[targetRole]

    if not callerId then return false end
    if not targetId then return true end

    if callerId < targetId then return true end
    if isEquial and callerId == targetId then return true end

    return false
end
