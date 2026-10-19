--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/traitor/weapon_hidebomb_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hgame/tier_2_entities/traitor/explosive_hidebomb_sh.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\traitor\\weapon_hidebomb_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Reg("weapon_hidebomb","hg_wep_base")
if not SWEP then return end

SWEP.PrintName 				= L("weapon_hidebomb")
SWEP.Author 				= "Homigrad"
SWEP.Instructions			= L("weapon_hidebomb_desc")
SWEP.Category 				= L("weapon_category_traitor")

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Slot					= 4
SWEP.SlotPos				= 2
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP.WorldModel				= "models/props_junk/cardboard_box004a.mdl"

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

SWEP.dwsItemPos = Vector(0,0,0)
SWEP.dwsItemAng = Vector(0,0,90)
SWEP.itemType = "none"
SWEP.isPropBox = true

SWEP.EnableTransformModel = true

SWEP.wmScale = 1
SWEP.wmVector = Vector(2,1,-2)
SWEP.wmAngle = Angle(0,0,0)
SWEP.wmScale = 0.5

SWEP.HoldType = "normal"

SWEP.HolsterTime = 0
SWEP.DeployTime = 0


function SWEP:Reload() end
function SWEP:PrimaryAttack() end
function SWEP:SecondaryAttack() end

if SERVER then
    local function Bomb(ent,att)
        if not IsValid(ent) then return end
        ent:RemoveCallOnRemove("hidebomb")

        local pos = ent:GetPos() + ent:OBBCenter()
        local attacker = IsValid(att) and att or ent

        if isfunction(Explosive) then
            Explosive("explosive_hidebomb",pos,nil,attacker)
        end

        util.BlastDamage(attacker,attacker,pos,650,350)

        local eff = EffectData()
        eff:SetOrigin(pos)
        eff:SetScale(2)
        util.Effect("Explosion",eff)
        sound.Play("ambient/explosions/explode_4.wav",pos,100,100)

        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:Alive() then
                local dist = ply:GetPos():Distance(pos)
                if dist <= 650 then
                    local d = DamageInfo()
                    d:SetDamage(math.Clamp((1 - dist / 650) * 400, 50, 400))
                    d:SetDamageType(DMG_BLAST)
                    d:SetAttacker(attacker)
                    d:SetInflictor(attacker)
                    d:SetDamagePosition(pos)
                    ply:TakeDamageInfo(d)
                end
            end
        end

        if IsValid(ent) and ent:GetClass() == "prop_physics" and ent.parentBomb then ent:Remove() end
    end

    SWEP:Event_Add("Init","Normal",function(self)
        self:SetHoldType("normal")
        self:SetNWBool("HaveBomb",true)
    end)

    --local cyka = {}

    function SWEP:PrimaryAttack()
        if IsValid(self.bomb) then return end

        local owner = self:GetOwner()

        local tr = {}
        tr.start = owner:GetAttachment(owner:LookupAttachment("eyes")).Pos
        local dir = Vector(1,0,0)
        dir:Rotate(owner:EyeAngles())
        tr.endpos = tr.start + dir * 75
        tr.filter = owner

        local traceResult = util.TraceLine(tr)
        local ent = traceResult.Entity

        if not IsValid(ent) then
            ent = ents.Create("prop_physics")
            ent:SetModel("models/props_junk/cardboard_box004a.mdl")

            ent:SetPos(traceResult.HitPos)
            ent:Spawn()
            ent.doNotDropLoot = true
        end

        self.bomb = ent
        ent.parentBomb = self

        ent:CallOnRemove("hidebomb",Bomb,owner)
        ent:EmitSound("buttons/button24.wav",75,50)
        self:SetNWBool("HaveBomb",false)
    end

    function SWEP:SecondaryAttack()
        if not IsValid(self.bomb) then return end

        local ent = self.bomb

        ent:EmitSound("snds_jack_gmod/plunger.ogg")

        local att = self:GetOwner()
		timer.Simple(math.Rand(0.3,0.4),function() Bomb(ent,att) end)

        self.bomb = nil
        self:Remove()
    end
else
    function SWEP:ShouldRender() return self:GetNWBool("HaveBomb") end
    
    function SWEP:DrawHUD()
        local owner = self.Owner
        local tr = {}
        tr.start = owner:GetAttachment(owner:LookupAttachment("eyes")).Pos
        local dir = Vector(1,0,0)
        dir:Rotate(owner:EyeAngles())
        tr.endpos = tr.start + dir * 75
        tr.filter = owner

        local traceResult = util.TraceLine(tr)
        local ent = traceResult.Entity

        if not IsValid(ent) then
            local hit = traceResult.Hit and 1 or 0
            local frac = traceResult.Fraction
            surface.SetDrawColor(Color(255, 255, 255, 255 * hit))
            draw.NoTexture()
            Circle(traceResult.HitPos:ToScreen().x, traceResult.HitPos:ToScreen().y, 5 / frac, 32)
        else
            local frac = traceResult.Fraction
            surface.SetDrawColor(Color(255, 255, 255, 255))
            draw.NoTexture()
            Circle(traceResult.HitPos:ToScreen().x, traceResult.HitPos:ToScreen().y, 5 / frac, 32)
            draw.DrawText(L("weapon_hidebomb_claim") .. " " .. tostring((util.GetSurfaceIndex(ent:GetBoneSurfaceProp(0)) == 3 or util.GetSurfaceIndex(ent:GetBoneSurfaceProp(0)) == 66) and L("weapon_hidebomb_metal") or ""), "TargetID", traceResult.HitPos:ToScreen().x, traceResult.HitPos:ToScreen().y - 40, color_white, TEXT_ALIGN_CENTER )
        end
    end
end
