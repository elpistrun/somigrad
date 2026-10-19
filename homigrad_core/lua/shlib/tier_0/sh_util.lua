--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_0/sh_util.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_0\\sh_util.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
function util.Is64Bit() return BRANCH == "x86-64" end
IS64BIT = BRANCH == "x86-64"

local SteamIDTo64,SteamIDFrom64 = util.SteamIDTo64,util.SteamIDFrom64

function util.IsValidSteamID(any)
	local steamid = SteamIDTo64(any)

	if steamid == "0" then
		return SteamIDFrom64(any) != "STEAM_0:0:0"
	else
		return true
	end
end

function util.IsSteamID32(any)
	if TypeID(any) != TYPE_STRING or string.sub(any,1,6) != "STEAM_" then return false end
	
	local steamid = SteamIDTo64(any)

	if steamid == "0" then
		return false
	else
		return true
	end
end

function util.GetSteamID32AFromAny(any)
	if TypeID(any) != TYPE_STRING then return false end
	
	if string.sub(any,1,6) == "STEAM_" then
		return any
	else
		any = util.SteamIDFrom64(any)
		return (any != "0" and any) or false
	end
end

function util.GetSteamID64FromAny(any)
	if TypeID(any) != TYPE_STRING then return false end

	if string.sub(any,1,6) == "STEAM_" then
		any = util.SteamIDTo64(any)
		return any != "0" and any or false
	else
		return (util.SteamIDFrom64(any) != "STEAM_0:0:0" and any) or false
	end
end

local function func_error(err) ErrorNoHaltWithStack(err) end

local result,r1,r2,r3,r4,r5,r6,_error,errorH,tbl
local debug_getinfo = debug.getinfo

function util.pcall(func,...)
	_error = true

	result,r1,r2,r3,r4,r5,r6 = xpcall(func,func_error,...)

	errorH = _error
	_error = nil

	if result then
		if type(errorH) == "string" then
			ErrorNoHaltWithStack(errorH)

			return false,errorH
		end

		return true,r1,r2,r3,r4,r5,r6
	end
end--eeeeeeeeeeee

function util.error(text)
	if _error then
		_error = text
	else
		ErrorNoHaltWithStack(text)
	end
end

function util.FindInClassList(class,list)
	local value = list[class]

	if not value then
		for class2,value2 in pairs(list) do
			local star = string.sub(class2,#class2,#class2) == "*"
			local no = string.sub(class2,1,1) == "!"
			local thisClass = class

			if no then
				class2 = string.sub(class2,2,#class2)
			end

			if star then
				class2 = string.sub(class2,1,#class2 - 1)
				thisClass = string.sub(thisClass,1,#class2)
			end

			if thisClass == class2 then
				if no then return end

				value = value2
			end
		end
	end

	return value
end

function util.EyeCanSee(eye,dir,posLookup,k)
	local diff = posLookup - eye
    diff = dir:Dot(diff) / diff:Length()

    return diff >= (k or 0.4)
end

local CMoveData = FindMetaTable("CMoveData")

function CMoveData:RemoveKey(key)
	local newbuttons = bit.band(self:GetButtons(),bit.bnot(key))
	self:SetButtons(newbuttons)
end

local tr = {}
local TraceLine = util.TraceLine

function util.VisibleEntity(pos,ent,filter,fast)
	local world = game.GetWorld()
	
	tr.start = pos
	tr.mask = MASK_ALL
	tr.filter = function(entHit)
		if entHit == world then return true end//WTF?
		if entHit == filter or (entHit:OBBMins():Length() + entHit:OBBMaxs():Length()) <= 40 then return false end

		return true
	end

	if fast then
		tr.endpos = ent:GetPos():Add(ent:OBBCenter():Rotate(ent:GetAngles()))

		local result = TraceLine(tr)
		
		if result.Entity == ent or result.HitPos:Distance(tr.endpos) <= 1 then
			return result.HitPos,0
		else
			return
		end
	end
	
	local hit,hitBone

	for i = 0,ent:GetHitBoxCount(0) - 1 do
		local bone = ent:GetHitBoxBone(i,0)
		if not bone then continue end//lol

		local matrix = ent:GetBoneMatrix(bone)
		if not matrix then continue end//lol
		
		tr.endpos = matrix:GetTranslation()
		local result = TraceLine(tr)
		if result.Entity == ent then hit = result.HitPos hitBone = bone break end
	end

	return hit,hitBone
end

local whitelsit = {
	["prop_door"] = true,
	["prop_door_rotating"] = true,
	["func_door"] = true,
	["func_door_rotating"] = true
}

function util.IsDoor(ent)
	return whitelsit[ent:GetClass()] or false
end

local util_JSONToTable = util.JSONToTable

function util.JSONToTableUnLimit(json,ignoreLimit) return util_JSONToTable(json,ignoreLimit,true) end//уёбище ебанное
