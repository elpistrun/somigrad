--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/other/weapon_handcuffs/tier_0_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\other\\weapon_handcuffs\\tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Reg("weapon_handcuffs","hg_wep_base",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName = L("weapon_handcuffs")
SWEP.Author = "0oa"
SWEP.Instructions = L("weapon_handcuffs_desc")
SWEP.Category = L("weapon_category_item")

SWEP.Slot = 5
SWEP.SlotPos = 3
SWEP.Spawnable = true

SWEP.WorldModel = "models/freeman/flexcuffs.mdl"
SWEP.WorldBodygroups = {
    [1] = 1
}

SWEP.wmAngle = Angle(0,0,-90)
SWEP.wmVector = Vector(3,2,-1)

SWEP.dwsItemAng = Angle(0,90,0)
SWEP.dwsItemPos = Vector(0,0,0)
SWEP.dwsItemFOV = -14

SWEP.dwmForward = 3.5
SWEP.dwmRight = 1
SWEP.dwmUp = -1

SWEP.itemType = "other"
SWEP.InvCount = 4
SWEP.InvCountIgnoreLimit = true

SWEP.invNoDrawClip = true

SWEP.InvMoveSnd = InvMoveSndWeapon

SWEP.EnableTransformModel = true

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

if SERVER then
    util.AddNetworkString("cuff")
else
    net.Receive("cuff",function(len)
        local self = net.ReadEntity()
        self.CuffPly = net.ReadEntity()
        self.CuffTime = net.ReadFloat()
    end)
end

local function GetPly(tr)
    local ent = tr.Entity
    if not IsValid(ent) then return end

    local rag, ply
    if ent:IsPlayer() then
        ply = ent
        rag = ply.FakeRagdoll or ply.hgFakeRagdoll or (ply.GetDummy and ply:GetDummy())
    elseif ent:GetClass() == "prop_ragdoll" then
        rag = ent
        ply = (RagdollOwner and RagdollOwner(ent)) or (hg and hg.RagdollOwner and hg.RagdollOwner(ent))
    end

    if IsValid(rag) and (rag:GetNWBool("Cuffs", false) or rag.isHandcuffed) then return end
    if IsValid(ply) and (ply:GetNWBool("Cuffs", false) or ply.isHandcuffed) then return end
    if IsValid(ply) and ply:HasGodMode() then return end

    if IsValid(rag) then return rag end
    if IsValid(ply) and (ply:InFake() or ply:GetNWBool("fake", false)) then return ply end

    return nil
end

local cuffTime = 2

if SERVER then
    event.Add("Player Spawn","Cuffs",function(ply)
        ply:SetNWBool("Cuffs",false)
        ply.isHandcuffed = nil
    end)

    hook.Add("PlayerSwitchWeapon","!Cuffs",function(ply,old,new)
        if ply:GetNWBool("Cuffs",false) or ply.isHandcuffed then return true end
    end)

    function SWEP:PrimaryAttack()
        if IsValid(self.CuffPly) then return end

        local owner = self:GetOwner()

        local tr = owner:EyeTrace(75)
        if not tr then return end

        local ply = GetPly(tr)

        if ply then
            owner:EmitSound("weapons/pinpull.wav")

            self.CuffPly = ply
            self.CuffTime = CurTime()

            self:SendCuff()
        end
    end
    
    SWEP.SecondaryAttack = SWEP.PrimaryAttack
    
    function SWEP:SendCuff()
        net.Start("cuff")
        net.WriteEntity(self)
        net.WriteEntity(self.CuffPly or Entity(-1))
        net.WriteFloat(self.CuffTime)
        net.Send(self:GetOwner())
    end

    function SWEP:Cuff(target)
        if not IsValid(target) then return end
        local owner = self:GetOwner()
        if not IsValid(owner) then return end

        local rag, ply
        if target:IsPlayer() then
            ply = target
            rag = ply.FakeRagdoll or ply.hgFakeRagdoll or (ply.GetDummy and ply:GetDummy())
            if not IsValid(rag) then
                if ply.EnterFake then
                    rag = ply:EnterFake(true)
                elseif Faking then
                    Faking(ply, true)
                    rag = ply.FakeRagdoll or ply.hgFakeRagdoll or (ply.GetDummy and ply:GetDummy())
                end
            end
        else
            rag = target
            ply = (RagdollOwner and RagdollOwner(rag)) or (hg and hg.RagdollOwner and hg.RagdollOwner(rag))
        end

        if not IsValid(rag) then return end

        if IsValid(ply) and ply:IsPlayer() then
            ply:SetNWBool("Cuffs", true)
            ply.isHandcuffed = true
        end

        rag:SetNWBool("Cuffs", true)
        rag.isHandcuffed = true

        local handL = rag:LookupBone("ValveBiped.Bip01_L_Hand") or rag:LookupBone("bip_hand_L")
        local handR = rag:LookupBone("ValveBiped.Bip01_R_Hand") or rag:LookupBone("bip_hand_R")
        local physL, physR
        if handL and handR then
            physL = rag:TranslateBoneToPhysBone(handL)
            physR = rag:TranslateBoneToPhysBone(handR)
        end

        local cuffPos = rag:GetPos() + Vector(0, 0, 10)
        local physObjL = (physL and rag:GetPhysicsObjectNum(physL)) or nil
        local physObjR = (physR and rag:GetPhysicsObjectNum(physR)) or nil

        if IsValid(physObjL) and IsValid(physObjR) then
            cuffPos = (physObjL:GetPos() + physObjR:GetPos()) * 0.5
            physObjR:SetPos(physObjL:GetPos())
        end

        local weld = constraint.Weld(rag, rag, physL or 0, physR or 0, 0, false, false)
        rag.cuffWeld = weld

        local cuffEnt = ents.Create("ent_handcuffs")
        if IsValid(cuffEnt) then
            cuffEnt:SetPos(cuffPos)
            cuffEnt:SetAngles(rag:GetAngles())
            cuffEnt:Spawn()
            cuffEnt:Activate()

            cuffEnt.cuffedRag = rag
            cuffEnt.cuffedPly = ply
            cuffEnt.cuffWeld = weld
            rag.cuffEnt = cuffEnt

            if IsValid(physObjL) then
                constraint.Weld(cuffEnt, rag, 0, physL, 0, false, false)
            else
                cuffEnt:SetParent(rag)
            end
        end

        rag:EmitSound("weapons/pinpull.wav", 65, 90)
        sound.Emit(nil, "weapons/pinpull.wav", 75, 1, 100, rag:GetPos())

        self.CuffPly = nil
        self:SendCuff()

        self:Remove()
    end

    function SWEP:OnThink()
        local cuffPly = self.CuffPly
        if not IsValid(cuffPly) then return end

        local owner = self:GetOwner()
        if not IsValid(owner) then return end

        local tr = owner:EyeTrace(75)
        if not tr then return end
        
        local ply = GetPly(tr)

        if ply ~= cuffPly then
            self.CuffPly = nil
            self:SendCuff()
            return
        end

        if self.CuffTime + cuffTime <= CurTime() then
            self:Cuff(ply)
        end
    end
end

if SERVER then return end

function SWEP:DrawHUD()
    local tr = self:GetOwner():EyeTrace(75)
    if not tr then return end
    
    local ply = GetPly(tr)

    local hit = tr.Hit and 1 or 0

    local pos = tr.HitPos:ToScreen()
    local x,y = pos.x,pos.y
    
    local frac = tr.Fraction * 100

    if ply then
        surface.SetDrawColor(Color(255, 255, 255, 255))
        draw.NoTexture()
        Circle(x, y, 5 / frac, 32)

        draw.DrawText(L("handcuffs_text_target"),"TargetID",x,y - 40,color_white,TEXT_ALIGN_CENTER)

        if IsValid(self.CuffPly) then
            local anim_pos = 1 - math.Clamp((self.CuffTime + cuffTime - CurTime()) / cuffTime,0,1)

            surface.DrawRect(x - 50,y + 50,anim_pos * 100,25)
        end
    else
        surface.SetDrawColor(Color(255, 255, 255, 255 * hit))
        draw.NoTexture()
        Circle(x, y, 5 / frac, 32)
    end
end
