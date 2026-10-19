--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/metabolism/stamina_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\metabolism\\stamina_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local max = math.max

if SERVER then
	util.AddNetworkString("breath")
	util.AddNetworkString("cough")

	hook.Add("PlayerSpawn","HomigradStaminaInit",function(ply)
		ply.stamina = 100
		ply.staminamul = 1
		ply.pulse = 1 / 80
		ply.nextStaminaBreath = 0
		ply.breathModeToggle = false
		ply:SetNWFloat("stamina",100)
		ply:SetNWFloat("staminamul",1)
		ply:SetNWFloat("pulse",1 / 80)
	end)

	event.Add("Start Round","HomigradStaminaRoundReset",function()
		for _,ply in ipairs(player.GetAll()) do
			ply.stamina = 100
			ply.staminamul = 1
			ply.pulse = 1 / 80
			ply.nextStaminaBreath = 0
			ply.breathModeToggle = false
			ply:SetNWFloat("stamina",100)
			ply:SetNWFloat("staminamul",1)
			ply:SetNWFloat("pulse",1 / 80)
		end
	end)

	hook.Add("KeyPress","HomigradStaminaJump",function(ply,key)
		if key == IN_JUMP and ply:Alive() and ply:IsOnGround() and not (ply.InFake and ply:InFake()) then
			local stopStamina = ply.stopStamina
			if stopStamina == nil and ply.GetPlayerClass then
				local pClass = ply:GetPlayerClass()
				if istable(pClass) then stopStamina = pClass.stopStamina end
			end
			if not stopStamina then
				local mul = ply.mulStamina or 1
				local drain = 3.5 * mul
				ply.stamina = math.max((ply.stamina or 100) - drain,0)
				ply:SetNWFloat("stamina",math.Round(ply.stamina,1))
			end
		end
	end)

	local lastTick = CurTime()
	hook.Add("Think","HomigradStaminaThink",function()
		local curTime = CurTime()
		local dt = math.Clamp(curTime - lastTick,0.01,0.1)
		lastTick = curTime

		for _,ply in ipairs(player.GetAll()) do
			if not ply:Alive() then continue end

			if ply.stamina == nil then ply.stamina = 100 end
			if ply.staminamul == nil then ply.staminamul = 1 end

			local stopStamina = ply.stopStamina
			if stopStamina == nil and ply.GetPlayerClass then
				local pClass = ply:GetPlayerClass()
				if istable(pClass) then stopStamina = pClass.stopStamina end
			end
			if stopStamina == nil and isfunction(ply.PlayerClassEvent) then
				stopStamina = ply:PlayerClassEvent("StopStamina")
			end
			stopStamina = not not stopStamina

			local mulStamina = ply.mulStamina
			if mulStamina == nil and ply.GetPlayerClass then
				local pClass = ply:GetPlayerClass()
				if istable(pClass) then mulStamina = pClass.mulStamina end
			end
			mulStamina = mulStamina or 1

			local inFake = ply.InFake and ply:InFake()

			if inFake then
				local rag = ply.GetDummy and ply:GetDummy() or ply:GetNWEntity("FakeRagdoll")
				local moving = false
				if IsValid(rag) then
					local vel = rag:GetVelocity():LengthSqr()
					if vel > 2500 then moving = true end
				end

				if moving and not stopStamina then
					ply.stamina = math.max(ply.stamina - 1 * dt * mulStamina,0)
				else
					ply.stamina = math.min(ply.stamina + 8 * dt,100)
				end
			else
				local vel = ply:GetVelocity():Length2D()
				local onGround = ply:IsOnGround()
				local isSprinting = ply:KeyDown(IN_SPEED) and vel > 125 and onGround and not ply:Crouching()

				if isSprinting and not stopStamina then
					local drain = 7.5 * dt * mulStamina
					ply.stamina = math.max(ply.stamina - drain,0)
				else
					local regen = 8
					if ply:Crouching() then
						regen = 18
					elseif vel < 15 then
						regen = 14
					else
						regen = 8
					end

					local adr = ply:GetNWFloat("adrenaline",0)
					regen = regen * (1 + adr * 0.4)

					ply.stamina = math.min(ply.stamina + regen * dt,100)
				end
			end

			-- Stamina multiplier for movement speed
			local stamMul = 1
			if ply.stamina < 15 then
				stamMul = math.Clamp(0.75 + (ply.stamina / 15) * 0.25,0.75,1)
			end
			ply.staminamul = stamMul

			-- Pulse calculation (seconds per beat: 1 / BPM)
			local isDeadOrStopped = ply.heartstop or ply.HeadPop or ply.isDead or ply:GetNWBool("heartstop",false) or ply:GetNWBool("isDead",false) or ply:GetNWBool("HeadPop",false) or (ply.blood and ply.blood <= 0) or (not ply:Alive())
			if isDeadOrStopped then
				ply.pulse = 0
			else
				local targetBpm = 70 + (1 - ply.stamina / 100) * 65 + (ply:GetNWFloat("adrenaline",0) * 25)
				local curBpm = 1 / ((ply.pulse and ply.pulse > 0) and ply.pulse or (1 / 75))
				curBpm = Lerp(dt * 1.5,curBpm,targetBpm)
				ply.pulse = 1 / math.Clamp(curBpm,50,200)
			end

			-- Breathing sound trigger when stamina is low
			if not isDeadOrStopped and ply.stamina < 30 and curTime > (ply.nextStaminaBreath or 0) then
				local delay = math.Clamp(0.4 + (ply.stamina / 30) * 0.4,0.4,0.8)
				ply.nextStaminaBreath = curTime + delay
				ply.breathModeToggle = not ply.breathModeToggle

				net.Start("breath")
				net.WriteEntity(ply)
				net.WriteString(tostring(math.Round(delay,2)))
				net.WriteBool(ply.breathModeToggle)
				net.SendPVS(ply:GetPos())
			end

			if (ply.nextStamSync or 0) <= curTime then
				ply.nextStamSync = curTime + 0.1
				ply:SetNWFloat("stamina",math.Round(ply.stamina,1))
				ply:SetNWFloat("staminamul",math.Round(ply.staminamul,2))
				ply:SetNWFloat("pulse",ply.pulse or 0)
				local rag = ply.GetDummy and ply:GetDummy() or ply:GetNWEntity("FakeRagdoll")
				if IsValid(rag) then
					rag:SetNWFloat("pulse", ply.pulse or 0)
				end
			end
		end
	end)
end

event.Add("Move","Homigrad Stamina",function(ply,mv)
	if not ply:Alive() then return end

	local stam = ply:GetNWFloat("stamina",100)
	local mul = ply:GetNWFloat("staminamul",1)

	if stam <= 3 and mv:KeyDown(IN_SPEED) then
		mul = mul * 0.8
	end

	local maxspeed = mv:GetMaxSpeed() * mul

	mv:SetMaxSpeed(maxspeed)
	mv:SetMaxClientSpeed(maxspeed)
end)

local pulseStart = 0

hook.Add("RenderScreenspaceEffects","Stamina",function()
	local ply = LocalPlayer()
	if not ply:Alive() or ply:GetNWBool("Otrub") then return end

	local pulse = 1 / ply:GetNWFloat("pulse",1 / 80)

	local k = math.max(pulse - 80,0) / 80
	k = k + math.Clamp(-pulse + 60,0,40) / 60

	local time = RealTime()

	if k <= 0 then return end

	if pulseStart + 1 / pulse * 60 < time then
		pulseStart = time 

		LocalPlayer():EmitSound("snd_jack_hmcd_heartpound.wav",75,100,math.min(k,0.25))

		if k > 0.2 then
			LocalPlayer():ViewPunch(Angle(-0.25 * k,0,0))
		end
	end
	
	if hook.Run("Should Draw Screenspace") == false then return end
end)

if CLIENT then
	local stamColor = Color(220,220,220,200)
	local stamBg = Color(30,30,30,160)
	local stamLow = Color(200,60,60,220)
	local stamAlpha = 0

	hook.Add("HUDPaint","HomigradStaminaHUD",function()
		local ply = LocalPlayer()
		if not ply:Alive() or ply:GetNWBool("Otrub") then return end
		if hook.Run("HUDShouldDraw","HomigradStamina") == false then return end

		local stam = ply:GetNWFloat("stamina",100)
		local targetAlpha = (stam < 95 or ply:KeyDown(IN_SPEED)) and 1 or 0
		stamAlpha = Lerp(FrameTime() * 4,stamAlpha,targetAlpha)
		if stamAlpha <= 0.01 then return end

		local w,h = 160,8
		local x = 40
		local y = ScrH() - 60

		surface.SetDrawColor(stamBg.r,stamBg.g,stamBg.b,stamBg.a * stamAlpha)
		surface.DrawRect(x,y,w,h)

		local col = stam < 25 and stamLow or stamColor
		surface.SetDrawColor(col.r,col.g,col.b,col.a * stamAlpha)
		surface.DrawRect(x + 1,y + 1,(w - 2) * math.Clamp(stam / 100,0,1),h - 2)
	end)
end


