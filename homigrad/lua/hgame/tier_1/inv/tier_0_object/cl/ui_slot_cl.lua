--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/inv/tier_0_object/cl/ui_slot_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\inv\\tier_0_object\\cl\\ui_slot_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local PANEL = oop.Reg("v_inv_slot","v_panel")
if not PANEL then return end

local SetDrawColor = surface.SetDrawColor
local DrawRect = surface.DrawRect

local mat_load = Material("homigrad/vgui/loading.png")

local function CreateInvFont(mul)
    mul = mul or (ScrW() / 1920)
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
CreateInvFont()

event.Add("Screen Size","Fonts Inv",function(mul)
    CreateInvFont(mul)
end)

local black = Color(0,0,0)

local isWeaponTable = {isWeapon = true}

local empty = {}

PANEL:Event_Add("Init","Main",function(self)
    self.hovered = 0
end)

function PANEL:SetItem(spawnname,count)
    if spawnname == false then
        self.setItem = false
    else
        self.setItem = {spawnname = spawnname,count = count}
    end
end

function PANEL:GetItem()
    if self.setItem ~= nil then return self.setItem end

    local slots = self.inv
    slots = slots and slots.slots[self.slotX]
    slots = slots and slots[self.slotY]

    for item in pairs(slots or empty) do return item end
end

function PANEL:GetCount()
    if self.setItem ~= nil then return self.setItem and self.setItem.count or 0 end

    local count = 0
    local slots = self.inv
    slots = slots and slots.slots[self.slotX]
    slots = slots and slots[self.slotY]

    for first in pairs(slots or empty) do
        item = first
        count = count + 1
    end

    return count
end

function PANEL:GetItemTable(name,y)
    if not name then
        name = self:GetItem()
        name = name and name.spawnname

        if not name then return end
    end

    if y then
        local x,y = name,y
        name = nil

        for item in pairs(self.inv.slots[x][y]) do
            name = item.spawnname
        end

        if not name then return end
    end

    local tbl = scripted_ents.Get(name)
    if tbl then return tbl end

    tbl = weapons.Get(name)

    if tbl then
        tbl.isWeapon = true

        return tbl
    end

    if IsValid(name.ent) and name.ent:IsWeapon() then return isWeaponTable end

    return empty
end

function PANEL:Draw(w,h)
    SetDrawColor(25,25,25,255)
    DrawRect(0,0,w,h)

    local isDown = self:IsDown() or InvSlotGrab == self
    local isHovered = self:IsHovered()

    if isDown then
        SetDrawColor(0,0,0,125)
        DrawRect(0,0,w,h)
    elseif isHovered then
        SetDrawColor(255,255,255,5)
        DrawRect(0,0,w,h)
    end

    self.hovered = LerpFT(0.5,self.hovered,(isHovered or self.isDown or InvSlotGrab == self) and 1 or 0)

    self:DrawItem(w,h)

    --

    local k = math.max((self.shake or 0) - CurTime(),0) / 0.5

    SetDrawColor(255,0,0,k * 255)
    DrawRect(0,0,w,h)

    SetDrawColor(255,255,255,5)
    DrawRect(0,0,w,1)
    DrawRect(0,0,1,h)

    SetDrawColor(0,0,0,255)
    DrawRect(0,h - 1,w,1)
    DrawRect(w - 1,0,1,h)
end

function PANEL:DrawItem(w,h,r,g,b)
    local item = self:GetItem()
    local count = (isfunction(self.GetCount) and self:GetCount()) or (item and item.count) or 1
    
    local cornerH = math.max(h * 0.15,6) + 1

    if item then
        local tbl = self:GetItemTable(item.spawnname)
        if not tbl.invNoDrawClip and item.clip then count = item.clip end
        
        local itemType = tbl.itemType
        local isPoison = item and (item.spawnname == "weapon_poison" or item.spawnname == "poison")
        local isPropBox = tbl.isPropBox or tbl.WorldModel == "models/props_junk/cardboard_box004a.mdl" or itemType == "none" or (item and (item.spawnname == "weapon_hidebomb" or item.spawnname == "weapon_jahidka"))
        local isKnife = tbl.IsKnife or itemType == "knife" or itemType == "melee" or (item and (item.spawnname == "weapon_kabar" or item.spawnname == "melee_kabar"))

        local col
        if isPoison then
            col = Color(220, 30, 30)
        elseif isPropBox then
            col = nil
        elseif isKnife then
            col = Color(0, 160, 40)
        else
            col = tbl.itemColor or InvColorTypes[tbl.itemType]
        end

        if col then
            SetDrawColor(col.r,col.g,col.b,10)
            draw.GradientDown(0,0,w,h)
        end

        local success = true

        if tbl.DrawInv then
            local ok, res = pcall(tbl.DrawInv, tbl, item, w, h, self)
            success = ok and res
        else

            local icon = isfunction(EntityIcon) and EntityIcon(item.spawnname)
            if icon and not icon:IsError() then
                surface.SetMaterial(icon)
                local size = h - 14 + self.hovered * 5
            
                surface.SetDrawColor(r or 255,g or 255,b or 255)
                surface.DrawTexturedRect(w / 2 - size / 2 + 1,h / 2 - size / 2 + 1,size,size)

                if count > 1 then
                    draw.SimpleText("x" .. count,"InvFont",4,2)
                end
                
                success = false
            elseif tbl.WorldModel then
                local x,y = self:LocalToScreen()
                DrawWeaponSelectionEX(tbl,x,y,w,h - 13,true,-self.hovered * 1)
            else
                local name = tostring(tbl.PrintName or item.spawnname or "")
                draw.SimpleText(name,"InvFont",w / 2,h / 2,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                success = false
            end
        end

        if success then
            local stripCol = col or Color(40, 40, 40)
            if IsColor(success) then stripCol = success end
            
            SetDrawColor(stripCol.r,stripCol.g,stripCol.b,180)
            DrawRect(0,h - cornerH,w,cornerH)

            SetDrawColor(255,255,255,5)
            DrawRect(0,h - cornerH,w,1)

            draw.SimpleText(L(tostring(tbl.PrintName or item.spawnname)),"InvFont",w / 2,h - cornerH / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

            if count > 1 then
                draw.SimpleText("x" .. count,"InvFont",4,2)
            end
        end

        local parent = self:GetParent()

        if self:IsHovered() and not (self.wait or self.waitQueue) and (input.IsButtonDown(KEY_H)) and parent.InputLSHIFT then parent:InputLSHIFT(self) end--RUST RUST RUST1!1
    end

    if self.wait or self.waitQueue then
        SetDrawColor(255,255,255,75)
        surface.SetMaterial(mat_load)
        surface.DrawTexturedRectRotated(w / 2,h / 2,h / 2,h / 2,(CurTime() * 1000) % 360)
    end
end

function PANEL:OnMouse(key,value)
    if not value or (self.donotpressright and key == MOUSE_RIGHT) then return end--shit

    local item = self:GetItemTable()
    if not item then return end

    timer.Simple(math.Rand(0,0.01),function()
        InvPlaySnd(item,"InvGrabSnd","InvMoveSnd",InvMoveSnd,50,-0.2)
    end)

    InvSlotGrab = self
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

function PANEL:OnMouseOut(key,outside)
    local grab = InvSlotGrab
    InvSlotGrab = nil

    if not grab then return end

    -- Detect target slot using exact screen coordinates
    local hovered = GetSlotUnderCursor(grab)
    if not IsValid(hovered) then
        hovered = vgui.GetHoveredPanel()
    end

    local isTargetSlot = IsValid(hovered) and hovered ~= grab and (hovered.slotX ~= nil or hovered.slotName ~= nil or hovered.slotIndex ~= nil)

    if isTargetSlot then
        grab.wait = true

        local itemGrab = grab:GetItemTable()
        timer.Simple(math.Rand(0,0.01),function()
            InvPlaySnd(itemGrab,"InvMoveSnd","InvMoveSnd",InvMoveSnd)
        end)

        local itemto = hovered:GetItemTable()
        timer.Simple(math.Rand(0.025,0.04),function()
            InvPlaySnd(itemto,"InvMoveSnd","InvMoveSnd",InvMoveSnd)
        end)

        local count = (input.IsButtonDown(KEY_LCONTROL) or key == MOUSE_MIDDLE) and 1
        if key == MOUSE_MIDDLE and input.IsButtonDown(KEY_LSHIFT) then count = 2 end

        -- Target is player's weapon slot: loot item into player's hands/weapons
        if hovered.slotIndex ~= nil then
            RunConsoleCommand("hg_inv_move_me", grab.inv and grab.inv.id, grab.slotX, grab.slotY)
            return
        end

        -- Target is player's armor slot: equip armor directly
        if hovered.slotName ~= nil then
            if isfunction(hovered.InvMove2) then
                hovered:InvMove2(grab.inv and grab.inv.id, nil, grab.slotX, grab.slotY, count)
            end
            return
        end

        -- Moving between container slots
        if isfunction(grab.InvMove) then
            grab:InvMove(grab.inv and grab.inv.id,hovered.inv and hovered.inv.id,grab.slotX,grab.slotY,hovered.slotX,hovered.slotY,count)
        else
            RunConsoleCommand("hg_inv_move",grab.inv and grab.inv.id,hovered.inv and hovered.inv.id,grab.slotX,grab.slotY,hovered.slotX,hovered.slotY,count)
        end
        if isfunction(hovered.InvMove2) then
            hovered:InvMove2(grab.inv and grab.inv.id,hovered.inv and hovered.inv.id,grab.slotX,grab.slotY,hovered.slotX,hovered.slotY,count)
        end
        if grab.InvInsert then grab:InvInsert(hovered) end
        return
    end

    -- If dropped on InvPanelOther background (e.g. between slots), move to first available slot in other inventory!
    if IsValid(InvPanelOther) and IsCursorInPanel(InvPanelOther) and InvPanelOther.inv and InvPanelOther.inv.id then
        grab.wait = true
        local count = (input.IsButtonDown(KEY_LCONTROL) or key == MOUSE_MIDDLE) and 1
        RunConsoleCommand("hg_inv_move", grab.inv and grab.inv.id, InvPanelOther.inv.id, grab.slotX, grab.slotY, 0, 0, count)
        return
    end

    -- Dragged outside any slots / into empty space -> Drop item into world!
    grab.wait = true
    timer.Simple(0.8, function()
        if IsValid(grab) then
            grab.wait = nil
            grab.waitQueue = nil
        end
    end)
    if isfunction(grab.InvDrop) then
        grab:InvDrop(grab.inv and grab.inv.id, grab.slotX, grab.slotY, not input.IsButtonDown(KEY_LCONTROL) and 1)
    else
        RunConsoleCommand("hg_inv_drop", grab.inv and grab.inv.id, grab.slotX, grab.slotY, not input.IsButtonDown(KEY_LCONTROL) and 1)
    end
end

function PANEL:UpdateInv()
    self.wait = nil
    self.waitQueue = nil
end

--concommand

function PANEL:InvDrop(id,x,y,count) RunConsoleCommand("hg_inv_drop",id,x,y,count) end
function PANEL:InvMove(inv1,inv2,x1,y1,x2,y2,count) RunConsoleCommand("hg_inv_move",inv1,inv2,x1,y1,x2,y2,count) end
function PANEL:InvMove2() end

hook.Add("DrawOverlay", "Homigrad_DrawGrabbedInvItem", function()
    local grab = InvSlotGrab
    if not IsValid(grab) then return end

    local item = grab:GetItem()
    if not item then return end

    local tbl = grab.GetItemTable and grab:GetItemTable(item.spawnname)
    if not tbl then return end

    local mx, my = gui.MouseX(), gui.MouseY()
    if mx == 0 and my == 0 then return end

    local s = math.floor(52 * (ScreenSize or 1))
    local x = mx - s / 2
    local y = my - s / 2

    local count = (isfunction(grab.GetCount) and grab:GetCount()) or (item and item.count) or 1
    if not tbl.invNoDrawClip and item.clip then count = item.clip end


    local itemType = tbl.itemType
    local isPoison = item.spawnname == "weapon_poison" or item.spawnname == "poison"
    local isPropBox = tbl.isPropBox or tbl.WorldModel == "models/props_junk/cardboard_box004a.mdl" or itemType == "none" or item.spawnname == "weapon_hidebomb" or item.spawnname == "weapon_jahidka"
    local isKnife = tbl.IsKnife or itemType == "knife" or itemType == "melee" or item.spawnname == "weapon_kabar" or item.spawnname == "melee_kabar"

    local col
    if isPoison then
        col = Color(220, 30, 30)
    elseif isPropBox then
        col = nil
    elseif isKnife then
        col = Color(0, 160, 40)
    else
        col = tbl.itemColor or InvColorTypes[tbl.itemType]
    end

    -- Draw Slot Background
    surface.SetDrawColor(25, 25, 25, 235)
    surface.DrawRect(x, y, s, s)

    if col then
        surface.SetDrawColor(col.r, col.g, col.b, 25)
        surface.DrawRect(x, y, s, s)
    end

    -- Draw Model / Icon
    local icon = isfunction(EntityIcon) and EntityIcon(item.spawnname)
    if icon and not icon:IsError() then
        surface.SetMaterial(icon)
        local iconSize = s - 14
        surface.SetDrawColor(255, 255, 255, 240)
        surface.DrawTexturedRect(x + (s - iconSize) / 2, y + (s - iconSize) / 2 - 4, iconSize, iconSize)
    elseif tbl.WorldModel then
        DrawWeaponSelectionEX(tbl, x, y - 4, s, s - 12, true, 0)
    else
        local name = tostring(tbl.PrintName or item.spawnname or "")
        draw.SimpleText(name, "InvFont", x + s / 2, y + s / 2 - 4, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Draw Count
    if count > 1 then
        draw.SimpleText("x" .. count, "InvFont", x + 3, y + 2, color_white)
    end

    -- Bottom name strip
    local cornerH = math.max(s * 0.22, 12)
    local stripCol = col or Color(40, 40, 40)
    surface.SetDrawColor(stripCol.r, stripCol.g, stripCol.b, 200)
    surface.DrawRect(x, y + s - cornerH, s, cornerH)

    surface.SetDrawColor(255, 255, 255, 40)
    surface.DrawRect(x, y + s - cornerH, s, 1)

    local displayName = tostring(tbl.PrintName or item.spawnname or "")
    if L then displayName = L(displayName) end
    surface.SetFont("InvFont")
    local tw, th = surface.GetTextSize(displayName)
    if tw > s - 4 then
        while #displayName > 3 and surface.GetTextSize(displayName .. "...") > s - 4 do
            displayName = string.sub(displayName, 1, -2)
        end
        displayName = displayName .. "..."
    end
    draw.SimpleText(displayName, "InvFont", x + s / 2, y + s - cornerH / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    -- Slot Borders
    surface.SetDrawColor(255, 255, 255, 30)
    surface.DrawRect(x, y, s, 1)
    surface.DrawRect(x, y, 1, s)

    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawRect(x, y + s - 1, s, 1)
    surface.DrawRect(x + s - 1, y, 1, s)
end)
