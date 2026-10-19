-- Client-only file: it binds a key and reasons about the local player, neither of which
-- exists on the server. The loader hands a _cl file to AddCSLuaFile instead of running it
-- on the server (and now really does -- see shlib/loader.lua), but a single mistake in
-- that dispatch must not turn into a dead server boot: this file used to throw
-- "attempt to index global 'keyboard' (a nil value)" from its first line on the server and
-- take every file the loader had not reached yet with it. State the realm you need.
if not CLIENT then return end

-- keyboard exists on the client, but not every build exposes DefaultBindCode.
if keyboard and keyboard.DefaultBindCode then keyboard.DefaultBindCode("fake",30,true) end

local nextFakeCmd = 0
concommand.Add("fake",function()
	local ply = LocalPlayer()
	local serverCd = IsValid(ply) and ply:GetNWFloat("NextFakeToggle", 0) or 0
	if CurTime() < nextFakeCmd or CurTime() < serverCd then return end
	nextFakeCmd = CurTime() + 0.5
	net.Start("fake")
	net.SendToServer()
end)

event.Add("Player Spawn","Other",function(ply)
	ply:AddEFlags(EFL_NO_DAMAGE_FORCES)
	ply:RemoveAllDecals()
end)

//

local delays = {}

event.Add("Death","RemoveNPClientRagdoll",function(dmgTab)
    local ent = dmgTab.target

    if not IsValid(ent) or not ent:IsNPC() then return end

    local pos = ent:GetPos()
    local mdl = ent:GetModel()

    delays[#delays + 1] = {mdl,pos,RealTime() + LocalPlayer():Ping() + 0.05}
end)

hook.Add("Think","RemoveNPCClientRagdoll",function()
    local time = RealTime()
    
    for id,info in pairs(delays) do
        local mdl = info[1]

        for i,ent in pairs(ents.FindInSphere(info[2],128)) do
            if ent:GetClass() == "class C_ClientRagdoll" and ent:GetModel() == mdl then ent:Remove() end
        end

        if info[3] < time then delays[id] = nil continue end
    end
end)

//

local Clamp = math.Clamp

local function loadHandMat(path,fallback)
    local mat = Material(path)
    if mat and not mat:IsError() then return mat end
    return Material(fallback)
end

local matHandR = loadHandMat("icon32/hand_point_180.png","icon16/arrow_right.png")
local matHandL = loadHandMat("icon32/hand_point_090.png","icon16/arrow_left.png")

local function fakeRag(ply)
    if ply.GetDummy then
        local dummy = ply:GetDummy()
        if IsValid(dummy) and dummy ~= ply then return dummy end
    end
    local rag = ply:GetNWEntity("FakeRagdoll")
    if IsValid(rag) then return rag end
    rag = ply:GetNWEntity("Ragdoll")
    if IsValid(rag) then return rag end
    rag = ply:GetNWEntity("DeathRagdoll")
    if IsValid(rag) then return rag end
end

local function drawGrabHand(rag,boneName,mat,rot)
    local bone = rag:LookupBone(boneName)
    if not bone or bone < 0 then return end
    local handPos = rag:GetBonePosition(bone)
    if not handPos then return end
    local pos = handPos:ToScreen()
    local w,h = ScrW(),ScrH()
    pos.x = Clamp(pos.x,w / 2 - w / 4,w / 2 + w / 4)
    pos.y = Clamp(pos.y,h / 2 - h / 4,h / 2 + h / 4)
    surface.SetMaterial(mat)
    surface.DrawTexturedRectRotated(pos.x,pos.y,64,64,rot)
end

hook.Add("HUDPaint","Fake",function()
    local ply = LocalPlayer()
    if not ply:GetNWBool("Fake") and not ply:GetNWBool("fake") then return end
    if GetViewEntity() ~= ply then return end

    local rag = fakeRag(ply)
    if not IsValid(rag) then return end

    surface.SetDrawColor(255,255,255,255)

    if ply:GetNWBool("LeftArm") then
        drawGrabHand(rag,"ValveBiped.Bip01_L_Hand",matHandL,-65)
    end
    if ply:GetNWBool("RightArm") then
        drawGrabHand(rag,"ValveBiped.Bip01_R_Hand",matHandR,155)
    end
end)

hook.Add("PrePlayerDraw","HG Fake Hide",function(ply)
    if not IsValid(ply) then return end
    if ply:GetNWBool("fake") or ply:GetNWBool("Fake") then return true end
end)

cvars.CreateReplicateOption("hg_ragdoll_always_e","0")
cvars.CreateReplicateOption("hg_ragdoll_cave_spine","0")

local function sendRagdollOpts()
    local always = GetConVar("hg_ragdoll_always_e")
    local cave = GetConVar("hg_ragdoll_cave_spine")
    pcall(function()
        net.Start("hg_fake_opts")
        net.WriteBool(not always or always:GetBool())
        net.WriteBool(cave and cave:GetBool() or false)
        net.SendToServer()
    end)
end

cvars.AddChangeCallback("hg_ragdoll_always_e",function() sendRagdollOpts() end,"hg_fake_opts")
cvars.AddChangeCallback("hg_ragdoll_cave_spine",function() sendRagdollOpts() end,"hg_fake_opts")
hook.Add("InitPostEntity","HG Fake Opts",function()
    if cookie.GetNumber("hg_cave_spine_default_off",0) == 0 then
        cookie.Set("hg_cave_spine_default_off","1")
        RunConsoleCommand("hg_ragdoll_cave_spine","0")
    end
    if cookie.GetNumber("hg_always_e_homigrad_off",0) == 0 then
        cookie.Set("hg_always_e_homigrad_off","1")
        RunConsoleCommand("hg_ragdoll_always_e","0")
    end
    timer.Simple(1,sendRagdollOpts)
end)

hook.Add("HandlePlayerSwimming","!Remove",function()
    return false
end)

hook.Remove("HUDPaint", "Fake_Cooldown_HUD")