--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/tier_0_hg_wep_base/deploy_holster_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
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

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\tier_0_hg_wep_base\\deploy_holster_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Get("hg_wep_base")
if not SWEP then return end

SWEP.HolsterTime = 0.25
SWEP.DeployTime = 0.25

SWEP.HoldType = "pistol"

SWEP:Event_Add("Init","HoldType",function(self)
    self:SetupStandType()

    if CLIENT then
        self:SetNWVarProxy("HoldType",function(_,key,old,new)
            if not self.SetupStandType then return end--wtf
            
            self:SetupStandType()
        end)
    end

    timer.Simple(0,function() if IsValid(self) then self:SetupStandType() end end)
end)

function SWEP:Deployed()
    if self.deployed then return end--ura

    self.deployed = true
    self:SetNWFloat("DeployStart",CurTime())
    self.DeployStart = RealTime()

    self:SetNWFloat("HolsterStart",0)
    self.HolsterStart = 0
    
    local owner = self:GetOwner()

    if self.HoldType then self:SetStandType(self.HoldType) end
    self:Event_Call("Deploy",owner)

    if self.OnDeploy then self:OnDeploy() end

    if SERVER then
        if owner:IsNPC() then return end

        net.Start("wep deployed")
        net.WriteEntity(self)
        net.Send(owner)

        timer.Simple(0.001,function()//отправляем клиенту инфу о том что он достал оружие, при создании баг такой есть
            if not IsValid(self) then return end

            net.Start("wep deployed")
            net.WriteEntity(self)
            net.Send(owner)
        end)
    end
end

function SWEP:Holstered()
    self:SetNWFloat("HolsterStart",CurTime())
    self.HolsterStart = RealTime()
    
    local owner = self:GetOwner()

    self:SetStandType("normal")
    self:Event_Call("Holster",owner)

    if SERVER and owner:IsNPC() then self:HolsteredEnd() return end

    if self.OnHolstered then self:OnHolstered() end

    if SERVER then
        net.Start("wep holstered")
        net.WriteEntity(self)
        net.Send(owner)
    end
end

function SWEP:HolsteredEnd()
    local owner = self:GetOwner()
    self.deployed = nil
    self:Event_Call("Holster End",owner)

    if self.OnHolsteredEnd then self:OnHolsteredEnd() end

    if SERVER and not owner:IsNPC() then
        net.Start("wep holstered end")
        net.WriteEntity(self)
        net.Send(owner)
    end
end

function SWEP:Deploy()
    -- A fake body holds nothing. sv_fake refuses the switch away from a weapon that was
    -- out when the body dropped, so that weapon is still the active one -- it just must
    -- not deploy, otherwise it stays drawn in the corpse's hand.
    local owner = self:GetOwner()

    if IsValid(owner) and owner.InFake and owner:InFake() then return false end

    self:SetNWFloat("DeployStart",CurTime() + 10)
end//костыли ебаные, бывает моменты когда он достаёт и не пришло ничоо,

-- The line above parks DeployStart ten seconds into the future so that the draw pose is
-- guaranteed to play, and Deployed() is supposed to replace it with the real time. Every
-- animation below feeds DeployStart straight into `(DeployStart + DeployTime - time)`,
-- so while that correction has not arrived DeployStart is still ten seconds ahead and k
-- sits pinned at 1: the arm holds the draw pose, IsDeployed() stays false so the weapon
-- cannot fire, and it only snaps back once those ten seconds actually elapse.
--
-- A DeployStart further ahead than the deploy itself can last is never meaningful, so it
-- is replaced with the moment the draw actually started. That moment has to be remembered:
-- returning "now" instead means the caller re-reads a fresh now every frame, which keeps
-- `(start + DeployTime - time)` at exactly DeployTime and pins k at 1 just as the raw
-- placeholder did -- the pose still never releases. Anchor it once, drop the anchor as
-- soon as the real DeployStart arrives.
-- keyed by entity index rather than the entity itself, so this never keeps a removed
-- weapon alive
local DEPLOY_ANCHORED = {}

function SWEP:GetDeployStart(now)
    now = now or CurTime()

    local start = self:GetNWFloat("DeployStart",0)
    local id = self:EntIndex()

    if start > now + (self.DeployTime or 0) then
        local anchor = DEPLOY_ANCHORED[id]

        -- re-anchor if the placeholder itself changed, i.e. a fresh Deploy()
        if not anchor or anchor.from ~= start then
            anchor = {from = start,at = now}
            DEPLOY_ANCHORED[id] = anchor
        end

        return anchor.at
    end

    DEPLOY_ANCHORED[id] = nil

    return start
end

function SWEP:IsDeployed() return self:GetDeployStart() + self.DeployTime < CurTime() end//true если оружие он достал
function SWEP:IsHolstered() return self:GetNWFloat("HolsterStart",0) + self.HolsterTime + 1 >= CurTime() end//true если убирает оружие

local Clamp = math.Clamp

function SWEP:GetStandAnimK()
    local time = CurTime()

    local deployTime = self.DeployTime
    local k

    -- DeployTime is 0 on a couple of weapons (melee_fubar, weapon_hidebomb). Dividing by
    -- it turns the whole expression into 0/0 = nan, and nan bone angles are how a model
    -- ends up warped and spinning instead of just not animating. No deploy time means no
    -- deploy animation: fully deployed.
    if deployTime and deployTime > 0 then
        k = 1 - Clamp((self:GetDeployStart(time) + deployTime - time) / deployTime,0,1)
    else
        k = 1
    end

    if self:IsHolstered() then
        local holsterTime = self.HolsterTime

        k = (holsterTime and holsterTime > 0)
            and Clamp((self:GetNWFloat("HolsterStart",0) + holsterTime - time) / holsterTime,0,1)
            or 1
    end

    return k
end

SWEP:Event_Add("Deploy","HoldType",function(self) self:SetupStandType() end,-1)
