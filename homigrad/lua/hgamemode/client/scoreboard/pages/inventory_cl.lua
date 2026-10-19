--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/client/scoreboard/pages/inventory_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\client\\scoreboard\\pages\\inventory_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Panel = ScoreboardPages[2] or {}
ScoreboardPages[2] = Panel

Panel.Name = "inventory"

local SetDrawColor,DrawRect = surface.SetDrawColor,surface.DrawRect

local function EnsureInvFont()
    local mul = ScrW() / 1920
    if mul < 0.75 then mul = 0.75 end
    surface.CreateFont("InvFont",{
        font = "Arial",
        size = math.max(12, math.Round(12 * mul)),
        weight = 0,
        outline = true,
        shadow = true,
        antialias = false,
        additive = true,
    })
end
EnsureInvFont()

local function IsInsidePanel(pnl, target)
    if not IsValid(pnl) or not IsValid(target) then return false end
    if pnl == target then return true end
    local cur = pnl:GetParent()
    while IsValid(cur) do
        if cur == target then return true end
        cur = cur:GetParent()
    end
    return false
end

local function IsCursorInPanel(pnl)
    if not IsValid(pnl) or not pnl:IsVisible() then return false end
    local sx, sy = pnl:LocalToScreen(0, 0)
    local sw, sh = pnl:GetSize()
    local mx, my = gui.MouseX(), gui.MouseY()
    return mx >= sx and mx <= sx + sw and my >= sy and my <= sy + sh
end

local function IsCursorInAnyInv()
    if IsCursorInPanel(InvPanelOther) then return true end
    if IsCursorInPanel(InvPanelPlayer) then return true end
    if IsCursorInPanel(InvPanelBackpack) then return true end
    if IsCursorInPanel(InvPanelCase) then return true end
    return false
end

local function GetSlotUnderCursor(ignorePnl)
    local mx, my = gui.MouseX(), gui.MouseY()
    if mx == 0 and my == 0 then return nil end

    for pnl in pairs(vgui.CreatePanels or empty) do
        if IsValid(pnl) and pnl:IsVisible() and pnl ~= ignorePnl then
            if pnl.slotX ~= nil or pnl.slotName ~= nil or pnl.slotIndex ~= nil then
                local sx, sy = pnl:LocalToScreen(0, 0)
                local sw, sh = pnl:GetSize()
                if mx >= sx and mx <= sx + sw and my >= sy and my <= sy + sh then
                    return pnl
                end
            end
        end
    end

    if IsValid(InvPanelOther) then
        local canvas = InvPanelOther.canvasPanel or InvPanelOther
        for _, child in pairs(canvas:GetChildren()) do
            if IsValid(child) and child ~= ignorePnl then
                for _, sub in pairs(child:GetChildren()) do
                    if IsValid(sub) and sub ~= ignorePnl and sub.slotX ~= nil then
                        local sx, sy = sub:LocalToScreen(0, 0)
                        local sw, sh = sub:GetSize()
                        if mx >= sx and mx <= sx + sw and my >= sy and my <= sy + sh then
                            return sub
                        end
                    end
                end
            end
        end
    end

    return nil
end

local ArmorSlotButtons = {
	{
		title = "Drop",
		actionFunc = function(slot, itemID, itemData, itemInfo)
			RunConsoleCommand("hg_inv_drop_armor",tostring(itemInfo.name))
		end
	},
	{
		title = "Toggle",
		visTestFunc = function(slot, itemID, itemData, itemInfo) return itemInfo.tgl end,
		actionFunc = function(slot, itemID, itemData, itemInfo)
			net.Start("Armor_Toggle")
			net.WriteString(itemID)
			net.SendToServer()
		end
	},
	{
		title = "Repair",
		visTestFunc = function(slot, itemID, itemData, itemInfo) return itemData.dur < itemInfo.dur * .9 end,
		actionFunc = function(slot, itemID, itemData, itemInfo)
			net.Start("JMod_Inventory")
			net.WriteString(itemID)
			net.SendToServer()
		end
	},
	{
		title = "Recharge",
		visTestFunc = function(slot, itemID, itemData, itemInfo)
			if itemInfo.chrg then
				for resource, maxAmt in pairs(itemInfo.chrg) do
					if itemData.chrg[resource] < maxAmt then return true end
				end
			end

			return false
		end,
		actionFunc = function(slot, itemID, itemData, itemInfo)
			net.Start("JMod_Inventory")
			net.WriteInt(4, 8) -- recharge
			net.WriteString(itemID)
			net.SendToServer()
		end
	}
}

local ArmorResourceNiceNames = {
	chemicals = "Chemicals",
	power = "Electricity"
}

net.Receive("update armor ui",function()
    if IsValid(InvArmorFrame) then InvArmorFrame:UpdateInv() end
end)

local empty = {}

local color_white = Color(255,255,255)

local angZero = Angle(0, 0, 0)
local vecZero = Vector(0, 0, 0)

local function DrawArmorModel(specs, x, y, size, col)
    if not specs or not specs.mdl then return false end
    local mdlPath = specs.mdl
    local DrawModel = CSMById(mdlPath, "inv_armor_slot_" .. mdlPath)
    if not IsValid(DrawModel) then return false end

    DrawModel:SetNoDraw(true)
    DrawModel:SetSkin(specs.skin or 0)
    DrawModel:SetMaterial(specs.mat or "")
    if specs.bdg then
        for id, val in pairs(specs.bdg) do
            DrawModel:SetBodygroup(id, val)
        end
    end

    local mins, maxs = DrawModel:GetRenderBounds()
    local center = (mins + maxs) * 0.5
    local radius = math.max(mins:Distance(maxs) * 0.5, 6)

    local dist = radius / math.sin(math.rad(18))
    local yaw = 0 -- Static front view, no 360 rotation
    local rad = math.rad(yaw)
    local camPos = center + Vector(dist, 0, dist * 0.15)
    local camAng = (center - camPos):Angle()

    render.ClearDepth()

    cam.Start3D(camPos, camAng, 36, x, y, size, size)
        render.SuppressEngineLighting(true)
        render.ResetModelLighting(0.4, 0.4, 0.4)
        render.SetModelLighting(BOX_TOP, 0.9, 0.9, 0.9)
        render.SetModelLighting(BOX_FRONT, 0.7, 0.7, 0.7)
        render.SetModelLighting(BOX_RIGHT, 0.5, 0.5, 0.5)

        render.SetColorModulation(col.r / 255, col.g / 255, col.b / 255)

        DrawModel:SetAngles(angZero)
        DrawModel:SetPos(vecZero)
        DrawModel:SetupBones()
        DrawModel:DrawModel()

        render.SetColorModulation(1, 1, 1)
        render.SuppressEngineLighting(false)
    cam.End3D()

    return true
end

local function CreateSlot(name,parent)
    if not vgui.Panels or not vgui.Panels["v_inv_slot"] then
        pcall(include, "hgame/tier_1/inv/tier_0_object/cl/ui_slot_cl.lua")
    end

    local slot = parent.slots[name] or (vgui.Panels and vgui.Panels["v_inv_slot"] and oop.CreatePanel("v_inv_slot",parent)) or oop.CreatePanel("v_panel",parent)
    slot:setSize(64 * ScreenSize,64 * ScreenSize)
    slot.slotX = 0
    slot.slotY = 0
    slot.inv = {}
    slot.slotName = name
    
    parent.slots[name] = slot

    function slot:Draw(w,h)
        SetDrawColor(15,15,15,125)
        DrawRect(0,0,w,h)

        if self:IsHovered() then
            if self:IsDown() then
                surface.SetDrawColor(0,0,0,5)
            else
                surface.SetDrawColor(255,255,255,5)
            end

            surface.DrawRect(0,0,w,h)
        end

        local ItemID,ItemData,specs = Armor_GetItemInSlot(LocalPlayer().Armors,name)

        if slot.SetItem then
            slot:SetItem(specs and specs.ent or false)
        end

        if ItemData then
            local col = ItemData.col or color_white
            local size = math.floor(h - 14)
            local drawnModel = false

            if specs and specs.mdl then
                local x, y = self:LocalToScreen(0, 0)
                if x and y then
                    drawnModel = DrawArmorModel(specs, math.floor(x + (w - size) / 2), math.floor(y + 6), size, col)
                end
            end

            -- dur может отсутствовать и в записи, и в описании -- делить на nil нельзя,
            -- иначе весь Draw слота (а с ним и все ячейки) падает каждый кадр.
            local k = math.Clamp((ItemData.dur or 0) / (specs and specs.dur or 0),0,1)

            surface.SetDrawColor(200,200,200)
            surface.DrawRect(0,h - 2,w * k,2)

            local i = 0

            for name,v in pairs(ItemData.chrg or empty) do
                if name == "power" then
                    surface.SetDrawColor(200,200,0)
                else
                    surface.SetDrawColor(200,0,255)
                end

                surface.DrawRect(0,h - 4 - (2 * i) - (1 * (i + 1 )),w * k,2)
            end
        end

        draw.Frame(0,0,w,h,cframe2,cframe1)
    end

    function slot:InvDrop()
        RunConsoleCommand("hg_inv_drop_armor",tostring(name))
    end

    function slot:InvMove(inv1,inv2,x1,y1,x2,y2,count)
        RunConsoleCommand("hg_inv_move_armor",tostring(name),inv2,x2,y2)
    end
    
    function slot:InvMove2(inv1,inv2,x1,y1,x2,y2,count)
        RunConsoleCommand("hg_inv_equip_armor",inv1,x1,y1)
    end
    function slot:GetItem()
        local ItemID, ItemData, specs = Armor_GetItemInSlot(LocalPlayer().Armors, name)
        if ItemData then
            return {spawnname = (specs and specs.ent) or ItemData.name, count = 1, isArmor = true, armorSlot = name}
        end
    end

    function slot:GetItemTable(itemSpawnName)
        local ItemID, ItemData, specs = Armor_GetItemInSlot(LocalPlayer().Armors, name)
        if specs then return specs end
        if itemSpawnName then
            return scripted_ents.Get(itemSpawnName) or weapons.Get(itemSpawnName) or empty
        end
        return empty
    end

    function slot:OnMouse(key, value)
        if not value or key ~= MOUSE_LEFT then return end
        local ItemID, ItemData, specs = Armor_GetItemInSlot(LocalPlayer().Armors, name)
        if not ItemData then return end
        InvSlotGrab = self
    end

    function slot:OnMouseOut(key, outside)
        local grab = InvSlotGrab
        InvSlotGrab = nil

        if not grab or grab ~= self then return end

        local targetSlot = GetSlotUnderCursor(self)
        local targetInv
        local sx, sy = 0, 0
        if IsValid(targetSlot) and targetSlot.inv and targetSlot.inv.id then
            targetInv = targetSlot.inv
            sx = targetSlot.slotX or 0
            sy = targetSlot.slotY or 0
        elseif IsValid(InvPanelOther) and IsCursorInPanel(InvPanelOther) and InvPanelOther.inv and InvPanelOther.inv.id then
            targetInv = InvPanelOther.inv
        end

        if targetInv and targetInv.id then
            RunConsoleCommand("hg_inv_move_armor", tostring(name), tostring(targetInv.id), tostring(sx), tostring(sy))
            return
        end

        -- If not dropped into a valid slot or container, drop into the world!
        self:InvDrop()
    end

    return slot
end

local weaponToSlot = {}
local slotToWeapon = {}

local function AssignWeaponsToSlots()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then
        table.Empty(slotToWeapon)
        table.Empty(weaponToSlot)
        return slotToWeapon
    end

    local raw = ply:GetWeapons()
    local currentWeps = {}
    for _, wep in ipairs(raw) do
        if IsValid(wep) then
            local class = wep:GetClass()
            if class ~= "weapon_hands" and class ~= "weapon_fists" and class ~= "weapon_zombie" then
                currentWeps[wep] = true
            end
        end
    end

    -- Remove weapons no longer held by player
    for wep, slotIdx in pairs(weaponToSlot) do
        if not currentWeps[wep] or not IsValid(wep) then
            slotToWeapon[slotIdx] = nil
            weaponToSlot[wep] = nil
        end
    end

    -- Collect and sort newly acquired weapons
    local unassigned = {}
    for wep in pairs(currentWeps) do
        if not weaponToSlot[wep] then
            unassigned[#unassigned + 1] = wep
        end
    end

    table.sort(unassigned, function(a, b)
        local slotA = a.Slot or 1
        local slotB = b.Slot or 1
        if slotA ~= slotB then return slotA < slotB end

        local posA = a.SlotPos or 1
        local posB = b.SlotPos or 1
        if posA ~= posB then return posA < posB end

        return a:GetClass() < b:GetClass()
    end)

    for _, wep in ipairs(unassigned) do
        local pref = (wep.Slot and (wep.Slot + 1)) or 1
        local assignedSlot = nil
        if not slotToWeapon[pref] and pref >= 1 and pref <= 9 then
            assignedSlot = pref
        else
            for i = 1, 9 do
                if not slotToWeapon[i] then
                    assignedSlot = i
                    break
                end
            end
        end
        if assignedSlot then
            slotToWeapon[assignedSlot] = wep
            weaponToSlot[wep] = assignedSlot
        end
    end

    return slotToWeapon
end

local function GetCarriedWeapons()
    return AssignWeaponsToSlots()
end

local defaultInvColorTypes = {
    weapon = Color(80,0,255),
    weaponSecondary = Color(80,80,200),
    other = Color(0,100,0),
    granade = Color(190,75,0),
    medical = Color(200,0,0),
}

local function CreateWeaponSlots(parent)
    parent.weaponSlots = {}
    local count = 9

    for i = 1, count do
        local slot = oop.CreatePanel("v_panel", parent)
        slot.slotIndex = i
        slot.hovered = 0
        parent.weaponSlots[i] = slot

        slot:ad(function(self, pw, ph)
            local scale = ScreenSize or 1
            local slotSize = math.floor(52 * scale)
            local totalW = count * slotSize
            local startX = math.floor((pw - totalW) / 2)
            local startY = math.floor(ph - slotSize)

            self:setSize(slotSize, slotSize)
            self:setPos(startX + (i - 1) * slotSize, startY)
        end)

        function slot:Step()
            local slots = AssignWeaponsToSlots()
            self.weapon = slots[i]
        end

        function slot:Draw(w, h)
            -- Solid background (no opacity)
            SetDrawColor(20, 20, 20, 255)
            DrawRect(0, 0, w, h)

            local wep = self.weapon
            local isActive = IsValid(wep) and LocalPlayer():GetActiveWeapon() == wep
            local wepTable = IsValid(wep) and (weapons.Get(wep:GetClass()) or scripted_ents.Get(wep:GetClass()) or wep)

            if IsValid(wep) and wepTable then
                local class = wep:GetClass()
                local itemType = wepTable.itemType
                local isPropBox = class == "weapon_hidebomb" or class == "weapon_jahidka" or itemType == "none" or (wepTable.WorldModel and string.find(wepTable.WorldModel, "cardboard_box"))
                local isKnife = class == "weapon_kabar" or class == "melee_kabar" or wepTable.IsKnife or itemType == "knife" or itemType == "melee"

                local isPoison = wepClass == "weapon_poison" or wepClass == "poison" or itemType == "poison"
                local col
                if isPoison then
                    col = Color(220, 30, 30)
                elseif isPropBox then
                    col = nil
                elseif isKnife then
                    col = Color(0, 160, 40)
                else
                    local colTypes = InvColorTypes or defaultInvColorTypes
                    col = colTypes[itemType or "weapon"] or colTypes.weapon
                end

                if col then
                    SetDrawColor(col.r, col.g, col.b, 25)
                    draw.GradientDown(0, 0, w, h)
                end
            end

            if self:IsHovered() then
                surface.SetDrawColor(255, 255, 255, 12)
                DrawRect(0, 0, w, h)
            end

            self.hovered = LerpFT(0.25, self.hovered or 0, self:IsHovered() and 1 or 0)

            if IsValid(wep) then
                local x, y = self:LocalToScreen(0, 0)
                if x and y then
                    local drawn = false
                    if wepTable and wepTable.WorldModel and wepTable.WorldModel ~= "" and isfunction(DrawWeaponSelectionEX) then
                        pcall(function()
                            DrawWeaponSelectionEX(wepTable, x + 2, y + 2, w - 4, h - 4, true, -(self.hovered or 0) * 1)
                            drawn = true
                        end)
                    end

                    if not drawn then
                        local iconMat = wepTable and wepTable.IconWeaponSelection
                        if iconMat and not iconMat:IsError() then
                            local s = math.max(math.min(w, h) - 10, 16)
                            surface.SetDrawColor(255, 255, 255, 255)
                            surface.SetMaterial(iconMat)
                            surface.DrawTexturedRect(w / 2 - s / 2, h / 2 - s / 2, s, s)
                            drawn = true
                        elseif wep.DrawWeaponSelection then
                            pcall(function()
                                wep:DrawWeaponSelection(x + 2, y + 2, w - 4, h - 4, 255)
                                drawn = true
                            end)
                        end
                    end

                    if not drawn and isfunction(EntityIcon) then
                        local mat = EntityIcon(wep:GetClass())
                        if mat and not mat:IsError() then
                            surface.SetMaterial(mat)
                            surface.SetDrawColor(255, 255, 255, 255)
                            local s = math.max(math.min(w, h) - 10, 16)
                            surface.DrawTexturedRect(w / 2 - s / 2, h / 2 - s / 2, s, s)
                            drawn = true
                        end
                    end

                    if not drawn then
                        local name = tostring(wepTable.PrintName or wep:GetClass() or "")
                        draw.SimpleText(name, "InvFont", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                end
            end

            -- Borders
            SetDrawColor(255, 255, 255, 12)
            DrawRect(0, 0, w, 1)
            DrawRect(0, 0, 1, h)

            SetDrawColor(0, 0, 0, 255)
            DrawRect(0, h - 1, w, 1)
            DrawRect(w - 1, 0, 1, h)
        end

        function slot:GetItem()
            local wep = self.weapon
            if IsValid(wep) then
                return {spawnname = wep:GetClass(), count = 1}
            end
        end

        function slot:GetItemTable(name)
            local wep = self.weapon
            if IsValid(wep) then
                return weapons.Get(wep:GetClass()) or scripted_ents.Get(wep:GetClass()) or wep
            end
            return empty
        end

        function slot:InvDrop()
            local wep = self.weapon
            if IsValid(wep) then
                RunConsoleCommand("drop", tostring(wep:EntIndex()), wep:GetClass())
            end
        end

        function slot:InvMove2(inv1, inv2, x1, y1)
            RunConsoleCommand("hg_inv_move_me", inv1, x1, y1)
        end

        function slot:OnMouse(key, value)
            local wep = self.weapon
            if not IsValid(wep) then return end

            if key == MOUSE_LEFT then
                if value then
                    InvSlotGrab = self
                end
            elseif key == MOUSE_RIGHT and value then
                local menu = DermaMenu()
                menu:SetParent(parent)
                menu:AddOption("Выбросить", function()
                    if IsValid(wep) then
                        RunConsoleCommand("drop", tostring(wep:EntIndex()), wep:GetClass())
                    end
                end)
                if IsValid(InvPanelOther) and InvPanelOther.inv and InvPanelOther.inv.id then
                    menu:AddOption("Переложить", function()
                        if IsValid(wep) then
                            RunConsoleCommand("hg_inv_put_weapon", tostring(wep:EntIndex()), tostring(InvPanelOther.inv.id), "0", "0")
                        end
                    end)
                end
                menu:SetPos(gui.MouseX(), gui.MouseY())
                menu:SetZPos(1000)
            end
        end

        function slot:OnMouseOut(key, outside)
            local grab = InvSlotGrab
            InvSlotGrab = nil

            if not grab or grab ~= self then return end

            local targetSlot = GetSlotUnderCursor(self)
            local wep = self.weapon
            if not IsValid(wep) then return end

            local targetInv
            local sx, sy = 0, 0
            if IsValid(targetSlot) and targetSlot.inv and targetSlot.inv.id then
                targetInv = targetSlot.inv
                sx = targetSlot.slotX or 0
                sy = targetSlot.slotY or 0
            elseif IsValid(InvPanelOther) and IsCursorInPanel(InvPanelOther) and InvPanelOther.inv and InvPanelOther.inv.id then
                targetInv = InvPanelOther.inv
            end

            if targetInv and targetInv.id then
                RunConsoleCommand("hg_inv_put_weapon", tostring(wep:EntIndex()), tostring(targetInv.id), tostring(sx), tostring(sy))
                return
            end

            -- If released outside valid slots/containers, drop weapon into the world!
            self:InvDrop()
        end
    end
end

function Panel.Open(frame)
    if not LocalPlayer():Alive() then
        function frame:Draw(w,h)
            draw.SimpleText("Ты мёртв.","H.45",w / 2,h / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end

        return
    end

    frame.slots = {}
    frame.carriedWeapons = GetCarriedWeapons()

    function frame:Step()
        self.carriedWeapons = GetCarriedWeapons()
    end

    InvArmorFrame = frame

    local playerModel = oop.CreatePanel("v_playermodel",frame):ad(function(self,w,h) self:setSize(w * 0.2,h * 0.7):setPos(math.min(64 * ScreenSize * 3,64 * ScreenSize * 2 + 64),scrh / 2.25 - self:H() / 2) end)
    playerModel:SetPlayer(LocalPlayer(),LocalPlayer():GetEntity())

    -- Ensure armor render is synced to playerModel
    if isfunction(Armor_GetBuildSpecsFromArmors) and isfunction(Armor_SetupRender) and istable(LocalPlayer().Armors) then
        local specs = Armor_GetBuildSpecsFromArmors(LocalPlayer().Armors)
        LocalPlayer().ArmorRender = Armor_SetupRender(specs, true, LocalPlayer():GetModel())
        if IsValid(playerModel.mdl) then
            playerModel.mdl.ArmorRender = LocalPlayer().ArmorRender
        end
    end

    function playerModel:PreDraw(w,h)
        SetDrawColor(0,0,0,100)
        DrawRect(0,0,w,h)
        draw.GradientDown(0,0,w,h)
    end

    function frame:InputLSHIFT(butt)
        if not IsValid(InvPanelOther) then return end

        butt.waitQueue = true

        InvPlaySndDecay(butt:GetItemTable(),"InvMoveSnd","InvMoveSnd",InvMoveSnd,-20,-0.3)
        InvMoveQueueAdd({butt,"hg_inv_move_armor",butt.slotName,InvPanelOther.inv.id})
    end
    
    function frame:UpdateInv()
        self.carriedWeapons = GetCarriedWeapons()
        if isfunction(Armor_GetBuildSpecsFromArmors) and isfunction(Armor_SetupRender) and istable(LocalPlayer().Armors) then
            local specs = Armor_GetBuildSpecsFromArmors(LocalPlayer().Armors)
            LocalPlayer().ArmorRender = Armor_SetupRender(specs, true, LocalPlayer():GetModel())
            if IsValid(playerModel) and IsValid(playerModel.mdl) then
                playerModel.mdl.ArmorRender = LocalPlayer().ArmorRender
            end
        end
        for i,child in pairs(self:GetChildren()) do
            if child.UpdateInv then child:UpdateInv() end
        end
    end

    playerModel:ad(function()
        local x,y = playerModel.x + playerModel:W(),playerModel.y

        local size = 64 * ScreenSize

        CreateSlot("head",frame):setPos(x,y)
        CreateSlot("eyes",frame):setPos(x + size,y + size)
        CreateSlot("mouthnose",frame):setPos(x + size,y)

        CreateSlot("ears",frame):setPos(x,y + size)
        
        CreateSlot("rightshoulder",frame):setPos(x,y + size * 2 + 32)
        CreateSlot("rightforearm",frame):setPos(x,y + size * 3 + 32)

        CreateSlot("rightthigh",frame):setPos(x,y + size * 6 + 32)
        CreateSlot("rightcalf",frame):setPos(x,y + size * 7 + 32)

        CreateSlot("chest",frame):setPos(x,y + size * 5)
        CreateSlot("pelvis",frame):setPos(x + size,y + size * 5)

        x = playerModel.x - size

        CreateSlot("leftshoulder",frame):setPos(x,y + size * 2 + 32)
        CreateSlot("leftforearm",frame):setPos(x,y + size * 3 + 32)

        CreateSlot("leftthigh",frame):setPos(x,y + size * 6 + 32)
        CreateSlot("leftcalf",frame):setPos(x,y + size * 7 + 32)

        CreateSlot("acc_head",frame):setPos(x,y)
        CreateSlot("acc_eyes",frame):setPos(x - size,y)
        CreateSlot("acc_neck",frame):setPos(x,y + size)
        CreateSlot("acc_ears",frame):setPos(x - size,y + size)

        CreateSlot("acc_lshoulder",frame):setPos(x - size,y + size * 2 + 32)
        CreateSlot("acc_rshoulder",frame):setPos(x - size,y + size * 3 + 32)

        CreateSlot("acc_backpack",frame):setPos(x - size,y + size * 5)
        CreateSlot("acc_chestrig",frame):setPos(x,y + size * 5)
        CreateSlot("armband",frame):setPos(x - size,y + size * 6 + 32)
        
        CreateSlot("waist",frame):setPos(x - size,y + size * 7 + 32)
    end)

    CreateWeaponSlots(frame)

    event.Call("Scoreborad Inventoru UI Create",frame)
end

function Panel.Hovered(value,isClose)
    INVOPEN = value

    --InvCloseK = (isClose and 1) or (value and 1 or 0)
end

//if Initialize then OpenTab() end

function ScoreboardInvOpen()
    if not InitNET or not LocalPlayer():Alive() then return end

    ScoreboardPage = 2

    if ScoreboardStatus ~= true then
        OpenTab()
    end
end

function ScoreboardInvClose()
    if ScoreboardStatus ~= nil then CloseTab() end
end

event.Add("Player Death","Inventory UI",function(ply)
    if ply ~= LocalPlayer() then return end

    timer.Simple(0.1,function()--BLAAAAAAAAAAAAAAAAAAAAAAAAD
        if IsValid(ScoreboardFrame) then ScoreboardFrame:UpdateButtons() end
    end)
end)

event.Add("Player Spawn","Inventory UI",function(ply)
    if not InitNET or ply ~= LocalPlayer() then return end

    timer.Simple(0,function()
        if IsValid(ScoreboardFrame) then ScoreboardFrame:UpdateButtons() end
    end)
end)

function Panel.CanOpen() return LocalPlayer():Alive() end
