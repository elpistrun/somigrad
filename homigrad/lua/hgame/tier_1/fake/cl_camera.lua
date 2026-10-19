--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/fake/cl_camera.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\fake\\cl_camera.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local vecZero = Vector(0.01,0.01,0.01)
local vecFull = Vector(1,1,1)

event.Add("PreCalcView","Ragdoll",function(ply,view)
	local rag = ply:GetNWEntity("Ragdoll")
	if not IsValid(rag) then rag = ply:GetNWEntity("DeathRagdoll") end
	if not IsValid(rag) then rag = ply:GetNWEntity("FakeRagdoll") end

	if ply:Alive() and IsValid(rag) and (ply:GetNWBool("fake", false) or ply:GetNWBool("Fake", false)) then
		view.noSmooth = true

		local pos,ang = ply:Eye()

		local head = rag:LookupBone("ValveBiped.Bip01_Head1")
		if head then
			rag:SetHeadScale(true)//DRAWMODEL

			head = head and rag:GetBoneMatrix(head)

			if head then
				local headAng = head:GetAngles():Clone()
                headAng:RotateAroundAxis(headAng:Up(),90)
                headAng:RotateAroundAxis(headAng:Right(),180)
                headAng:RotateAroundAxis(headAng:Forward(),90)

				ang:Lerp(math.min(math.max(rag:GetVelocity():Length() / 512 - 0.25,0) / 0.75,1),headAng)
			end

			//pos = pos + Vector(-75,0,0):Rotate(ang)

			view.vec = pos
			view.ang = ang
			view.origin = pos
			view.angles = ang
			view.drawviewer = true

			if ply:EyeMode() then
				return view
			end
		end
	end
end,-10)
