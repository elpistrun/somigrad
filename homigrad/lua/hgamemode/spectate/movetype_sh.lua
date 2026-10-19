--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/spectate/movetype_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\spectate\\movetype_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
if SERVER then
	concommand.Add("hg_spectate", function(ply, cmd, args)
		if not IsValid(ply) or (ply:Alive() and not ply:GetNWBool("FakeDeath")) then return end

		local targetIdx = tonumber(args[1])
		local target = targetIdx and Entity(targetIdx)

		if IsValid(target) and target:IsPlayer() and target ~= ply and target:Alive() then
			ply:SetNWEntity("HeSpectateOn", target)
			ply:Spectate(OBS_MODE_CHASE)
			ply:SpectateEntity(target)
			ply:SetMoveType(MOVETYPE_OBSERVER)
		else
			ply:SetNWEntity("HeSpectateOn", NULL)
			ply:UnSpectate()
			ply:Spectate(OBS_MODE_ROAMING)
			ply:SetMoveType(MOVETYPE_NOCLIP)
			ply:SetNoDraw(true)
			ply:SetNotSolid(true)
		end
	end)

	concommand.Add("hg_spectate_pos", function(ply, cmd, args)
		if not IsValid(ply) or (ply:Alive() and not ply:GetNWBool("FakeDeath")) then return end
		local x, y, z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
		if x and y and z then
			ply:SetPos(Vector(x, y, z))
		end
	end)
end

local function SpectateMove(ply, mv)
	if not IsValid(ply) then return end
	if ply:Alive() and not ply:GetNWBool("FakeDeath") then return end
	local mt = ply:GetMoveType()
	if mt ~= MOVETYPE_NOCLIP and mt ~= MOVETYPE_OBSERVER then return end
	if (ply:GetNWFloat("DeadStart", 0) + 0.5) > CurTime() then return end

	local move = Vector()

	if mv:KeyDown(IN_FORWARD) then move:Add(Vector(1, 0, 0)) end
	if mv:KeyDown(IN_BACK) then move:Add(Vector(-1, 0, 0)) end
	if mv:KeyDown(IN_MOVERIGHT) then move:Add(Vector(0, -1, 0)) end
	if mv:KeyDown(IN_MOVELEFT) then move:Add(Vector(0, 1, 0)) end

	move:Rotate(ply:EyeAngles())

	if mv:KeyDown(IN_JUMP) then move:Add(Vector(0, 0, 1)) end
	if mv:KeyDown(IN_DUCK) then move:Add(Vector(0, 0, -1)) end

	local speed = 750
	if mv:KeyDown(IN_SPEED) then speed = speed * 2.5 end
	if mv:KeyDown(IN_WALK) then speed = speed / 3 end

	move:Mul(speed * FrameTime())

	mv:SetOrigin(mv:GetOrigin() + move)
	return true
end

event.Add("Move", "Noclip", SpectateMove)
hook.Add("Move", "HG_SpectateNoclip", SpectateMove)

