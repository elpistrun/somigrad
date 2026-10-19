--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/sh_footsteps.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\sh_footsteps.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local function format(value)
	if value >= 10 then return value else return "0" .. value end
end

local replace = {}
local replaceVolume = {}

local replaceLand = {}
local replaceLandVolume = {}

local function add(name,start,endcount,volume,sndName)
	local list = {}
	local paperRandom = {}
	for i = start,endcount do list[i] = sndName .. format(i) .. ".wav" paperRandom[i] = true end

	replace[name] = {list,start,endcount,paperRandom}
	replaceVolume[name] = volume
end

local function addLand(name,start,endcount,volume,sndName)
	local list = {}
	local paperRandom = {}
	for i = start,endcount do list[i] = sndName .. format(i) .. ".wav" paperRandom[i] = true end

	replaceLand[name] = {list,start,endcount,paperRandom}
	replaceLandVolume[name] = volume
end

local function replaced(name,name2,volume,volumeLand)
	replace[name] = replace[name2]
	replaceLand[name] = replaceLand[name2]

	replaceVolume[name] = volume or replaceVolume[name2]
	replaceLandVolume[name] = volumeLand or replaceLandVolume[name2]
end

add(	"concrete",				1,17,0.25,	"homigrad/player/footsteps/new/concrete_ct_")
addLand("concrete",				1,6,0.5,	"homigrad/player/footsteps/new/land_rubber_")
replaced("default","concrete")

add(	"tile",					1,14,0.25,	"homigrad/player/footsteps/new/tile_")
addLand("tile",					1,5,0.5,	"homigrad/player/footsteps/new/land_tile_")

add(	"rubbe",				1,10,0.25,	"homigrad/player/footsteps/new/bass_")
addLand("rubbe",				1,6,0.5,	"homigrad/player/footsteps/new/land_rubber_")
replaced("rubber","rubbe")

add(	"glasssheetstep",		7,13,0.5,	"homigrad/player/footsteps/new/glass_")
addLand("glasssheetstep",		1,6,1,		"homigrad/player/footsteps/new/land_glass_")
replaced("glass","glasssheetstep")
replace.glasssheetstep[1][6] = "homigrad/player/footsteps/new/glass_1.wav"

add(	"wood",					1,15,0.25,	"homigrad/player/footsteps/new/wood_")
addLand("wood",                 1,6,0.25,	"homigrad/player/footsteps/new/land_rubber_")
replaced("woodpanel","wood",0.5,1)
replaced("woodboxfootstep","wood",0.5,1)
replaced("woodcrete","wood",0.5,1)

--

add(	"grass",				1,13,0.1,	"homigrad/player/footsteps/new/grass_")
addLand("grass",				1,5,0.5,	"homigrad/player/footsteps/new/land_grass_")

add(	"dirt",					1,14,0.25,	"homigrad/player/footsteps/new/dirt_")
addLand("dirt",					1,5,0.5,	"homigrad/player/footsteps/new/land_dirt_")

add(	"sand",					1,12,0.25,	"homigrad/player/footsteps/new/sand_")
addLand("sand",					1,6,0.5,	"homigrad/player/footsteps/new/land_sand_")

add(	"gravel",				1,12,0.25,	"homigrad/player/footsteps/new/gravel_")
addLand("gravel",               1,5,0.5,	"homigrad/player/footsteps/new/land_gravel_")

add(	"mud",                  1,9,0.25,	"homigrad/player/footsteps/new/mud_")
addLand("mud",                  1,5,0.5,	"homigrad/player/footsteps/new/land_mud_")

add(	"snow",					1,12,0.25,	"homigrad/player/footsteps/new/snow_")
addLand("snow",					1,5,0.5,	"homigrad/player/footsteps/new/land_snow_")

--

add(	"metal",				35,50,0.25,	"homigrad/player/footsteps/new/metal_solid_")
addLand("metal",				1,6,0.5,	"homigrad/player/footsteps/new/land_metal_solid_")
add(	"duct",					1,6,0.5,	"homigrad/player/footsteps/new/metal_auto_")
addLand("duct",					1,6,1,		"homigrad/player/footsteps/new/land_metal_vent_")
replaced("metalvent","duct")

add(	"chainlink",			1,7,0.5,	"homigrad/player/footsteps/new/metal_chainlink_")
addLand("chainlink",			1,5,1,		"homigrad/player/footsteps/new/land_metal_grate_")
replace.chainlink[1][8] = "homigrad/player/footsteps/new/metal_chainlink_8.wav"
replace.chainlink[1][9] = "homigrad/player/footsteps/new/metal_chainlink_9.wav"--stupid moments

replaceLand.default[1][1] = "homigrad/player/land.wav"
replaceLand.default[1][2] = "homigrad/player/land2.wav"
replaceLand.default[1][3] = "homigrad/player/land3.wav"

local table_Random = table.Random

local function getRandom(paperRandom,latestRandom)
	latestRandom = latestRandom or 0

	if paperRandom[latestRandom] then
		paperRandom[latestRandom] = nil
		local _,value = table_Random(paperRandom)
		paperRandom[latestRandom] = true

		return value
	else
		local _,value = table_Random(paperRandom)

		return value
	end
end

local GetFileFromFilename = string.GetFileFromFilename
local string_sub = string.sub
local string_gsub = string.gsub

event.Add("Footstep","Homigrad",function(ply,pos,foot,sndName,volume,filter)
	if ((ply:KeyDown(IN_DUCK) or ply:KeyDown(IN_WALK)) and not ply:KeyDown(IN_SPEED)) or SERVER then return true end

	sndName = GetFileFromFilename(sndName)
	sndName = string_sub(sndName,1,#sndName - 5)
	sndName = string_gsub(sndName,"_","")

	local snd = replace[sndName] or replace.tile
	--if not snd then print("cant find footsteps sound '" .. tostring(sndName) .. "'\n") return end

	local value = getRandom(snd[4],ply.lastFootstepCount)
	ply.lastFootstepCount = value

	ply:EmitSound(snd[1][value],75,100,(replaceVolume[sndName] or 0.25) * 0.5 * (ply:IsSprinting() and 2 or 1),CHAN_ITEM)

	return true
end,1)

local tr = {}
local vecDown = Vector(0,0,32)

local delayHit = 0.25

local TraceHull = util.TraceHull
local GetSurfaceData = util.GetSurfaceData

event.Add("Landing","Homigrad",function(ply,inWater,onFloat,speed)
	if SERVER or (ply.delayHitGround or 0) > CurTime() then return end
	
	ply.delayHitGround = CurTime() + delayHit

	tr.start = ply:GetPos()
	tr.endpos = tr.start - vecDown
	tr.filter = ply
	local mins,maxs = ply:GetHull()
	tr.mins = mins
	tr.maxs = -mins

	local result = TraceHull(tr)
	if not result.Hit then return end--lol

	local data = GetSurfaceData(result.SurfaceProps)
	if not data then return end
	
	local sndName = string_gsub(data.name,"_","")

	local snd = replaceLand[sndName] or replaceLand.default
	--if not snd then print("cant find footsteps land sound '" .. tostring(sndName) .. "'") return end

	local value = getRandom(snd[4],ply.lastFootstepCount)
	ply.lastFootstepCount = value

	ply:EmitSound(snd[1][value],80,100,replaceLandVolume[sndName] or 0.4,CHAN_ITEM)

	return true
end,1)
