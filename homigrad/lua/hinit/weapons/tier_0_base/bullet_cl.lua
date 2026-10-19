--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/weapons/tier_0_base/bullet_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hinit/weapons/tier_0_base/tier_0_sh.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad\\lua\\hinit\\weapons\\tier_0_base\\bullet_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Get("hg_wep")
if not SWEP then return end

local hg_volume_shoot

local random,Rand = math.random,math.Rand

local mat_smoke = Material("homigrad/shine")
local mat_smoke_alpha = Material("homigrad/shine_alpha")

local mat_smoke2 = {
	Material("particle/smokesprites_0009"),
	Material("particle/smokesprites_0010"),
	Material("particle/smokesprites_0011")
}

local mat_sprak = Material("sprites/spark")
local mat_muzzle = Material("mat_jack_gmod_shinesprite")

local hg_best_weaponlight
cvars.CreateOption("hg_best_weaponlight","-1",function(value) hg_best_weaponlight = tonumber(value) end,-2,1)

local cos,sin = math.cos,math.sin

function SWEP:ShootLight(pos,dir,color)
	local t = math.min(1 / 24,self.Primary.Wait,0.7)

	if hg_best_weaponlight == 1 then
		DynamicLamp(pos + Vector(2,0,4):Rotate(dir:Angle()),math.Rand(485,545),1000 / t):SetBrightness(math.Rand(0.025,0.05) * 6):SetColor(color):SetTexture("effects/flashlight/soft"):Spawn()
	elseif hg_best_weaponlight == 0 then
		local dlight = DynamicLight(self:EntIndex())
		dlight.pos = pos
		dlight.r = color.r
		dlight.g = color.g
		dlight.b = color.b
		dlight.brightness = 2
        
		dlight.decay = 1000 / (t * 10)
		dlight.size = Rand(100,200)

		dlight.nolight = true
		dlight:Spawn()

		local dlightFlash = {}
		for k,v in pairs(dlight) do dlightFlash[k] = v end

		dlightFlash.decay = 1000 / t
		dlightFlash.dietime = CurTime() + 1000 / dlightFlash.decay
		dlightFlash.d = 1000 / dlightFlash.decay

		DynamicLightMap[dlightFlash] = dlightFlash

		/*ParticleLightEmit(dlight)
		timer.Simple(time,function() ParticleLightEmit(dlight) end)*/
	end
end

function SWEP:ShootEffect(pos,dir)
    local color = Color(255,225,125)

    self:ShootLight(pos,dir,color)
    self:ShootEffect_Manual(pos,dir,color)
end

local AlphaMul = 0.5

function SWEP:ShootEffect_Manual(pos,dir,colorMuzzle,settings)
	settings = settings or {}

	if hg_best_weaponlight == -2 then return end
	
    local ang = dir:Angle()
	local emitter = ParticleEmitterLight(pos)
	emitter:SetLight("fast")

	local flashScale = settings.flashScale or 1
	
	local Time = RealTime()
	
	for i = 1,random(2,3) do--sparks
		local part = emitter:Add(mat_muzzle,pos - dir * Rand(4,6))
		if part then
			part:SetDieTime(Rand(1 / 28,1 / 30))

			part:SetColor(colorMuzzle.r,colorMuzzle.g,colorMuzzle.b)
			part:SetLight(false)

			part:SetStartAlpha(Rand(75,155))
            part:SetEndAlpha(Rand(0,25))

			part:SetStartSize(Rand(5,10) * flashScale / 2)
			part:SetEndSize(Rand(30,35) * flashScale)
			part:SetRoll(Rand(-360,360))

			part:SetVelocity(dir * Rand(500,500))

			part:SetAirResistance(Rand(1750,2000))
		end
	end

	for i = 1,random(6,8) do--sparks lebgth
		local ang = ang:Clone():Rotate(Angle(Rand(-180,180),Rand(-180,180)))

		local part = emitter:Add(mat_smoke_alpha,pos + Vector(Rand(0,1),0,0):Rotate(ang))
		if part then
			part:SetDieTime(1 / Rand(18,24))

			part:SetColor(colorMuzzle.r,colorMuzzle.g,colorMuzzle.b)
			part:SetLight(false)

			part:SetStartAlpha(Rand(225,255))
			part:SetEndAlpha(Rand(0,25) * flashScale)

			part:SetStartSize(Rand(0.1,0.175) * flashScale)
			part:SetEndSize(Rand(0.2,0.3) * flashScale)

			part:SetStartLength(Rand(2,4) * flashScale)
			part:SetEndLength(Rand(6,7) * flashScale)

			part:SetVelocity(Vector(Rand(125,300),0,0):Rotate(ang))
		end
	end

	--

	local part = emitter:Add(mat_sprak,pos + Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1)))
	if part then--glow
		part:SetDieTime(0.075)
        part:SetColor(colorMuzzle.r,colorMuzzle.g,colorMuzzle.b)
		part:SetLight(false)
		part:SetStartAlpha(15)
		
		part:SetStartSize(Rand(6,8))
		part:SetEndSize(random(45,55) * flashScale)

		part:SetRoll(Rand(360,-360))
		part:SetVelocity(dir * 125)
	end

	local part = emitter:Add(mat_sprak,pos + Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1)))
	if part then--glow alpha
		part:SetDieTime(0.035)
        part:SetColor(colorMuzzle.r,colorMuzzle.g,colorMuzzle.b)
		part:SetLight(false)
		part:SetStartAlpha(5)

		part:SetStartSize(Rand(12,13))
		part:SetEndSize(random(125,145) * flashScale)

		part:SetRoll(Rand(360,-360))
		part:SetVelocity(dir * 75)
	end

	--

	for i = 1,random(1,3) do--very alpha black smoke
		local part = emitter:Add(ParticleMatSmoke[random(1,#ParticleMatSmoke)],(pos + Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1))))
		if part then
			part:SetDieTime(Rand(0.5,1))

			local p = random(35,45)
			part:SetColor(p,p,random(25,35))

			part:SetStartAlpha(Rand(15,25))
			part.LightFlashMul = 0
			part:SetEndAlpha(0)

			part:SetStartSize(Rand(6,8))
			part:SetEndSize(12)
			part:SetRoll(Rand(128,360))

			part:SetVelocity((dir * Rand(5,10)):Rotate(Angle(0,cos(Time * 36) * 50,0)) + Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1)))
		end
	end

	local timeScale = settings.gasTimeScale or 1
	local gasSideScale = settings.gasSideScale or 1

	for i = 1,random(1,3) do--side gas
		local part = emitter:Add(mat_smoke,pos + Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1)))
		if part then
			part:SetDieTime(Rand(0.5,1) * timeScale)

			local p = random(200,255)
			part:SetColor(p,p,p)

			part:SetStartAlpha(Rand(25,35) * AlphaMul)
			part.LightFlashMul = 0.5
			part:SetEndAlpha(0)

			part:SetStartSize(Rand(6,8))
			part:SetEndSize(Rand(75,90) * gasSideScale)

			part:SetStartLength(Rand(7,8))
			part:SetEndLength(Rand(45,85) * gasSideScale)

			part:SetAirResistance(Rand(500,750))

            local ang = ang:Clone()
            ang:RotateAroundAxis(ang:Up(),90 + cos(Time * 25) * 7 + cos(Rand(0,100)) * Rand(25,45))
            ang:RotateAroundAxis(ang:Right(),sin(Time * 25) * 7)

			part:SetVelocity(Vector(Rand(75,300),0,0):Rotate(ang):Add(Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1))))
		end

		local part = emitter:Add(mat_smoke,pos + Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1)))
		if part then
			part:SetDieTime(Rand(0.5,1) * timeScale)

			local p = random(200,255)
			part:SetColor(p,p,p)

			part:SetStartAlpha(Rand(25,35) * AlphaMul)
			part.LightFlashMul = 0.5
			part:SetEndAlpha(0)

			part:SetStartSize(Rand(6,8))
			part:SetEndSize(Rand(75,90) * gasSideScale)

			part:SetStartLength(Rand(7,8))
			part:SetEndLength(Rand(45,85) * gasSideScale)

			part:SetAirResistance(Rand(500,750))

            local ang = ang:Clone()
            ang:RotateAroundAxis(ang:Up(),-90 + cos(Time * 25) * 7 + cos(Rand(0,100)) * Rand(25,45))
            ang:RotateAroundAxis(ang:Right(),sin(Time * 25) * 7)

			part:SetVelocity(Vector(Rand(75,300),0,0):Rotate(ang):Add(Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1))))
		end
	end

	local gasForwardScale = settings.gasForwardScale or 1

	for i = 1,random(3,4) do--forward gass
		local part = emitter:Add(mat_smoke,pos - dir:Clone():Mul(12):Add(Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1))))
		if part then
			part:SetDieTime(Rand(0.25,0.5) * timeScale)

			local p = random(200,255)
			part:SetColor(p,p,p)

			part:SetStartAlpha(Rand(25,35) * AlphaMul)
			part:SetEndAlpha(0)

			part:SetStartSize(Rand(6,8))
			part:SetEndSize(Rand(30,45) * gasForwardScale)

            part:SetStartLength(Rand(4,5))
			part:SetEndLength(Rand(55,75) * gasForwardScale)

			part:SetAirResistance(Rand(1000,1750))

            local ang = ang:Clone()
            ang:RotateAroundAxis(ang:Up(),sin(Time * 75 + i) * Rand(0.5,1.5) * 8,0)
            ang:RotateAroundAxis(ang:Right(),cos(Time * 75 + i) * Rand(0.5,1.5) * 3)

			part:SetVelocity(Vector(Rand(255,750),0,0):Rotate(ang):Add(Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1))))
		end
	end

	if self.Shell then
		local gun,isFake = self:GetGun()
		local pos,ang = self:GetRejectShell(gun)

		local dirShell = Vector(1,0,0):Rotate(ang)

		local dirGravity = dir:Clone()
		dirGravity[3] = 0
		dirGravity:Normalize()

		for i = 1,random(3,4) do--shell gass fast
			local part = emitter:Add(mat_smoke,pos - dirShell:Clone():Mul(12):Add(Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1))))
			if part then
				part:SetDieTime(Rand(0.1,0.2) * timeScale)

				local p = random(200,255)
				part:SetColor(p,p,p)

				part:SetStartAlpha(Rand(35,90) * AlphaMul)
				part.LightFlashMul = 0.5
				part:SetEndAlpha(0)

				part:SetStartSize(Rand(6,8))
				part:SetEndSize(Rand(45,55))

				part:SetStartLength(Rand(30,35))
				part:SetEndLength(Rand(35,45))

				part:SetAirResistance(Rand(800,900))

				local ang = ang:Clone()
				ang:RotateAroundAxis(ang:Up(),sin(Time * 75 + i) * Rand(0.5,1.5) * 45,0)
				ang:RotateAroundAxis(ang:Right(),cos(Time * 75 + i) * Rand(0.5,1.5) * 6)

				part:SetVelocity(Vector(Rand(255,400),0,0):Rotate(ang):Add(Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1))))
				part:SetGravity(-dirGravity * 1000)
			end
		end

		for i = 1,random(3,4) do--shell gass
			local part = emitter:Add(mat_smoke,pos + dirShell:Clone():Add(Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1))))
			if part then
				part:SetDieTime(Rand(0.5,1) * timeScale)

				local p = random(200,255)
				part:SetColor(p,p,p)

				part:SetStartAlpha(Rand(25,35) * AlphaMul)
				part.LightFlashMul = 0.5
				part:SetEndAlpha(0)

				part:SetStartSize(Rand(1,2))
				part:SetEndSize(Rand(45,75))

				part:SetRoll(Rand(-1000,1000))

				part:SetAirResistance(Rand(150,250))

				local ang = ang:Clone()
				ang:RotateAroundAxis(ang:Up(),sin(Time * 75 + i) - 25 * Rand(0.9,1.1) + Rand(-25,75))
				ang:RotateAroundAxis(ang:Right(),cos(Time * 75 + i) - 25 * Rand(0.9,1.1) + Rand(-45,45))

				part:SetVelocity(Vector(Rand(95,125),0,0):Rotate(ang):Add(Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1))))
				part:SetGravity(-dirGravity * 250)
			end
		end
	end

	emitter:Finish()
end

//

local hg_volume_shoot = 1
cvars.CreateOption("hg_volume_shoot","1",function(value) hg_volume_shoot = tonumber(value or 1) or 1 end,0,1)

local min,max = math.min,math.max

local TraceLine = util.TraceLine

local distanceFarMain = 4000
local distanceFar = 2000
local distanceMinFar = 500

function SWEP:ShootSound(pos,dir,entIndex)
	local ent = sound.GetEmitEntity(entIndex)//нужно если объект вне зоны pvs, даже если в зоне pvs всеравно его юзаем тк переход между виртуальным и настоящим может навести проблем..
	//например как мы звуки уберём

	ent:SetPos(pos)

	//

	local eyepos = EyePos()
	local dis = pos:Distance(eyepos)

	local snd = self.Primary.Sound
	if TypeID(snd) == TYPE_TABLE then snd = snd[math.random(1,#snd)] end

	local sndFar = self.Primary.SoundFar
	if TypeID(sndFar) == TYPE_TABLE then sndFar = sndFar[math.random(1,#sndFar)] end

	ent:StopSound(snd)

	local pitch = self.Primary.SoundPitch or 100
	local t = 1 - min(dis / distanceFarMain,1)
	sound.Emit(ent,snd,140,Lerp(t,0,hg_volume_shoot),Lerp(t,pitch - 20,pitch),pos)

	local pitch = self.Primary.SoundPitchFar or pitch or 100
	local t = 1 - min(max(dis - distanceMinFar,0) / distanceFar,1)
	sound.Emit(ent,sndFar,140,Lerp(t,hg_volume_shoot,0),Lerp(t,pitch - 20,pitch),pos,nil,nil,nil,eyepos - (eyepos - pos):Mul(0.5))
	
	//

	local ammotype = self.Primary.AmmoDWR or self.Primary.Ammo

	DWR_PlayReverb(pos,ammotype,nil,self)

	if not self.dwr_cracksDisable then
		DWR_PlayBulletCrack(pos,dir,SOUNDSPEED * 6,nil,ammotype)
	end
end

