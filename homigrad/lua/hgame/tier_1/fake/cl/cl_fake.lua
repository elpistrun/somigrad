local lply = LocalPlayer()

hook.Add("PlayerFootstep", "CustomFootstep", function(ply)
	if IsValid(ply.FakeRagdoll) then return true end
end)

event.Add("RenderLocalPlayerHead", "FakeHideHead", function(ply)
	if IsValid(ply) and ply:GetNWBool("Fake") then return true end
end)

hook.Add("Player Think", "Player_Fake", function(ply, time)
	ply.Fake = ply:GetNWBool("Fake")
	ply.FakeRagdoll = ply:GetNWEntity("FakeRagdoll")

	local framework = rawget(_G, "hg")
	if not framework or not framework.GetCurrentCharacter then return end

	local ent = framework.GetCurrentCharacter(ply)
	if not IsValid(ent) or not ent.IsRagdoll or not ent:IsRagdoll() then return end
	if not framework.bone or not framework.bone.Set then return end

	local function setFingers(side, angle, speed)
		framework.bone.Set(ent, side .. "_finger0", Vector(0, 0, 0), Angle(0, angle == 20 and 20 or 0, 0), 1, speed)
		framework.bone.Set(ent, side .. "_finger01", Vector(0, 0, 0), Angle(0, angle == 20 and 20 or 0, 0), 1, speed)
		framework.bone.Set(ent, side .. "_finger1", Vector(0, 0, 0), Angle(0, angle == 20 and -40 or 0, 0), 1, speed)
		framework.bone.Set(ent, side .. "_finger11", Vector(0, 0, 0), Angle(0, angle == 20 and -80 or 0, 0), 1, speed)
		framework.bone.Set(ent, side .. "_finger2", Vector(0, 0, 0), Angle(0, angle == 20 and -40 or 0, 0), 1, speed)
		framework.bone.Set(ent, side .. "_finger21", Vector(0, 0, 0), Angle(0, angle == 20 and -80 or 0, 0), 1, speed)
	end

	setFingers("l", ply:GetNWBool("LeftArm") and 20 or 0, ply:GetNWBool("LeftArm") and 0.2 or 0.1)
	setFingers("r", ply:GetNWBool("RightArm") and 20 or 0, ply:GetNWBool("RightArm") and 0.2 or 0.1)
end)

hook.Add("Think", "Homigrad_Ragdoll_Color", function()
	for _, ent in ipairs(ents.FindByClass("prop_ragdoll")) do
		if not IsValid(ent) or not ent:IsRagdoll() then continue end
		if ragdollManager and ragdollManager.entities and ragdollManager.entities[ent] then continue end
		if not ent:GetNWVector("PlayerColor") then continue end
		if ent.hgColorOverride then continue end

		ent.hgColorOverride = true
		ent.GetPlayerColor = function(self)
			return self:GetNWVector("PlayerColor")
		end
	end
end)

hook.Add("HUDPaint", "Shit123", function()
	local framework = rawget(_G, "hg")
	lply = LocalPlayer()
	if not framework or not framework.GetPhrase or not IsValid(lply) then return end
	if ROUND_NAME == "dr" and lply:GetNWBool("Fake") and lply:Alive() then
		draw.SimpleText(string.format(framework.GetPhrase("dr_youwilldiein"), math.Clamp(math.Round(lply:GetNWFloat("TimeToDeath") - CurTime(), 1), 0, 100000)), "H.25", ScrW() / 2, ScrH() / 1.5, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end)
