--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/fake/cl_fake.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\fake\\cl_fake.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local vec = Vector(1,1,1)

hook.Add("InitPostEntity","PlyColor",function()
    matproxy.Add({
        name = "PlayerColor",
        init = function(self,mat,values)
            self.ResultTo = values.resultvar or "$color"
        end,
        bind = function(self,mat,ent)
            mat:SetVector(self.ResultTo,(IsValid(ent) and ent.GetPlayerColor and ent:GetPlayerColor()) or vec)
       end 
    })
end)

//

event.Add("PlayerDraw","FakeDontRender",function(ply)
    if ply:GetNWBool("fake") then return false end
end,-10)

event.Add("Player Spawn","Other",function(ply)
	ply:AddEFlags(EFL_NO_DAMAGE_FORCES)
	ply:RemoveAllDecals()
end)

RagdollEntities = RagdollEntities or {}

hook.Add("OnEntityCreated","RagdollFake",function(ent)
    if not IsValid(ent) or ent:GetClass() != "prop_ragdoll" then return end

    ent:SetNWVarProxy("IsFakeRagdoll",function(_,_,_,value)
        if not value or ent.fakeSetup then return end
        ent.fakeSetup = true

        for k,v in pairs(oop.listClass["fake_ragdoll"][1]) do ent[k] = v end
    
        ent:Initialize()
        ent.RenderOverride = function() ent:Draw() end

        RagdollEntities[ent] = true
        ent:CallOnRemove("RagdollEntities",function() RagdollEntities[ent] = nil end)
    end)
end)

net.Receive("fake",function() LocalPlayer():SetNWEntity("Ragdoll",Entity(net.ReadInt(16))) end)
net.Receive("fake up",function()
	local ply = LocalPlayer()
	if IsValid(ply) then
		ply:SetNWEntity("Ragdoll",NULL)
		ply:SetNoDraw(false)
	end
end)
net.Receive("ragplayercolor",function()
	local ent = net.ReadEntity()
	local col = net.ReadVector()
	if IsValid(ent) then
		ent:SetNWVector("PlayerColor",col)
		ent.GetPlayerColor = function() return col end
	end
end)

//

local delays = {}

event.Add("Death","RemoveNPClientRagdoll",function(dmgTab)
    local ent = dmgTab.target

    if not IsValid(ent) or not ent:IsNPC() then return end

    local pos = ent:GetPos()
    local mdl = ent:GetModel()

    delays[#delays + 1] = {mdl,pos,RealTime() + 1}
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

local math_hand1 = Material("icon32/hand_point_180.png")
local math_hand2 = Material("icon32/hand_point_090.png")

local Clamp = math.Clamp

hook.Add("HUDPaint","Fake",function()
    local ply = LocalPlayer()
    if not ply:GetNWBool("Fake") then return end

    surface.SetDrawColor(255,255,255,255)

    local rag = ply:GetNWEntity("Ragdoll")
    if not IsValid(rag) then return end
    
    local w,h = ScrW(),ScrH()

    if ply:GetNWBool("LeftArm") then
        local hand = rag:GetBonePosition(rag:LookupBone("ValveBiped.Bip01_L_Hand"))
        local pos = hand:ToScreen()
        pos.x = Clamp(pos.x,w / 2 - w / 4,w / 2 + w / 4)
        pos.y = Clamp(pos.y,h / 2 - h / 4,h / 2 + h / 4)

        surface.SetMaterial(math_hand2)
        surface.DrawTexturedRectRotated(pos.x,pos.y,64,64,-90 + 25)
    end

    if ply:GetNWBool("RightArm") then
        local hand = rag:GetBonePosition(rag:LookupBone("ValveBiped.Bip01_R_Hand"))
        local pos = hand:ToScreen()
        pos.x = Clamp(pos.x,w / 2 - w / 4,w / 2 + w / 4)
        pos.y = Clamp(pos.y,h / 2 - h / 4,h / 2 + h / 4)

        surface.SetMaterial(math_hand1)
        surface.DrawTexturedRectRotated(pos.x,pos.y,-64,-64,180 - 25)
    end

    local wep = ply:GetActiveWeapon()

    local pos = EyePos() + ply:EyeAngles():Forward() * 8000
    pos = pos:ToScreen()

    pos.x = Clamp(pos.x,w / 2 - w / 3,w / 2 + w / 3)
    pos.y = Clamp(pos.y,h / 2 - h / 3,h / 2 + h / 3)
    
    local dis = math.Distance(pos.x,pos.y,w / 2,h / 2) / (h / 2)

    local a = 25 + dis * 255

    local size = math.max(dis * 32,6)

    if IsValid(wep) and wep:GetClass() ~= "weapon_hands" then a = a * 0.35 end
end)

cvars.CreateReplicateOption("hg_fake_always_e","1")

hook.Add("HandlePlayerSwimming","!Remove",function()
    return false
end)
