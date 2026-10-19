FindMetaTable("Player").InFakeDeath = function(self) return self:GetNWBool("FakeDeath") end

if SERVER then
	util.AddNetworkString("death")

	hook.Add("PlayerDeath","HG DeathScreen",function(ply,inf,att)
		if IsValid(ply) then
			ply.pulse = 0
			ply:SetNWFloat("pulse",0)
			ply.heartstop = true
			ply:SetNWBool("heartstop",true)
		end
		timer.Simple(0.05,function()
			if not IsValid(ply) then return end
			if ply.hgDeathScreenSent then
				ply.hgDeathScreenSent = nil
				return
			end

			local dmgTab = istable(ply.LastDmg) and ply.LastDmg or {}
			dmgTab.target = ply
			dmgTab.att = IsValid(att) and att or ply
			dmgTab.weapon = inf
			dmgTab.reasons = dmgTab.reasons or {}
			if IsValid(att) and att == ply then
				dmgTab.reasons.killyourself = true
				dmgTab.killedBy = "player"
				dmgTab.killedTargetName = ply:Name()
			elseif IsValid(att) and att:IsPlayer() then
				dmgTab.killedBy = "player"
				dmgTab.killedTargetName = att:Name()
			end

			local rag = ply:GetNWEntity("FakeRagdoll")
			if not IsValid(rag) then rag = ply.FakeRagdoll or ply:GetNWEntity("DeathRagdoll") end
			if not IsValid(rag) then rag = ply:GetRagdollEntity() end
			dmgTab.ragEntIndex = IsValid(rag) and rag:EntIndex() or 0

			net.Start("death")
			net.WriteTable(dmgTab)
			net.Broadcast()
		end)
	end)

	hook.Add("PlayerSpawn","HG DeathScreen",function(ply)
		ply.hgDeathScreenSent = nil
	end)

	return
end

local oldValue
local fadeStart = 0
local white = Color(255,255,255)

hook.Add("HUDPaint","FakeDeath",function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end
    
    local active = ply:InFakeDeath()

    if oldValue ~= active then
        oldValue = active
        fadeStart = RealTime()
    end

    if not ply:Alive() or not ply:InFake() then return end

    local k = math.max(fadeStart - RealTime() + 3,0) / 3
    k = math.min(k * 10,1)

    if active and ply:Alive() and not ply.isDead and not ply:GetNWBool("isDead",false) and ply:Health() > 0 then
        if ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK) or ply:KeyDown(IN_LEFT) or ply:KeyDown(IN_RIGHT) then
            RunConsoleCommand("fake_dead","0")
        end
    end
    
    if k <= 0 then return end

    white.a = 255 * k

    draw.SimpleText(active and "FAKE DEATH" or "ALIVE","HS.25",ScrW() / 2,ScrH() * 0.9,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
end)