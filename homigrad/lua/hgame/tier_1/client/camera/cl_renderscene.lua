--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/client/camera/cl_renderscene.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\client\\camera\\cl_renderscene.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local vecZero,vecFull = Vector(0.001,0.001,0.001),Vector(1,1,1)

local list = {}

local function step(self,parentbone,vec)
	for _,bone in pairs(self:GetChildBones(parentbone)) do
		self:ManipulateBoneScale(bone,vec)

		step(self,bone,vec)
	end
end

hook.Add("PreRender","SetHeadScale",function()
	for ent in pairs(list) do
		list[ent] = nil
		if not IsValid(ent) then continue end
		
		local head = ent:LookupBone("ValveBiped.Bip01_Head1")
		if not head then return end

		ent:ManipulateBoneScale(head,vecFull)

		if HeadPopOffsetByModel[ent:GetModel()] then
			step(ent,head,vecFull)
		end

		ent.HeadPop = nil
	end
end)

FindMetaTable("Entity").SetHeadScale = function(self,value)
	local head = self:LookupBone("ValveBiped.Bip01_Head1")
	if not head then return end

	self.HeadPop = value

	local vec = value and vecZero or vecFull
	self:ManipulateBoneScale(head,vec)

	if HeadPopOffsetByModel[self:GetModel()] then
		step(self,head,vec)
	end

	list[self] = true
end

//

FOV = 100

cvars.CreateOption("hg_fov","100",function(value)
    FOV = tonumber(value or 100) or 100
end,90,120)

local function IsNoclip(ply)
    if not IsValid(ply) then return false end
    if ply:InVehicle() then return false end
    local mt = ply:GetMoveType()
    if mt == MOVETYPE_NOCLIP or mt == MOVETYPE_OBSERVER then return true end
    if ply.GetObserverMode and ply:GetObserverMode() > 0 then return true end
    if ply.GetNWBool and ply:GetNWBool("noclip",false) then return true end
    if ply.GetFlags and bit.band(ply:GetFlags(),8) ~= 0 then return true end
    return false
end

event.Add("PreCalcView","NoclipBypass",function(ply,view)
    if ply:Alive() and IsNoclip(ply) then
        ply:SetHeadScale(false)
        view.drawviewer = false
        DRAWMODEL = nil

        local eye = ply:EyePos()
        local ang = ply:EyeAngles()
        ang[3] = 0

        view.vec = eye
        view.ang = ang
        view.origin = eye
        view.angles = ang
        view.znear = 1
        view.fov = FOV
        view.noSmooth = true

        return view
    end
end,-30)

event.Add("PreCalcView","FOV",function(ply,view)
    view.fov = FOV + 13
end,-22)

event.Add("PreCalcView","CalcView Weapon",function(ply,view)
	local wep = ply:GetActiveWeapon()
	if not IsValid(wep) or not wep.CalcView then return end

	local pos,ang,fov = wep:CalcView(ply,view.origin,view.angles,view.fov)

	if pos then
		view.pos = pos
		view.vec = pos
		view.origin = pos
	end
	if ang then
		view.angles = ang
		view.ang = ang
	end
	if fov then view.fov = fov end
end,-21)

event.Add("PreCalcView","EyeMode",function(ply,view)
    if not ply:Alive() then
        DRAWMODEL = nil
        ply:SetHeadScale(false)
        view.drawviewer = false
        return
    end

    local bodyCvar = GetConVar("hg_firstperson_body")
    local bodyEnabled = not bodyCvar or bodyCvar:GetInt() > 0
    local isEyeMode = ply:EyeMode()

    DRAWMODEL = (GetViewEntity() == ply) and bodyEnabled and not isEyeMode

    if DRAWMODEL then
        ply:SetHeadScale(true)
        view.drawviewer = true
    else
        ply:SetHeadScale(false)
        view.drawviewer = false
        DRAWMODEL = nil
    end

    view.znear = 1
end,-20)

event.Add("PreCalcView","Homigrad",function(ply,view)
	if not ply:Alive() then return end
	ply:SetupBones()

	local vec,ang = ply:Eye(true)
    if not vec or not ang then
        vec = ply:EyePos()
        ang = ply:EyeAngles()
    end

	if DRAWMODEL and ang and ang[1] > 15 then
		local pitchDown = math.Clamp((ang[1] - 15) / 75,0,1)
		vec:Add(ang:Forward() * (pitchDown * 5.5))
		vec:Add(Vector(0,0,pitchDown * 1.5))
	end

    view.vec = vec
    view.ang = ang
    view.origin = vec
    view.angles = ang
    view.znear = 1
end,-10)
