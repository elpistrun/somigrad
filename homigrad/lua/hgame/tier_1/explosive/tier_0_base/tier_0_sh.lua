--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/explosive/tier_0_base/tier_0_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\explosive\\tier_0_base\\tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local EXP = oop.Reg("explosive_base",nil,true)
if not EXP then return INCLUDE_BREAK end

function EXP:SetPos(pos)
    self.pos = pos
end

function EXP:SetParent(ent)
    self.parent = ent
end

function EXP:SetAttacker(attacker)
    self.attacker = attacker
end

EXP.Power = 25
EXP.Damage = 50
EXP.RadiusDamage = 1000//наносит урон от взрывной волны
EXP.RadiusStun = 1500//оглушает взрывной волной

EXP.FragCount = 3000
EXP.FragDamage = 45
EXP.FragMaxDistance = 7000

// Client

EXP.SoundClose = {"weapons/m67/m67_detonate_01.wav","weapons/m67/m67_detonate_02.wav","weapons/m67/m67_detonate_03.wav"}
EXP.SoundDist = {"weapons/m67/m67_detonate_dist_01.wav","weapons/m67/m67_detonate_dist_02.wav","weapons/m67/m67_detonate_dist_03.wav"}
EXP.SoundFar = {"weapons/m67/m67_detonate_far_dist_01.wav","weapons/m67/m67_detonate_far_dist_02.wav","weapons/m67/m67_detonate_far_dist_03.wav"}

EXP.ParticleGround = "100lb_ground"
EXP.ParticleAir = "100lb_air"

EXP.Earrape = true
EXP.ExplosiveWave = true

if SERVER then
    util.AddNetworkString("explosive")

    function Explosive_FragSplosion(ent, pos, count, dmg, dist, att)
        if JMod and JMod.FragSplosion then
            JMod.FragSplosion(ent or game.GetWorld(), pos, count or 1000, dmg or 50, dist or 3500, att or ent or game.GetWorld())
        else
            util.BlastDamage(ent or game.GetWorld(), att or ent or game.GetWorld(), pos, dist or 500, dmg or 100)
        end
    end

    function EXP:Emit()
        local pos = self.pos or (IsValid(self.parent) and (self.parent:GetPos() + self.parent:OBBCenter())) or vector_origin
        local parent = self.parent
        local attacker = self.attacker
        local className = self.className or "explosive_base"

        net.Start("explosive")
        net.WriteString(className)
        net.WriteTable({pos, parent})
        net.Broadcast()

        local radius = self.RadiusDamage or 500
        local dmg = self.Damage or 100
        local power = self.Power or 25
        local radiusStun = self.RadiusStun or 1000

        local inflictor = IsValid(parent) and parent or game.GetWorld()
        local att = IsValid(attacker) and attacker or inflictor
        util.BlastDamage(inflictor, att, pos, radius, dmg)

        for _, e in ipairs(ents.FindInSphere(pos, radius)) do
            if IsValid(e) then
                local phys = e:GetPhysicsObject()
                if IsValid(phys) then
                    local dir = (e:GetPos() - pos):GetNormalized()
                    phys:ApplyForceOffset(dir * power * 1000, pos)
                end
                if e:IsPlayer() and e:Alive() and not e:HasGodMode() then
                    local dist = e:GetPos():Distance(pos)
                    local pain = math.Clamp((1 - dist / radiusStun) * 200, 0, 200)
                    if pain > 0 then
                        e:SetNWFloat("pain", e:GetNWFloat("pain", 0) + pain)
                        if (e:GetNWFloat("pain", 0) > 180 or dist < radius * 0.7) and Fake then
                            Fake(e)
                        end
                    end
                end
            end
        end

        if self.FragCount and self.FragCount > 0 then
            Explosive_FragSplosion(parent, pos, self.FragCount, self.FragDamage or 45, self.FragMaxDistance or 3500, attacker)
        end

        if self.ExplosiveLogicPost then
            self:ExplosiveLogicPost()
        end

        if IsValid(parent) and parent:GetClass() == "prop_physics" and parent.parentBomb then
            parent:Remove()
        end
    end

    function Explosive(className, pos, parent, attacker)
        className = className or "explosive_base"
        pos = pos or (IsValid(parent) and (parent:GetPos() + parent:OBBCenter())) or vector_origin

        local exp = oop.Create(className)
        if not exp then
            exp = oop.Create("explosive_base")
        end
        if not exp then return end

        exp:SetPos(pos)
        if IsValid(parent) then exp:SetParent(parent) end
        if IsValid(attacker) then exp:SetAttacker(attacker) end

        exp:Emit()

        return exp
    end
end

