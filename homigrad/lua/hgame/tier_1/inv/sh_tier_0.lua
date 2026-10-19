--[[
    Homigrad Server & Shared Inventory System
    Implements InvCreate, storage containers, lootbox handling and sync
]]

Inv = Inv or {}

Inv.objects = Inv.objects or {}
Inv.objectsID = Inv.objectsID or {}

if SERVER then
    util.AddNetworkString("inv open")
    util.AddNetworkString("inv close")
    util.AddNetworkString("inv error")
    util.AddNetworkString("use")

    local invCounter = 0

    function InvCreate(w, h)
        w = w or 4
        h = h or 1
        invCounter = invCounter + 1

        local inv = {}
        inv.id = invCounter
        inv.w = w
        inv.h = h
        inv.class = "storage"
        inv.slots = {}
        inv.viewers = {}

        for x = 1, w do
            inv.slots[x] = {}
            for y = 1, h do
                inv.slots[x][y] = {}
            end
        end

        function inv:SetParent(ent, class)
            self.parent = ent
            self.class = class or "storage"
            Inv.objects[ent] = self
            Inv.objectsID[self.id] = self
            return self
        end

        function inv:AddEnt(ent, targetX, targetY)
            if not IsValid(ent) then return false end

            local slotX, slotY
            if targetX and targetY and self.slots[targetX] and self.slots[targetX][targetY] and table.Count(self.slots[targetX][targetY]) == 0 then
                slotX, slotY = targetX, targetY
            else
                for y = 1, self.h do
                    for x = 1, self.w do
                        if table.Count(self.slots[x][y]) == 0 then
                            slotX, slotY = x, y
                            break
                        end
                    end
                    if slotX then break end
                end
            end

            if not slotX then return false end

            local item = {
                spawnname = ent:GetClass(),
                count = 1,
                ent = ent,
                clip = ent:IsWeapon() and ent:Clip1() or nil,
                x = slotX,
                y = slotY
            }

            self.slots[slotX][slotY][item] = true

            ent:SetNoDraw(true)
            ent:SetNotSolid(true)
            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then phys:EnableMotion(false) end
            if IsValid(self.parent) then
                ent:SetPos(self.parent:GetPos())
                ent:SetParent(self.parent)
            end

            return true
        end

        function inv:GetAllItems()
            local list = {}
            for x = 1, self.w do
                for y = 1, self.h do
                    for item in pairs(self.slots[x][y]) do
                        list[#list + 1] = item
                    end
                end
            end
            return list
        end

        function inv:Sync(ply)
            local targetViewers
            if ply then
                if not IsValid(ply) then return end
            else
                targetViewers = {}
                for viewer in pairs(self.viewers or {}) do
                    if IsValid(viewer) then
                        targetViewers[#targetViewers + 1] = viewer
                    else
                        self.viewers[viewer] = nil
                    end
                end
                if #targetViewers == 0 then return end
            end

            local syncTable = {
                id = self.id,
                parent = self.parent,
                class = self.class or "storage",
                type = self.type,
                name = self.name or (IsValid(self.parent) and self.parent.Name) or "storage",
                slots = {}
            }

            for x = 1, self.w do
                syncTable.slots[x] = {}
                for y = 1, self.h do
                    syncTable.slots[x][y] = {}
                    for item in pairs(self.slots[x][y]) do
                        local netItem = {
                            spawnname = item.spawnname,
                            count = item.count or 1,
                            clip = item.clip
                        }
                        syncTable.slots[x][y][netItem] = true
                    end
                end
            end

            net.Start("inv open")
            net.WriteTable(syncTable)
            if ply then
                net.Send(ply)
            elseif targetViewers and #targetViewers > 0 then
                net.Send(targetViewers)
            end
        end


        function inv:Open(ply)
            if not IsValid(ply) or not ply:Alive() then return end

            if self.OnOpen then
                self:OnOpen(ply)
            end

            self.viewers[ply] = true
            self:Sync(ply)
        end

        function inv:Close(ply)
            if not IsValid(ply) then return end
            self.viewers[ply] = nil

            if self.OnClose then
                self:OnClose(ply)
            end

            net.Start("inv close")
            net.WriteString(tostring(self.id))
            net.Send(ply)
        end

        return inv
    end

    function ReturnPlayerLoot(inv)
        if not inv or not IsValid(inv.victim) or not inv.victim:IsPlayer() then return end
        local ply = inv.victim
        ply.Info = ply.Info or {}
        ply.Info.Weapons = ply.Info.Weapons or {}

        for _, item in ipairs(inv:GetAllItems()) do
            local class = item.spawnname
            local ent = item.ent
            if class and class ~= "weapon_hands" and class ~= "weapon_fists" and class ~= "weapon_zombie" then
                if (string.StartWith(class, "ent_jack_gmod_ezarmor_") or item.armorName) and isfunction(Armor_Equip) then
                    Armor_Equip(ply, item.armorName or class, item.col)
                    if IsValid(ent) then ent:Remove() end
                else
                    local wep = ply:Give(class)
                    if not IsValid(wep) then
                        ply.Info.Weapons[class] = {
                            Clip1 = item.clip or (IsValid(ent) and ent:IsWeapon() and ent:Clip1()) or 0,
                            Clip2 = 0
                        }
                    else
                        if item.clip and wep.SetClip1 then wep:SetClip1(item.clip) end
                    end
                    if IsValid(ent) then ent:Remove() end
                end
            end
        end

        for viewer in pairs(inv.viewers or {}) do
            if IsValid(viewer) then inv:Close(viewer) end
        end

        if Inv and Inv.objects then Inv.objects[ply] = nil end
        if Inv and Inv.objectsID and inv.id then Inv.objectsID[inv.id] = nil end
        ply.inv = nil
    end

    function DropAllInvItems(inv, pos)
        if not inv then return end
        pos = pos or (IsValid(inv.parent) and inv.parent:GetPos()) or Vector(0, 0, 0)
        for _, item in ipairs(inv:GetAllItems()) do
            local class = item.spawnname
            local ent = item.ent
            if IsValid(ent) then
                ent:SetNoDraw(false)
                ent:SetNotSolid(false)
                ent:SetParent(nil)
                ent:SetPos(pos + VectorRand() * 15 + Vector(0, 0, 10))
                local phys = ent:GetPhysicsObject()
                if IsValid(phys) then
                    phys:EnableMotion(true)
                    phys:Wake()
                end
            elseif class then
                local spawned = ents.Create(class)
                if IsValid(spawned) then
                    spawned:SetPos(pos + VectorRand() * 15 + Vector(0, 0, 10))
                    spawned:Spawn()
                end
            end
        end
        inv.slots = {}
        for x = 1, inv.w do
            inv.slots[x] = {}
            for y = 1, inv.h do
                inv.slots[x][y] = {}
            end
        end
        for viewer in pairs(inv.viewers or {}) do
            if IsValid(viewer) then inv:Close(viewer) end
        end
        if Inv and Inv.objectsID and inv.id then Inv.objectsID[inv.id] = nil end

    end

    function InvThinkStorage(inv)
        if not inv then return end
        if not IsValid(inv.parent) then
            if inv.isRagdollLoot or inv.isPlayerLoot then
                if IsValid(inv.victim) and inv.victim:IsPlayer() and inv.victim:Alive() and not inv.victim.fake then
                    ReturnPlayerLoot(inv)
                else
                    DropAllInvItems(inv, inv.lastParentPos)
                end
            else
                DropAllInvItems(inv, inv.lastParentPos)
            end
            return
        end
        local pos = inv.parent:GetPos()
        inv.lastParentPos = pos

        for ply in pairs(inv.viewers) do
            if not IsValid(ply) or not ply:Alive() or ply:GetPos():DistToSqr(pos) > (160 * 160) then
                inv:Close(ply)
            end
        end

        if inv.isRagdollLoot and IsValid(inv.victim) and inv.victim:IsPlayer() and inv.victim:Alive() and not inv.victim.fake then
            ReturnPlayerLoot(inv)
        elseif inv.isPlayerLoot and IsValid(inv.victim) then
            if not (inv.victim:GetNWBool("Cuffs", false) or inv.victim.isHandcuffed) then
                ReturnPlayerLoot(inv)
            end
        end
    end

    hook.Add("Think", "Inv_Storage_Think", function()
        for id, inv in pairs(Inv.objectsID) do
            if inv.Think then
                inv:Think()
            end
        end
    end)

    concommand.Add("hg_inv_close", function(ply, cmd, args)
        local id = tonumber(args[1]) or args[1]
        local inv = Inv.objectsID[id]
        if inv then inv:Close(ply) end
    end)

    concommand.Add("hg_inv_move_me", function(ply, cmd, args)
        local invID = tonumber(args[1]) or args[1]
        local x = tonumber(args[2])
        local y = tonumber(args[3])
        local inv = Inv.objectsID[invID]
        if not inv or not inv.slots[x] or not inv.slots[x][y] then
            if inv then inv:Sync() end
            return
        end

        local targetItem
        for item in pairs(inv.slots[x][y]) do
            targetItem = item
            break
        end
        if not targetItem then
            inv:Sync()
            return
        end

        local class = targetItem.spawnname
        local ent = targetItem.ent

        -- If it's a weapon and player already has it: do NOT take it / do NOT convert to ammo!
        if ((IsValid(ent) and ent:IsWeapon()) or (weapons and weapons.Get(class))) and ply:HasWeapon(class) then
            inv:Sync()
            return
        end

        inv.slots[x][y][targetItem] = nil

        if IsValid(ent) then
            ent:SetNoDraw(false)
            ent:SetNotSolid(false)
            ent:SetParent(nil)
            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then
                phys:EnableMotion(true)
                phys:Wake()
            end
            ent:SetPos(ply:EyePos() + ply:GetAimVector() * 20)

            if ent:IsWeapon() then
                local clip1 = ent:Clip1()
                local clip2 = ent:Clip2()
                local chamber = (ent.GetNWInt and ent:GetNWInt("Chamber", 0)) or 0
                ply.AllowWeaponPickup = true
                local given = ply:Give(class)
                ply.AllowWeaponPickup = nil
                if IsValid(given) then
                    if given.SetClip1 then given:SetClip1(clip1) end
                    if given.SetClip2 then given:SetClip2(clip2) end
                    if given.SetNWInt then given:SetNWInt("Chamber", chamber) end
                end
                if IsValid(ent) and ent ~= given then ent:Remove() end
            elseif (string.StartWith(class, "ent_jack_gmod_ezarmor_") or ent.itemType == "armor" or targetItem.armorName) and isfunction(Armor_Equip) then
                local armorName = targetItem.armorName or ent.ArmorName or class
                Armor_Equip(ply, armorName, targetItem.col or ent.ArmorCol)
                ent:Remove()
            else
                ent:SetPos(ply:GetPos() + Vector(0, 0, 10))
            end
        else
            if (string.StartWith(class, "ent_jack_gmod_ezarmor_") or targetItem.armorName) and isfunction(Armor_Equip) then
                Armor_Equip(ply, targetItem.armorName or class, targetItem.col)
            else
                local wep = ply:Give(class)
                if not IsValid(wep) then
                    local spawned = ents.Create(class)
                    if IsValid(spawned) then
                        spawned:SetPos(ply:GetPos() + Vector(0, 0, 10))
                        spawned:Spawn()
                    end
                elseif targetItem.clip and wep.SetClip1 then
                    wep:SetClip1(targetItem.clip)
                end
            end
        end

        inv:Sync()

        if inv.PopItem then inv:PopItem() end
        if #inv:GetAllItems() == 0 and inv.OnClose then
            inv:OnClose()
        end
    end)

    concommand.Add("hg_inv_drop", function(ply, cmd, args)
        local invID = tonumber(args[1]) or args[1]
        local x = tonumber(args[2])
        local y = tonumber(args[3])
        local inv = Inv.objectsID[invID]
        if not inv or not inv.slots[x] or not inv.slots[x][y] then return end

        local targetItem
        for item in pairs(inv.slots[x][y]) do
            targetItem = item
            break
        end
        if not targetItem then return end

        inv.slots[x][y][targetItem] = nil

        local class = targetItem.spawnname
        local ent = targetItem.ent

        if IsValid(ent) then
            ent:SetNoDraw(false)
            ent:SetNotSolid(false)
            ent:SetParent(nil)
            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then
                phys:EnableMotion(true)
                phys:Wake()
                phys:SetVelocity(ply:GetAimVector() * 80 + Vector(0, 0, 15))
                phys:AddAngleVelocity(VectorRand() * 40)
            end
            ent:SetPos(ply:EyePos() + ply:GetAimVector() * 30)
        else
            local spawned = ents.Create(class)
            if IsValid(spawned) then
                spawned:SetPos(ply:EyePos() + ply:GetAimVector() * 30)
                spawned:Spawn()
                local phys = spawned:GetPhysicsObject()
                if IsValid(phys) then
                    phys:Wake()
                    phys:EnableMotion(true)
                    phys:SetVelocity(ply:GetAimVector() * 80 + Vector(0, 0, 15))
                    phys:AddAngleVelocity(VectorRand() * 40)
                end
            end
        end

        inv:Sync()

        if inv.PopItem then inv:PopItem() end
        if #inv:GetAllItems() == 0 and inv.OnClose then
            inv:OnClose()
        end
    end)

    concommand.Add("hg_inv_drop_armor", function(ply, cmd, args)
        if not IsValid(ply) or not ply:Alive() then return end
        local targetName = args[1]
        if not targetName or targetName == "" then return end

        local targetID, targetData
        if isfunction(Armor_GetItemInSlot) and istable(ply.Armors) then
            targetID, targetData = Armor_GetItemInSlot(ply.Armors, targetName)
        end

        if not targetID and istable(ply.Armors) then
            for id, data in pairs(ply.Armors) do
                if data.name == targetName then
                    targetID = id
                    targetData = data
                    break
                end
            end
        end

        if not targetID or not targetData then return end

        local spec = ArmorListClasses and ArmorListClasses[targetData.name]
        local entClass = (spec and spec.ent) or targetData.name

        ply.Armors[targetID] = nil
        if isfunction(Armor_Sync) then
            Armor_Sync(ply)
        else
            ply:SetNWTable("Armor", ply.Armors)
        end

        local dropPos = ply:EyePos() + ply:GetAimVector() * 25
        local ent = ents.Create(entClass)
        if IsValid(ent) then
            ent:SetPos(dropPos)
            ent:SetAngles(ply:EyeAngles())
            ent.ArmorName = targetData.name
            ent.ArmorCol = targetData.col
            ent.dur = targetData.dur
            ent:Spawn()

            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then
                phys:Wake()
                phys:EnableMotion(true)
                phys:SetVelocity(ply:GetAimVector() * 120 + Vector(0, 0, 25))
                phys:AddAngleVelocity(VectorRand() * 60)
            end
        end

        if sound.Emit then
            sound.Emit(ply:EntIndex(), "eft_gear_sounds/gear_armor_drop.wav", 65, 1, 100, ply:GetPos())
        else
            sound.Play("eft_gear_sounds/gear_armor_drop.wav", ply:GetPos(), 65, 100, 1)
        end
    end)

    concommand.Add("hg_inv_move_armor", function(ply, cmd, args)
        if not IsValid(ply) or not ply:Alive() then return end
        local targetName = args[1]
        local inv2ID = tonumber(args[2]) or args[2]
        local x2 = tonumber(args[3])
        local y2 = tonumber(args[4])

        local inv2 = Inv.objectsID[inv2ID]
        if not inv2 then return end

        local targetID, targetData
        if isfunction(Armor_GetItemInSlot) and istable(ply.Armors) then
            targetID, targetData = Armor_GetItemInSlot(ply.Armors, targetName)
        end
        if not targetID and istable(ply.Armors) then
            for id, data in pairs(ply.Armors) do
                if data.name == targetName then
                    targetID = id
                    targetData = data
                    break
                end
            end
        end

        if not targetID or not targetData then return end

        local spec = ArmorListClasses and ArmorListClasses[targetData.name]
        local entClass = (spec and spec.ent) or targetData.name

        ply.Armors[targetID] = nil
        if isfunction(Armor_Sync) then
            Armor_Sync(ply)
        else
            ply:SetNWTable("Armor", ply.Armors)
        end

        local itemEnt = ents.Create(entClass)
        if IsValid(itemEnt) then
            itemEnt:SetPos(ply:GetPos())
            itemEnt:Spawn()
            itemEnt.ArmorName = targetData.name
            itemEnt.ArmorCol = targetData.col
            itemEnt.dur = targetData.dur
            if not inv2:AddEnt(itemEnt, x2, y2) then
                itemEnt:SetPos(ply:EyePos() + ply:GetAimVector() * 20)
            end
        end

        inv2:Sync()
    end)

    concommand.Add("hg_inv_equip_armor", function(ply, cmd, args)
        if not IsValid(ply) or not ply:Alive() then return end
        local invID = tonumber(args[1]) or args[1]
        local x = tonumber(args[2])
        local y = tonumber(args[3])

        local inv = Inv.objectsID[invID]
        if not inv or not inv.slots[x] or not inv.slots[x][y] then return end

        local targetItem
        for item in pairs(inv.slots[x][y]) do
            targetItem = item
            break
        end
        if not targetItem then return end

        inv.slots[x][y][targetItem] = nil

        local armorName = targetItem.armorName or (IsValid(targetItem.ent) and targetItem.ent.ArmorName) or targetItem.spawnname
        if isfunction(Armor_Equip) then
            Armor_Equip(ply, armorName, targetItem.col or (IsValid(targetItem.ent) and targetItem.ent.ArmorCol))
        end

        if IsValid(targetItem.ent) then targetItem.ent:Remove() end

        inv:Sync()
    end)

    concommand.Add("hg_inv_move", function(ply, cmd, args)
        local inv1ID = tonumber(args[1]) or args[1]
        local inv2ID = tonumber(args[2]) or args[2]
        local x1 = tonumber(args[3])
        local y1 = tonumber(args[4])
        local x2 = tonumber(args[5])
        local y2 = tonumber(args[6])

        local inv1 = Inv.objectsID[inv1ID]
        local inv2 = Inv.objectsID[inv2ID]
        if not inv1 or not inv1.slots[x1] or not inv1.slots[x1][y1] then
            if inv1 then inv1:Sync() end
            if inv2 then inv2:Sync() end
            return
        end
        if not inv2 then
            if inv1 then inv1:Sync() end
            return
        end

        if inv1 == inv2 and x1 == x2 and y1 == y2 then return end

        -- If x2 or y2 are not provided or non-positive, auto-find first empty slot in target inventory
        if not x2 or not y2 or x2 <= 0 or y2 <= 0 or not (inv2.slots[x2] and inv2.slots[x2][y2]) then
            x2, y2 = nil, nil
            for y = 1, inv2.h do
                for x = 1, inv2.w do
                    if table.Count(inv2.slots[x][y]) == 0 then
                        x2, y2 = x, y
                        break
                    end
                end
                if x2 then break end
            end
        end

        if not x2 or not y2 or not inv2.slots[x2] or not inv2.slots[x2][y2] then
            inv1:Sync()
            inv2:Sync()
            return
        end

        local item1
        for it in pairs(inv1.slots[x1][y1]) do item1 = it break end
        if not item1 then
            inv1:Sync()
            inv2:Sync()
            return
        end

        local item2
        for it in pairs(inv2.slots[x2][y2]) do item2 = it break end

        inv1.slots[x1][y1][item1] = nil
        inv2.slots[x2][y2][item1] = true
        item1.x, item1.y = x2, y2

        if item2 then
            inv2.slots[x2][y2][item2] = nil
            inv1.slots[x1][y1][item2] = true
            item2.x, item2.y = x1, y1
        end

        inv1:Sync()
        if inv1 ~= inv2 then inv2:Sync() end
    end)

    concommand.Add("hg_inv_put_weapon", function(ply, cmd, args)
        if not IsValid(ply) or not ply:Alive() then return end
        local wepEntIndex = tonumber(args[1])
        local invID = tonumber(args[2]) or args[2]
        local x = tonumber(args[3])
        local y = tonumber(args[4])

        local inv = Inv.objectsID[invID]
        if not inv then return end

        local wep = Entity(wepEntIndex or 0)
        if not IsValid(wep) or not wep:IsWeapon() or wep:GetOwner() ~= ply then
            local class = args[1]
            if class and isstring(class) then
                wep = ply:GetWeapon(class)
            end
        end
        if not IsValid(wep) then return end
        local class = wep:GetClass()
        if class == "weapon_hands" or class == "weapon_fists" or class == "weapon_zombie" then return end

        local clip1 = wep:Clip1()
        local clip2 = wep:Clip2()
        local chamber = (wep.GetNWInt and wep:GetNWInt("Chamber", 0)) or 0

        ply:StripWeapon(class)
        if ply.Info and ply.Info.Weapons then
            ply.Info.Weapons[class] = nil
        end

        local itemEnt = ents.Create(class)
        if IsValid(itemEnt) then
            itemEnt:SetPos(IsValid(inv.parent) and inv.parent:GetPos() or ply:GetPos())
            itemEnt:Spawn()
            if itemEnt.SetClip1 then itemEnt:SetClip1(clip1) end
            if itemEnt.SetClip2 then itemEnt:SetClip2(clip2) end
            if itemEnt.SetNWInt then itemEnt:SetNWInt("Chamber", chamber) end
            itemEnt.Clip = clip1

            if not inv:AddEnt(itemEnt, (x and x > 0) and x or nil, (y and y > 0) and y or nil) then
                itemEnt:SetPos(ply:EyePos() + ply:GetAimVector() * 20)
            end
        end

        inv:Sync()

        if sound.Emit then
            sound.Emit(ply:EntIndex(), "homigrad/vgui/item_drop.wav", 65, 1, 100, ply:GetPos())
        else
            sound.Play("homigrad/vgui/item_drop.wav", ply:GetPos(), 65, 100, 1)
        end
    end)

    -- Fallback handler when player presses E on lootbox/storage props
    hook.Add("PlayerUse", "Homigrad_Lootbox_FallbackUse", function(ply, ent)
        if not IsValid(ent) or not IsValid(ply) or not ply:Alive() then return end
        local class = ent:GetClass()
        if string.StartWith(class, "ent_lootbox_") or class == "ent_storage" or class == "ent_destroy_storage" then
            if not ent.inv then
                local w = ent.w or 4
                local h = ent.h or 1
                local inv = InvCreate(w, h):SetParent(ent, "storage")
                ent.inv = inv
                inv.name = ent.Name or ent:GetClass()
                inv.Think = InvThinkStorage
                inv.OnOpen = function(_, p)
                    if not inv.CreateLoot then
                        inv.CreateLoot = true
                        local max = ent.GetRandomCount and ent:GetRandomCount() or math.random(2, 4)
                        for i = 1, max do
                            local r = ent.GetRandom and ent:GetRandom()
                            if r then
                                local itemEnt = ents.Create(r)
                                if IsValid(itemEnt) then
                                    itemEnt:SetPos(ent:GetPos())
                                    itemEnt:Spawn()
                                    if not inv:AddEnt(itemEnt) then itemEnt:Remove() end
                                end
                            end
                        end
                    end
                    sound.Emit(ent:EntIndex(), "homigrad/vgui/item_drop.wav", 65, 1, 100, ent:GetPos())
                end
                inv.OnClose = function()
                    sound.Emit(ent:EntIndex(), "homigrad/vgui/item_drop.wav", 65, 1, 80, ent:GetPos())
                    if #inv:GetAllItems() == 0 then ent:Remove() end
                end
            end

            ent.inv:Open(ply)
            return false
        end
    end)

    -- Looting fake players and ragdolls
    function LootRagdoll(ply, rag)
        if not IsValid(ply) or not ply:Alive() or ply.fake or ply:GetNWBool("Fake") then return end
        if not IsValid(rag) or rag:GetClass() ~= "prop_ragdoll" then return end
        if ply:GetShootPos():DistToSqr(rag:NearestPoint(ply:GetShootPos())) > (140 * 140) then return end

        local victim = (isfunction(RagdollOwner) and RagdollOwner(rag)) or rag.hgOwner or rag.RagdollOwner
        if not IsValid(victim) or not victim:IsPlayer() then
            victim = rag:GetNWEntity("RagdollOwner")
        end

        if IsValid(victim) and victim == ply then return end

        local inv = rag.inv
        if not inv then
            inv = InvCreate(6, 4):SetParent(rag, "storage")
            rag.inv = inv

            local victimNick = (IsValid(victim) and victim:Nick()) or rag:GetNWString("Nick", rag:GetNWString("PlayerName", "Тело"))
            inv.name = victimNick
            inv.Think = InvThinkStorage
            inv.isRagdollLoot = true
            inv.ragdoll = rag
            inv.victim = victim

            inv.OnOpen = function(_, p)
                if sound.Emit then
                    sound.Emit(rag:EntIndex(), "homigrad/vgui/item_drop.wav", 65, 1, 100, rag:GetPos())
                else
                    sound.Play("homigrad/vgui/item_drop.wav", rag:GetPos(), 65, 100, 1)
                end
            end
            inv.OnClose = function()
                if sound.Emit then
                    sound.Emit(rag:EntIndex(), "homigrad/vgui/item_drop.wav", 65, 1, 80, rag:GetPos())
                else
                    sound.Play("homigrad/vgui/item_drop.wav", rag:GetPos(), 65, 80, 1)
                end
            end

            if IsValid(victim) and victim:IsPlayer() then
                -- Strip active and carried weapons into inventory items directly (without dropping ents in world)
                local weps = victim:GetWeapons()
                for _, wep in ipairs(weps) do
                    if IsValid(wep) then
                        local class = wep:GetClass()
                        if class ~= "weapon_hands" and class ~= "weapon_fists" and class ~= "weapon_zombie" then
                            local clip1 = wep:Clip1()
                            local clip2 = wep:Clip2()

                            victim:StripWeapon(class)
                            if victim.Info and victim.Info.Weapons then
                                victim.Info.Weapons[class] = nil
                            end

                            local slotX, slotY
                            for y = 1, inv.h do
                                for x = 1, inv.w do
                                    if table.Count(inv.slots[x][y]) == 0 then
                                        slotX, slotY = x, y
                                        break
                                    end
                                end
                                if slotX then break end
                            end

                            if slotX and slotY then
                                local item = {
                                    spawnname = class,
                                    count = 1,
                                    clip = clip1,
                                    x = slotX,
                                    y = slotY
                                }
                                inv.slots[slotX][slotY][item] = true
                            end
                        end
                    end
                end

                -- Remove weapon model from ragdoll's hands if it was welded during fake shooting
                if IsValid(victim.wep) then
                    if IsValid(victim.WepCons) then victim.WepCons:Remove() victim.WepCons = nil end
                    if IsValid(victim.WepCons2) then victim.WepCons2:Remove() victim.WepCons2 = nil end
                    victim.wep:Remove()
                    victim.wep = nil
                    victim.curweapon = nil
                    if victim.Info then
                        victim.Info.ActiveWeapon = nil
                        victim.Info.ActiveWeapon2 = nil
                    end
                end

                -- Check stored weapons in victim.Info.Weapons
                if victim.Info and victim.Info.Weapons then
                    for class, winfo in pairs(table.Copy(victim.Info.Weapons)) do
                        if class ~= "weapon_hands" and class ~= "weapon_fists" and class ~= "weapon_zombie" then
                            victim.Info.Weapons[class] = nil
                            local slotX, slotY
                            for y = 1, inv.h do
                                for x = 1, inv.w do
                                    if table.Count(inv.slots[x][y]) == 0 then
                                        slotX, slotY = x, y
                                        break
                                    end
                                end
                                if slotX then break end
                            end
                            if slotX and slotY then
                                local item = {
                                    spawnname = class,
                                    count = 1,
                                    clip = winfo.Clip1,
                                    x = slotX,
                                    y = slotY
                                }
                                inv.slots[slotX][slotY][item] = true
                            end
                        end
                    end
                end

                -- Move armor pieces into inventory items directly
                if istable(victim.Armors) then
                    for id, armorData in pairs(table.Copy(victim.Armors)) do
                        local spec = ArmorListClasses and ArmorListClasses[armorData.name]
                        local entClass = (spec and spec.ent) or armorData.name

                        local slotX, slotY
                        for y = 1, inv.h do
                            for x = 1, inv.w do
                                if table.Count(inv.slots[x][y]) == 0 then
                                    slotX, slotY = x, y
                                    break
                                end
                            end
                            if slotX then break end
                        end
                        if slotX and slotY then
                            local item = {
                                spawnname = entClass,
                                count = 1,
                                armorName = armorData.name,
                                col = armorData.col,
                                dur = armorData.dur,
                                x = slotX,
                                y = slotY
                            }
                            inv.slots[slotX][slotY][item] = true
                        end
                        victim.Armors[id] = nil
                    end
                    if isfunction(Armor_Sync) then Armor_Sync(victim) end
                end
            end
        end

        inv:Open(ply)
    end

    function LootPlayer(ply, target)
        if not IsValid(ply) or not ply:Alive() or ply.fake or ply:GetNWBool("Fake") then return end
        if not IsValid(target) or not target:IsPlayer() or not target:Alive() then return end
        if target == ply then return end

        local rag = target:GetNWEntity("DeathRagdoll")
        if not IsValid(rag) then rag = target:GetNWEntity("FakeRagdoll") end
        if not IsValid(rag) then rag = target.FakeRagdoll or target.fakeragdoll end
        if IsValid(rag) then
            return LootRagdoll(ply, rag)
        end

        local inv = target.inv
        if not inv then
            inv = InvCreate(6, 4):SetParent(target, "storage")
            target.inv = inv
            inv.name = target:Nick()
            inv.Think = InvThinkStorage
            inv.isPlayerLoot = true
            inv.victim = target

            inv.OnOpen = function(_, p)
                if sound.Emit then
                    sound.Emit(target:EntIndex(), "homigrad/vgui/item_drop.wav", 65, 1, 100, target:GetPos())
                else
                    sound.Play("homigrad/vgui/item_drop.wav", target:GetPos(), 65, 100, 1)
                end
            end
            inv.OnClose = function()
                if sound.Emit then
                    sound.Emit(target:EntIndex(), "homigrad/vgui/item_drop.wav", 65, 1, 80, target:GetPos())
                else
                    sound.Play("homigrad/vgui/item_drop.wav", target:GetPos(), 65, 80, 1)
                end
            end

            -- Move carried weapons
            local weps = target:GetWeapons()
            for _, wep in ipairs(weps) do
                if IsValid(wep) then
                    local class = wep:GetClass()
                    if class ~= "weapon_hands" and class ~= "weapon_fists" and class ~= "weapon_zombie" then
                        local clip1 = wep:Clip1()
                        local clip2 = wep:Clip2()

                        target:StripWeapon(class)
                        if target.Info and target.Info.Weapons then
                            target.Info.Weapons[class] = nil
                        end

                        local slotX, slotY
                        for y = 1, inv.h do
                            for x = 1, inv.w do
                                if table.Count(inv.slots[x][y]) == 0 then
                                    slotX, slotY = x, y
                                    break
                                end
                            end
                            if slotX then break end
                        end

                        if slotX and slotY then
                            local item = {
                                spawnname = class,
                                count = 1,
                                clip = clip1,
                                x = slotX,
                                y = slotY
                            }
                            inv.slots[slotX][slotY][item] = true
                        end
                    end
                end
            end

            -- Move armors
            if istable(target.Armors) then
                for id, armorData in pairs(table.Copy(target.Armors)) do
                    local spec = ArmorListClasses and ArmorListClasses[armorData.name]
                    local entClass = (spec and spec.ent) or armorData.name

                    local slotX, slotY
                    for y = 1, inv.h do
                        for x = 1, inv.w do
                            if table.Count(inv.slots[x][y]) == 0 then
                                slotX, slotY = x, y
                                break
                            end
                        end
                        if slotX then break end
                    end
                    if slotX and slotY then
                        local item = {
                            spawnname = entClass,
                            count = 1,
                            armorName = armorData.name,
                            col = armorData.col,
                            dur = armorData.dur,
                            x = slotX,
                            y = slotY
                        }
                        inv.slots[slotX][slotY][item] = true
                    end
                    target.Armors[id] = nil
                end
                if isfunction(Armor_Sync) then Armor_Sync(target) end
            end
        end

        inv:Open(ply)
    end

    net.Receive("use", function(len, ply)
        if not IsValid(ply) or not ply:Alive() or ply.fake or ply:GetNWBool("Fake") then return end
        local ent = net.ReadEntity()
        if not IsValid(ent) then return end
        if string.StartWith(ent:GetClass(), "ent_lootbox_") or ent:GetClass() == "ent_storage" or ent:GetClass() == "ent_destroy_storage" then
            hook.Run("PlayerUse", ply, ent)
        elseif ent:GetClass() == "prop_ragdoll" then
            LootRagdoll(ply, ent)
        elseif ent:IsPlayer() and (ent:GetNWBool("Cuffs", false) or ent.isHandcuffed or ent.fake or ent:GetNWBool("fake", false)) then
            LootPlayer(ply, ent)
        end
    end)
end

if CLIENT then
    local white = Color(255, 255, 255)
    hook.Add("HUD Target", "Homigrad_RagdollLoot_HUD", function(ent, k, w, h)
        if not IsValid(ent) or ent:GetClass() ~= "prop_ragdoll" then return end
        local owner = (isfunction(RagdollOwner) and RagdollOwner(ent)) or ent.hgOwner or ent.RagdollOwner
        if not IsValid(owner) and not ent.deadbody and not ent:GetNWBool("hgDeathCorpse") then return end
        if owner == LocalPlayer() then return end

        local animK = k or 1
        white.a = 255 * animK
        local name = (IsValid(owner) and owner:Nick()) or ent:GetNWString("Nick", ent:GetNWString("PlayerName", "Тело"))
        draw.SimpleText(name, "HS.18", w / 2, h / 2 - 55 * (1 - animK), white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        return true
    end)
end
