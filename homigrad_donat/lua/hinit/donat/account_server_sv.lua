if not SERVER then return end

util.AddNetworkString("balance_sync")
util.AddNetworkString("donat_inventory_sync")
util.AddNetworkString("freedrop_sync")
util.AddNetworkString("outfit_profile_sync")
util.AddNetworkString("mission_sync")
util.AddNetworkString("email_sync")
util.AddNetworkString("shop_buy")
util.AddNetworkString("donat_inventory_outfit")
util.AddNetworkString("donat_inventory_model_outfit")

file.CreateDir("homigrad")
file.CreateDir("homigrad/accounts")

local function getAccountFilePath(steamid64)
    return "homigrad/accounts/" .. steamid64 .. ".json"
end

function Homigrad_LoadAccount(steamid64)
    if not steamid64 or steamid64 == "" then return nil end
    local path = getAccountFilePath(steamid64)
    local data = nil

    if file.Exists(path, "DATA") then
        local raw = file.Read(path, "DATA")
        if raw and raw ~= "" then
            data = util.JSONToTable(raw)
        end
    end

    if not istable(data) then
        data = {
            balance = { money = 50000, moneyDonat = 1000 },
            inventory = {},
            freedrop = { complete = {}, time = 0 },
            outfit = { playermodelItemID = nil, items = {} },
            missions = {},
            email = {}
        }
    else
        data.balance = data.balance or { money = 50000, moneyDonat = 1000 }
        data.balance.money = data.balance.money or 50000
        data.balance.moneyDonat = data.balance.moneyDonat or 1000
        data.inventory = data.inventory or {}
        data.freedrop = data.freedrop or { complete = {}, time = 0 }
        data.freedrop.complete = data.freedrop.complete or {}
        data.outfit = data.outfit or { items = {} }
        data.missions = data.missions or {}
        data.email = data.email or {}
    end

    -- Keep shared global tables in sync for server-side queries
    BalanceData[steamid64] = data.balance
    DonatInventoryData[steamid64] = data.inventory
    FreeDropData[steamid64] = data.freedrop
    OutfitData[steamid64] = data.outfit
    MissionData[steamid64] = data.missions
    EmailData[steamid64] = data.email

    return data
end

function Homigrad_SaveAccount(steamid64, data)
    if not steamid64 or not istable(data) then return end
    file.Write(getAccountFilePath(steamid64), util.TableToJSON(data, true))

    BalanceData[steamid64] = data.balance
    DonatInventoryData[steamid64] = data.inventory
    FreeDropData[steamid64] = data.freedrop
    OutfitData[steamid64] = data.outfit
    MissionData[steamid64] = data.missions
    EmailData[steamid64] = data.email
end

function Homigrad_SyncAccount(ply)
    if not IsValid(ply) or ply:IsBot() then return end
    local sid64 = ply:SteamID64()
    if not sid64 then return end

    local acc = Homigrad_LoadAccount(sid64)
    if not acc then return end

    net.Start("balance_sync")
    net.WriteString("json:" .. (util.TableToJSON(acc.balance) or "{}"))
    net.WriteString(sid64)
    net.Send(ply)

    net.Start("donat_inventory_sync")
    net.WriteString("json:" .. (util.TableToJSON(acc.inventory) or "{}"))
    net.WriteString(sid64)
    net.Send(ply)

    net.Start("freedrop_sync")
    net.WriteString("json:" .. (util.TableToJSON(acc.freedrop) or "{}"))
    net.WriteString(sid64)
    net.Send(ply)

    net.Start("outfit_profile_sync")
    net.WriteString("json:" .. (util.TableToJSON(acc.outfit) or "{}"))
    net.WriteString(sid64)
    net.Send(ply)

    net.Start("mission_sync")
    net.WriteString("json:" .. (util.TableToJSON(acc.missions or {}) or "{}"))
    net.WriteString(sid64)
    net.Send(ply)
end

function Homigrad_SyncOutfit(ply)
    if not IsValid(ply) or ply:IsBot() then return end
    local sid64 = ply:SteamID64()
    if not sid64 then return end

    local acc = Homigrad_LoadAccount(sid64)
    if not acc then return end

    net.Start("outfit_profile_sync")
    net.WriteString("json:" .. (util.TableToJSON(acc.outfit) or "{}"))
    net.WriteString(sid64)
    net.Broadcast()
end

function Homigrad_UpdateProfileSetting(ply, cvarName, value)
    if not IsValid(ply) or ply:IsBot() then return end
    local sid64 = ply:SteamID64()
    if not sid64 then return end

    local acc = Homigrad_LoadAccount(sid64)
    if not acc then return end
    acc.outfit = acc.outfit or { items = {} }

    if cvarName == "hg_profile_showsteambackground" then
        acc.outfit.backgroundSteam = tobool(value) or value == "1"
    elseif cvarName == "hg_profile_background_opacity" then
        acc.outfit.backgroundOpacity = tonumber(value) or 0
    elseif cvarName == "hg_profile_background_y" then
        acc.outfit.backgroundY = tonumber(value) or 0
    elseif cvarName == "hg_profile_background" then
        acc.outfit.background = tostring(value)
    elseif cvarName == "hg_profile_color" then
        if value and value ~= "" then
            local parsed = util.JSONToTable(value)
            acc.outfit.color = parsed
        else
            acc.outfit.color = nil
        end
    end

    Homigrad_SaveAccount(sid64, acc)
    Homigrad_SyncOutfit(ply)
end

net.Receive("cvars_replicate", function(len, ply)
    if not IsValid(ply) then return end
    local name = net.ReadString()
    local val = net.ReadString()
    if string.StartWith(name, "hg_profile_") then
        Homigrad_UpdateProfileSetting(ply, name, val)
    end
end)

local profileCv = {
    "hg_profile_showsteambackground",
    "hg_profile_background_opacity",
    "hg_profile_background_y",
    "hg_profile_background",
    "hg_profile_color"
}
for _, cv in ipairs(profileCv) do
    concommand.Add(cv, function(ply, cmd, args)
        if not IsValid(ply) then return end
        local val = table.concat(args, " ")
        Homigrad_UpdateProfileSetting(ply, cv, val)
    end)
end

hook.Add("PlayerInitialSpawn", "Homigrad_AccountSync_Initial", function(ply)
    timer.Simple(2, function()
        if IsValid(ply) then
            Homigrad_SyncAccount(ply)
        end
    end)
end)

-- Apply equipped playermodel from outfit data
hook.Add("PlayerSpawn", "Homigrad_Account_ApplyOutfit", function(ply)
    if not IsValid(ply) or ply:IsBot() then return end
    local sid64 = ply:SteamID64()
    if not sid64 then return end

    local acc = Homigrad_LoadAccount(sid64)
    if acc and acc.outfit and acc.outfit.playermodelItemData and acc.outfit.playermodelItemData.model then
        local mdl = acc.outfit.playermodelItemData.model
        if util.IsValidModel(mdl) then
            ply:SetModel(mdl)
        end
    end
end)

-- Shop Purchase Handler
net.Receive("shop_buy", function(len, ply)
    if not IsValid(ply) then return end
    local catID = net.ReadInt(11)
    local subID = net.ReadInt(11)
    local itemID = net.ReadInt(11)
    local count = math.Clamp(net.ReadInt(7), 1, 100)

    local cat = ShopConfig and ShopConfig[catID]
    if not cat then return end

    local itemData
    if subID and subID > 0 and cat.list and cat.list[subID] and cat.list[subID].list then
        itemData = cat.list[subID].list[itemID]
    elseif cat.list and cat.list[itemID] then
        itemData = cat.list[itemID]
    end

    if not itemData then return end

    local sid64 = ply:SteamID64()
    local acc = Homigrad_LoadAccount(sid64)
    if not acc then return end

    local price = itemData.price and (itemData.price * count)
    local priceDonat = itemData.priceDonat and (itemData.priceDonat * count)

    if price and (acc.balance.money or 0) >= price then
        acc.balance.money = acc.balance.money - price
    elseif priceDonat and (acc.balance.moneyDonat or 0) >= priceDonat then
        acc.balance.moneyDonat = acc.balance.moneyDonat - priceDonat
    else
        return -- Not enough funds
    end

    -- Add items to inventory
    for i = 1, count do
        local uniqID = tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)) .. "_" .. tostring(i)
        local invItem = table.Copy(itemData)
        invItem.price = nil
        invItem.priceDonat = nil
        acc.inventory[uniqID] = invItem
    end

    Homigrad_SaveAccount(sid64, acc)
    Homigrad_SyncAccount(ply)
end)

-- Free Drop Claim Handler
net.Receive("freedrop_sync", function(len, ply)
    if not IsValid(ply) then return end
    local dayStr = net.ReadString()
    local day = tonumber(dayStr)
    if not day or not FreeDropConfig or not FreeDropConfig[day] then return end

    local sid64 = ply:SteamID64()
    local acc = Homigrad_LoadAccount(sid64)
    if not acc then return end

    acc.freedrop = acc.freedrop or { complete = {}, time = 0 }
    acc.freedrop.complete = acc.freedrop.complete or {}

    if acc.freedrop.complete[day] then return end -- already claimed

    acc.freedrop.complete[day] = true
    acc.freedrop.time = os.time()

    -- Add items from config
    local reward = FreeDropConfig[day]
    if istable(reward) then
        for _, it in ipairs(reward) do
            local uniqID = tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999))
            acc.inventory[uniqID] = table.Copy(it)
        end
    end

    if FreeDropConfigAdded and FreeDropConfigAdded[day] then
        for _, it in ipairs(FreeDropConfigAdded[day]) do
            local uniqID = tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999))
            acc.inventory[uniqID] = table.Copy(it)
        end
    end

    Homigrad_SaveAccount(sid64, acc)
    Homigrad_SyncAccount(ply)
end)

-- Outfit Playermodel Equip/Unequip Handler
net.Receive("donat_inventory_outfit", function(len, ply)
    if not IsValid(ply) then return end
    local itemID = net.ReadString()
    local sid64 = ply:SteamID64()
    local acc = Homigrad_LoadAccount(sid64)
    if not acc then return end

    acc.outfit = acc.outfit or {}

    if itemID == "" or itemID == "nil" then
        acc.outfit.playermodelItemID = nil
        acc.outfit.playermodelItemData = nil
    else
        local invItem = acc.inventory[itemID]
        if invItem and (invItem.class == "playermodel" or invItem.model) then
            acc.outfit.playermodelItemID = itemID
            acc.outfit.playermodelItemData = invItem
            if invItem.model and util.IsValidModel(invItem.model) then
                ply:SetModel(invItem.model)
            end
        end
    end

    Homigrad_SaveAccount(sid64, acc)
    Homigrad_SyncAccount(ply)
end)

-- Inventory Item Command Handler (add, clone, remove, set)
net.Receive("donat_inventory_sync", function(len, ply)
    if not IsValid(ply) then return end
    local sid64 = net.ReadString()
    local args = net.ReadTable()
    if not istable(args) or not args[1] then return end

    local acc = Homigrad_LoadAccount(sid64 or ply:SteamID64())
    if not acc then return end

    local cmd = args[1]
    if cmd == "remove" then
        local id = tostring(args[2])
        acc.inventory[id] = nil
    elseif cmd == "clone" then
        local id = tostring(args[2])
        if acc.inventory[id] then
            local newID = tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999))
            acc.inventory[newID] = table.Copy(acc.inventory[id])
        end
    elseif cmd == "set" then
        local id = tostring(args[2])
        if args[3] and istable(args[3]) then
            acc.inventory[id] = args[3]
        end
    elseif cmd == "add" then
        local class = args[2]
        if class then
            local newID = tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999))
            acc.inventory[newID] = { class = class }
        end
    end

    Homigrad_SaveAccount(sid64 or ply:SteamID64(), acc)
    Homigrad_SyncAccount(ply)
end)
