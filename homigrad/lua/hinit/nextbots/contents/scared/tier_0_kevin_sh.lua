--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/nextbots/contents/scared/tier_0_kevin_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
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

-- "addons\\homigrad\\lua\\hinit\\nextbots\\contents\\scared\\tier_0_kevin_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("npc_kevin","npc_alternate")
if not ENT then return end

ENT.PrintName = "Kevin"
ENT.Category = "Nextbot | Scary"
ENT.IconOverride = "homigrad/scp/scared/youseemee2.png"

ENT.Speed = 800

ENT.Acceleration = 5000
ENT.Deceleration = 5000

ENT.ScanTargetDistance = 9999
ENT.MusicDistance = 2500

local random,Rand = math.random,math.Rand

if SERVER then
	util.AddNetworkString("kevin impact")
else
	net.Receive("kevin impact",function()
		local pos = net.ReadVector() + Vector(0,0,16)
		sound.Emit(nil,"snd_jack_fragsplodeclose.wav",125,1,100,pos,nil,ent)
		
		DWR_PlayReverb(pos,"explosions",false,{})

		local plooie = EffectData()
		plooie:SetOrigin(pos)
		plooie:SetScale(.01)
		plooie:SetRadius(.5)
		plooie:SetNormal(vector_up)

		local emitter = ParticleEmitter(pos)

		for i = 1,random(15,25) do
			local part = emitter:Add(ParticleMatSmoke[random(1,#ParticleMatSmoke)],pos)
			if not part then continue end
	
			local dir = Vector(Rand(-1,1),Rand(-1,1),Rand(0.5,1))
			dir = dir:Clone():Mul(Rand(555,666) * 4)

			dir:Rotate(Angle(Rand(-75,75),Rand(-75,75),0))
	
			part:SetDieTime(Rand(9,13))
	
			part:SetStartAlpha(random(75,125)) part:SetEndAlpha(0)
			part:SetStartSize(Rand(25,55)) part:SetEndSize(Rand(300,400))
	
			part.Pos = pos
			part:SetCollide(true)
			part:SetColor(Rand(75,170),0,0)
	
			part:SetRoll(Rand(-300,300) * 10)
			part:SetVelocity(dir) part:SetAirResistance(Rand(75,100))
			part:SetPos(pos)
		end

		emitter:Finish()
	end)
end

ENT.MusicHide = true

ENT.JumpSound = ""
ENT.JumpHighSound = ""
ENT.TauntSounds = {
	{
		Sound("homigrad/scp/kevin/killed2.wav"),
		3,
		function(ent)
			local pos = ent:GetPos()

			timer.Simple(0.3,function()
				blood_Explode(pos,pos - Vector(0,0,1))

				for i = 1,3 do
					blood_Explode(pos,pos - Vector(0,0,1))

					net.Start("kevin impact",true)
					net.WriteVector(pos)
					net.Broadcast()

					timer.Simple(0.2 * i,function()
						net.Start("kevin impact",true)
						net.WriteVector(pos)
						net.Broadcast()
					end)
				end
			end)
		end
	},
	{
		Sound("homigrad/scp/bear/killed2.wav"),
		3,
		function(ent)
			local pos = ent:GetPos()

			timer.Simple(0.35,function()
				for i = 1,3 do
					timer.Simple(0.18 * i,function()
						blood_Explode(pos,pos + Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)))
						blood_Explode(pos,pos + Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)))

						net.Start("kevin impact",true)
						net.WriteVector(pos)
						net.Broadcast()
					end)
				end

				timer.Simple(1.1,function()
					for i = 1,3 do
						blood_Explode(pos,pos + Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)))

						net.Start("kevin impact",true)
						net.WriteVector(pos)
						net.Broadcast()
					end
				end)
			end)
		end
	}
}

ENT.Music = Sound("homigrad/scp/bear/pain.wav")
ENT.SpriteMat = Material("homigrad/scp/scared/youseemee2.png")

ENT.Stun = 0

function ENT:HideUpdate(currentTime)
	if self.Stun > currentTime then return end

	if currentTime - self.LastHidingPlaceScan >= self.ScanHiddingInterval then
		self.LastHidingPlaceScan = currentTime

		local hidingSpot = self:GetNearestUsableHidingSpot()
		self:ClaimHidingSpot(hidingSpot)
	end

	if self.HidingSpot ~= nil then
		if currentTime - self.LastPathRecompute >= self.RepathHiddingInterval then
			self.LastPathRecompute = currentTime
			self.MovePath:Compute(self, self.HidingSpot.pos)
		end

		self.MovePath:Update(self)
	end
end

ENT.LastFootStep = 0
ENT.FootStep = true

function ENT:AttackEntPost(ent)
	local taunt = self.TauntSounds[math.random(1,#self.TauntSounds)]
	taunt[3](self)

	for i = 1,3 do self:PlaySND(taunt[1],ent) end

	self.Stun = CurTime() + taunt[2]
end

function ENT:ChaseUpdate(currentTime)
	if self.Stun > currentTime then return end

	self:AttackThink(currentTime)

	self:FussAmbient_Interval(currentTime)
	self:RecomputeTargetPath_Interval(currentTime)

	self:MovePathUpdate()
	self:SkyThink(currentTime)

	if self.FootStep and self.LastFootStep < currentTime then
		self.LastFootStep = currentTime + 0.25

		sound.Emit(self:EntIndex(),"homigrad/scp/kevin/footsteps/step_metal" .. math.random(1,3) .. ".wav",511,1,100,self:GetPos() + self:OBBCenter())
	end
end

function ENT:DrawSprite(pos,normal,size,color,rot)
	local follow = self:GetNWString("State") == "Follow"
	if not follow then return end

	render.DrawQuadEasy(pos,normal,size * (not LocalPlayer():Alive() and 2 or 5) + math.Rand(-1,1) * 50,follow and size * 13 + math.Rand(-1,1) * 25 or size,color,rot + math.sin(CurTime() * 1000 + math.Rand(-1,1)) * 2)
end

