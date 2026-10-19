--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/tier_0_hg_wep_base/render/util_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hgame/tier_2_entities/tier_0_hg_wep_base/tier_0_sh.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\tier_0_hg_wep_base\\render\\util_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Get("hg_wep_base")
if not SWEP then return end

-- Bones a weapon can be hung on, most specific first. Playermodels do not all expose the
-- same hand bone: the Valve skeleton has ValveBiped.Bip01_R_Hand, but third-party models
-- (and plenty of ragdolls standing in for players) only carry the finger/forearm names.
-- Any of them holds a weapon convincingly, and the old code stopped at the first miss.
-- That miss then travelled straight into the draw path, which has no nil check, so a
-- model without that exact bone produced "cl_drawworldmodel.lua:33: attempt to index
-- local 'gun' (a nil value)" on every draw pass.
local HOLD_BONES = {
    "ValveBiped.Bip01_R_Hand",
    "ValveBiped.Bip01_R_Finger0",
    "ValveBiped.Bip01_R_Forearm",
    "ValveBiped.Bip01_R_UpperArm",
}

-- The engine's own right-hand weapon attachment on a ValveBiped playermodel. Unlike the
-- bones it does not depend on the model's bone matrices being set up, so it is what is
-- left when GetBoneMatrix comes back empty on the first frames after a spawn or a model
-- change.
local HAND_ATTACHMENT = "anim_attachment_RH"

-- model path -> already told the console which path it takes, so this does not spam
local WARNED_HAND = {}

-- Melee weapons do not follow the gun convention. A gun (and the crowbar) is authored
-- along the model's +X, so it only needs the hand bone's own angles; a bat, a spear or a
-- pipe is a prop-shaped model authored along its *up* axis, which is why they all stood
-- upright in the fist instead of lying along the hand. Laying one along the hand's forward
-- axis is a single 90 degree rotation, and that angle is the one number that really does
-- differ per model -- so it is a convar, reachable from the console while the game runs:
--
--     hg_melee_wmangle "pitch yaw roll"     default "0 -90 0"
--
-- Adjust it live, and a weapon that carries its own wmAngle (hinit/halflife's crowbar
-- does, tuned for its own model) is left alone and ignores this.
local MELEE_ANGLE_DEFAULT = Angle(70,0,180)
local MELEE_VECTOR_DEFAULT = Vector(3.5,3,0)

local MeleeAngleCvar

if CLIENT then
    MeleeAngleCvar = CreateClientConVar("hg_melee_wmangle","70 0 180",true,false,"Hold rotation for melee weapons whose model is not gun-shaped, \"pitch yaw roll\"")
end

local function IsZeroAngle(a)
    return not a or (a[1] == 0 and a[2] == 0 and a[3] == 0)
end

-- Parsed every call on purpose: it is a handful of weapons per frame, and reading the
-- convar directly is what makes "change it and look" work without any refresh command.
local function GetMeleeHoldAngle()
    local str = MeleeAngleCvar and MeleeAngleCvar:GetString()

    if not str or str == "" or str == "0 -90 0" then return MELEE_ANGLE_DEFAULT end

    local split = string.Explode(" ",str)

    return Angle(tonumber(split[1]) or 0,tonumber(split[2]) or 0,tonumber(split[3]) or 0)
end

function SWEP:GetTransformFromRagdoll(owner)
    owner = owner or self:GetOwner()

    if not IsValid(owner) then return end

    local Pos,Ang

    if self.UseHandAttachment then
        local id = owner.LookupAttachment and owner:LookupAttachment(HAND_ATTACHMENT)
        if id and id > 0 then
            local att = owner:GetAttachment(id)
            if att and att.Pos then
                Pos,Ang = att.Pos:Clone(),att.Ang:Clone()
            end
        end
    end

    local bone

    if not Pos then
        -- wmBone is nil on weapons that never got the render/config_sh.lua defaults; calling
        -- LookupBone(nil) on those is its own error, so only ask for it when it is set.
        if self.wmBone then
            bone = owner:LookupBone(self.wmBone)
            if bone and bone < 0 then bone = nil end
        end

        if not bone then
            for i = 1,#HOLD_BONES do
                bone = owner:LookupBone(HOLD_BONES[i])

                if bone and bone >= 0 then break end
            end
        end

        if bone and bone >= 0 then
            local matrix = owner:GetBoneMatrix(bone)

            if matrix then
                Pos,Ang = matrix:GetTranslation(),matrix:GetAngles()
            end

            if not Pos and owner.GetBonePosition then
                local bPos, bAng = owner:GetBonePosition(bone)
                if bPos and (bPos ~= owner:GetPos() or bPos:LengthSqr() > 0) then
                    Pos = bPos:Clone()
                    Ang = bAng and bAng:Clone() or Angle(0,0,0)
                end
            end

            if not Pos and owner.TranslateBoneToPhysBone and owner.GetPhysicsObjectNum then
                local physBone = owner:TranslateBoneToPhysBone(bone)
                local phys = owner:GetPhysicsObjectNum(physBone)
                if IsValid(phys) then
                    Pos = phys:GetPos():Clone()
                    Ang = phys:GetAngles():Clone()
                end
            end
        end
    end

    if not Pos then
        -- Fall back to the engine's hand attachment before giving up: it needs no bone
        -- matrices, and a weapon a couple of units off the fist beats an invisible one.
        local id = owner.LookupAttachment and owner:LookupAttachment(HAND_ATTACHMENT)

        if id and id > 0 then
            local att = owner:GetAttachment(id)

            if att and att.Pos then Pos,Ang = att.Pos,att.Ang end
        end

        -- One line per model, so a console log says which path that playermodel takes
        -- instead of us guessing whether the bone lookup or the bone matrix is the miss.
        local mdl = owner.GetModel and owner:GetModel()

        if not WARNED_HAND[mdl] then
            WARNED_HAND[mdl] = true

            MsgN("[hg_wep_base] ",mdl,": no usable hold bone (",bone,"), ",Pos and ("using " .. HAND_ATTACHMENT) or "skipping the draw","\n")
        end
    end

    -- callers treat nil as "nothing to draw this frame": see draw_cl.lua
    if not Pos then return end

    local Forward,Right,Up = Ang:Forward(),Ang:Right(),Ang:Up()
    local ang = self.wmAngle

    -- melee weapons that never picked their own number get the tunable one (see above)
    if self.IsMelee and not self.UseHandAttachment and IsZeroAngle(ang) then ang = GetMeleeHoldAngle() end

    if ang and not IsZeroAngle(ang) then
        Ang:RotateAroundAxis(Up,ang[1])
        Ang:RotateAroundAxis(Right,ang[2])
        Ang:RotateAroundAxis(Forward,ang[3])
    end

    local vec = self.wmVector
    if self.IsMelee and not self.UseHandAttachment and (not vec or (vec[1] == 0 and vec[2] == 0 and vec[3] == 0)) then vec = MELEE_VECTOR_DEFAULT end
    if vec then
        Forward:Mul(vec[1]) Right:Mul(vec[2]) Up:Mul(vec[3])

        Pos:Add(Forward)
        Pos:Add(Right)
        Pos:Add(Up)
    end

    return Pos,Ang
end

function SWEP:GetWorldModelName() return self.WorldModelHands or self.WorldModel end
function SWEP:GetWorldModel() return self.EnableTransformModel and self.wm or self end
