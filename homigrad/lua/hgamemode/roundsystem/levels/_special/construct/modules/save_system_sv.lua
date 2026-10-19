local Level = oop.Get("level_construct")
if not Level then return end

if not file.IsDir("homigrad", "DATA") then
    file.CreateDir("homigrad")
end
if not file.IsDir("homigrad/construct", "DATA") then
    file.CreateDir("homigrad/construct")
end

local function GetSaveFilePath()
    local mapName = string.lower(game.GetMap())
    return "homigrad/construct/construct_" .. mapName .. ".json"
end

-- =========================================================================
-- CUPBOARD BUILDING PRIVILEGE (TERRITORY PROTECTION)
-- =========================================================================

local function IsAuthorizedAt(pos, ply)
    if not IsValid(ply) then return false end
    if ply:IsAdmin() or ply:IsSuperAdmin() then return true end

    local distSq = ((CupboardDistance or 400) * 1.5) ^ 2
    local plySteam = ply:SteamID()

    for _, cb in ipairs(ents.FindByClass("ent_cupboard")) do
        if IsValid(cb) and cb:GetNWBool("Uses", false) then
            if cb:GetPos():DistToSqr(pos) <= distSq then
                local ownerSteam = cb:GetNWString("OwnerSteamID", "")
                local ownerEnt = cb:GetNWEntity("Owner")

                if ownerSteam == plySteam or ownerEnt == ply then
                    return true, cb
                end

                if Construct_Teams and ownerSteam ~= "" then
                    local team = Construct_Teams[ownerSteam]
                    if team and team.members and team.members[plySteam] then
                        return true, cb
                    end
                end

                return false, cb
            end
        end
    end

    return true
end

hook.Add("PlayerSpawnProp", "Construct_Cupboard_ProtectProp", function(ply, model)
    if roundActiveName ~= "level_construct" then return end
    if ply:GetNWBool("IgnoreQ") or ply:IsAdmin() then return end

    local tr = ply:GetEyeTrace()
    local allowed, cb = IsAuthorizedAt(tr.HitPos, ply)
    if not allowed then
        ply:ChatPrint("[Construct] Запрещено строить! Зона защищена шкафом: " .. tostring(cb:GetNWString("Name", "чужой игрок")))
        return false
    end
end)

hook.Add("PlayerSpawnSENT", "Construct_Cupboard_ProtectSENT", function(ply, class)
    if roundActiveName ~= "level_construct" then return end
    if ply:GetNWBool("IgnoreQ") or ply:IsAdmin() then return end

    local tr = ply:GetEyeTrace()
    local allowed, cb = IsAuthorizedAt(tr.HitPos, ply)
    if not allowed then
        ply:ChatPrint("[Construct] Запрещено спавнить в чужой зоне! Защищено шкафом: " .. tostring(cb:GetNWString("Name", "чужой игрок")))
        return false
    end
end)

hook.Add("CanTool", "Construct_Cupboard_ProtectTool", function(ply, tr, tool)
    if roundActiveName ~= "level_construct" then return end
    if ply:GetNWBool("IgnoreQ") or ply:IsAdmin() then return end

    local pos = tr.HitPos
    local targetEnt = tr.Entity
    if IsValid(targetEnt) and not targetEnt:IsPlayer() then
        pos = targetEnt:GetPos()
    end

    local allowed, cb = IsAuthorizedAt(pos, ply)
    if not allowed then
        ply:ChatPrint("[Construct] У вас нет доступа к чужой постройке!")
        return false
    end
end)

hook.Add("PhysgunPickup", "Construct_Cupboard_ProtectPhysgun", function(ply, ent)
    if roundActiveName ~= "level_construct" then return end
    if not IsValid(ent) or ent:IsPlayer() or ply:GetNWBool("IgnoreQ") or ply:IsAdmin() then return end

    local allowed, cb = IsAuthorizedAt(ent:GetPos(), ply)
    if not allowed then
        return false
    end
end)

-- =========================================================================
-- SPAWNPOINT (BED) LOGIC
-- =========================================================================

hook.Add("PlayerSelectSpawn", "Construct_SelectSpawnPoint", function(ply)
    if roundActiveName ~= "level_construct" then return end

    local sp = ply.customSpawnPoint
    if IsValid(sp) and sp:GetNWBool("Uses", false) then
        return sp
    end
end)

hook.Add("PlayerInitialSpawn", "Construct_RebindSpawnPoint", function(ply)
    timer.Simple(2.5, function()
        if not IsValid(ply) then return end
        local pSteam = ply:SteamID()
        for _, sp in ipairs(ents.FindByClass("ent_spawnpoint")) do
            if IsValid(sp) and sp:GetNWBool("Uses", false) and sp:GetNWString("OwnerSteamID") == pSteam then
                ply.customSpawnPoint = sp
                sp:SetNWEntity("Owner", ply)
                ply:ChatPrint("[Construct] Ваша точка возрождения привязана к кровати.")
                break
            end
        end
    end)
end)

-- =========================================================================
-- PERSISTENCE: SAVE / LOAD / WIPE
-- =========================================================================

function Construct_Save()
    local path = GetSaveFilePath()
    local saveTable = {
        map = game.GetMap(),
        time = os.time(),
        props = {},
        cupboards = {},
        spawnpoints = {},
        storages = {}
    }

    -- 1. Props
    for _, ent in ipairs(ents.FindByClass("prop_physics")) do
        if IsValid(ent) and not ent:CreatedByMap() then
            local phys = ent:GetPhysicsObject()
            saveTable.props[#saveTable.props + 1] = {
                model = ent:GetModel(),
                pos = ent:GetPos(),
                ang = ent:GetAngles(),
                color = ent:GetColor(),
                mat = ent:GetMaterial(),
                skin = ent:GetSkin(),
                frozen = IsValid(phys) and not phys:IsMotionEnabled() or false
            }
        end
    end

    -- 2. Cupboards
    for _, ent in ipairs(ents.FindByClass("ent_cupboard")) do
        if IsValid(ent) then
            local phys = ent:GetPhysicsObject()
            saveTable.cupboards[#saveTable.cupboards + 1] = {
                pos = ent:GetPos(),
                ang = ent:GetAngles(),
                ownerSteam = ent:GetNWString("OwnerSteamID", ""),
                ownerNick = ent:GetNWString("Name", ""),
                uses = ent:GetNWBool("Uses", false),
                frozen = IsValid(phys) and not phys:IsMotionEnabled() or false
            }
        end
    end

    -- 3. Spawnpoints
    for _, ent in ipairs(ents.FindByClass("ent_spawnpoint")) do
        if IsValid(ent) then
            local phys = ent:GetPhysicsObject()
            saveTable.spawnpoints[#saveTable.spawnpoints + 1] = {
                pos = ent:GetPos(),
                ang = ent:GetAngles(),
                ownerSteam = ent:GetNWString("OwnerSteamID", ""),
                ownerNick = ent:GetNWString("Name", ""),
                uses = ent:GetNWBool("Uses", false),
                frozen = IsValid(phys) and not phys:IsMotionEnabled() or false
            }
        end
    end

    -- 4. Storages
    for _, ent in ipairs(ents.FindByClass("ent_storage")) do
        if IsValid(ent) then
            local phys = ent:GetPhysicsObject()
            local items = {}
            if ent.inv and ent.inv.GetAllItems then
                for _, it in ipairs(ent.inv:GetAllItems()) do
                    if IsValid(it.ent) then
                        items[#items + 1] = {
                            class = it.ent:GetClass(),
                            clip = it.ent:IsWeapon() and it.ent:Clip1() or nil,
                            x = it.x,
                            y = it.y
                        }
                    end
                end
            end

            saveTable.storages[#saveTable.storages + 1] = {
                pos = ent:GetPos(),
                ang = ent:GetAngles(),
                health = ent.health or 500,
                frozen = IsValid(phys) and not phys:IsMotionEnabled() or false,
                items = items
            }
        end
    end

    local json = util.TableToJSON(saveTable, true)
    if json then
        file.Write(path, json)
        local totalCount = #saveTable.props + #saveTable.cupboards + #saveTable.spawnpoints + #saveTable.storages
        print("[Construct] Сохранено объектов: " .. totalCount .. " в " .. path)
    end
end

function Construct_Load()
    local path = GetSaveFilePath()
    if not file.Exists(path, "DATA") then
        print("[Construct] Нет сохраненных данных для карты " .. game.GetMap())
        return
    end

    local json = file.Read(path, "DATA")
    if not json or json == "" then return end

    local saveTable = util.JSONToTable(json)
    if not saveTable then return end

    -- Clean up existing construct-saved entities to prevent dupes
    for _, ent in ipairs(ents.FindByClass("prop_physics")) do
        if ent.ConstructSavedProp then ent:Remove() end
    end
    for _, ent in ipairs(ents.FindByClass("ent_cupboard")) do
        if ent.ConstructSavedProp then ent:Remove() end
    end
    for _, ent in ipairs(ents.FindByClass("ent_spawnpoint")) do
        if ent.ConstructSavedProp then ent:Remove() end
    end
    for _, ent in ipairs(ents.FindByClass("ent_storage")) do
        if ent.ConstructSavedProp then ent:Remove() end
    end

    -- 1. Restore Props
    for _, d in ipairs(saveTable.props or {}) do
        local prop = ents.Create("prop_physics")
        if IsValid(prop) then
            prop:SetModel(d.model)
            prop:SetPos(d.pos)
            prop:SetAngles(d.ang)
            if d.color then prop:SetColor(Color(d.color.r, d.color.g, d.color.b, d.color.a)) end
            if d.mat and d.mat ~= "" then prop:SetMaterial(d.mat) end
            if d.skin then prop:SetSkin(d.skin) end
            prop.ConstructSavedProp = true
            prop:Spawn()

            local phys = prop:GetPhysicsObject()
            if IsValid(phys) then
                phys:Wake()
                if d.frozen then
                    phys:EnableMotion(false)
                else
                    phys:EnableMotion(true)
                end
            end
        end
    end

    -- 2. Restore Cupboards
    for _, d in ipairs(saveTable.cupboards or {}) do
        local cb = ents.Create("ent_cupboard")
        if IsValid(cb) then
            cb:SetPos(d.pos)
            cb:SetAngles(d.ang)
            cb.ConstructSavedProp = true
            cb:Spawn()
            cb:SetNWBool("Uses", d.uses or false)
            cb:SetNWString("OwnerSteamID", d.ownerSteam or "")
            cb:SetNWString("Name", d.ownerNick or "")

            for _, ply in ipairs(player.GetAll()) do
                if ply:SteamID() == d.ownerSteam then
                    cb:SetNWEntity("Owner", ply)
                    break
                end
            end

            local phys = cb:GetPhysicsObject()
            if IsValid(phys) then
                phys:Wake()
                if d.frozen then phys:EnableMotion(false) else phys:EnableMotion(true) end
            end
        end
    end

    -- 3. Restore Spawnpoints
    for _, d in ipairs(saveTable.spawnpoints or {}) do
        local sp = ents.Create("ent_spawnpoint")
        if IsValid(sp) then
            sp:SetPos(d.pos)
            sp:SetAngles(d.ang)
            sp.ConstructSavedProp = true
            sp:Spawn()
            sp:SetNWBool("Uses", d.uses or false)
            sp:SetNWString("OwnerSteamID", d.ownerSteam or "")
            sp:SetNWString("Name", d.ownerNick or "")

            for _, ply in ipairs(player.GetAll()) do
                if ply:SteamID() == d.ownerSteam then
                    sp:SetNWEntity("Owner", ply)
                    ply.customSpawnPoint = sp
                    break
                end
            end

            local phys = sp:GetPhysicsObject()
            if IsValid(phys) then
                phys:Wake()
                if d.frozen then phys:EnableMotion(false) else phys:EnableMotion(true) end
            end
        end
    end

    -- 4. Restore Storages
    for _, d in ipairs(saveTable.storages or {}) do
        local st = ents.Create("ent_storage")
        if IsValid(st) then
            st:SetPos(d.pos)
            st:SetAngles(d.ang)
            st.ConstructSavedProp = true
            st.health = d.health or 500
            st:Spawn()

            local phys = st:GetPhysicsObject()
            if IsValid(phys) then
                phys:Wake()
                if d.frozen then phys:EnableMotion(false) else phys:EnableMotion(true) end
            end

            -- Restore inventory items
            if st.inv and d.items then
                timer.Simple(0.2, function()
                    if not IsValid(st) or not st.inv then return end
                    for _, it in ipairs(d.items) do
                        local itEnt = ents.Create(it.class)
                        if IsValid(itEnt) then
                            itEnt:SetPos(st:GetPos())
                            itEnt:Spawn()
                            if it.clip and itEnt:IsWeapon() then
                                itEnt:SetClip1(it.clip)
                            end
                            if not st.inv:AddEnt(itEnt, it.x, it.y) then
                                itEnt:Remove()
                            end
                        end
                    end
                end)
            end
        end
    end

    local totalCount = #(saveTable.props or {}) + #(saveTable.cupboards or {}) + #(saveTable.spawnpoints or {}) + #(saveTable.storages or {})
    print("[Construct] Загружено объектов: " .. totalCount .. " из " .. path)
end

function Construct_Wipe()
    local path = GetSaveFilePath()
    if file.Exists(path, "DATA") then
        file.Delete(path)
    end

    for _, ent in ipairs(ents.FindByClass("prop_physics")) do
        if not ent:CreatedByMap() then ent:Remove() end
    end
    for _, ent in ipairs(ents.FindByClass("ent_cupboard")) do
        ent:Remove()
    end
    for _, ent in ipairs(ents.FindByClass("ent_spawnpoint")) do
        ent:Remove()
    end
    for _, ent in ipairs(ents.FindByClass("ent_storage")) do
        ent:Remove()
    end

    for _, ply in ipairs(player.GetAll()) do
        ply.customSpawnPoint = nil
        ply:ChatPrint("[Construct] Постройки на карте были полностью очищены (вайп).")
    end

    print("[Construct] Вайп карты завершён.")
end

-- =========================================================================
-- TIMERS, HOOKS, AND COMMANDS
-- =========================================================================

-- Periodic auto-save every 60s during construct
timer.Create("Construct_AutoSaveTimer", 60, 0, function()
    if roundActiveName == "level_construct" then
        Construct_Save()
    end
end)

-- Auto-save when player disconnects (keeps their buildings safe)
hook.Add("PlayerDisconnected", "Construct_SaveOnDisconnect", function(ply)
    if roundActiveName == "level_construct" then
        Construct_Save()
    end
end)

-- Auto-save on server shutdown
hook.Add("ShutDown", "Construct_SaveOnShutDown", function()
    if roundActiveName == "level_construct" then
        Construct_Save()
    end
end)

-- Auto-load on round start
hook.Add("Homigrad_RoundStart", "Construct_LoadOnRoundStart", function(levelName)
    if levelName == "level_construct" then
        timer.Simple(1, function()
            Construct_Load()
        end)
    end
end)

-- Auto-save before round ends
hook.Add("Homigrad_RoundEnd", "Construct_SaveOnRoundEnd", function(winner, roundDataEnd)
    if roundActiveName == "level_construct" then
        Construct_Save()
    end
end)

-- Console commands
concommand.Add("c_save", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then return end
    Construct_Save()
    if IsValid(ply) then ply:ChatPrint("[Construct] Постройки сохранены!") end
end)

concommand.Add("c_load", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then return end
    Construct_Load()
    if IsValid(ply) then ply:ChatPrint("[Construct] Постройки загружены!") end
end)

concommand.Add("c_wipe", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then return end
    Construct_Wipe()
    if IsValid(ply) then ply:ChatPrint("[Construct] Вайп выполнен!") end
end)

hook.Add("PlayerSay", "Construct_ChatCommands", function(ply, text)
    local txt = string.lower(string.Trim(text))
    if txt == "!save" or txt == "/save" then
        if ply:IsAdmin() then
            Construct_Save()
            ply:ChatPrint("[Construct] Постройки сохранены!")
        end
        return ""
    elseif txt == "!wipe" or txt == "/wipe" then
        if ply:IsAdmin() then
            Construct_Wipe()
            ply:ChatPrint("[Construct] Вайп выполнен!")
        end
        return ""
    elseif txt == "!load" or txt == "/load" then
        if ply:IsAdmin() then
            Construct_Load()
            ply:ChatPrint("[Construct] Постройки загружены!")
        end
        return ""
    end
end)
