--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_2_world/sound/dwr/init_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_2_world\\sound\\dwr\\init_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local MASK_GLOBAL = CONTENTS_WINDOW + CONTENTS_SOLID + CONTENTS_MONSTERCLIP + CONTENTS_CURRENT_0
local previousAmmo = 0
local previousWep = NULL
local blacklist = {}
local serverBlacklist = {}

local function applySettingsToDSP(ply, cmd, args)
	print("snd_pitchquality 1;")
	print("snd_disable_mixer_duck 0;")
	print("snd_surround_speakers 1;")
	print("dsp_enhance_stereo 1;")
	print("dsp_slow_cpu 0;")
	print("snd_spatialize_roundrobin 0;")
	print("dsp_room 1;")
	print("dsp_water 14;")
	print("dsp_spatial 40;")
	print("snd_defer_trace 0")
end

concommand.Add("cl_dwr_show_dsp_settings", applySettingsToDSP, nil, "Show the best dsp/sound settings for better experience")

concommand.Add("cl_dwr_check_contents", function(ply, cmd, args)
	local contents = {
		["_EMPTY"] = CONTENTS_EMPTY,
		["_SOLID"] = CONTENTS_SOLID,
		["_WINDOW"] = CONTENTS_WINDOW,
		["_AUX"] = CONTENTS_AUX,
		["_GRATE"] = CONTENTS_GRATE,
		["_SLIME"] = CONTENTS_SLIME,
		["_WATER"] = CONTENTS_WATER,
		["_BLOCKLOS"] = CONTENTS_BLOCKLOS,
		["_OPAQUE"] = CONTENTS_OPAQUE,
		["_TESTFOGVOLUME"] = CONTENTS_TESTFOGVOLUME,
		["_TEAM4"] = CONTENTS_TEAM4,
		["_TEAM3"] = CONTENTS_TEAM3,
		["_TEAM1"] = CONTENTS_TEAM1,
		["_TEAM2"] = CONTENTS_TEAM2,
		["_IGNORE_NODRAW"] = CONTENTS_IGNORE_NODRAW_OPAQUE,
		["_MOVEABLE"] = CONTENTS_MOVEABLE,
		["_AREAPORTAL"] = CONTENTS_AREAPORTAL,
		["_PLAYERCLIP"] = CONTENTS_PLAYERCLIP,
		["_MONSTERCLIP"] = CONTENTS_MONSTERCLIP,
		["_CURRENT_0"] = CONTENTS_CURRENT_0,
		["_CURRENT_180"] = CONTENTS_CURRENT_180,
		["_CURRENT_270"] = CONTENTS_CURRENT_270,
		["_CURRENT_90"] = CONTENTS_CURRENT_90,
		["_CURRENT_DOWN"] = CONTENTS_CURRENT_DOWN,
		["_CURRENT_UP"] = CONTENTS_CURRENT_UP,
		["_DEBRIS"] = CONTENTS_DEBRIS,
		["_DETAIL"] = CONTENTS_DETAIL,
		["_HITBOX"] = CONTENTS_HITBOX,
		["_LADDER"] = CONTENTS_LADDER,
		["_MONSTER"] = CONTENTS_MONSTER,
		["_ORIGIN"] = CONTENTS_ORIGIN,
		["_TRANSLUCENT"] = CONTENTS_TRANSLUCENT,
		["_LAST_VISIBLE"] = LAST_VISIBLE_CONTENTS,
		["_ALL_VISIBLE"] = ALL_VISIBLE_CONTENTS,
	}

	local trace_contents = ply:GetEyeTrace().Contents
	local output = ""

	for name, content_number in pairs(contents) do
		if bit.band(trace_contents, content_number) == content_number then
			output = output .. name .. " "
		end
	end

	print(output)
end)

local function equalVector(vector1,vector2) return vector1:IsEqualTol(vector2,2) end

local tr = {
	filter = FilterFunctionSND,
	mask = MASK_GLOBAL
}

local result
local Vector = Vector//ДЕЙМ БРО ХУК ПУДЖА СВЕЖЕЕ МЯСО
local TraceLine = util.TraceLine

local function traceableToSky(pos,x,y)
	tr.start = Vector(pos[1] + x,pos[2] + y,pos[3])
	tr.endpos = pos
 
	if TraceLine(tr).HitPos ~= pos then return false end

	tr.endpos = Vector(pos[1] + x,pos[2] + y,pos[3] + SOUNDHIGHROOFDISTANCE)

	result = TraceLine(tr)

	return result.HitSky or not result.Hit
end

local function getOutdoorsState(pos)
	return traceableToSky(pos,0,0) or traceableToSky(pos,120,0) or traceableToSky(pos,0,120) or traceableToSky(pos,-120,0) or traceableToSky(pos,0,-120)
end

local empty = {}

local function getPositionState(pos)
	FilterSND = empty

	return getOutdoorsState(pos) and "outdoors" or "indoors"
end

DWR_PositionState = getPositionState
DWR_TracableToSky = traceableToSky

local function getDistanceState(pos1, pos2)
	local distance = pos1:Distance(pos2) * UNITS_TO_METERS -- meters l0l

	-- tweak this number later plz
	if distance > 100 then
		return "distant"
	else
		return "close"
	end
end

local dwr_supportedAmmoTypes = {
	["pistol"] = true,
	["ar2"] = true,
	["357"] = true,
	["buckshot"] = true,
	["smg1"] = true
}

local function formatAmmoType(ammotype)
	ammotype = string.lower(ammotype)

	if table.HasValue(dwr_supportedAmmoTypes, ammotype) then
		return ammotype
	elseif ammotype == "explosions" then
		return "explosions"
	else
		return "other"
	end
end

local function getEntriesStartingWith(pattern, array)
	local tempArray = {}
	pattern = string.lower(pattern)

	for _, path in ipairs(array) do
		path = string.lower(path)

		if string.StartWith(path, pattern) then
			table.insert(tempArray, path)
		end
	end

	if table.IsEmpty(tempArray) then
		print("[DWR] WTF. Nothing found??? Here's debug info!!!", pattern, table.ToString(dwr_reverbFiles, "debug", false))

		return {"dwr/kleiner.wav"}
	end

	return tempArray
end

local function reflectVector(pVector, normal)
	local dn = 2 * pVector:Dot(normal)

	return pVector - normal * dn
end

local cl_dwr_occlusion_rays_reflections
//cvars.CreateOption("cl_dwr_occlusion_rays_reflections","0",function(value) cl_dwr_occlusion_rays_reflections = tonumber(value) end,0,16)

local cl_dwr_occlusion_rays_max_distance
//cvars.CreateOption("cl_dwr_occlusion_rays_max_distance","10000",function(value) cl_dwr_occlusion_rays_max_distance = tonumber(value) end,0,10000)

local function traceableToPos(earpos, pos, offset)
	local lastTrace = {}
	local totalDistance = 0

	earpos[3] = earpos[3] + 10
	pos[3] = pos[3] + 10

	local traceToOffset = util.TraceLine({
		start = earpos,
		endpos = earpos + offset,
		mask = MASK_GLOBAL
	})

	totalDistance = traceToOffset.HitPos:Distance(traceToOffset.StartPos)
	lastTrace = traceToOffset

	for i = 1, cl_dwr_occlusion_rays_reflections do
		local bounceTrace = util.TraceLine({
			start = lastTrace.HitPos,
			endpos = lastTrace.HitPos + reflectVector(lastTrace.HitPos,lastTrace.Normal):Mul(1000000000),
			mask = MASK_GLOBAL
		})

		if bounceTrace.StartSolid or bounceTrace.AllSolid then break end
		totalDistance = totalDistance + bounceTrace.HitPos:Distance(bounceTrace.StartPos)
		lastTrace = bounceTrace
	end

	local traceLastTraceToPos = util.TraceLine({
		start = lastTrace.HitPos,
		endpos = pos,
		mask = MASK_GLOBAL
	})

	totalDistance = totalDistance + traceLastTraceToPos.HitPos:Distance(traceLastTraceToPos.StartPos)
	if totalDistance > cl_dwr_occlusion_rays_max_distance then return false end

	return traceLastTraceToPos.HitPos == pos
end

local cl_dwr_occlusion_rays
//cvars.CreateOption("cl_dwr_occlusion_rays","32",function(value) cl_dwr_occlusion_rays = tonumber(value) end,0,128)

local math_floor = math.floor

local function getOcclusionPercent(earpos,pos)
	local traceAmount = math_floor(cl_dwr_occlusion_rays / 4)
	local degrees = 360 / traceAmount
	local successfulTraces = 0
	local failedTraces = 0

	for j = 1, 4 do
		local singletrace = Vector(100000000, 0, 0)
		local angle

		if j == 1 then
			angle = Angle(degrees, 0)
		elseif j == 2 then
			angle = Angle(degrees, degrees)
		elseif j == 3 then
			angle = Angle(-degrees, degrees)
		elseif j == 4 then
			angle = Angle(0, degrees)
		end

		for i = 1, traceAmount do
			singletrace:Rotate(angle)

			local traceToPos = traceableToPos(earpos,pos:Clone(),singletrace)
			successfulTraces = successfulTraces + (traceToPos and 1 or 0)
			failedTraces = failedTraces + (traceToPos and 0 or 1)
		end
	end

	return failedTraces / (traceAmount * 4) // percentageOfFailedTraces
end

local function calculateDelay(distance, speed)
	if speed == 0 then return 0 end

	return distance / speed
end

local cl_dwr_disable_reverb
cvars.CreateOption("cl_dwr_disable_reverb","0",function(value) cl_dwr_disable_reverb = (tonumber(value) or 0) > 0 end,0,1)

local cl_dwr_volume
cvars.CreateOption("cl_dwr_volume","1",function(value) cl_dwr_volume = tonumber(value) or 0 end,0,1)

local random = math.random

dwrFiles = {}

local function make(ammotype,indoors_close,indoors_distant,outdoors_close,outdoors_distant)
	dwrFiles[ammotype] = {
		indoors = {close = {},distant = {}},
		outdoors = {close = {},distant = {}}
	}

	for i = 1,indoors_close do dwrFiles[ammotype].indoors.close[i] = "dwr/" .. ammotype .. "/indoors/close/" .. i .. ".wav" end
	for i = 1,indoors_distant do dwrFiles[ammotype].indoors.distant[i] = "dwr/" .. ammotype .. "/indoors/distant/" .. i .. ".wav" end

	for i = 1,outdoors_close do dwrFiles[ammotype].outdoors.close[i] = "dwr/" .. ammotype .. "/outdoors/close/" .. i .. ".wav" end
	for i = 1,outdoors_distant do dwrFiles[ammotype].outdoors.distant[i] = "dwr/" .. ammotype .. "/outdoors/distant/" .. i .. ".wav" end
end

make("357",6,6,9,9)
make("ar2",6,6,9,9)
make("buckshot",8,8,8,8)
make("pistol",6,6,3,2)
make("smg1",6,6,6,2)
make("other",6,6,6,2)
make("other",6,6,6,2)
make("explosions",8,8,6,8)

local min = math.min

local function playReverb(src, ammotype, isSuppressed, weapon)
	if cl_dwr_disable_reverb == true or weapon.dwr_reverbDisable then return end

	local earpos = EyePos()
	local volume = weapon.dwr_customVolume or 1

	local positionState = getPositionState(src)
	local earpos_positionState = getPositionState(earpos)

	local distanceState = getDistanceState(src, earpos)
	ammotype = weapon.dwr_customAmmoType or formatAmmoType(ammotype)

	if weapon.dwr_customIsSuppressed ~= nil then
		isSuppressed = weapon.dwr_customIsSuppressed
	end

	if isSuppressed then volume = volume * 0.25 end

	local soundLevel = 140 -- sound plays everywhere
	local soundFlags = SND_DO_NOT_OVERWRITE_EXISTING_ON_CHANNEL
	local pitch = math.random(94, 107)
	local dsp = 0 -- https://developer.valvesoftware.com/wiki/DSP
	local distance = earpos:Distance(src) * UNITS_TO_METERS -- in meters

	local traceToSrc = util.TraceLine({
		start = earpos,
		endpos = src,
		mask = MASK_GLOBAL
	})

	local direct = equalVector(traceToSrc.HitPos, src)
	local occlusionPercentage = 0

	if not direct then
		//occlusionPercentage = getOcclusionPercent(earpos, src)

		if positionState ~= "outdoors" or earpos_positionState ~= "outdoors" then
			dsp = 30-- lowpass
		end

		volume = volume //* (1 - math.Clamp(occlusionPercentage - 0.5, 0, 0.5))
	end

	local distanceMultiplier = 1 - min(distance / 400,1)

	if distanceState == "close" then
		volume = volume * distanceMultiplier
	elseif distanceState == "distant" then
		if positionState == "outdoors" then
			volume = volume * distanceMultiplier * 2
		else
			volume = volume * distanceMultiplier * 0.5
		end

		pitch = Lerp(distanceMultiplier,pitch - 50,pitch)
	end

	local reverbQueue = {}
	local snd = dwrFiles[ammotype][positionState][distanceState]
	reverbQueue[#reverbQueue + 1] = snd[random(#snd)]

	if distanceState == "close" and positionState == "indoors" then
		//reverbQueue[#reverbQueue + 1] = reverbQueue[1]
	end

	local d = calculateDelay(distance,SOUNDSPEED)

	local pos = earpos - (earpos - src):Mul(0.5)

	if d > 0.06 then
		timer.GameSimple(calculateDelay(distance,SOUNDSPEED), function()
			for _, path in ipairs(reverbQueue) do
				SoundEmit(path,soundLevel,volume * cl_dwr_volume,pitch,pos,dsp)
			end
		end)
	else
		for _, path in ipairs(reverbQueue) do
			SoundEmit(path,soundLevel,volume * cl_dwr_volume,pitch,pos,dsp)
		end
	end
end

DWR_PlayReverb = playReverb

-- shamelessly pasted from arccw because math is hard
function calculateSpread(dir, spread)
	if not spread then return dir end

	local radius = math.Rand(0, 1)
	local theta = math.Rand(0, math.rad(360))
	local bulletang = dir:Angle()
	local forward, right, up = bulletang:Forward(), bulletang:Right(), bulletang:Up()
	local x = radius * math.sin(theta)
	local y = radius * math.cos(theta)

	return dir + right * spread.x * x + up * spread.y * y
end

local list = {close = {},distant = {}}
for i = 1,8 do list.close[i] = "dwr/bulletcracks/close/" .. i .. ".wav" end
for i = 1,5 do list.distant[i] = "dwr/bulletcracks/distant/f" .. i .. ".wav" end

local min = math.min

local TraceLine = util.TraceLine

local tr = {
	mask = MASK_SHOT
}

local tr2 = {
	mask = MASK_SHOT
}

local pitch = {
	-10,
	-10
}

local yaw = {
	-5,
	5
}

/*timer.Create("TEST",1 / 11,0,function()
	DWR_PlayBulletCrack(Vector(274,774,320),Vector(1,0,0):Rotate(Angle(0,90,0)),SOUNDSPEED)
end)*/

BulletCrackRadiusInMetrs = 12

local max,min,random = math.max,math.min,math.random

local function playBulletCrack(src,dir,vel)
	local earpos = EyePos()

	local distanceState = getDistanceState(src,earpos)
	local distance,point

	//debugoverlay.Sphere(src,1,0.1)
	//

	tr.start = src
	tr.endpos = src + dir:Clone():Mul(32000)

	local trajectory = TraceLine(tr)
	local distance,point,distanceToPointOnLine = util.DistanceToLine(trajectory.StartPos,trajectory.HitPos,earpos)

	tr2.start = earpos
	tr2.endpos = src
	tr2.filter = FilterFunctionSND

	local view = equalVector(TraceLine(tr2).HitPos,point)

	if not view then
		tr.endpos = src + Vector(1,0,0):Rotate(dir:Angle():Add(Angle(-10,0,0))):Mul(32000)

		local trajectory = TraceLine(tr)
		local distance2,point2,distanceToPointOnLine = util.DistanceToLine(trajectory.StartPos,trajectory.HitPos,earpos)
		
		tr2.endpos = point2

		if equalVector(TraceLine(tr2).HitPos,point2) then//distance2 < distance then
			view = true

			if distance2 < distance then
				distance = distance2

				point = point2
			end
		end
	end
	//

	distance = distance * UNITS_TO_METERS
	
	local earposDis = src:Distance(earpos)

	local distanceBulletCrack = (BulletCrackRadiusInMetrs + earposDis / 1000)
	local k = 1 - min(distance / distanceBulletCrack,1)

	k = k * (1 - min(max(600 - earposDis,0) / 600,1))

	local diff = dir
    diff = (src - earpos):GetNormalized():Dot(diff)

    if diff < 0 then
		diff = min(-diff * 1,1)

		k = k * diff
	else
		k = 0
	end

	timer.GameSimple(calculateDelay(src:Distance(point) * UNITS_TO_METERS,vel),function()
		local snd = list[distanceState]
		snd = snd[random(1,#snd)]

		local ent = sound.CreateEmit(point)
		
		for i = 1,2 do
			SoundEmitEntity(ent,snd,125,cl_dwr_volume * math.min(k,1),random(60,70),nil,not view and 14 or 0)
		end
	
		if view then event.Run("Bullet Crack",k) end
	end)
end

//timer.Create("test",1 / 3,0,function() playBulletCrack(Vector(4159.759277 ,3602.629639 ,654.426086),Vector(0,1,0),SOUNDSPEED * 10) end)

DWR_PlayBulletCrack = playBulletCrack

local function processSound(data, isweapon)
	local earpos = EyePos()
	local src = data.Pos
	local dsp = 0 -- https://developer.valvesoftware.com/wiki/DSP
	local distance = earpos:Distance(src) * UNITS_TO_METERS -- in meters
	local volume = data.Volume

	local traceToSrc = util.TraceLine({
		start = earpos,
		endpos = src,
		mask = MASK_GLOBAL
	})

	if not traceToSrc then return data end
	local direct = equalVector(traceToSrc.HitPos, src)

	if not direct then
		//local occlusionPercentage = getOcclusionPercent(earpos, src)

		-- lowpass
		if occlusionPercentage == 1 then
			dsp = 30
		end

		volume = volume //* (1 - math.Clamp(occlusionPercentage - 0.5, 0, 0.5))
	end

	if not isweapon then
		if distanceState == "close" then
			local distanceMultiplier = math.Clamp(5000 / distance ^ 2, 0, 1)
			volume = volume * distanceMultiplier
		elseif distanceState == "distant" then
			local distanceMultiplier = math.Clamp(9000 / distance ^ 2, 0, 1)
			volume = volume * distanceMultiplier
		end
	end

	data.Volume = volume
	data.DSP = dsp

	return data
end

local function readVectorUncompressed()
	local tempVec = Vector(0, 0, 0)
	tempVec.x = net.ReadFloat()
	tempVec.y = net.ReadFloat()
	tempVec.z = net.ReadFloat()

	return tempVec
end

net.Receive("dwr_EntityFireBullets_networked", function(len)
	local src = readVectorUncompressed()
	local dir = readVectorUncompressed()
	local vel = readVectorUncompressed()
	local spread = readVectorUncompressed()
	local ammotype = net.ReadString()
	local isSuppressed = net.ReadBool()
	local entity = net.ReadEntity()

	if entity == LocalPlayer() then return end
	
	local weapon = {}

    if ammotype ~= "HelicopterGun" then
		playBulletCrack(src,dir,vel:Length(),spread,ammotype,weapon)
	end
	
	playReverb(src,ammotype,isSuppressed,weapon)
end)

net.Receive("dwr_EntityEmitSound_networked", function(len)
	local data = net.ReadTable()
	if not data then return end

	data = processSound(data,true)

	local ent = data.Entity
	if ent == NULL then return end
	if ent == LocalPlayer() then return end

	ent:EmitSound(data.SoundName,data.SoundLevel,data.Pitch,data.Volume,CHAN_STATIC,data.Flags,data.DSP)
end)

local function explosionProcess(data)
	if not string.find(data.SoundName, "explo") or string.find(data.SoundName, "dwr") or not string.StartWith(data.SoundName, "^") then return end
	playReverb(data.Pos, "explosions", false, {})
end

/*hook.Add("EntityEmitSound", "dwr_EntityEmitSound", function(data)
	if data.Pos == nil or not data.Pos then return end
	explosionProcess(data)

	if GetConVar("cl_dwr_process_everything"):GetInt() == 1 then
		local isweapon = false

		if string.find(data.SoundName, "weapon") then
			isweapon = true
		end

		data = processSound(data, isweapon)

		return true
	end
end)*/
-- end of main
