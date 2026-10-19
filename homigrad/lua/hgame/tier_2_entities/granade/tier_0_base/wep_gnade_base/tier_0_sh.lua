local SWEP = oop.Reg("wep_gnade_base","hg_wep_base",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName = "База Гранаты"
SWEP.Author = "Homigrad"
SWEP.Purpose = ""
SWEP.Instructions = ""

SWEP.Slot = 4
SWEP.SlotPos = 0
SWEP.Spawnable = true

SWEP.Category = L("weapon_category_granades")

SWEP.WorldModel = "models/pwb/weapons/w_f1.mdl"

SWEP.itemType = "granade"
SWEP.Granade = ""
SWEP.TimeDetonate = 3.5

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

SWEP.HoldType = "normal"

if CLIENT then
    SWEP:Event_Add("Init","ArmThink",function(self)
        if not self.NeedArmThink then return end

        local path = tostring(self) .. "Think"
        
        timer.Create(path,0.1,0,function()
            if not IsValid(self) then timer.Remove(path) return end
            self:StepWorld()
        end)
    end)
end

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if self:GetNWInt("Hold") == 0 then
        self:SetNWInt("Hold", 1)
        self:SetNextPrimaryFire(CurTime() + 0.5)
        self:SetNextSecondaryFire(CurTime() + 0.5)
        self:EmitSound("weapons/pinpull.wav", 65, 100)
    end
    owner:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:SecondaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if self:GetNWInt("Hold") == 0 then
        self:SetNWInt("Hold", 2)
        self:SetNextPrimaryFire(CurTime() + 0.5)
        self:SetNextSecondaryFire(CurTime() + 0.5)
        self:EmitSound("weapons/pinpull.wav", 65, 100)
    end
    owner:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:StepWorld()
    if self:GetNWBool("Arm") then self:ArmThink() end
end

SWEP:Event_Add("Think","Main",function(self,owner)
    local hold = self:GetNWInt("Hold")

    if hold == 0 then return end

    if hold == 1 then
        self:SetStandType("melee")
        owner:SetAnimation(PLAYER_ATTACK1)
        
        if SERVER then
            if not owner:KeyDown(IN_ATTACK) then
                self:Throw(750)
                return
            end

            if owner:KeyDown(IN_ATTACK2) then
                if not self.ignoreAttack2 then
                    self.ignoreAttack1 = true
                    self:SetNWInt("Hold",2)
                end
            else
                self.ignoreAttack2 = nil
            end
        end
    end

    if hold == 2 then
        self:SetStandType("knife")
        owner:SetAnimation(PLAYER_ATTACK1)

        if SERVER then
            if not owner:KeyDown(IN_ATTACK2) then
                self:Throw(250)
                return
            end

            if owner:KeyDown(IN_ATTACK) then
                if not self.ignoreAttack1 then
                    self.ignoreAttack2 = true
                    self:SetNWInt("Hold",1)
                end
            else
                self.ignoreAttack1 = nil
            end
        end
    end

    if SERVER and self.NeedArmThink then self:StepWorld() end
end)

function SWEP:ArmThink() end

function SWEP:Holster()
    if self:GetNWInt("Hold") ~= 0 and SERVER then
        self:Throw(0)
    end
    return true
end

function SWEP:SetFakeWep()
    if self:GetNWInt("Hold") ~= 0 then
        self:Throw(0)
    else
        return false
    end
end

if SERVER then
    function SWEP:Throw(force)
        local owner = self:GetOwner()
        if not IsValid(owner) then return end

        force = force or 750
        self:SetNWInt("Hold", 0)
        self:SetNWBool("Arm", true)
        self.TimeStart = CurTime()
        self.TimeDetonate = self.TimeDetonate or 3.5
        self.attacker = owner

        local eyePos = owner:EyePos()
        local eyeAng = owner:EyeAngles()
        local aimVec = owner:GetAimVector()

        local throwPos = eyePos + aimVec * 16 + eyeAng:Right() * 4 + eyeAng:Up() * -2
        local throwVel = aimVec * force + owner:GetVelocity() * 0.8

        owner:DropWeapon(self)

        self:SetPos(throwPos)
        self:SetAngles(eyeAng)

        local phys = self:GetPhysicsObject()
        if not IsValid(phys) then
            self:PhysicsInit(SOLID_VPHYSICS)
            phys = self:GetPhysicsObject()
        end

        if IsValid(phys) then
            phys:Wake()
            phys:SetVelocity(throwVel)
            phys:AddAngleVelocity(VectorRand() * 300)
        end

        if self.ArmPost then
            self:ArmPost()
        end

        local timerID = "gnade_detonate_" .. self:EntIndex()
        timer.Create(timerID, 0.05, 0, function()
            if not IsValid(self) then
                timer.Remove(timerID)
                return
            end

            if self.ArmThink then
                self:ArmThink()
            end

            if CurTime() >= (self.TimeStart or 0) + (self.TimeDetonate or 3.5) then
                timer.Remove(timerID)
                if self.Detonate then
                    self:Detonate()
                elseif self.ExplosiveClass and isfunction(Explosive) then
                    Explosive(self.ExplosiveClass, self:GetPos() + Vector(0, 0, 5), self, self.attacker)
                    self:Remove()
                else
                    util.BlastDamage(self, self.attacker or self, self:GetPos(), 400, 150)
                    local eff = EffectData()
                    eff:SetOrigin(self:GetPos())
                    util.Effect("Explosion", eff)
                    self:Remove()
                end
            end
        end)
    end
end

function SWEP:CanHUDTarget() return not self:GetNWBool("Arm") end

SWEP.InvMoveSnd = InvMoveSndGranade
SWEP.InvCount = 3
