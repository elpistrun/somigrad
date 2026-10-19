local ENT = oop.Get("fake_ragdoll")
if not ENT then return end

function ENT:OnInit()
	self:DrawShadow(false)

    self:Event_Call("Init")
end

function ENT:GetPlayer() return self:GetController() end

function ENT:IsSpeaking()
    local ply = self:GetPlayer()
    if IsValid(ply) then return ply:IsSpeaking() end
end

function ENT:VoiceVolume()
    local ply = self:GetPlayer()
    if IsValid(ply) then return ply:VoiceVolume() end
end

local vec = Vector(1,1,1)

function ENT:GetPlayerColor() return self:GetPVSVar("PlayerColor",vec) end

function ENT:Draw(flags)
    DeterminateLODFirst(self)
    
    if not self.renderLOD2_5 then return end
    if not self.renderLOD2 then self:DrawModel() return end

    local owner = self:GetController()
    
    if owner == LocalPlayer() then
        -- Hide the head explicitly: the ragdoll is rendered through the local-player path.
        self.r_headPop = true
        RenderLocalPlayer(self,nil,owner,flags)
    else
        RenderPlayer(self,nil,owner,flags)
    end

    -- Homigrad weapons are drawn through RenderPlayer_Weapon. ARC9 and other
    -- SWEPs without DrawFromPlayer still need a hand-follow fallback.
    self:DrawWeaponOnHand(owner,flags)
end

-- Weapon offset from hand bone
local wepHandOffset = {
    pos = Vector(2, 0, 0),
    ang = Angle(0, 0, -90)
}

function ENT:DrawWeaponOnHand(owner,flags)
    if not IsValid(owner) or not owner:IsPlayer() then return end

    local wep = owner:GetActiveWeapon()
    if not IsValid(wep) or wep:GetClass() == "weapon_hands" then return end
    if wep.DrawFromPlayer then
        wep:DrawFromPlayer(self, nil, owner)
        return
    end

    if wep.ARC9 and wep.DrawWorldModel then
        wep:DrawWorldModel(flags)
        return
    end

    local data = wep.wmFastData or wep.wmData
    local wm = wep.wm
    if not IsValid(wm) then
        if wep.GetWorldModel then wm = wep:GetWorldModel(data) end
        if not IsValid(wm) then return end
    end

    local vec = (data and data.vec and data.vec:Clone()) or wepHandOffset.pos
    local ang = (data and data.ang and data.ang:Clone()) or wepHandOffset.ang
    local pos,wepAng = wep.Transform_GetFromRagdoll and wep:Transform_GetFromRagdoll(self,vec,ang)
    if not pos then return end

    wm:SetPos(pos)
    wm:SetAngles(wepAng)
    wm:DrawModel()
end

local function setup(ent)
    if ragdollManager.entities[ent] then return end
    ragdollManager.entities[ent] = true

    ent:CallOnRemove("RagdollEntities",function()
        ragdollManager.entities[ent] = nil
        ent:OnRemove()
    end)

    for k,v in pairs(oop.listClass["fake_ragdoll"][1]) do ent[k] = v end

    ent:Initialize()
    ent.RenderOverride = function(self,flags) ent:Draw(flags) end
end

event.Add("EntityCreate","RagdollFake",function(ent)
    if ent:GetClass() != "prop_ragdoll" then return end

    ent:ProxyPVSVar("IsFakeRagdoll",function(_,_,value)
        if not value then return end

        setup(ent)
    end)

    if ent:GetNWBool("IsFakeRagdoll") then setup(ent) end
end)
