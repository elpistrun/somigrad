--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/armor/cl_render_armor.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\armor\\cl_render_armor.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local table_GetKeys = table.GetKeys

local vecFull = Vector(1,1,1)
local plyboneedit

local tostring = tostring

function Armor_IsFace(slots)
	return slots.mouthnose or slots.eyes or slots.head or slots.acc_ears or slots.acc_head or slots.acc_eyes or slots.ears
end

function Armor_SetupRender(list,isClient)
	local renderOrder = {}

	for id,armorSpec in pairs(list) do
		local copy = {
			pos = armorSpec.pos,
			ang = armorSpec.ang,
			size = armorSpec.size,
			siz = armorSpec.siz,

			bon = armorSpec.bon,
			skin = armorSpec.skin,
			mat = armorSpec.mat,

			slots = armorSpec.slots,

			bdg = armorSpec.bdg
		}

		local mdl = armorSpec.mdl
		
		renderOrder[#renderOrder + 1] = {mdl,copy,armorSpec.col}
	end

	return renderOrder
end

event.Add("JMod_EZarmorSync","SetupRender",function(ply,tbl)
	ply.ArmorRender = Armor_SetupRender(tbl,ply == LocalPlayer(),ply:GetModel())
end,-1)

local vecZero = Vector(0,0,0)
local angZero = Angle(0,0,0)
local chache = {}

local function GetPos(ent,entModel,spec)
	local bon = spec.bon 
	if not bon then return end

	local bone = ent:LookupBone(bon)
	if not bone then return end
	
	local matrix = ent.GetBoneMatrix and ent:GetBoneMatrix(bone)
	if not matrix and ent.SetupBones then
		ent:SetupBones()
		matrix = ent.GetBoneMatrix and ent:GetBoneMatrix(bone)
	end

	local Pos, Ang

	if matrix then
		Pos, Ang = matrix:GetTranslation(), matrix:GetAngles()
	else
		local bpos, bang = ent:GetBonePosition(bone)
		if bpos then
			Pos, Ang = Vector(bpos), Angle(bang)
		end
	end
	
	if Pos and Ang then
		local info = ViewArmorOffsetByModel and ViewArmorOffsetByModel[entModel]
		info = info and info[bon]

		local addVec = info and info.vec or vecZero
		local Right,Forward,Up = Ang:Right(),Ang:Forward(),Ang:Up()

		local pos = spec.pos or vecZero
		Pos:Add(Right * (pos[1] + addVec[1]))
		Pos:Add(Forward * (pos[2] + addVec[2]))
		Pos:Add(Up * (pos[3] + addVec[3]))

		local addAng = info and info.ang or angZero
		local ang = spec.ang or angZero
		Ang:RotateAroundAxis(Right,ang[1] + addAng[1])
		Ang:RotateAroundAxis(Up,ang[2] + addAng[2])
		Ang:RotateAroundAxis(Forward,ang[3] + addAng[3])

        return Pos,Ang
    end
end

local Mat = Matrix()
local color_white = Color(255,255,255)

local render_SetColorModulation = render.SetColorModulation

local empty = {}

function Armor_DrawArmorOnEntity(ent,entModel,mdlPath,spec,col,tag,isWorld)
	local mdl,isCreate = CSMById(mdlPath,tag .. mdlPath .. entModel .. tostring(spec),isWorld)
	if not mdl then return end

	if isCreate then
		mdl:SetMaterial(spec.mat or "")
		mdl:SetSkin(spec.skin or 0)
		
		local addSize = vecZero

		local info = ViewArmorOffsetByModel and ViewArmorOffsetByModel[entModel]
		if info then
			info = info[spec.bon]

			if info then
				addSize = info.size or vecZero
			end
		end

		Mat:SetScale((spec.siz or vecFull) + addSize)
		mdl:EnableMatrix("RenderMultiply",Mat)

		if not isWorld then
			mdl:SetNoDraw(true)
		end

		for id,set in pairs(spec.bdg or empty) do
			mdl:SetBodygroup(id,set)
		end
	end

	local Pos,Ang = GetPos(ent,entModel,spec)
    if not Pos then return end

	mdl:SetPos(Pos)
    mdl:SetAngles(Ang)

	render_SetColorModulation(col.r / 255,col.g / 255,col.b / 255)
	mdl:SetupBones()
	mdl:DrawModel()

	return mdl
end

local Armor_DrawArmorOnEntity = Armor_DrawArmorOnEntity
local color_white = Color(255,255,255)

function Armor_PlayerModelDraw(ent,ArmorRender,isWorld,tag,dontRenderFace)
	if not ArmorRender or #ArmorRender == 0 then
		local ply = LocalPlayer()
		local armors = (IsValid(ply) and ply.Armors) or {}
		if table.Count(armors) > 0 then
			local specs = Armor_GetBuildSpecsFromArmors and Armor_GetBuildSpecsFromArmors(armors)
			if specs then
				ArmorRender = Armor_SetupRender(specs, true, ent:GetModel())
				if IsValid(ply) then ply.ArmorRender = ArmorRender end
			end
		end
	end

	if not ArmorRender then return end

	local i = 0

	tag = (tag or "") .. tostring(ent) .. tostring(ent:GetModel())

	local entModel = ent:GetModel()

	chache = {}

	::start::
	
	i = i + 1

	local pkg = ArmorRender[i]
	if not pkg then render_SetColorModulation(1,1,1) return end

	if dontRenderFace and Armor_IsFace(pkg[2].slots) then goto start end

	local mdl = Armor_DrawArmorOnEntity(ent,entModel,pkg[1],pkg[2],pkg[3] or color_white,tag,isWorld)

	goto start
end

cvars.CreateOption("hg_draw_armor","1",function(value)
	if tonumber(value) > 0 then
		event.Add("PlayerDraw","Armor",function(ply,tag,link,isWorld)
			if isWorld == nil then isWorld = not tag end

			link = link or ply

			Armor_PlayerModelDraw(ply,link.ArmorRender,isWorld,tag,(ply == GetViewEntity() or ply.HeadPop))
		end,10)
	else
		event.Remove("PlayerDraw","Armor",10)
	end
end)
