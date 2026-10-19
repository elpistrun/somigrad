--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/footkick_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\footkick_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
event.Add("Bones","Footkick",function(ply,link,ft,time)
    if not ply.PlayerClassEvent or not ply:Alive() or ply.fake or event.Call("Can Foot Kick") == false then return end
    if ply:PlayerClassEvent("ShouldFootKick") == false then return end

    local active
    local isLocal = SERVER

    if SERVER then
        local active = ply:KeyDown(IN_ZOOM)
        if ply.footKickKey ~= active then
            ply.footKickKey = active

            if active then FootKick(ply) end//https://www.youtube.com/watch?v=tenfF8LdHpQ
        end
    end

    //

    local pelvis = ply:LookupBone("ValveBiped.Bip01_Pelvis")
    if not pelvis then return end
    
    pelvis = ply:GetBoneMatrix(pelvis)
    if not pelvis then return end

    local pos,ang = ply:Eye()
    ang[1] = math.max(ang[1],20)

    local anim_pos = math.max((ply:GetNWFloat("FootKickStart",0) - CurTime() + 0.25) / 0.25,0)
    anim_pos = math.min(anim_pos * 1.8,1)

    local diff = (pelvis:GetAngles()[2] - ang[2]) % 180

    local syka = ang[1] / 90
    syka = math.max(syka - 0.6,0) / 0.4
    syka = 1 - syka

    ply:AddBoneAng("rthigh",Angle((diff - 110) * syka,-90 + ang[1],0) * anim_pos,false)
end)

if SERVER then
    util.AddNetworkString("tfa kick door")

    function FootKick(ply)
        if not IsValid(ply) or not ply:Alive() or (ply.InFake and ply:InFake()) or ply.fake then return end
        if (ply.nextFootKick or 0) > CurTime() then return end
        ply.nextFootKick = CurTime() + 0.65

        ply:SetNWFloat("FootKickStart",CurTime())
        ply:EmitSound("weapons/iceaxe/iceaxe_swing1.wav",75,math.random(75,85))

        if ply.stamina then
            ply.stamina = math.max(ply.stamina - 12 * (ply.mulStamina or 1),0)
            ply:SetNWFloat("stamina",math.Round(ply.stamina,1))
        end

        local tr = {}
        tr.start = ply:EyePos()
        tr.endpos = tr.start + ply:GetAimVector() * 70
        tr.filter = ply
        tr.mins = Vector(-10,-10,-15)
        tr.maxs = Vector(10,10,15)
        local res = util.TraceHull(tr)

        if not res.Hit then return end

        local ent = res.Entity
        if not IsValid(ent) then return end

        local hitClass = ent:GetClass()

        if hitClass == "prop_door_rotating" or hitClass == "func_door" or hitClass == "func_door_rotating" then
            ent:EmitSound("physics/wood/wood_plank_break" .. math.random(1,4) .. ".wav",85,math.random(90,110))
            ent:Fire("open","",0)
            ent:Fire("unlock","",0)

            net.Start("tfa kick door")
            net.WriteEntity(ent)
            net.Broadcast()
            return
        end

        if ent:IsPlayer() and ent:Alive() then
            ent:EmitSound("physics/body/body_medium_impact_hard" .. math.random(1,6) .. ".wav",80,100)
            local dmg = DamageInfo()
            dmg:SetDamage(math.random(15,25))
            dmg:SetAttacker(ply)
            dmg:SetInflictor(ply)
            dmg:SetDamageType(DMG_CLUB)
            dmg:SetDamageForce(Vector(0,0,0))
            dmg:SetDamagePosition(res.HitPos)
            ent:TakeDamageInfo(dmg)

            local pushDir = ply:GetAimVector()
            pushDir.z = 0
            if pushDir:LengthSqr() > 0 then
                pushDir:Normalize()
            else
                pushDir = ply:GetForward()
            end

            if not (ent.InFake and ent:InFake()) then
                if Faking then
                    Faking(ent, pushDir * 320)
                elseif ent.EnterFake then
                    ent:EnterFake(pushDir * 320)
                else
                    ent:SetVelocity(pushDir * 120)
                end
            else
                local rag = ent:GetNWEntity("FakeRagdoll") or ent.fakeEnt or ent.FakeRagdoll
                if IsValid(rag) then
                    local phys = rag:GetPhysicsObject()
                    if IsValid(phys) then
                        phys:ApplyForceCenter(pushDir * 12000)
                    end
                end
            end
            return
        elseif ent:IsRagdoll() then
            ent:EmitSound("physics/body/body_medium_impact_hard" .. math.random(1,6) .. ".wav",80,100)
            local phys = ent:GetPhysicsObjectNum(res.PhysicsBone or 0) or ent:GetPhysicsObject()
            if IsValid(phys) then
                local pushDir = ply:GetAimVector()
                pushDir.z = math.Clamp(pushDir.z, -0.4, 0.1)
                pushDir:Normalize()
                phys:ApplyForceCenter(pushDir * 14000)
            end
            return
        end

        local phys = ent:GetPhysicsObject()
        if IsValid(phys) and not ent:IsPlayer() then
            ent:EmitSound("physics/body/body_medium_impact_hard" .. math.random(1,6) .. ".wav",75,100)
            phys:Wake()
            phys:ApplyForceOffset(ply:GetAimVector() * math.Clamp(phys:GetMass() * 500,4000,60000),res.HitPos)
        end
    end

    concommand.Add("+kick",function(ply) FootKick(ply) end)
    concommand.Add("-kick",function() end)
    concommand.Add("footkick",function(ply) FootKick(ply) end)
else
    local random,Rand = math.random,math.Rand

    net.Receive("tfa kick door",function()
        local ent = net.ReadEntity()
        local ang = ent:GetAngles()

        local pos = ent:GetPos()
        local emitter = ParticleEmitterLight(pos)
    
        local max = random(23,25)
        local startPos,endPos = ent:GetPos():Add(ent:OBBMins()),ent:GetPos():Add(ent:OBBMaxs():Rotate(ang))
    
        for i = 1,max do
            local part = emitter:Add(ParticleMatSmoke[random(1,#ParticleMatSmoke)],pos)
            if not part then continue end
    
            local k = i / max
            
            part:SetDieTime(Rand(2,3))
    
            part:SetStartAlpha(random(7,15)) part:SetEndAlpha(0)
            part:SetStartSize(Rand(25,55)) part:SetEndSize(Rand(125,175))
    
            part:SetCollide(true)
            part:SetColor(75,75,75)
            part:SetLight(true)
    
            part:SetGravity(ParticleGravity)
            part:SetRoll(Rand(-125,125))
            part:SetAirResistance(Rand(600,900))
            part:SetPos(Lerp(k,startPos,endPos))
        end
    end)
end
