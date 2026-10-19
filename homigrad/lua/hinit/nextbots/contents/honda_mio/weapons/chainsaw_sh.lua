--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/nextbots/contents/honda_mio/weapons/chainsaw_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hinit/nextbots/contents/honda_mio/tier_0_sh.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad\\lua\\hinit\\nextbots\\contents\\honda_mio\\weapons\\chainsaw_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Get("npc_honda_mio")
if not ENT then return end

local Chainsaw = {}
ENT.Weapons.Chainsaw = Chainsaw

function Chainsaw.Attack(ent)

end

local chainsaw = Material("homigrad/scp/honda_mio/chainsaw_down.png")

ENT.Brz = 0
ENT.BrzI = 0

Chainsaw.Speed = 1200
Chainsaw.Acceleration = 1200
Chainsaw.Deceleration = 1200

if CLIENT then
    function Chainsaw.Off(self)
        if IsValid(self.snd1) then self.snd1:Remove() end
        if IsValid(self.snd2) then self.snd2:Remove() end
    end

    function Chainsaw.On(self)
        self.Stun = CurTime() + 5

        local snd = sound.CreatePoint(self,"homigrad/scp/honda_mio/chainsaw_start.wav")
        snd.level = 511
        snd.deleteTime = RealTime() + 5
    end
end

ENT.Stun = 0

function Chainsaw.Draw(self,pos,normal,size,color,rot)
    render.SetMaterial(chainsaw)

    local k = 0

    if self.Stun <= CurTime() then
        local snd1 = sound.CreatePoint(self,"homigrad/scp/honda_mio/chainsaw_idle.wav")
        self.snd1 = snd1
        snd1.level = 511
        snd1.restartTime = 1
        snd1.volume = 0

        local snd2 = sound.CreatePoint(self,"homigrad/scp/honda_mio/chainsaw_active.wav")
        self.snd2 = snd2
        snd2.level = 511
        snd2.restartTime = 8
        snd2.volume = 0.5

        local time = RealTime()

        if (self.BrzDelay or 0) < time then
            self.BrzDelay = time + (self.BrzI == 0 and math.Rand(2,2) or math.Rand(0.25,0.4))

            self.Brz = 1

            if self.BrzI == 0 then
                self.BrzI = math.random(1,3)
            end

            self.BrzI = self.BrzI - 1
        end

        self.Brz = LerpFT(0.35,self.Brz,0)

        snd1.volume = math.max((1 - self.Brz) * 0.5,0.1)

        local dis = self:GetNWEntity("Target")
        dis = IsValid(dis) and math.Clamp(1 - dis:GetPos():Distance(self:GetPos()) / 512,0,1) or 0
        
        k = math.Clamp(self.Brz * 1000 + dis * 2 + math.Clamp(self:GetNWFloat("AttackDoor",0) - CurTime() + 1,0,1),0.1,1)

        snd2.volume = k
    else
        if IsValid(self.snd1) then self.snd1:Remove() end
        if IsValid(self.snd2) then self.snd2:Remove() end
    end
    
    size = size * 0.7
    
    render.DrawQuadEasy(pos - normal * 15 + Vector(0,5,-25):Rotate(normal:Angle()),normal,size,size,color,rot + math.cos(CurTime() * 15) * 5 - (1 - self.FrameL) * 45 - k * 45)
end

function Chainsaw.AttackEnt(self,ent)
    local pos = ent:GetPos()
    
    blood_Explode(pos,pos + Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)))

    net.Start("kevin impact")
    net.WriteVector(pos)
    net.Broadcast()

    local path = "homigrad/scp/honda_mio/chainsaw_kill" .. math.random(1,2) .. ".wav"
    for i = 1,3 do self:PlaySND(path,ent) end

    self.Stun = CurTime() + 4
    self.Killed = self.Stun
    self.KilledPos = pos
end

function Chainsaw.AttackDoor(self,ent)
    self:SetNWFloat("AttackDoor",CurTime())
end

ENT.Killed = 0
ENT.KilledDelay = 0

function Chainsaw.Think(self,currentTime)
    if self.Killed > currentTime and self.KilledDelay < currentTime then
        self.KilledDelay = currentTime + math.Rand(0.1,0.25)

        net.Start("chainsaw")
        net.WriteVector(self.KilledPos)
        net.Broadcast()
    end
end

if SERVER then
    util.AddNetworkString("chainsaw")

    return
end

local delay = 0

local random,Rand = math.random,math.Rand

net.Receive("chainsaw",function()
	local pos,dir = net.ReadVector(),Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1))
	local r = random(10,15)

	local emitter = ParticleEmitter(pos)

	for i = 1,r do
		local part = emitter:Add(ParticleMatBlood[random(1,#ParticleMatBlood)],pos)
		if not part then continue end

		part:SetDieTime(Rand(0.5,1))

        part:SetStartAlpha(random(35,75)) part:SetEndAlpha(0)
        part:SetStartSize(Rand(10,15)) part:SetEndSize(Rand(125,175))

        part:SetCollide(true) part:SetCollideCallback(blood_CollideFunc)

		local dir = dir:Clone():Mul(2000 * Rand(0.25,1))
		dir:Rotate(Angle(Rand(80,110 ) * Rand(0.9,1.1),Rand(-180,180) * Rand(0.9,1.1)))
		dir:Mul(Rand(0.9,1.1))

		--part:SetStartLength(dir:Length() / 100)--wooooooow
		--part:SetEndLength(0)

		part:SetRoll(Rand(-360,360))
		part:SetVelocity(dir) part:SetAirResistance(512)
		part:SetPos(pos)
	end

	for i = 1,random(5,6) do
		local part = emitter:Add(ParticleMatSmoke[random(1,#ParticleMatSmoke)],pos)
		if not part then continue end

		part:SetDieTime(Rand(0.7,1))

        part:SetStartAlpha(random(15,25)) part:SetEndAlpha(0)
        part:SetStartSize(Rand(10,15)) part:SetEndSize(Rand(300,400))

        part:SetCollide(true) part:SetCollideCallback(blood_CollideFunc)
		part:SetColor(125,0,0)

		local dir = dir:Clone():Mul(2000 * Rand(0.25,1))
		dir:Rotate(Angle(Rand(80,110 ) * Rand(0.9,1.1),Rand(-180,180) * Rand(0.9,1.1)))
		dir:Mul(Rand(0.9,1.1))

		part:SetVelocity(dir) part:SetAirResistance(1000)
		part:SetPos(pos)
	end

    for i = 1,3 do
        timer.Simple(0.05 * i,function()
            local emitter = ParticleEmitter(pos)

            dir:Rotate(Angle(math.sin(CurTime() * 6) * 55,math.cos(CurTime() * 6) * 55,0))
            
            for i = 1,r do
                local part = emitter:Add(ParticleMatBlood[random(1,#ParticleMatBlood)],pos)
                if not part then continue end

                part:SetDieTime(Rand(0.4,0.5))

                part:SetStartAlpha(random(155,175)) part:SetEndAlpha(0)
                part:SetStartSize(Rand(10,15)) part:SetEndSize(Rand(15,15))

                part:SetGravity(ParticleGravity)
                part:SetCollide(true) part:SetCollideCallback(blood_CollideFunc)

                local dir = dir:Clone():Mul(3000 * Rand(0.5,1))
                dir:Rotate(Angle(Rand(-15,15) * Rand(0.9,1.1),Rand(-15,15) * Rand(0.9,1.1)))
                dir:Mul(Rand(0.9,1.1))

                part:SetStartLength(dir:Length() / 15)--wooooooow
                part:SetEndLength(0)

                part:SetVelocity(dir) part:SetAirResistance(250)
                part:SetPos(pos)
            end

            emitter:Finish()
        end)
    end

	for i = 1,random(2,5) do
		local part = emitter:Add(ParticleMatBlood[random(1,#ParticleMatBlood)],pos)
		if not part then continue end

		part:SetDieTime(Rand(10,15))

        part:SetStartAlpha(random(125,200)) part:SetEndAlpha(0)
        part:SetStartSize(Rand(5,7)) part:SetEndSize(Rand(5,7))

		part:SetGravity(ParticleGravity)
        part:SetCollide(true) part:SetCollideCallback(blood_CollideFunc)
		part:SetColor(125,0,0)

		part:SetPos(pos + dir:Clone():Rotate(Angle(Rand(80,89),Rand(-180,180),0)):Mul(Rand(15,25)))

		local dir = dir:Clone():Mul(75)
		dir:Rotate(Angle(Rand(-90,90) * Rand(0.9,1.1),Rand(-90,90) * Rand(0.25,1.1)))
		dir[3] = dir[3] + Rand(75,333)

		part:SetStartLength(dir:Length() / 23)--wooooooow
		part:SetEndLength(0)

		part:SetVelocity(dir)
	end

	emitter:Finish()
end)
