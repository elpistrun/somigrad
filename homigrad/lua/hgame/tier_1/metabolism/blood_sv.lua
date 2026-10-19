if CLIENT then return end

local nextBleedTick = 0

hook.Add("Think", "Homigrad_BleedSystem", function()
	local curTime = CurTime()
	if curTime < nextBleedTick then return end
	nextBleedTick = curTime + 0.65

	for _, ply in ipairs(player.GetAll()) do
		if not IsValid(ply) or not ply:Alive() or ply.isDead or ply:GetNWBool("isDead", false) then continue end

		local bleed = ply:GetNWFloat("bleed", 0)
		local blood = ply.blood or ply:GetNWFloat("blood", 5000)

		if bleed > 0 then
			local loss = math.min(bleed * 1.6, blood)
			blood = math.max(0, blood - loss)
			ply.blood = blood
			ply:SetNWFloat("blood", blood)

			-- Gradual clotting
			bleed = math.max(0, bleed - 0.12)
			ply.bleed = bleed
			ply:SetNWFloat("bleed", bleed)

			-- Drip blood particles & decals
			local inFake = ply.Fake or ply:GetNWBool("fake", false) or (ply.InFake and ply:InFake())
			local rag = inFake and (ply.GetDummy and ply:GetDummy() or ply:GetNWEntity("FakeRagdoll")) or nil
			local emitEnt = IsValid(rag) and rag or ply
			local pos = emitEnt:WorldSpaceCenter() + VectorRand() * 6

			if bleed >= 20 and util.NetworkStringToID("bleed artery") ~= 0 then
				net.Start("bleed artery")
				net.WriteVector(pos)
				net.WriteVector(Vector(math.Rand(-15, 15), math.Rand(-15, 15), -40))
				net.SendPVS(pos)
			elseif util.NetworkStringToID("blood particle") ~= 0 then
				net.Start("blood particle")
				net.WriteVector(pos)
				net.WriteVector(Vector(math.Rand(-10, 10), math.Rand(-10, 10), -25))
				net.SendPVS(pos)
			end

			-- Blood puddle / floor decal
			local trDown = util.TraceLine({
				start = pos,
				endpos = pos - Vector(0, 0, 75),
				filter = {ply, rag}
			})
			if trDown.Hit then
				util.Decal("Blood", trDown.HitPos + trDown.HitNormal * 2, trDown.HitPos - trDown.HitNormal * 16)
			end

			-- Low blood physiological effects
			if blood <= 3500 then
				ply.pain = (ply.pain or 0) + 1
				ply:SetNWFloat("pain", ply.pain)
			end

			if blood <= 2500 and not ply:GetNWBool("Otrub", false) then
				ply:SetNWBool("Otrub", true)
			end

			if blood <= 1500 and not inFake then
				if Faking then
					Faking(ply)
				elseif ply.EnterFake then
					ply:EnterFake()
				end
			end

			if blood <= 0 then
				ply.heartstop = true
				ply:SetNWBool("heartstop", true)
				ply.isDead = true
				ply:SetNWBool("isDead", true)
				ply:SetNWBool("Alive", false)
				ply:SetNWBool("FakeDeath", true)
				ply.pulse = 0
				ply:SetNWFloat("pulse", 0)
				if IsValid(rag) then
					rag:SetNWFloat("pulse", 0)
				end
				ply.LastDmg = {
					reasons = { blood = true, bleed = true },
					target = ply,
					att = ply,
					weapon = "bleed",
					boneName = "body",
					killedBy = "bleed",
					killedTargetName = "Bleed Out"
				}
				ply:Kill()
			end
		end
	end
end)
