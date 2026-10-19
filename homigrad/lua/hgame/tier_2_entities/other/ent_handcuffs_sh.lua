--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/other/ent_handcuffs_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\other\\ent_handcuffs_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("ent_handcuffs",{"base_entity"})
if not ENT then return end

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "handcuffs"

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/freeman/flexcuffs.mdl")
        self:SetBodygroup(1,1)

        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:DrawShadow(true)
        self:SetUseType(SIMPLE_USE)
    
        //self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

        self:SetHealth(25)
    end
    
    function ENT:Kill()
        sound.Emit(nil,"weapons/clipempty_pistol.wav",75,1,100,self:GetPos(),"0")
        self:Remove()
    end

    function ENT:OnTakeDamage(dmginfo)
        self:TakePhysicsDamage(dmginfo)
        local dmg = dmginfo:GetDamage()
        self:SetHealth(self:Health() - dmg)
        if self:Health() <= 0 then
            self:Kill()
        end
    end

    function ENT:OnRemove()
        if IsValid(self.cuffWeld) then
            self.cuffWeld:Remove()
        end
        if IsValid(self.cuffedRag) then
            self.cuffedRag:SetNWBool("Cuffs", false)
            self.cuffedRag.isHandcuffed = nil
            self.cuffedRag.cuffEnt = nil
            if IsValid(self.cuffedRag.cuffWeld) then
                self.cuffedRag.cuffWeld:Remove()
            end
        end
        if IsValid(self.cuffedPly) then
            self.cuffedPly:SetNWBool("Cuffs", false)
            self.cuffedPly.isHandcuffed = nil
        end
    end

    function ENT:Think()
        if not IsValid(self.cuffedRag) and not IsValid(self.cuffedPly) then
            self:Remove()
            return
        end
        self:NextThink(CurTime() + 1)
        return true
    end

    ENT.UsePreStop = true

    function ENT:Use(ply)
        if ply.fake or (self.delayUse or 0) > CurTime() then return end

        self.delayUse = CurTime() + math.Rand(0.1,0.2)

        ply:ViewPunch(Angle(1,0,0))
        
        sound.Emit(self:EntIndex(),"physics/metal/weapon_impact_hard" .. math.random(1,3) .. ".wav",75,1,100,nil,"0")

        self:SetHealth(self:Health() - 1)
        if self:Health() <= 0 then self:Kill() end
    end
else
    local white = Color(255,255,255)

    function ENT:HUDTarget(ply,k,w,h)
        white.a = 255 * k
    
        local v = self:Health()

        local text

        if v > 17 then
            text = L("handcuffs_hard")
        elseif v > 9 then
            text = L("handcuffs_medium")
        else
            text = L("handcuffs_easy")
        end

        draw.SimpleText(L("handcuffs_text",text),"H.18",w / 2,h / 2 - 50 * (1 - k),white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end    
end
