--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_adminpanel/lua/hadminpanel/tier_1/role_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:11 <
]]

-- "addons\\homigrad_adminpanel\\lua\\hadminpanel\\tier_1\\role_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
//Прописываю тут потому-что не хочу отдавать файлом и лишний раз серв нагружать

AdminPanelSuccessReg("role_list",nil,"rights")
AdminPanelSuccessReg("lua_superadmin",nil,"rights")
AdminPanelSuccessReg("lua_admin",nil,"rights")

local success = AdminPanelSuccessReg("discord_role_id",nil,"rights")
success.parametrs = {
    {name = "role_id",type = "string"}
}

AdminPanel_Command_Registry("role_create",{"string"}):SetType("async"):SetCategory("roles")
AdminPanel_Command_Registry("role_remove",{"string"}):SetType("async"):SetCategory("roles")
AdminPanel_Command_Registry("role_rename",{"string","string"}):SetType("async"):SetCategory("roles")

AdminPanel_Command_Registry("role_user_add",{"string","string"}):SetType("async"):SetCategory("roles")
AdminPanel_Command_Registry("role_user_remove",{"string","string"}):SetType("async"):SetCategory("roles")

AdminPanel_Command_Registry("role_success_set",{
{type = "string",name = "role",required = true},
{type = "string",name = "success",required = true},
{type = "bool",name = "access",required = true}
}):SetType("async"):SetCategory("roles")

AdminPanel_Command_Registry("role_success_set_parametr",{
{type = "string",name = "role",required = true},
{type = "string",name = "success",required = true},
{type = "string",name = "parametr",required = true},
{type = "string",name = "value"}
}):SetType("async"):SetCategory("roles")

AdminPanel_Command_Registry("role_deny_set",{"string","string"}):SetType("async"):SetCategory("roles")
AdminPanel_Command_Registry("role_set_inherit",{"string","number"}):SetType("async"):SetCategory("roles")

AdminPanel_Command_Registry("role_getsuccess",{"string"}):SetCategory("roles")
AdminPanel_Command_Registry("role_getlist",{}):SetCategory("roles")

AdminPanel_Command_Registry("role_setcolor",{"string","number","number","number"}):SetType("async"):SetCategory("roles")
AdminPanel_Command_Registry("role_setname",{"string","string"}):SetType("async"):SetCategory("roles")

AdminPanelSuccessReg("dontShowUserGroup",nil,"rights")
AdminPanelSuccessReg("visibleHidenUserGroup",nil,"rights")

AdminPanelSuccessReg("admin_chat_visible",nil,"rights")
AdminPanel_Command_Registry("admin_chat",{"line"},nil,"async","admin_operator").dontShowGUI = true

//

event.Add("AP Roles Inherit Sync","IDByName",function()
    AdminPanelRolesInheritByName = {}
    
    for id,name in pairs(AdminPanelRolesInherit) do
        AdminPanelRolesInheritByName[name] = id
    end
end,-10)

function AdminPanelRole_GetFirstRole(roles)
    local roleFirst
    for name in pairs(roles) do
        if not AdminPanelRolesInheritByName[name] then continue end
        
        if not roleFirst or AdminPanelRolesInheritByName[roleFirst] > AdminPanelRolesInheritByName[name] then roleFirst = name end
    end
    return roleFirst
end

function AdminPanelRole_GetFirstRoleDisplay(roles)
    local roleFirst
    for name in pairs(roles) do
        local role = AdminPanelRoles and AdminPanelRoles[name]
        if not AdminPanelRolesInheritByName[name] or (role and role.success.dontShowUserGroup) then continue end
        
        if not roleFirst or AdminPanelRolesInheritByName[roleFirst] > AdminPanelRolesInheritByName[name] then roleFirst = name end
    end
    return roleFirst
end

function AdminPanelRole_GetSuccessNeedRole(success)
    if not AdminPanelRoles then return end

    for id,nameRole in SortedPairs(AdminPanelRolesInherit,true) do
        local role = AdminPanelRoles[nameRole]
        if role and role.success[success] then return nameRole end
    end
end

function AdminPanelRole_GetName(name)
    return AdminPanelRoles and AdminPanelRoles[name] and AdminPanelRoles[name].name or name
end

//

local PLAYER = FindMetaTable("Player")

local defaultGroupColors = {
    ["root"] = Color(255, 80, 80),
    ["superadmin"] = Color(255, 60, 60),
    ["admin"] = Color(255, 180, 80),
    ["moderator"] = Color(120, 200, 255),
    ["operator"] = Color(100, 220, 100),
    ["vip"] = Color(255, 215, 0),
    ["user"] = Color(200, 200, 200)
}

local defaultGroupTitles = {
    ["root"] = "Владелец",
    ["superadmin"] = "Суперадмин",
    ["admin"] = "Администратор",
    ["moderator"] = "Модератор",
    ["operator"] = "Оператор",
    ["vip"] = "VIP",
    ["user"] = "Игрок"
}

PLAYER.GetUserGroup = function(self)
    local profile = Profiles[self:SteamID()]
    if profile and profile.roleFirst then
        if profile.roleFirst == "root" then return "superadmin" end
        return profile.roleFirst
    end

    local gmodGroup = self:GetNWString("UserGroup", "")
    if gmodGroup ~= "" and gmodGroup ~= "user" then
        if gmodGroup == "root" then return "superadmin" end
        return gmodGroup
    end

    if ULib and ULib.ucl and ULib.ucl.authed then
        local uid = self:UniqueID()
        local uclUser = ULib.ucl.authed[uid]
        if uclUser and uclUser.group and uclUser.group ~= "" and uclUser.group ~= "user" then
            if uclUser.group == "root" then return "superadmin" end
            return uclUser.group
        end
    end

    if not AdminPanelRoles or not self:GetNWBool("Init") then return (gmodGroup ~= "" and gmodGroup) or "user" end
    return (gmodGroup ~= "" and gmodGroup) or "user"
end

PLAYER.GetUserGroupDisplay = function(self)
    local profile = Profiles[self:SteamID()]
    if profile and profile.roleFirstDisplay then
        return profile.roleFirstDisplay
    end
    if profile and profile.roleFirst then
        return profile.roleFirst
    end

    local gmodGroup = self:GetNWString("UserGroup", "")
    if gmodGroup ~= "" and gmodGroup ~= "user" then
        return gmodGroup
    end

    if ULib and ULib.ucl and ULib.ucl.authed then
        local uid = self:UniqueID()
        local uclUser = ULib.ucl.authed[uid]
        if uclUser and uclUser.group and uclUser.group ~= "" and uclUser.group ~= "user" then
            return uclUser.group
        end
    end

    if not AdminPanelRoles or not self:GetNWBool("Init") then return (gmodGroup ~= "" and gmodGroup) or "user" end
    return (gmodGroup ~= "" and gmodGroup) or "user"
end

local color_gray = Color(125,125,125)

PLAYER.GetUserColor = function(self)
    local profile = Profiles[self:SteamID()]
    local color = profile and profile.color
    if color then return color end
    if self:GetNWBool("DontShowMyPerm") then return color_gray end

    local role = profile and (profile.roleFirst or profile.roleFirstDisplay)
    if role and AdminPanelRoles and AdminPanelRoles[role] and AdminPanelRoles[role].color then
        return AdminPanelRoles[role].color
    end
    if role and defaultGroupColors[role] then
        return defaultGroupColors[role]
    end

    local name = self:GetUserGroup()
    if name and AdminPanelRoles and AdminPanelRoles[name] and AdminPanelRoles[name].color then
        return AdminPanelRoles[name].color
    end

    if name and defaultGroupColors[name] then
        return defaultGroupColors[name]
    end

    local gmodGroup = self:GetNWString("UserGroup", "")
    if gmodGroup ~= "" and defaultGroupColors[gmodGroup] then
        return defaultGroupColors[gmodGroup]
    end

    return defaultGroupColors["user"]
end

PLAYER.GetUserName = function(self)
    if self:GetNWBool("DontShowMyPerm") and not (LocalPlayer().HasSuccess and LocalPlayer():HasSuccess("visibleHidenUserGroup")) then return end

    local profile = Profiles[self:SteamID()]
    local role = profile and (profile.roleFirstDisplay or profile.roleFirst)
    if role and AdminPanelRoles and AdminPanelRoles[role] and AdminPanelRoles[role].name then
        return AdminPanelRoles[role].name
    end
    if role and defaultGroupTitles[role] then
        return defaultGroupTitles[role]
    end

    local name = self:GetUserGroupDisplay()
    if name and AdminPanelRoles and AdminPanelRoles[name] and AdminPanelRoles[name].name then
        return AdminPanelRoles[name].name
    end

    if name and defaultGroupTitles[name] then
        return defaultGroupTitles[name]
    end

    local gmodGroup = self:GetNWString("UserGroup", "")
    if gmodGroup ~= "" and defaultGroupTitles[gmodGroup] then
        return defaultGroupTitles[gmodGroup]
    end

    return (role and defaultGroupTitles[role]) or role or (name and defaultGroupTitles[name]) or name or (gmodGroup ~= "" and gmodGroup) or "Игрок"
end

PLAYER.HasSuccess = function(self,successName)
    return AdminPanelRole_HasSuccess(self,successName)
end

PLAYER.IsSuperAdmin = function(self)
    if DEV then return true end
    local grp = self:GetNWString("UserGroup", "")
    if grp == "superadmin" or grp == "root" then return true end
    local profile = Profiles[self:SteamID()]
    if profile and profile.roles and (profile.roles.root or profile.roles.superadmin) then return true end
    return AdminPanelRole_HasSuccess(self,"lua_superadmin")
end

PLAYER.IsAdmin = function(self)
    if DEV then return true end
    local grp = self:GetNWString("UserGroup", "")
    if grp == "admin" or grp == "superadmin" or grp == "root" then return true end
    local profile = Profiles[self:SteamID()]
    if profile and profile.roles and (profile.roles.root or profile.roles.superadmin or profile.roles.admin) then return true end
    return AdminPanelRole_HasSuccess(self,"lua_admin")
end

-- Регистрация группы root в ULib, если ULib установлен
local function RegisterRootInULib()
    if not (ULib and ULib.ucl) then return end
    if ULib.ucl.groups and not ULib.ucl.groups["root"] then
        if SERVER and ULib.ucl.addGroup then
            ULib.ucl.addGroup("root", nil, "superadmin", true)
        else
            ULib.ucl.groups["root"] = { allow = {}, inherit_from = "superadmin" }
        end
    end
end
hook.Add("Initialize", "AP Register Root In ULib", RegisterRootInULib)
hook.Add("InitPostEntity", "AP Register Root In ULib", RegisterRootInULib)
RegisterRootInULib()

if SERVER then return end

cvars.CreateReplicateOption("hg_dontshowmyperms","0")

