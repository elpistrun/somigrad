--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_adminpanel/lua/hadminpanel/tier_2/role_local_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:11 <
]]

-- Дамп клиентский: роли приезжали из внешней БД (Create_SyncDataManager -> HTTP),
-- которой в этой сборке нет. Без них HasSuccess всегда false, поэтому список
-- команд в меню пустой, а вкладка ролей не открывается.
-- Держим роли локально (data/hg_adminpanel_roles.json), раздаём их клиентам сами
-- и реализуем все команды role_*, которые дёргает вкладка "Роли".

AdminPanel_ServerCommands = AdminPanel_ServerCommands or {}
Profiles = Profiles or {}

local DEFAULT_ROLE = "user"
local ROOT_ROLE = "root"

-- Роль хранится как "категории прав целиком" + точечные исключения:
-- categories == nil - все права, success[name] == false - точечный запрет.
-- Так роль остаётся правильной и для прав, которые есть только на клиенте
-- (часть команд регистрируется в _cl файлах).
local function ExpandSuccess(def)
    local success = {}
    local categories = def.categories

    for successName,info in pairs(AdminPanelSuccess) do
        if not categories or categories[info.category] then success[successName] = true end
    end

    for successName,value in pairs(def.success or {}) do
        if value == false then
            success[successName] = nil
        elseif istable(value) then
            -- В JSON ключи всегда строки, а параметры прав индексируются числами.
            local params = {}

            for key,param in pairs(value) do params[tonumber(key) or key] = param end

            success[successName] = params
        else
            success[successName] = value
        end
    end

    return success
end

local function BuildRoleTable(def,name)
    local color = def.color or {}

    return {
        name = def.title or name,
        color = Color(color[1] or 255,color[2] or 255,color[3] or 255),
        success = ExpandSuccess(def)
    }
end

if CLIENT then
    net.Receive("hg_ap_roles_local",function()
        local size = net.ReadUInt(32)
        local data = util.Decompress(net.ReadData(size))
        if not data then return end

        data = util.JSONToTable(data)
        if not data or not data.order then return end

        local roles,inherit,list = {},{},{}

        for id,name in ipairs(data.order) do
            local def = data.roles[name]
            if not def then continue end

            roles[name] = BuildRoleTable(def,name)
            inherit[id] = name
            list[name] = data.list and data.list[name] or {}
        end

        AdminPanelRoles = roles
        AdminPanelRolesInherit = inherit
        AdminPanelRolesList = list

        event.Call("AP Roles Inherit Sync")
        event.Call("AP Roles Sync")
        event.Call("AP Roles List Sync")

        for steamid,info in pairs(data.profiles or {}) do
            local profile = Profiles[steamid] or {}
            Profiles[steamid] = profile

            profile.name = info.name or profile.name
            profile.roles = info.roles or {}

            event.Call("Profile Sync",steamid,profile)
        end
    end)

    return
end

util.AddNetworkString("hg_ap_roles_local")

local commands = AdminPanel_ServerCommands

local ROLES_FILE = "hg_adminpanel_roles.json"

local store = util.JSONToTable(file.Read(ROLES_FILE,"DATA") or "") or {}

-- Старый формат файла был просто steamid -> имя роли.
if not store.order then
    local users = {}

    for steamid,roleName in pairs(store) do
        if isstring(roleName) then users[steamid] = {[roleName] = true} end
    end

    store = {users = users}
end

store.roles = store.roles or {}
store.order = store.order or {}
store.users = store.users or {}

local function Save()
    file.Write(ROLES_FILE,util.TableToJSON(store,true))
end

--
-- Стандартный набор ролей при первом запуске
--
-- Категории прав: rcon, project, roles, rights, admin, admin_operator,
-- levels, game, jailbreak, mapData, other. nil - вообще все права.
--

local roleDefault = {
    {name = ROOT_ROLE,title = "Владелец",color = {255,60,60}},
    {name = "superadmin",title = "Суперадмин",color = {255,80,80}},
    {name = "dsuperadmin",title = "Донат Суперадмин",color = {220,100,255},
        categories = {admin = true,admin_operator = true,levels = true,game = true,
            jailbreak = true,roles = true,rights = true,mapData = true,other = true}},
    {name = "admin",title = "Администратор",color = {255,160,50},
        categories = {admin = true,admin_operator = true,levels = true,game = true,
            jailbreak = true,roles = true,rights = true,mapData = true,other = true}},
    {name = "dadmin",title = "Донат Админ",color = {255,200,60},
        categories = {admin = true,admin_operator = true,levels = true,game = true,
            jailbreak = true,mapData = true,other = true}},
    {name = "operator",title = "Оператор",color = {100,180,255},
        categories = {admin = true,admin_operator = true,other = true}},
    {name = "doperator",title = "Донат Оператор",color = {80,220,220},
        categories = {admin_operator = true,other = true}},
    {name = DEFAULT_ROLE,title = "Игрок",color = {200,200,200},categories = {}}
}

local function BuildDefaults()
    for _,def in ipairs(roleDefault) do
        if not store.roles[def.name] then
            store.roles[def.name] = {
                title = def.title,
                color = def.color,
                categories = def.categories,
                success = {}
            }
        else
            store.roles[def.name].title = store.roles[def.name].title or def.title
            store.roles[def.name].color = store.roles[def.name].color or def.color
            if store.roles[def.name].categories == nil and def.categories ~= nil then
                store.roles[def.name].categories = def.categories
            end
        end

        if not table.HasValue(store.order, def.name) then
            local userPos = table.KeyFromValue(store.order, DEFAULT_ROLE)
            if userPos then
                table.insert(store.order, userPos, def.name)
            else
                store.order[#store.order + 1] = def.name
            end
        end
    end
end

local function BuildRoles()
    BuildDefaults()

    local roles,inherit,list = {},{},{}

    for id,name in ipairs(store.order) do
        local def = store.roles[name]
        if not def then continue end

        roles[name] = BuildRoleTable(def,name)
        inherit[id] = name
        list[name] = {}
    end

    for steamid,userRoles in pairs(store.users) do
        for name in pairs(userRoles) do
            if list[name] then list[name][steamid] = true end
        end
    end

    AdminPanelRoles = roles
    AdminPanelRolesInherit = inherit
    AdminPanelRolesList = list

    if ULib and ULib.ucl then
        local ulibHierarchy = {
            {name = "root", inherit = "superadmin"},
            {name = "superadmin", inherit = "admin"},
            {name = "dsuperadmin", inherit = "admin"},
            {name = "admin", inherit = "operator"},
            {name = "dadmin", inherit = "operator"},
            {name = "operator", inherit = "user"},
            {name = "doperator", inherit = "user"}
        }

        for _, g in ipairs(ulibHierarchy) do
            if ULib.ucl.groups and not ULib.ucl.groups[g.name] then
                if isfunction(ULib.ucl.addGroup) then
                    ULib.ucl.addGroup(g.name, nil, g.inherit, true)
                else
                    ULib.ucl.groups[g.name] = { allow = {}, inherit_from = g.inherit }
                end
            end
        end
    end

    event.Call("AP Roles Inherit Sync")
    event.Call("AP Roles Sync")
    event.Call("AP Roles List Sync")
end

local rolePriority = {
    "root",
    "superadmin",
    "dsuperadmin",
    "admin",
    "dadmin",
    "operator",
    "doperator"
}

local function GetUserRoles(steamid)
    local userRoles = store.users[steamid]

    if not userRoles or table.IsEmpty(userRoles) then
        local ply = player.GetBySteamID(steamid)
        if IsValid(ply) then
            local grp = string.lower(ply:GetNWString("UserGroup", ply:GetUserGroup() or ""))
            for _, r in ipairs(rolePriority) do
                if grp == r then return {[r] = true} end
            end
            if ply:IsSuperAdmin() then
                return {["superadmin"] = true}
            elseif ply:IsAdmin() then
                return {["admin"] = true}
            end
        end
        return {[DEFAULT_ROLE] = true}
    end

    return userRoles
end

local function ApplyProfile(steamid,name)
    local profile = Profiles[steamid] or {}
    Profiles[steamid] = profile

    if name then profile.name = name end

    profile.roles = GetUserRoles(steamid)
    profile.roleFirst = AdminPanelRole_GetFirstRole(profile.roles)
    profile.roleFirstDisplay = AdminPanelRole_GetFirstRoleDisplay(profile.roles)

    return profile
end

local function Send(target)
    local profiles = {}

    for steamid,profile in pairs(Profiles) do
        profiles[steamid] = {name = profile.name,roles = profile.roles}
    end

    local data = util.Compress(util.TableToJSON({
        roles = store.roles,
        order = store.order,
        list = AdminPanelRolesList,
        profiles = profiles
    }))

    local size = #data

    net.Start("hg_ap_roles_local")
    net.WriteUInt(size,32)
    net.WriteData(data,size)

    if IsValid(target) then net.Send(target) else net.Broadcast() end
end

AdminPanel_Roles_Send = Send

local function Sync()
    Save()
    BuildRoles()

    for steamid in pairs(store.users) do ApplyProfile(steamid) end

    for _,ply in ipairs(player.GetAll()) do ApplyProfile(ply:SteamID(),ply:Nick()) end

    Send()
end

AdminPanel_Roles_Sync = Sync

--
-- Права
--

local empty = {}

function AdminPanelRole_HasSuccess(ply,successName)
    if not AdminPanelRoles then return false end

    local profile = Profiles[ply:SteamID()]

    for name in pairs(profile and profile.roles or empty) do
        if name == ROOT_ROLE then return true end

        local role = AdminPanelRoles[name]
        if role and role.success[successName] then return true end
    end

    local userRole = AdminPanelRoles[DEFAULT_ROLE]

    return userRole and userRole.success[successName] and true or false
end

-- Чем меньше id в AdminPanelRolesInherit, тем выше роль
-- (AdminPanelRole_GetFirstRole берёт минимальный).
function AdminPanelRole_HasDominate(caller,target,isEquial)
    if not AdminPanelRolesInheritByName then return false end

    local callerRole = AdminPanelRole_GetFirstRole(caller.roles or empty)
    local targetRole = AdminPanelRole_GetFirstRole(target.roles or empty)

    local callerId = callerRole and AdminPanelRolesInheritByName[callerRole]
    local targetId = targetRole and AdminPanelRolesInheritByName[targetRole]

    if not callerId then return false end
    if not targetId then return true end

    if callerId < targetId then return true end
    if isEquial and callerId == targetId then return true end

    return false
end

function AdminPanelRole_SetPlayerRole(steamid,roleName)
    if not store.roles[roleName] then return false end

    store.users[steamid] = roleName ~= DEFAULT_ROLE and {[roleName] = true} or nil

    local targetPly = player.GetBySteamID(steamid)
    if IsValid(targetPly) then
        targetPly:SetUserGroup(roleName)
        targetPly:SetNWString("UserGroup", roleName)
    end

    if ULib and ULib.ucl and isfunction(ULib.ucl.addUser) then
        ULib.ucl.addUser(steamid, {}, {}, roleName)
    end

    Sync()
    Save()

    return true
end

--
--
-- Кто какие роли может править
--

local function NormalizeArgs(a, ...)
    if istable(a) then return a end
    return {a, ...}
end

local function CanEditRole(ply,name)
    if not IsValid(ply) then return true end

    local profile = Profiles[ply:SteamID()]
    if profile and profile.roles and profile.roles[ROOT_ROLE] then return true end
    if ply:IsSuperAdmin() or string.lower(ply:GetUserGroup() or "") == "root" then return true end

    local callerRole = profile and AdminPanelRole_GetFirstRole(profile.roles or empty)
    local callerId = callerRole and AdminPanelRolesInheritByName[callerRole]
    local targetId = AdminPanelRolesInheritByName[name]

    if not callerId or not targetId then return false end

    return callerId <= targetId
end

local function OrderIndex(name)
    for id,value in ipairs(store.order) do
        if value == name then return id end
    end
end

--
-- Команды вкладки "Роли"
--

function commands.role_create(ply,a,...)
    local args = NormalizeArgs(a,...)
    local name = string.Trim(tostring(args[1] or ""))
    if name == "" then return "Не указано имя роли" end
    if store.roles[name] then return "Роль '" .. name .. "' уже есть" end

    store.roles[name] = {title = name,color = {255,255,255},categories = {},success = {}}
    store.order[#store.order + 1] = name

    Sync()
    Save()

    return "Роль '" .. name .. "' создана"
end

function commands.role_remove(ply,a,...)
    local args = NormalizeArgs(a,...)
    local name = tostring(args[1] or "")

    if name == ROOT_ROLE or name == DEFAULT_ROLE then return "Эту роль удалять нельзя" end
    if not store.roles[name] then return "Нет роли '" .. name .. "'" end
    if not CanEditRole(ply,name) then return "Эта роль не ниже вашей" end

    local id = OrderIndex(name)
    if id then table.remove(store.order,id) end

    store.roles[name] = nil

    for steamid,userRoles in pairs(store.users) do
        userRoles[name] = nil

        if table.IsEmpty(userRoles) then store.users[steamid] = nil end
    end

    Sync()
    Save()

    return "Роль '" .. name .. "' удалена"
end

function commands.role_rename(ply,a,...)
    local args = NormalizeArgs(a,...)
    local name = tostring(args[1] or "")
    local newName = string.Trim(tostring(args[2] or ""))

    if not store.roles[name] then return "Нет роли '" .. name .. "'" end
    if newName == "" then return "Не указано новое имя" end
    if store.roles[newName] then return "Роль '" .. newName .. "' уже есть" end
    if name == ROOT_ROLE or name == DEFAULT_ROLE then return "Эту роль переименовывать нельзя" end
    if not CanEditRole(ply,name) then return "Эта роль не ниже вашей" end

    store.roles[newName] = store.roles[name]
    store.roles[name] = nil

    local id = OrderIndex(name)
    if id then store.order[id] = newName end

    for _,userRoles in pairs(store.users) do
        if userRoles[name] then
            userRoles[name] = nil
            userRoles[newName] = true
        end
    end

    Sync()
    Save()

    return "Роль '" .. name .. "' -> '" .. newName .. "'"
end

-- UI зовёт role_settitle, в реестре команда называется role_setname.
function commands.role_setname(ply,a,...)
    local args = NormalizeArgs(a,...)
    local name = tostring(args[1] or "")
    local title = string.Trim(tostring(args[2] or ""))

    local role = store.roles[name]
    if not role then return "Нет роли '" .. name .. "'" end
    if title == "" then return "Не указано отображаемое имя" end
    if not CanEditRole(ply,name) then return "Эта роль не ниже вашей" end

    role.title = title

    Sync()
    Save()

    return "Название роли '" .. name .. "': " .. title
end

commands.role_settitle = commands.role_setname

function commands.role_setcolor(ply,a,...)
    local args = NormalizeArgs(a,...)
    local name = tostring(args[1] or "")

    local role = store.roles[name]
    if not role then return "Нет роли '" .. name .. "'" end
    if not CanEditRole(ply,name) then return "Эта роль не ниже вашей" end

    role.color = {
        math.Clamp(tonumber(args[2]) or 255,0,255),
        math.Clamp(tonumber(args[3]) or 255,0,255),
        math.Clamp(tonumber(args[4]) or 255,0,255)
    }

    Sync()
    Save()
end

function commands.role_set_inherit(ply,a,...)
    local args = NormalizeArgs(a,...)
    local name = tostring(args[1] or "")

    if not store.roles[name] then return "Нет роли '" .. name .. "'" end
    if name == ROOT_ROLE then return "root всегда первый в иерархии" end
    if not CanEditRole(ply,name) then return "Эта роль не ниже вашей" end

    local id = OrderIndex(name)
    if not id then return end

    local target = math.Clamp(math.floor(tonumber(args[2]) or id),1,#store.order)

    -- Выше root не поднимаемся.
    if store.order[1] == ROOT_ROLE then target = math.max(target,2) end
    if target == id then return end

    table.remove(store.order,id)
    table.insert(store.order,target,name)

    Sync()
    Save()

    return "Иерархия: " .. name .. " -> " .. target
end

function commands.role_success_set(ply,a,...)
    local args = NormalizeArgs(a,...)
    local name = tostring(args[1] or "")
    local successName = tostring(args[2] or "")

    local role = store.roles[name]
    if not role then return "Нет роли '" .. name .. "'" end
    if successName == "" then return "Не указано право" end
    if not CanEditRole(ply,name) then return "Эта роль не ниже вашей" end

    -- Root / superadmin can grant any rights
    if IsValid(ply) and not (ply:IsSuperAdmin() or string.lower(ply:GetUserGroup() or "") == "root") then
        if AdminPanelSuccess[successName] and not AdminPanelRole_HasSuccess(ply,successName) then
            return "У вас самого нет права '" .. successName .. "'"
        end
    end

    local value = args[3]
    value = (value == true or value == 1 or value == "1" or value == "true")

    role.success = role.success or {}
    role.success[successName] = value or false

    Sync()
    Save()

    return name .. ": " .. successName .. " = " .. (value and "да" or "нет")
end

function commands.role_deny_set(ply,a,...)
    local args = NormalizeArgs(a,...)
    return commands.role_success_set(ply,{args[1],args[2],"0"})
end

function commands.role_success_set_parametr(ply,a,...)
    local args = NormalizeArgs(a,...)
    local name = tostring(args[1] or "")
    local successName = tostring(args[2] or "")
    local id = tonumber(args[3])

    local role = store.roles[name]
    if not role then return "Нет роли '" .. name .. "'" end
    if successName == "" then return "Не указано право" end
    if not id then return "Не указан параметр" end
    if not CanEditRole(ply,name) then return "Эта роль не ниже вашей" end

    local override = role.success[successName]

    if not istable(override) then
        override = {}
        role.success[successName] = override
    end

    local value = args[4]

    override[id] = value ~= nil and value ~= "" and tostring(value) or nil

    Sync()
    Save()

    return name .. ": " .. successName .. " параметр " .. id .. " = " .. tostring(override[id])
end

function commands.role_user_add(ply,args)
    local steamid = string.Trim(tostring(args[1] or ""))
    local name = tostring(args[2] or "")

    if not string.match(steamid,"^STEAM_%d:%d:%d+$") then return "Неверный стимайд: " .. steamid end
    if not store.roles[name] then return "Нет роли '" .. name .. "'" end
    if not CanEditRole(ply,name) then return "Эта роль не ниже вашей" end

    store.users[steamid] = store.users[steamid] or {}
    store.users[steamid][name] = true

    Sync()

    return steamid .. " -> " .. name
end

function commands.role_user_remove(ply,args)
    local steamid = string.Trim(tostring(args[1] or ""))
    local name = tostring(args[2] or "")

    local userRoles = store.users[steamid]
    if not userRoles or not userRoles[name] then return "У игрока нет роли '" .. name .. "'" end
    if not CanEditRole(ply,name) then return "Эта роль не ниже вашей" end

    userRoles[name] = nil

    if table.IsEmpty(userRoles) then store.users[steamid] = nil end

    Sync()

    return steamid .. " лишён роли " .. name
end

function commands.role_getlist()
    local list = {}

    for id,name in ipairs(store.order) do
        list[#list + 1] = id .. ") " .. name .. " (" .. table.Count(AdminPanelRolesList[name] or empty) .. ")"
    end

    return table.concat(list,", ")
end

function commands.role_getsuccess(ply,args)
    local name = tostring(args[1] or "")

    local role = AdminPanelRoles[name]
    if not role then return "Нет роли '" .. name .. "'" end

    local list = {}

    for successName in pairs(role.success) do list[#list + 1] = successName end

    table.sort(list)

    return name .. ": " .. table.concat(list,", ")
end

--
-- Игроки
--

local function SetupPlayer(ply)
    local steamid = ply:SteamID()
    if not steamid or steamid == "" then return end

    local grp = string.lower(ply:GetUserGroup() or ply:GetNWString("UserGroup", "") or "")

    -- Sync role from store.users to GMod usergroup
    if store.users[steamid] then
        local targetRole = nil
        for _, r in ipairs(rolePriority) do
            if store.users[steamid][r] then
                targetRole = r
                break
            end
        end

        if targetRole and targetRole ~= "user" and grp ~= targetRole then
            ply:SetUserGroup(targetRole)
            ply:SetNWString("UserGroup", targetRole)
            if ULib and ULib.ucl and isfunction(ULib.ucl.addUser) then
                ULib.ucl.addUser(steamid, {}, {}, targetRole)
            end
        end
    else
        local matchedRole = nil
        if ply:IsListenServerHost() or grp == "root" or grp == "owner" or grp == "founder" then
            matchedRole = ROOT_ROLE
        elseif grp == "superadmin" or ply:IsSuperAdmin() then
            matchedRole = "superadmin"
        elseif grp == "dsuperadmin" then
            matchedRole = "dsuperadmin"
        elseif grp == "admin" or ply:IsAdmin() then
            matchedRole = "admin"
        elseif grp == "dadmin" or grp == "headadmin" then
            matchedRole = "dadmin"
        elseif grp == "operator" or grp == "moderator" then
            matchedRole = "operator"
        elseif grp == "doperator" then
            matchedRole = "doperator"
        end

        if matchedRole then
            store.users[steamid] = {[matchedRole] = true}
            ply:SetUserGroup(matchedRole)
            ply:SetNWString("UserGroup", matchedRole)
            if ULib and ULib.ucl and isfunction(ULib.ucl.addUser) then
                ULib.ucl.addUser(steamid, {}, {}, matchedRole)
            end
            Save()
        end
    end

    ApplyProfile(steamid,ply:Nick())

    ply:SetNWBool("Init",true)
end

hook.Add("CAMI.PlayerUsergroupChanged", "AP Local Roles ULX", function(ply, oldGroup, newGroup)
    if not IsValid(ply) then return end
    local steamid = ply:SteamID()
    if not steamid or steamid == "" then return end
    newGroup = string.lower(newGroup or "")

    local recognized = {
        ["root"] = "root",
        ["owner"] = "root",
        ["founder"] = "root",
        ["superadmin"] = "superadmin",
        ["dsuperadmin"] = "dsuperadmin",
        ["admin"] = "admin",
        ["dadmin"] = "dadmin",
        ["headadmin"] = "dadmin",
        ["operator"] = "operator",
        ["moderator"] = "operator",
        ["doperator"] = "doperator"
    }

    local targetRole = recognized[newGroup]
    if targetRole then
        store.users[steamid] = {[targetRole] = true}
        ply:SetNWString("UserGroup", targetRole)
        Sync()
        Save()
    elseif newGroup == "user" then
        store.users[steamid] = nil
        ply:SetNWString("UserGroup", "user")
        Sync()
        Save()
    end
end)

local function Init()
    BuildRoles()

    for steamid in pairs(store.users) do ApplyProfile(steamid) end

    for _,ply in ipairs(player.GetAll()) do SetupPlayer(ply) end
end

-- AdminPanelSuccess дозаполняется файлами tier_2 и ui, поэтому строим роли
-- только после полной загрузки.
event.Add("Initialize","AP Local Roles",Init)

if Initialize then Init() end

hook.Add("PlayerInitialSpawn","AP Local Roles",function(ply)
    if not AdminPanelRoles then BuildRoles() end

    SetupPlayer(ply)
end)

-- Момент, когда клиент закончил initProtocol и готов принимать данные.
event.Add("Player Create","AP Local Roles",function(ply)
    ply:SetNWBool("Init",true)

    ApplyProfile(ply:SteamID(),ply:Nick())

    Send()
end)

concommand.Add("hg_role_set",function(ply,cmd,args)
    if IsValid(ply) then
        local profile = Profiles[ply:SteamID()]
        if not profile or not profile.roles[ROOT_ROLE] then return end
    end

    local steamid,roleName = args[1],args[2]

    if not steamid or not roleName then
        print("hg_role_set <steamid> <role>")

        for id,name in ipairs(store.order) do print("\t" .. id .. ") " .. name) end

        return
    end

    if not AdminPanelRole_SetPlayerRole(steamid,roleName) then
        print("Неизвестная роль '" .. roleName .. "'")

        return
    end

    print(steamid .. " -> " .. roleName)
end)

