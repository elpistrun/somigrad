if not SERVER then return end

--[[
    Homigrad Round System - Server Director
    Controls round lifecycle, level transitions, sync, team assignment,
    loadouts, end conditions and admin commands.
]]

util.AddNetworkString("roundActiveName")
util.AddNetworkString("levelNextName")
util.AddNetworkString("roundActive")
util.AddNetworkString("roundData")
util.AddNetworkString("roundDataEnd")
util.AddNetworkString("roundEmit")
util.AddNetworkString("loadscreen")
util.AddNetworkString("loadscreen_end")
util.AddNetworkString("want change team")

-- Global state
roundActive = roundActive or false
roundActiveName = roundActiveName or "level_homicide"
levelNextName = levelNextName or "level_homicide"
manualNextLevel = manualNextLevel or nil
roundTimeStart = roundTimeStart or CurTime()
roundTime = roundTime or 300
roundData = roundData or {}
roundDataEnd = roundDataEnd or nil

ActiveLevel = Levels and Levels[roundActiveName]

if GetGlobalBool("StopGame") == nil then
    SetGlobalBool("StopGame", false)
end

SetGlobalBool("LevelRandom", true)


-- =========================================================================
-- NETWORKING & SYNCHRONIZATION
-- =========================================================================

local function SyncActiveName(target)
    net.Start("roundActiveName")
    net.WriteString(roundActiveName or "level_homicide")
    if target then net.Send(target) else net.Broadcast() end
end

local function SyncNextName(target)
    net.Start("levelNextName")
    net.WriteString(levelNextName or roundActiveName or "level_homicide")
    if target then net.Send(target) else net.Broadcast() end
end

local function SyncActive(target)
    net.Start("roundActive")
    net.WriteBool(roundActive or false)
    if target then net.Send(target) else net.Broadcast() end
end

local function SyncData(target)
    net.Start("roundData")
    net.WriteTable(roundData or {})
    net.WriteFloat(roundTimeStart or CurTime())
    net.WriteFloat(roundTime or 300)
    if target then net.Send(target) else net.Broadcast() end
end

local function SyncDataEnd(target)
    net.Start("roundDataEnd")
    net.WriteTable(roundDataEnd or {})
    if target then net.Send(target) else net.Broadcast() end
end

local function SyncEmit(target)
    net.Start("roundEmit")
    if target then net.Send(target) else net.Broadcast() end
end

local function SendLoadScreen(curr, nextName, target)
    net.Start("loadscreen")
    net.WriteString(curr or roundActiveName or "level_homicide")
    net.WriteString(nextName or levelNextName or roundActiveName or "level_homicide")
    if target then net.Send(target) else net.Broadcast() end
end

local function SendLoadScreenEnd(target)
    net.Start("loadscreen_end")
    if target then net.Send(target) else net.Broadcast() end
end

function RoundSystem_SyncPlayer(ply)
    if not IsValid(ply) then return end
    SyncActiveName(ply)
    SyncNextName(ply)
    SyncActive(ply)
    SyncData(ply)
    if not roundActive and roundDataEnd then
        SyncDataEnd(ply)
    end
end

local function GetDefaultJoinTeam()
    local defaultTeam = 1
    if ActiveLevel and ActiveLevel.teamEncoder then
        local teamKeys = {}
        for id in pairs(ActiveLevel.teamEncoder) do
            if id ~= 1002 then teamKeys[#teamKeys + 1] = id end
        end
        table.sort(teamKeys)
        if #teamKeys > 0 then defaultTeam = teamKeys[1] end
    end
    return defaultTeam
end

hook.Add("PlayerInitialSpawn", "Homigrad_InitialJoinDead", function(ply)
    local defTeam = GetDefaultJoinTeam()
    ply:SetTeam(defTeam)
    timer.Simple(0, function()
        if not IsValid(ply) then return end
        if ply:Team() == 1002 or ply:Team() == 0 then
            ply:SetTeam(defTeam)
        end
        ply:StripWeapons()
        ply:RemoveAllAmmo()
        ply:KillSilent()
        ply.isDead = true
        ply:SetNWBool("isDead", true)
        ply:SetNWBool("Alive", false)
        ply:SetNWBool("FakeDeath", true)
        ply:Spectate(OBS_MODE_ROAMING)
    end)
end)

hook.Add("PlayerInitialSpawn", "Homigrad_RoundSync_Initial", function(ply)
    local defTeam = GetDefaultJoinTeam()
    ply:SetTeam(defTeam)

    timer.Simple(1.5, function()
        if not IsValid(ply) then return end
        RoundSystem_SyncPlayer(ply)

        if ply:Team() == 1002 or ply:Team() == 0 then
            ply:SetTeam(defTeam)
        end
        ply:KillSilent()
        ply.isDead = true
        ply:SetNWBool("isDead", true)
        ply:SetNWBool("Alive", false)
        ply:SetNWBool("FakeDeath", true)
        timer.Simple(0.2, function()
            if IsValid(ply) then
                ply:Spectate(OBS_MODE_ROAMING)
                if roundActive then
                    ply:ChatPrint("[Homigrad] Раунд уже идёт. Вы появитесь в следующем раунде.")
                end
            end
        end)
    end)
end)

-- Scoreboard team selection
net.Receive("want change team", function(len, ply)
    if not IsValid(ply) then return end
    local teamStr = net.ReadString()
    local teamID = tonumber(teamStr)
    if not teamID then return end

    if GAMEMODE and GAMEMODE.PlayerJoinTeam then
        GAMEMODE:PlayerJoinTeam(ply, teamID)
    else
        local oldTeam = ply:Team()
        ply:SetTeam(teamID)
        hook.Run("OnTeamChanged", ply, oldTeam, teamID)

        if teamID == 1002 then
            if ply:Alive() then ply:KillSilent() end
            ply.isDead = true
            ply:SetNWBool("isDead", true)
            ply:SetNWBool("Alive", false)
            ply:SetNWBool("FakeDeath", true)
            timer.Simple(0.2, function()
                if IsValid(ply) and not ply:Alive() then
                    ply:Spectate(OBS_MODE_ROAMING)
                    ply:SetMoveType(MOVETYPE_NOCLIP)
                end
            end)
        else
            if not ply:Alive() and (roundActiveName == "level_construct" or roundActiveName == "level_event") then
                ply:Spawn()
            end
        end
    end

    net.Start("want change team")
    net.Send(ply)
end)

-- =========================================================================
-- LEVEL ROTATION & SELECTION
-- =========================================================================

local AllowedRandomLevels = {
    ["level_homicide"] = true,
    ["level_riot"] = true,
    ["level_hunter"] = true,
    ["level_tdm"] = true,
    ["level_dm"] = true,
    ["level_hl2dm"] = true,
    ["level_hl2tdm"] = true,
}

local DisallowedRandomLevels = {
    ["level_nextbot"] = true,
    ["nextbot"] = true,
    ["nextbox"] = true,
    ["level_construct"] = true,
    ["construct"] = true,
    ["level_event"] = true,
    ["event"] = true,
    ["level_jailbreak"] = true,
    ["jailbreak"] = true,
    ["jb"] = true,
    ["level_deadrun"] = true,
    ["deadrun"] = true,
    ["level_bahmut"] = true,
    ["bahmut"] = true,
}

local function GetAvailableLevels()
    local list = {}
    for name, lvl in pairs(Levels or {}) do
        local lk = string.lower(name)
        if AllowedRandomLevels[lk] and not DisallowedRandomLevels[lk] and not lvl.CantRandom then
            list[#list + 1] = name
        end
    end
    if #list == 0 then
        list = {"level_homicide", "level_riot", "level_hunter", "level_tdm", "level_dm"}
        if Levels and Levels["level_hl2tdm"] then
            list[#list + 1] = "level_hl2tdm"
        elseif Levels and Levels["level_hl2dm"] then
            list[#list + 1] = "level_hl2dm"
        end
    end
    return list
end

local function PickRandomLevel(excludeCurrent)
    local list = GetAvailableLevels()
    if #list <= 1 then return list[1] end

    local filtered = {}
    for _, name in ipairs(list) do
        if not excludeCurrent or name ~= roundActiveName then
            filtered[#filtered + 1] = name
        end
    end

    if #filtered == 0 then return list[math.random(1, #list)] end
    return filtered[math.random(1, #filtered)]
end

function SetNextLevel(name)
    if not name or name == "" then return levelNextName end
    name = string.lower(string.Trim(name))

    if (name == "hl2dm" or name == "hl2") and Levels["level_hl2tdm"] then
        levelNextName = "level_hl2tdm"
    elseif Levels[name] then
        levelNextName = name
    elseif Levels["level_" .. name] then
        levelNextName = "level_" .. name
    else
        for k in pairs(Levels) do
            if string.find(string.lower(k), name, 1, true) then
                levelNextName = k
                break
            end
        end
    end

    SyncNextName()
    manualNextLevel = levelNextName
    print("[Homigrad] Следующий уровень установлен на: " .. tostring(levelNextName))
    return levelNextName
end

function Homigrad_ResetPlayerStats(ply)
    if not IsValid(ply) then return end

    -- Reset Stamina
    ply.stamina = 100
    ply.staminamul = 1
    ply.pulse = 1 / 80
    ply.nextStaminaBreath = 0
    ply.breathModeToggle = false
    ply:SetNWFloat("stamina", 100)
    ply:SetNWFloat("staminamul", 1)
    ply:SetNWFloat("pulse", 1 / 80)

    -- Reset Pain & Blackout / Vignette ("черная штучка" / otrub)
    ply.pain = 0
    ply.painlosing = 0
    ply:SetNWFloat("pain", 0)
    ply:SetNWFloat("painlosing", 0)
    ply:SetNWBool("Otrub", false)
    ply:SetNWBool("otrub", false)

    -- Reset Bleeding & Blood
    ply.bleed = 0
    ply.blood = 5000
    ply:SetNWFloat("bleed", 0)
    ply:SetNWFloat("blood", 5000)

    -- Reset Impulse / Hunger / Thirst / Poison
    ply:SetNWFloat("impulse", 0)
    ply:SetNWFloat("hungry", 10)
    ply:SetNWFloat("water", 10)
    ply:SetNWBool("Poison", false)

    -- Reset Fake / Death state
    ply.isDead = nil
    ply.heartstop = nil
    ply:SetNWBool("heartstop", false)
    ply.HeadPop = nil
    ply:SetNWBool("HeadPop", false)
    ply:SetNWBool("isDead", false)
    ply:SetNWBool("Alive", true)
    ply:SetNWBool("FakeDeath", false)
    ply.fake = false
    ply.Fake = false
    ply:SetNWBool("Fake", false)
    ply:SetNWBool("fake", false)

    local rag = ply:GetNWEntity("FakeRagdoll")
    if not IsValid(rag) then rag = ply.fakeEnt end
    if not IsValid(rag) then rag = ply:GetNWEntity("DeathRagdoll") end
    if not IsValid(rag) then rag = ply.fakeragdoll end
    if not IsValid(rag) then rag = ply:GetNWEntity("Ragdoll") end
    if IsValid(rag) and not rag:IsPlayer() then
        rag:Remove()
    end
    ply:SetNWEntity("DeathRagdoll", NULL)
    ply:SetNWEntity("FakeRagdoll", NULL)
    ply:SetNWEntity("Ragdoll", NULL)
    ply.fakeragdoll = nil
    ply.FakeRagdoll = nil
    ply.fakeEnt = nil
    ply.FakeShooting = false
    ply:SetNWInt("FakeShooting", false)

    ply:UnSpectate()
    ply:SetMoveType(MOVETYPE_WALK)
    ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
    ply:SetNotSolid(false)
    ply:SetNoDraw(false)
    ply:DrawViewModel(true)
    if ply.SetupBones then ply:SetupBones() end

    if RemoveFake then
        RemoveFake(ply)
    end

    ply:SetHealth(ply:GetMaxHealth() or 100)
    ply:SetWalkSpeed(DEFAULT_SPEED or 125)
    ply:SetRunSpeed(DEFAULT_RUNSPEED or 280)
    ply:SetSlowWalkSpeed(DEFAULT_SLOWWALK or 75)
    ply:SetLadderClimbSpeed(DEFAULT_LADDERSPEED or 75)
    ply:SetJumpPower(DEFAULT_JUMPPOWER or 190)
    ply:SetCrouchedWalkSpeed(0.6)
end

hook.Add("PlayerSpawn", "Homigrad_ResetPlayerStatsOnSpawn", function(ply)
    if roundActive and not ply.spawningFromRoundStart and not ply.constructRespawn and not ply.eventRespawn then
        timer.Simple(0, function()
            if not IsValid(ply) or ply.spawningFromRoundStart or ply.constructRespawn or ply.eventRespawn then return end
            local defTeam = GetDefaultJoinTeam()
            if ply:Team() == 1002 or ply:Team() == 0 then
                ply:SetTeam(defTeam)
            end
            ply:StripWeapons()
            ply:RemoveAllAmmo()
            ply:KillSilent()
            ply.isDead = true
            ply:SetNWBool("isDead", true)
            ply:SetNWBool("Alive", false)
            ply:SetNWBool("FakeDeath", true)
            ply:Spectate(OBS_MODE_ROAMING)
        end)
        return
    end

    Homigrad_ResetPlayerStats(ply)
end)

local lootBoxPool = {
    {"ent_lootbox_low", 45},
    {"ent_lootbox_small", 35},
    {"ent_lootbox_medium", 10},
    {"ent_lootbox_medical", 5},
    {"ent_lootbox_small_ammo", 5}
}

local function PickRandomLootBoxClass()
    local totalWeight = 0
    for _, item in ipairs(lootBoxPool) do
        totalWeight = totalWeight + item[2]
    end
    local roll = math.random(1, totalWeight)
    local current = 0
    for _, item in ipairs(lootBoxPool) do
        current = current + item[2]
        if roll <= current then
            return item[1]
        end
    end
    return "ent_lootbox_low"
end

function Homigrad_SpawnLootBoxes()
    if roundActiveName ~= "level_homicide" and roundActiveName ~= "homicide" then return end

    -- Clean existing lootboxes from map if any
    for _, ent in ipairs(ents.FindByClass("ent_lootbox_*")) do
        if IsValid(ent) then ent:Remove() end
    end

    local spawnPositions = {}

    -- 1. Gather all map spawn entities
    local spawnClasses = {
        "info_player_deathmatch",
        "info_player_start",
        "info_player_terrorist",
        "info_player_counterterrorist",
        "info_player_allies",
        "info_player_axis",
        "info_player_teamspawn"
    }

    for _, cls in ipairs(spawnClasses) do
        for _, sp in ipairs(ents.FindByClass(cls)) do
            if IsValid(sp) then
                spawnPositions[#spawnPositions + 1] = sp:GetPos()
            end
        end
    end

    -- 2. Gather from navmesh if available
    if navmesh and isfunction(navmesh.GetAllNavAreas) then
        local areas = navmesh.GetAllNavAreas()
        if areas and #areas > 0 then
            table.Shuffle(areas)
            local maxNav = math.min(#areas, 30)
            for i = 1, maxNav do
                spawnPositions[#spawnPositions + 1] = areas[i]:GetCenter()
            end
        end
    end

    if #spawnPositions == 0 then return end
    table.Shuffle(spawnPositions)

    local targetCount = math.Clamp(math.random(8, 14), 6, math.min(#spawnPositions, 20))
    local spawned = 0

    for _, pos in ipairs(spawnPositions) do
        if spawned >= targetCount then break end

        -- Trace down to find floor with offset
        local offset = Vector(math.random(-120, 120), math.random(-120, 120), 40)
        local tr = util.TraceLine({
            start = pos + offset,
            endpos = pos + offset - Vector(0, 0, 300),
            mask = MASK_SOLID_BRUSHONLY
        })

        if tr.Hit and not tr.StartSolid then
            local boxClass = PickRandomLootBoxClass()
            local box = ents.Create(boxClass)
            if IsValid(box) then
                box:SetPos(tr.HitPos + tr.HitNormal * 4)
                box:SetAngles(Angle(0, math.random(0, 360), 0))
                box:Spawn()
                box:Activate()

                local phys = box:GetPhysicsObject()
                if IsValid(phys) then
                    phys:Wake()
                    phys:EnableMotion(true)
                end

                spawned = spawned + 1
            end
        end
    end

    print("[Homigrad] Автоматически заспавнено лутбоксов на карте: " .. tostring(spawned))
end

function StartRound(levelName)
    if GetGlobalBool("StopGame") then
        print("[Homigrad] Игра остановлена (StopGame). Старт отменён.")
        return
    end

    local targetLevel = levelName or levelNextName or roundActiveName or "level_homicide"
    local players = PlayersInGame()

    if #players < 1 and targetLevel ~= "level_construct" and targetLevel ~= "level_event" then
        print("[Homigrad] Недостаточно игроков для начала раунда (нужно минимум 1, сейчас 0). Раунд не запущен.")
        roundActive = false
        SyncActive()
        SetGlobalString("Game Error", "need_2_players")
        return
    end

    timer.Remove("HomigradRoundTransition")
    timer.Remove("HomigradRoundLoadscreen")

    roundActive = true
    SetGlobalString("Game Error", "")
    roundActiveName = levelName or levelNextName or "level_homicide"
    ActiveLevel = Levels[roundActiveName]

    if not ActiveLevel then
        roundActiveName = "level_homicide"
        ActiveLevel = Levels[roundActiveName]
    end

    -- Clean up map
    homigrad_cleaning_map = true
    SetGlobalBool("MapCleaning", true)
    game.CleanUpMap(false, {"env_fire"})
    homigrad_cleaning_map = nil
    SetGlobalBool("MapCleaning", false)

    -- Reset map lighting and skybox to bright daylight
    if Homigrad_ResetLighting then
        Homigrad_ResetLighting()
    else
        engine.LightStyle(0, "m")
        for _, li in ipairs(ents.FindByClass("light_environment")) do
            if IsValid(li) then
                li:Fire("SetPattern", "m")
                li:Fire("FadeToPattern", "m")
            end
        end
    end

    -- Remove loose corpses and dropped items
    for _, ent in ipairs(ents.FindByClass("prop_ragdoll")) do
        if IsValid(ent) and not ent:IsPlayer() then ent:Remove() end
    end
    for _, ent in ipairs(ents.FindByClass("hg_wep_dropped")) do
        if IsValid(ent) then ent:Remove() end
    end

    -- Spawn random loot boxes around the map
    Homigrad_SpawnLootBoxes()

    roundTimeStart = CurTime()
    if roundActiveName == "level_construct" then
        roundTime = 999999999999 * 60
    elseif roundActiveName == "level_event" then
        roundTime = (ActiveLevel and ActiveLevel.RoundTime) or 7200
    else
        roundTime = (ActiveLevel and ActiveLevel.RoundTime) or (roundActiveName == "level_homicide" and 300) or 360
    end
    roundData = {}
    roundDataEnd = nil

    -- Pick next level for subsequent round
    if manualNextLevel then
        levelNextName = manualNextLevel
    elseif GetGlobalBool("LevelRandom") then
        levelNextName = PickRandomLevel(true)
    else
        levelNextName = levelNextName or roundActiveName
    end

    local players = PlayersInGame()

    -- Distribute teams
    if ActiveLevel and ActiveLevel.teamEncoder then
        local teamKeys = {}
        for id in pairs(ActiveLevel.teamEncoder) do
            teamKeys[#teamKeys + 1] = id
        end
        table.sort(teamKeys)

        if #teamKeys > 1 then
            if roundActiveName == "level_hunter" then
                local hunterIdx = math.random(1, math.max(#players, 1))
                for i, ply in ipairs(players) do
                    if i == hunterIdx then
                        ply:SetTeam(1)
                    else
                        ply:SetTeam(2)
                    end
                end
            else
                local tIdx = 1
                for _, ply in ipairs(players) do
                    ply:SetTeam(teamKeys[tIdx])
                    tIdx = (tIdx % #teamKeys) + 1
                end
            end
        else
            for _, ply in ipairs(players) do
                ply:SetTeam(teamKeys[1] or 1)
            end
        end
    end

    -- Homicide role assignment
    if roundActiveName == "level_homicide" then
        local plys = table.Copy(players)
        table.Shuffle(plys)

        for _, ply in ipairs(players) do
            ply.roleT = false
            ply.roleCT = false
        end

        local tCount = math.Clamp(math.floor(#plys / 6), 1, 3)
        local traitors = {}
        for i = 1, tCount do
            if plys[1] then
                local tPly = table.remove(plys, 1)
                tPly.roleT = true
                traitors[#traitors + 1] = tPly
            end
        end

        local ctCount = math.Clamp(math.floor(#players / 5), 1, 2)
        local armedInnocents = {}
        for i = 1, ctCount do
            if plys[1] then
                local ctPly = table.remove(plys, 1)
                ctPly.roleCT = true
                armedInnocents[#armedInnocents + 1] = ctPly
            end
        end

        local roundType = math.random(1, 4)
        roundData = {
            traitors = traitors,
            inoccent = armedInnocents, -- client homicide/init_tier_0_sh.lua line 72 expects "inoccent"
            roundType = roundType
        }
    end

    -- Call level lifecycle start
    if ActiveLevel and ActiveLevel.Start then
        ActiveLevel:Start()
    end

    -- Spawn and arm players
    for _, ply in ipairs(players) do
        Homigrad_ResetPlayerStats(ply)
        ply.spawningFromRoundStart = true
        ply:Spawn()
        ply.spawningFromRoundStart = nil
        Homigrad_ResetPlayerStats(ply)
        ply:StripWeapons()
        ply:RemoveAllAmmo()
        ply:Give("weapon_hands")

        if roundActiveName == "level_homicide" then
            local rType = roundData.roundType or 2
            if ply.roleT then
                if rType == 4 then
                    ply:Give("wep_r8")
                    ply:GiveAmmo(24, "pistol", true)
                else
                    local pistol = (math.random(1, 2) == 1) and "wep_glock" or "wep_fiveseven"
                    ply:Give(pistol)
                    ply:GiveAmmo(30, "pistol", true)
                end
                ply:Give("weapon_kabar")
                ply:Give("weapon_hidebomb")
                ply:Give("weapon_poison")
            elseif ply.roleCT then
                ply:Give("weapon_police_bat")
                ply:Give("weapon_handcuffs")
                if rType == 4 then
                    ply:Give("wep_r8")
                    ply:GiveAmmo(24, "pistol", true)
                else
                    ply:Give("wep_deagl")
                    ply:GiveAmmo(28, "rifle", true)
                    ply:GiveAmmo(28, "pistol", true)
                end
            else
                if math.random(1, 4) == 1 then
                    local items = {"med_band", "med_painkiller", "weapon_per4ik"}
                    ply:Give(items[math.random(1, #items)])
                end
            end
        else
            if ActiveLevel and ActiveLevel.GiveGear then
                ActiveLevel:GiveGear(ply, ply:Team())
            end
        end
    end

    -- Broadcast state to all clients
    SyncActiveName()
    SyncNextName()
    SyncActive()
    SyncData()
    SyncEmit()
    SendLoadScreenEnd()

    hook.Run("Homigrad_RoundStart", roundActiveName)
    print("[Homigrad] Раунд начался: " .. tostring(roundActiveName))
end

function EndRound(winner)
    if not roundActive then return end
    roundActive = false

    -- Gather end data
    if roundActiveName == "level_homicide" then
        local traitorNames = {}
        local firstTraitor = nil
        if roundData and roundData.traitors then
            for _, p in ipairs(roundData.traitors) do
                if IsValid(p) then
                    traitorNames[#traitorNames + 1] = p:Nick()
                    if not firstTraitor then firstTraitor = p end
                end
            end
        end

        if not firstTraitor then
            for _, p in ipairs(player.GetAll()) do
                if p.roleT then
                    firstTraitor = p
                    if #traitorNames == 0 then traitorNames[1] = p:Nick() end
                    break
                end
            end
        end

        local traitorText = (#traitorNames > 0) and table.concat(traitorNames, ", ") or "unknown"
        local subtext = (#traitorNames <= 1) and {"homicide_traitor_wasone", traitorText} or {"homicide_traitor_was", traitorText}

        local plySteamID = IsValid(firstTraitor) and firstTraitor:SteamID() or ""
        local plySteamID64 = IsValid(firstTraitor) and firstTraitor:SteamID64() or ""
        local avatarURL = IsValid(firstTraitor) and (firstTraitor:GetNWString("Avatar", "") ~= "" and firstTraitor:GetNWString("Avatar") or (firstTraitor.GetAvatar and firstTraitor:GetAvatar()) or "") or ""
        local avatarFrame = IsValid(firstTraitor) and (firstTraitor:GetNWString("AvatarFrame", "") ~= "" and firstTraitor:GetNWString("AvatarFrame") or (firstTraitor.GetAvatarFrame and firstTraitor:GetAvatarFrame()) or "") or ""
        local traitorNick = IsValid(firstTraitor) and firstTraitor:Nick() or traitorText

        if winner == "traitor" or winner == "t" then
            roundDataEnd = {
                winnerVGUI = {
                    color = Color(255, 50, 50),
                    name = "round_winner",
                    text = "homicide_win_t",
                    subtext = subtext,
                    ply = firstTraitor,
                    steamid = plySteamID,
                    steamid64 = plySteamID64,
                    avatar = (avatarURL ~= "" and avatarURL) or (plySteamID64 ~= "" and plySteamID64) or (plySteamID ~= "" and plySteamID) or true,
                    avatarFrame = avatarFrame,
                    playerNick = traitorNick,
                    sound = "homigrad/vgui/panorama/case_awarded_4_legendary_01.wav"
                }
            }
        else
            roundDataEnd = {
                winnerVGUI = {
                    color = Color(75, 75, 255),
                    name = "round_winner",
                    text = "homicide_win_ct",
                    subtext = subtext,
                    ply = firstTraitor,
                    steamid = plySteamID,
                    steamid64 = plySteamID64,
                    avatar = (avatarURL ~= "" and avatarURL) or (plySteamID64 ~= "" and plySteamID64) or (plySteamID ~= "" and plySteamID) or true,
                    avatarFrame = avatarFrame,
                    playerNick = traitorNick,
                    sound = "homigrad/vgui/panorama/case_awarded_4_legendary_01.wav"
                }
            }
        end
    else
        if ActiveLevel and ActiveLevel.EndData then
            roundDataEnd = ActiveLevel:EndData(winner)
        else
            roundDataEnd = {
                winnerVGUI = {
                    color = Color(160, 160, 160),
                    name = "round_end",
                    text = "nobody_win",
                    sound = "homigrad/vgui/panorama/case_awarded_4_legendary_01.wav"
                }
            }
        end
    end

    if ActiveLevel and ActiveLevel.End then
        ActiveLevel:End(roundDataEnd)
    end

    SyncActive()
    SyncDataEnd()
    SyncEmit()

    if manualNextLevel then
        levelNextName = manualNextLevel
        manualNextLevel = nil
        SyncNextName()
    elseif GetGlobalBool("LevelRandom", true) then
        levelNextName = PickRandomLevel(true)
        SyncNextName()
    end

    hook.Run("Homigrad_RoundEnd", winner, roundDataEnd)
    print("[Homigrad] Раунд завершён. Победитель: " .. tostring(winner))

    -- Intermission timer before next round
    local intermissionTime = 8
    timer.Create("HomigradRoundTransition", intermissionTime, 1, function()
        if GetGlobalBool("StopGame") then return end

        if #PlayersInGame() < 1 and levelNextName ~= "level_construct" and levelNextName ~= "level_event" then
            print("[Homigrad] Нет игроков для следующего раунда.")
            roundActive = false
            SyncActive()
            SetGlobalString("Game Error", "need_players")
            return
        end

        SendLoadScreen(roundActiveName, levelNextName)

        timer.Create("HomigradRoundLoadscreen", 3, 1, function()
            if GetGlobalBool("StopGame") then
                SendLoadScreenEnd()
                return
            end
            if #PlayersInGame() < 1 and levelNextName ~= "level_construct" and levelNextName ~= "level_event" then
                print("[Homigrad] Нет игроков для следующего раунда.")
                roundActive = false
                SyncActive()
                SendLoadScreenEnd()
                SetGlobalString("Game Error", "need_players")
                return
            end
            StartRound(levelNextName)
        end)
    end)
end

-- =========================================================================
-- THINK & ROUND PROGRESSION
-- =========================================================================

local nextThink = 0

local function RoundSystem_Think()
    if CurTime() < nextThink then return end
    nextThink = CurTime() + 0.5

    if not roundActive then return end
    if GetGlobalBool("StopGame") then return end

    -- Abort round if player count drops below 1
    if #PlayersInGame() < 1 and roundActiveName ~= "level_construct" and roundActiveName ~= "level_event" then
        print("[Homigrad] Игроков нет. Завершение раунда...")
        EndRound("nobody")
        return
    end


    -- Give players grace time to spawn and receive loadout
    if CurTime() - roundTimeStart < 3 then return end

    -- Timer expiration
    if roundActiveName ~= "level_construct" and roundActiveName ~= "level_event" and roundTimeStart and roundTime and CurTime() >= roundTimeStart + roundTime then
        if roundActiveName == "level_homicide" then
            EndRound("innocent")
        else
            EndRound("nobody")
        end
        return
    end

    -- Check active level end condition
    if roundActiveName == "level_homicide" then
        local aliveT = 0
        local aliveInno = 0

        for _, ply in ipairs(PlayersInGame()) do
            local isAlive = ply:Alive() and not ply.isDead and not ply:GetNWBool("isDead") and not ply:GetNWBool("FakeDeath") and ply:Health() > 0
            if isAlive and not (ply.isHandcuffed or ply:GetNWBool("Handcuffed")) then
                if ply.roleT then
                    aliveT = aliveT + 1
                else
                    aliveInno = aliveInno + 1
                end
            end
        end

        if aliveT == 0 and aliveInno > 0 then
            EndRound("innocent")
        elseif aliveT > 0 and aliveInno == 0 then
            EndRound("traitor")
        elseif aliveT == 0 and aliveInno == 0 then
            EndRound("nobody")
        end
    else
        if ActiveLevel and ActiveLevel.CheckEnd then
            ActiveLevel:CheckEnd()
        end
    end
end

hook.Add("Think", "Homigrad_RoundSystem_Think", RoundSystem_Think)

-- Block all respawns upon death: killed players stay dead corpses / spectators
hook.Add("PlayerDeathThink", "Homigrad_RoundSystem_DeathThink", function(ply)
    return false
end)

local function Homigrad_BlockGMDeathThink()
    if GAMEMODE then
        GAMEMODE.PlayerDeathThink = function(self, ply)
            return false
        end
    end
end
hook.Add("Initialize", "Homigrad_BlockGMDeathThink", Homigrad_BlockGMDeathThink)
hook.Add("PostGamemodeLoaded", "Homigrad_BlockGMDeathThink", Homigrad_BlockGMDeathThink)
if GAMEMODE then Homigrad_BlockGMDeathThink() end

util.AddNetworkString("Construct respawn")

hook.Add("PlayerDeath", "Homigrad_RoundSystem_PlayerDeath", function(ply)
    ply.isDead = true
    ply:SetNWBool("isDead", true)
    ply:SetNWBool("Alive", false)
    ply:SetNWFloat("DeadStart", CurTime())
    ply:SetNWFloat("DeathStart", CurTime())
    if roundActiveName == "level_construct" or roundActiveName == "level_event" then
        local grp = ply.eventGroup
        local delay = (roundActiveName == "level_event" and grp and grp.spawnTime) or (ActiveLevel and ActiveLevel.RespawnDelay) or 10
        ply:SetNWFloat("DeathWait", CurTime() + delay)
    end
    if RoundSystem_Think then
        timer.Simple(0, function()
            if RoundSystem_Think then RoundSystem_Think() end
        end)
    end
end)

net.Receive("Construct respawn", function(len, ply)
    if not IsValid(ply) or (ply:Alive() and not ply:GetNWBool("FakeDeath")) then return end
    if roundActiveName ~= "level_construct" then return end
    if ply:GetNWFloat("DeathWait", 0) > CurTime() then return end

    ply.isDead = false
    ply:SetNWBool("isDead", false)
    ply:SetNWBool("Alive", true)
    ply:SetNWBool("FakeDeath", false)
    ply.HeadPop = nil
    ply:SetNWBool("HeadPop", false)

    local rag = ply:GetNWEntity("FakeRagdoll")
    if not IsValid(rag) then rag = ply.fakeEnt end
    if IsValid(rag) and not rag:IsPlayer() then
        rag:Remove()
    end
    ply.fakeEnt = nil
    ply:SetNWEntity("FakeRagdoll", NULL)

    ply:UnSpectate()
    ply:SetMoveType(MOVETYPE_WALK)
    ply:SetNoDraw(false)
    ply:SetNotSolid(false)
    ply.constructRespawn = true
    ply:Spawn()
    ply.constructRespawn = nil

    if IsValid(ply.customSpawnPoint) and ply.customSpawnPoint:GetNWBool("Uses", false) then
        ply:SetPos(ply.customSpawnPoint:GetPos() + Vector(0, 0, 16))
    end

    ply:StripWeapons()
    ply:RemoveAllAmmo()
    ply:Give("weapon_hands")

    if ActiveLevel and ActiveLevel.GiveGear then
        ActiveLevel:GiveGear(ply, ply:Team())
    end
end)

-- Auto start initial round when map is ready and at least 1 player is in game
hook.Add("InitPostEntity", "Homigrad_RoundSystem_Init", function()
    timer.Simple(5, function()
        if not roundActive and not GetGlobalBool("StopGame") and #PlayersInGame() >= 1 then
            StartRound()
        end
    end)
end)

hook.Add("PlayerInitialSpawn", "Homigrad_CheckStartOnJoin", function(ply)
    timer.Simple(2.5, function()
        if not roundActive and not GetGlobalBool("StopGame") and #PlayersInGame() >= 1 then
            print("[Homigrad] Игрок подключился. Запуск раунда...")
            StartRound()
        end
    end)
end)

hook.Add("PlayerSpawn", "Homigrad_RoundSystem_FirstPlayer", function(ply)
    if not roundActive and not GetGlobalBool("StopGame") and #PlayersInGame() >= 1 then
        timer.Simple(2, function()
            if not roundActive and not GetGlobalBool("StopGame") and #PlayersInGame() >= 1 then
                StartRound()
            end
        end)
    end
end)


-- =========================================================================
-- COMMANDS (CONSOLE, CHAT, ULX, ADMINPANEL)
-- =========================================================================

local function CanRunAdminCmd(ply)
    if not IsValid(ply) then return true end
    if ply:IsAdmin() or ply:IsSuperAdmin() then return true end
    if AdminPanelRole_HasSuccess and AdminPanelRole_HasSuccess(ply, "admin") then return true end
    return false
end

concommand.Add("levelstart", function(ply, cmd, args)
    if not CanRunAdminCmd(ply) then return end
    local lvl = args[1]
    if lvl and lvl ~= "" then
        SetNextLevel(lvl)
        StartRound(levelNextName)
    else
        StartRound()
    end
end)

concommand.Add("levelend", function(ply, cmd, args)
    if not CanRunAdminCmd(ply) then return end
    local winner = args[1] or "admin"
    if tonumber(winner) then winner = tonumber(winner) end
    EndRound(winner)
end)

concommand.Add("levelnext", function(ply, cmd, args)
    if not CanRunAdminCmd(ply) then return end
    if args[1] then
        SetNextLevel(args[1])
    end
end)

concommand.Add("levelstop", function(ply, cmd, args)
    if not CanRunAdminCmd(ply) then return end
    local val = args[1] and tobool(args[1]) or not GetGlobalBool("StopGame")
    SetGlobalBool("StopGame", val)
    if val then
        timer.Remove("HomigradRoundTransition")
        timer.Remove("HomigradRoundLoadscreen")
        SendLoadScreenEnd()
    end
    print("[Homigrad] StopGame: " .. tostring(val))
end)

concommand.Add("stopgame", function(ply, cmd, args)
    if not CanRunAdminCmd(ply) then return end
    local val = (args[1] ~= nil) and tobool(args[1]) or not GetGlobalBool("StopGame")
    SetGlobalBool("StopGame", val)
    if val then
        timer.Remove("HomigradRoundTransition")
        timer.Remove("HomigradRoundLoadscreen")
        SendLoadScreenEnd()
    end
    print("[Homigrad] StopGame: " .. tostring(val))
end)

concommand.Add("levelrandom", function(ply, cmd, args)
    if not CanRunAdminCmd(ply) then return end
    local val = (args[1] ~= nil) and tobool(args[1]) or not GetGlobalBool("LevelRandom")
    SetGlobalBool("LevelRandom", val)
    print("[Homigrad] LevelRandom: " .. tostring(val))
end)

concommand.Add("roundactive", function(ply, cmd, args)
    if not CanRunAdminCmd(ply) then return end
    if roundActive then
        EndRound("admin")
    else
        StartRound()
    end
end)

-- Chat commands (!levelstart, !levelend, !levelnext, etc.)
hook.Add("PlayerSay", "Homigrad_RoundSystem_ChatCmds", function(ply, text)
    if not CanRunAdminCmd(ply) then return end
    local lower = string.lower(text)
    local parts = string.Explode(" ", lower)
    local cmd = parts[1]

    if cmd == "!levelstart" then
        if parts[2] then SetNextLevel(parts[2]) StartRound(levelNextName) else StartRound() end
        return ""
    elseif cmd == "!levelend" then
        EndRound("admin")
        return ""
    elseif cmd == "!levelnext" and parts[2] then
        SetNextLevel(parts[2])
        return ""
    elseif cmd == "!levelstop" or cmd == "!stopgame" then
        local val = not GetGlobalBool("StopGame")
        SetGlobalBool("StopGame", val)
        return ""
    elseif cmd == "!levelrandom" then
        local val = not GetGlobalBool("LevelRandom")
        SetGlobalBool("LevelRandom", val)
        return ""
    elseif cmd == "!roundactive" then
        if roundActive then EndRound("admin") else StartRound() end
        return ""
    elseif cmd == "!teamforce" then
        local targetStr = parts[2]
        local teamArg = tonumber(parts[3]) or 1

        if not targetStr then
            ply:ChatPrint("[Homigrad] Использование: !teamforce <steamid/имя> <1/2/3/1002>")
            return ""
        end

        local target
        local rawUpper = string.upper(targetStr)
        for _, p in ipairs(player.GetAll()) do
            if string.upper(p:SteamID()) == rawUpper or p:SteamID64() == targetStr then
                target = p
                break
            end
        end
        if not target then
            local lowTarget = string.lower(targetStr)
            for _, p in ipairs(player.GetAll()) do
                if string.find(string.lower(p:Nick()), lowTarget, 1, true) then
                    target = p
                    break
                end
            end
        end

        if not IsValid(target) then
            ply:ChatPrint("[Homigrad] Игрок не найден: " .. tostring(targetStr))
            return ""
        end

        local lvl = ActiveLevel
        local isHomicide = (roundActiveName == "level_homicide")

        if isHomicide then
            if teamArg == 2 then
                target.roleT = true
                target.roleCT = false
                roundData = roundData or {}
                roundData.traitors = roundData.traitors or {}
                local found = false
                for _, tr in ipairs(roundData.traitors) do
                    if tr == target then found = true break end
                end
                if not found then table.insert(roundData.traitors, target) end
                if roundData.inoccent then table.RemoveByValue(roundData.inoccent, target) end

                target:StripWeapons()
                target:RemoveAllAmmo()
                target:Give("weapon_hands")
                local rType = (roundData and roundData.roundType) or 2
                if rType == 4 then
                    target:Give("wep_r8")
                    target:GiveAmmo(24, "pistol", true)
                else
                    local pistol = (math.random(1, 2) == 1) and "wep_glock" or "wep_fiveseven"
                    target:Give(pistol)
                    target:GiveAmmo(30, "pistol", true)
                end
                target:Give("weapon_kabar")
                target:Give("weapon_hidebomb")
                target:Give("weapon_poison")
                target:ChatPrint("Вы были назначены Предателем (Красный)!")
            elseif teamArg == 1 then
                target.roleT = false
                target.roleCT = false
                if roundData and roundData.traitors then
                    table.RemoveByValue(roundData.traitors, target)
                end
                target:ChatPrint("Вы были назначены Невиновным!")
            elseif teamArg == 3 or teamArg == 1002 then
                target.roleT = false
                target.roleCT = false
                if roundData and roundData.traitors then
                    table.RemoveByValue(roundData.traitors, target)
                end
                target.hgChangingTeamNoKill = true
                target:SetTeam(1002)
                target.hgChangingTeamNoKill = nil
                if target:Alive() then
                    target:KillSilent()
                end
                target:ChatPrint("Вы переведены в Наблюдатели (Spectator)!")
            end

            net.Start("roundData")
            net.WriteTable(roundData or {})
            net.WriteFloat(roundTimeStart or CurTime())
            net.WriteFloat(roundTime or 300)
            net.Broadcast()
            LevelCall("Sync", roundData)
        else
            local targetTeam = teamArg
            if teamArg == 3 and not (lvl and lvl.teamEncoder and lvl.teamEncoder[3]) then
                targetTeam = 1002
            end

            target.hgChangingTeamNoKill = true
            target:SetTeam(targetTeam)
            target.hgChangingTeamNoKill = nil

            if targetTeam == 1002 then
                if target:Alive() then
                    target:KillSilent()
                end
                target:ChatPrint("Вы переведены в Наблюдатели (Spectator)!")
            else
                local tName = (lvl and lvl.GetTeamName and lvl:GetTeamName(target)) or ("Команда " .. tostring(targetTeam))
                target:ChatPrint("Вы переведены в команду: " .. tostring(tName) .. "!")
            end
        end

        ply:ChatPrint("[Homigrad] " .. target:Nick() .. " переведен (команда/роль: " .. tostring(teamArg) .. ")")
        return ""
    end
end)

-- Prevent unwanted respawn and player death on team change
local function Homigrad_SetupTeamHooks()
    if not GAMEMODE then return end

    GAMEMODE.PlayerRequestTeam = function(self, ply, teamid)
        if not IsValid(ply) then return end
        if not team.Joinable(teamid) and teamid ~= 1002 then return end
        self:PlayerJoinTeam(ply, teamid)
    end

    GAMEMODE.PlayerJoinTeam = function(self, ply, teamid)
        if not IsValid(ply) then return end
        local old = ply:Team()
        ply:SetTeam(teamid)
        hook.Run("OnPlayerChangedTeam", ply, old, teamid)
        hook.Run("OnTeamChanged", ply, old, teamid)

        if teamid == 1002 then
            if ply:Alive() then ply:KillSilent() end
            ply.isDead = true
            ply:SetNWBool("isDead", true)
            ply:SetNWBool("Alive", false)
            ply:SetNWBool("FakeDeath", true)
            timer.Simple(0.2, function()
                if IsValid(ply) and not ply:Alive() then
                    ply:Spectate(OBS_MODE_ROAMING)
                    ply:SetMoveType(MOVETYPE_NOCLIP)
                end
            end)
        else
            -- When switching to a player team while dead, DO NOT RESPAWN in standard round modes
            if not ply:Alive() then
                if roundActiveName == "level_construct" or roundActiveName == "level_event" then
                    ply:Spawn()
                else
                    ply.isDead = true
                    ply:SetNWBool("isDead", true)
                    ply:SetNWBool("Alive", false)
                    ply:SetNWBool("FakeDeath", true)
                    timer.Simple(0.2, function()
                        if IsValid(ply) and not ply:Alive() then
                            ply:Spectate(OBS_MODE_ROAMING)
                            ply:SetMoveType(MOVETYPE_NOCLIP)
                        end
                    end)
                end
            end
        end
    end
end

if GAMEMODE then Homigrad_SetupTeamHooks() end
hook.Add("Initialize", "Homigrad_NoKillPlayerJoinTeam", Homigrad_SetupTeamHooks)
hook.Add("PostGamemodeLoaded", "Homigrad_NoKillPlayerJoinTeam", Homigrad_SetupTeamHooks)

-- ULX command hooks if ULib / ULX installed
timer.Simple(1, function()
    if ULib and ulx then
        function ulx.levelstart(calling_ply, lvl)
            if lvl and lvl ~= "" then SetNextLevel(lvl) StartRound(levelNextName) else StartRound() end
            ulx.fancyLogAdmin(calling_ply, "#A запустил раунд (#s)", roundActiveName)
        end
        local c_start = ulx.command("Homigrad", "ulx levelstart", ulx.levelstart, "!levelstart")
        c_start:addParam{ type = ULib.cmds.StringArg, hint = "level name", ULib.cmds.optional }
        c_start:defaultAccess(ULib.ACCESS_ADMIN)
        c_start:help("Запустить раунд.")

        function ulx.levelend(calling_ply)
            EndRound("admin")
            ulx.fancyLogAdmin(calling_ply, "#A завершил текущий раунд")
        end
        local c_end = ulx.command("Homigrad", "ulx levelend", ulx.levelend, "!levelend")
        c_end:defaultAccess(ULib.ACCESS_ADMIN)
        c_end:help("Завершить текущий раунд.")

        function ulx.levelnext(calling_ply, lvl)
            SetNextLevel(lvl)
            ulx.fancyLogAdmin(calling_ply, "#A установил следующий уровень: #s", levelNextName)
        end
        local c_next = ulx.command("Homigrad", "ulx levelnext", ulx.levelnext, "!levelnext")
        c_next:addParam{ type = ULib.cmds.StringArg, hint = "level name" }
        c_next:defaultAccess(ULib.ACCESS_ADMIN)
        c_next:help("Выбрать следующий уровень.")

        function ulx.stopgame(calling_ply, bool)
            SetGlobalBool("StopGame", bool)
            if bool then
                timer.Remove("HomigradRoundTransition")
                timer.Remove("HomigradRoundLoadscreen")
                SendLoadScreenEnd()
            end
            ulx.fancyLogAdmin(calling_ply, "#A установил StopGame в #s", tostring(bool))
        end
        local c_stop = ulx.command("Homigrad", "ulx stopgame", ulx.stopgame, "!stopgame")
        c_stop:addParam{ type = ULib.cmds.BoolArg, default = true }
        c_stop:defaultAccess(ULib.ACCESS_ADMIN)
        c_stop:help("Остановить или возобновить логику раундов.")

        function ulx.levelrandom(calling_ply, bool)
            SetGlobalBool("LevelRandom", bool)
            ulx.fancyLogAdmin(calling_ply, "#A установил случайный выбор уровней: #s", tostring(bool))
        end
        local c_rand = ulx.command("Homigrad", "ulx levelrandom", ulx.levelrandom, "!levelrandom")
        c_rand:addParam{ type = ULib.cmds.BoolArg, default = true }
        c_rand:defaultAccess(ULib.ACCESS_ADMIN)
        c_rand:help("Включить/выключить случайную смену уровней.")

        function ulx.roundactive(calling_ply)
            if roundActive then EndRound("admin") else StartRound() end
            ulx.fancyLogAdmin(calling_ply, "#A переключил активность раунда: #s", tostring(roundActive))
        end
        local c_act = ulx.command("Homigrad", "ulx roundactive", ulx.roundactive, "!roundactive")
        c_act:defaultAccess(ULib.ACCESS_ADMIN)
        c_act:help("Переключить состояние раунда (активен / неактивен).")

        function ulx.respawn(calling_ply, target_plys)
            for _, ply in ipairs(target_plys) do
                Homigrad_RespawnPlayer(ply)
            end
            ulx.fancyLogAdmin(calling_ply, "#A возродил #T", target_plys)
        end
        local c_respawn = ulx.command("Homigrad", "ulx respawn", ulx.respawn, "!respawn")
        c_respawn:addParam{ type = ULib.cmds.PlayersArg, default = "<me>", ULib.cmds.optional }
        c_respawn:defaultAccess(ULib.ACCESS_ADMIN)
        c_respawn:help("Возродить игрока.")
    end
end)

-- =========================================================================
-- RESPAWN COMMAND SYSTEM
-- =========================================================================

function Homigrad_RespawnPlayer(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    -- Remove any existing ragdolls
    local rag = (IsValid(ply.fakeEnt) and ply.fakeEnt)
        or (IsValid(ply.FakeRagdoll) and ply.FakeRagdoll)
        or (IsValid(ply.hgFakeRagdoll) and ply.hgFakeRagdoll)
        or ply:GetNWEntity("FakeRagdoll")
        or ply:GetNWEntity("DeathRagdoll")
        or ply:GetNWEntity("Ragdoll")
    if IsValid(rag) and rag ~= ply then
        if clearGrab then
            clearGrab(rag.ZacConsLH)
            clearGrab(rag.ZacConsRH)
            rag.ZacConsLH, rag.ZacConsRH = nil, nil
        end
        rag:Remove()
    end
    ply:SetNWEntity("FakeRagdoll", NULL)
    ply:SetNWEntity("DeathRagdoll", NULL)
    ply:SetNWEntity("Ragdoll", NULL)
    ply.FakeRagdoll = nil
    ply.fakeEnt = nil
    ply.hgFakeRagdoll = nil

    ply.fake = false
    ply.Fake = false
    ply:SetNWBool("fake", false)
    ply:SetNWBool("Fake", false)
    ply.isDead = false
    ply:SetNWBool("isDead", false)
    ply:SetNWBool("Alive", true)
    ply:SetNWBool("FakeDeath", false)
    ply.heartstop = false
    ply:SetNWBool("heartstop", false)
    ply.HeadPop = nil
    ply:SetNWBool("HeadPop", false)
    ply.Otrub = 0
    ply:SetNWBool("Otrub", false)
    ply:SetNWBool("otrub", false)
    ply.pain = 0
    ply.bleed = 0
    ply.blood = 5000

    -- Reset bone manipulations (e.g. from headshots)
    for b = 0, ply:GetBoneCount() - 1 do
        ply:ManipulateBoneScale(b, Vector(1, 1, 1))
    end

    ply:UnSpectate()
    ply:SetNoDraw(false)
    ply:SetNotSolid(false)
    ply:SetMoveType(MOVETYPE_WALK)
    ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)

    ply.constructRespawn = true
    ply:Spawn()
    ply.constructRespawn = nil

    Homigrad_ResetPlayerStats(ply)

    ply:StripWeapons()
    ply:RemoveAllAmmo()
    ply:Give("weapon_physgun")
    ply:Give("gmod_tool")
    ply:Give("weapon_hands")
    ply:SelectWeapon("weapon_hands")

    timer.Simple(0, function()
        if not IsValid(ply) or not ply:Alive() then return end
        for _, wep in ipairs(ply:GetWeapons()) do
            local cls = wep:GetClass()
            if cls ~= "weapon_physgun" and cls ~= "gmod_tool" and cls ~= "weapon_hands" then
                wep:Remove()
            end
        end
        if not ply:HasWeapon("weapon_physgun") then ply:Give("weapon_physgun") end
        if not ply:HasWeapon("gmod_tool") then ply:Give("gmod_tool") end
        if not ply:HasWeapon("weapon_hands") then ply:Give("weapon_hands") end
        ply:SelectWeapon("weapon_hands")
    end)
end

local function FindPlayerByName(name, caller)
    if not name or name == "" then return caller end
    name = string.lower(string.Trim(name))
    if name == "^" or name == "me" then return caller end

    for _, p in ipairs(player.GetAll()) do
        if string.lower(p:Nick()) == name or string.lower(p:SteamID()) == name then
            return p
        end
    end

    for _, p in ipairs(player.GetAll()) do
        if string.find(string.lower(p:Nick()), name, 1, true) then
            return p
        end
    end
    return nil
end

hook.Add("PlayerSay", "Homigrad_RespawnChatCommand", function(ply, text)
    if not IsValid(ply) then return end
    local lower = string.lower(string.Trim(text))
    if string.StartWith(lower, "!respawn") or string.StartWith(lower, "/respawn") then
        local targetName = string.Trim(string.sub(text, string.find(text, " ") or #text + 1))
        local target = ply
        if targetName ~= "" and targetName ~= lower then
            target = FindPlayerByName(targetName, ply)
        end

        if not IsValid(target) then
            ply:ChatPrint("[Homigrad] Игрок не найден: " .. tostring(targetName))
            return ""
        end

        Homigrad_RespawnPlayer(target)
        if target == ply then
            ply:ChatPrint("[Homigrad] Вы успешно возродились.")
        else
            ply:ChatPrint("[Homigrad] Вы возродили игрока " .. target:Nick() .. ".")
            target:ChatPrint("[Homigrad] Вас возродил " .. ply:Nick() .. ".")
        end
        return ""
    end
end)

concommand.Add("respawn", function(ply, cmd, args)
    local target = ply
    if args and args[1] then
        target = FindPlayerByName(args[1], ply)
    end
    if not IsValid(target) then
        if IsValid(ply) then ply:ChatPrint("[Homigrad] Игрок не найден.") else print("[Homigrad] Игрок не найден.") end
        return
    end
    Homigrad_RespawnPlayer(target)
    if IsValid(ply) then
        ply:ChatPrint("[Homigrad] Возрожден: " .. target:Nick())
    else
        print("[Homigrad] Возрожден: " .. target:Nick())
    end
end)

