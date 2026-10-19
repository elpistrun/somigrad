local max = math.max

local function anim(ply,link)
    link = link or ply
    if not link:Alive() then return end

    local time = CurTime()
    local animVal = 0

    local dropStartTime = link:GetNWFloat("DropAnim", 0)
    local dropDuration = 0.35
    local dropRemaining = dropStartTime + dropDuration - time
    if dropRemaining > 0 and dropRemaining <= dropDuration then
        local progress = 1 - (dropRemaining / dropDuration)
        animVal = math.sin(progress * math.pi)
    end

    local pickupStartTime = link:GetNWFloat("PickupAnim", 0)
    local pickupDuration = 0.35
    local pickupRemaining = pickupStartTime + pickupDuration - time
    if pickupRemaining > 0 and pickupRemaining <= pickupDuration then
        local progress = 1 - (pickupRemaining / pickupDuration)
        animVal = math.max(animVal, math.sin(progress * math.pi))
    end

    if animVal <= 0.005 then return end

    if ply.AddBoneAng then
        ply:AddBoneAng("rclavicle", Angle(-5 * animVal, 0, 15 * animVal))
        ply:AddBoneAng("rupperarm", Angle(-15 * animVal, 0, -25 * animVal))
        ply:AddBoneAng("rforearm", Angle(20 * animVal, 0, 0))
    end
end

if SERVER then
    if event and event.Add then
        event.Add("PlayerDroppedWeapon","Anim Drop",function(owner,wep)
            if not IsValid(owner) or not owner:IsPlayer() then return end

            owner:SetNWFloat("DropAnim",CurTime())
        end)

        event.Add("Player Inv Drop Item","Anim Drop",function(ply,inv)
            if not IsValid(ply) or not inv or inv.parent ~= ply then return end

            ply:SetNWFloat("DropAnim",CurTime())
        end)

        event.Add("PlayerPickupItem","Anim Pickup",function(owner,wep,type)
            if type ~= "use" or not IsValid(owner) or not owner:IsPlayer() then return end

            owner:SetNWFloat("PickupAnim",CurTime())
        end)
    end
else
    if event and event.Add then
        event.Add("Bones","Anim Drop",function(ply,link)
            anim(ply,link)
        end)
    end
end

concommand.Add("TESTt",function(ply)
    if IsValid(ply) then
        ply:SetNWFloat("DropAnim",CurTime())
    end
end)
