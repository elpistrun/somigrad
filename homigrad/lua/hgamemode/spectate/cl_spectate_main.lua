--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/spectate/cl_spectate_main.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\spectate\\cl_spectate_main.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local view = {}

local old

local vecFull = Vector(1,1,1)

SpectateVec = EyePos()

local outdistance = 75
local outface,forwardface = 0,0

local watchFace

local function getVehicle(ply,filter)
	if not ply.GetVehicle then return end
	
	local vehicle = ply:GetVehicle()

	if IsValid(vehicle) then
		filter[#filter + 1] = vehicle

		vehicle = vehicle:GetParent()

		if IsValid(vehicle) then
			filter[#filter + 1] = vehicle:GetParent()
		end
	end
end

local closedPlyVec = Vector() -- для плавного перехода

SpectateAng = SpectateAng or Angle(0, 0, 0)


hook.Add("CreateMove", "HG_SpectateCameraMove", function(cmd)
	local ply = LocalPlayer()
	if not IsValid(ply) or ply:Alive() then return end

	-- When dead/spectating, capture and accumulate mouse look angles
	if not SpectateAng then
		SpectateAng = cmd:GetViewAngles()
	else
		local currentAngles = cmd:GetViewAngles()
		if currentAngles ~= angle_zero and currentAngles ~= Angle(0,0,0) then
			SpectateAng = currentAngles
		end
	end
end)

event.Add("PreCalcView","spectate",function(ply,view)
	ply = LocalPlayer()

	if ply:Alive() then outdistance = 75 return end
	
	local func = TableLevel().DisableSpectate
	if func and func(ply,view) ~= false then return end

	local eyeAng = ply:EyeAngles()
	local ang = (SpectateAng or view.ang or view.angles or (eyeAng ~= angle_zero and eyeAng) or Angle()):Clone()
	ang[3] = 0

	local spec = SpecEnt

	view.mulSide = 0.5
	view.drawviewer = false
	DRAWMODEL = nil
	ply:SetHeadScale(false)

	if not IsValid(spec) or IsSpectate == 2 then
		view.noSmooth = true

		if not SpectateVec or SpectateVec == vector_origin then
			SpectateVec = (view.vec and view.vec ~= vector_origin and view.vec:Clone()) or (view.origin and view.origin ~= vector_origin and view.origin:Clone()) or ply:EyePos()
		end

		local move = Vector(0, 0, 0)
		local speed = 800

		local function isDown(in_flag, default_key)
			if ply:KeyDown(in_flag) then return true end
			if default_key and input.IsKeyDown(default_key) then return true end
			return false
		end

		if isDown(IN_SPEED, KEY_LSHIFT) then speed = speed * 2.5 end
		if isDown(IN_WALK, KEY_LALT) then speed = speed * 0.3 end

		local fwd = ang:Forward()
		local right = ang:Right()
		local up = Vector(0, 0, 1)

		if isDown(IN_FORWARD, KEY_W) then move = move + fwd end
		if isDown(IN_BACK, KEY_S) then move = move - fwd end
		if isDown(IN_MOVERIGHT, KEY_D) then move = move + right end
		if isDown(IN_MOVELEFT, KEY_A) then move = move - right end
		if isDown(IN_JUMP, KEY_SPACE) then move = move + up end
		if isDown(IN_DUCK, KEY_LCONTROL) then move = move - up end

		if move:LengthSqr() > 0 then
			move:Normalize()
			SpectateVec = SpectateVec + move * (speed * FrameTime())
		end

		local cur = CurTime()
		if (ply.nextSpecPosSync or 0) < cur then
			ply.nextSpecPosSync = cur + 0.3
			RunConsoleCommand("hg_spectate_pos", tostring(math.Round(SpectateVec.x)), tostring(math.Round(SpectateVec.y)), tostring(math.Round(SpectateVec.z)))
		end

		view.vec = SpectateVec
		view.ang = ang
		view.origin = SpectateVec
		view.angles = ang
		view.znear = 1
		view.fov = FOV
		view.drawviewer = false

		return view
	end

	SpectateVec = spec and (spec:EyePos() or spec:GetPos()) or SpectateVec

	local ent = IsValid(spec:GetNWEntity("Ragdoll")) and spec:GetNWEntity("Ragdoll") or spec

	local dir = Vector(1,0,0):Rotate(ang)
	
	if not LocalPlayer():KeyDown(IN_WALK) and not LocalPlayer():KeyDown(IN_SPEED) then
		outdistance = math.max(outdistance - wheel * 5,0)
	end

	if IsSpectate != 1 then return end
	if outdistance == 0 then
		if not watchFace then
			watchFace = true
			
			ply:ChatPrint(L("spectate_wathface"))
		end

		if BodyCamMode then
			local ent = SpecEnt
	
			ent = ent:GetEntity()

			local headBone = ent:LookupBone("ValveBiped.Bip01_Head1")
			local head = headBone and ent:GetBoneMatrix(headBone)
		
			if head then
				local ang = head:GetAngles()
				ang:RotateAroundAxis(ang:Right(),90)
				ang:RotateAroundAxis(ang:Up(),-90)
				ang:RotateAroundAxis(ang:Forward(),90)
				ang:RotateAroundAxis(ang:Forward(),90)

				view.vec = head:GetTranslation():Add(Vector(5,-5,9):Rotate(ang))
				view.ang = ang
			end
		else
			local func = ent.Spectate2

			if func then
				return func(ent,ply,view)
			else
				if not spec.Eye then return end

				local pos,ang = spec:Eye()

				view.vec = pos
				view.ang = ang
				view.drawviewer = false

				if not override then
					override = true
					event.Run("PreCalcView",spec,view)
					override = nil
				end

				return view
			end
		end
	else
		if watchFace then
			watchFace = nil
			ply:ChatPrint(L("spectate_wath"))
		end

		if outdistance <= 10 then
			if LocalPlayer():KeyDown(IN_SPEED) then outface = outface + wheel / 4 end
			if LocalPlayer():KeyDown(IN_WALK) then forwardface = forwardface + wheel / 4 end

			local tr = {}

			local head = ent:LookupBone("ValveBiped.Bip01_Head1")
			head = head and ent:GetBoneMatrix(head)
	
			tr.start = (head and head:GetTranslation() or (ent:GetPos() + ent:OBBCenter())) + Vector(0,0,5 + forwardface)
			tr.endpos = tr.start + Vector(0,-12 + outface,0):Rotate(head and head:GetAngles() or Angle())

			local filter = {}
			filter[ply] = true
			getVehicle(ent,filter)
			tr.filter = function(ent) return filter[ent] end

			view.vec = util.TraceLine(tr).HitPos
			view.ang = view.ang + (tr.start - tr.endpos):Angle()
			view.fov = 150
			view.znear = 0.1
			view.drawviewer = false
		else
			local tr = {}

			local func = ent.Spectate1

			if func then
				return func(ent,ply,view)
			else
				ent:SetupBones()
				
				local head = ent:LookupBone("ValveBiped.Bip01_Head1")
				head = head and  ent:GetBoneMatrix(head)
		
				tr.start = head and head:GetTranslation() or (ent:GetPos() + ent:OBBCenter())
				tr.endpos = tr.start - dir * (outdistance)
				local filter = {}
				filter[ply] = true
				getVehicle(ent,filter)
				tr.filter = function(ent) return filter[ent] end

				if ent.SpectateFunc then ent:SpectateFunc(view) end

				view.vec = util.TraceLine(tr).HitPos
				view.ang = ang
			end

			view.vec:Add(closedPlyVec)
			closedPlyVec:LerpFT(0.5)
			view.drawviewer = false
			
			return view
		end
	end
end)

--

local oldKeyWalk

local oldNext
local oldBack

local function SetSpectate(ply)
	SpecEnt = ply

	if IsSpectate == 2 then
		ViewEntity = ply
	else
		ViewEntity = nil
	end

	if ply then
		if IsValid(ply) then
			RunConsoleCommand("hg_spectate",tostring(ply:EntIndex()))
		end
	else
		ViewEntity = nil
		
		RunConsoleCommand("hg_spectate")
	end
end

IsSpectate = 1

local function getClosedPly(tbl)
	local closedPly

	for i,ply in pairs(tbl) do
		if not closedPly then closedPly = ply continue end

		local dis = EyePos():Distance(ply:GetPos())

		if closedPly:GetPos():Distance(EyePos()) > dis then
			closedPly = ply
		end
	end

	return closedPly
end

hook.Add("Think","Spectate",function()
	local ply = LocalPlayer()
	if ply:Alive() then IsSpectate = 2 SpecEnt = nil return end

	if (InWindowTime or 0) + 0.25 > CurTime() then return end

	local key = ply:KeyDown(IN_RELOAD)

	if hook.Run("Lock R Spectate") == nil then
		if key ~= oldKeyWalk and key then
			if IsSpectate == 1 then
				IsSpectate = 2 -- свободный полёт
				SpectateVec = (SpecEnt and IsValid(SpecEnt) and (SpecEnt:EyePos() or SpecEnt:GetPos())) or SpectateVec or EyePos()
				SetSpectate()
				ply:ChatPrint(L("spectate_fly"))
			else
				IsSpectate = 1 -- наблюдение за игроком
				outdistance = 75
			end
		end
	end
	
	oldKeyWalk = key

	local tbl = {}

	for i,ply in pairs(player.GetAll()) do
		if not ply:Alive() then continue end

		tbl[#tbl + 1] = ply
	end

	if IsSpectate == 2 then
		local next, back = ply:KeyPressed(IN_ATTACK), ply:KeyPressed(IN_ATTACK2)
		if (next or back) and #tbl > 0 then
			IsSpectate = 1
			outdistance = 75
			local closedPly = getClosedPly(tbl)
			if closedPly then
				closedPlyVec = EyePos() - closedPly:EyePos()
				SetSpectate(closedPly)
			end
			return
		end
	elseif IsSpectate == 1 then
		if ActiveLevel then
			local func = ActiveLevel.SpectateNext
			if func and func(ActiveLevel,tbl) == false then return end
		end
		
		if #tbl == 0 then SpecEnt = nil return end

		if not IsValid(SpecEnt) or (SpecEnt.Alive and not SpecEnt:Alive()) then
			local closedPly = getClosedPly(tbl)

			if not closedPly then
				IsSpectate = 2 -- свободный полёт
				SetSpectate()
				ply:ChatPrint(L("spectate_fly"))
			else
				closedPlyVec = EyePos() - closedPly:EyePos()
				SetSpectate(closedPly)
			end
		end

		local next,back = ply:KeyDown(IN_ATTACK),ply:KeyDown(IN_ATTACK2)

		if oldNext ~= next and next then
			for i,ply in pairs(tbl) do
				if ply == SpecEnt then
					SetSpectate(tbl[(i + 1 > #tbl and 1) or (i + 1)])

					break
				end
			end
		end

		if oldBack ~= back and back then
			for i,ply in pairs(tbl) do
				if ply == SpecEnt then	
					SetSpectate(tbl[(i - 1 < 0 and #tbl) or (i - 1)])

					break
				end
			end
		end

		oldNext = next
		oldBack = back
	end
end)

hook.Add("PrePlayerDraw","SpectateFace",function(ply)
	if IsSpectate == 2 and ply == SpecEnt and (SpecEnt:EyeMode() or ply:InVehicle()) then return true end
end)
