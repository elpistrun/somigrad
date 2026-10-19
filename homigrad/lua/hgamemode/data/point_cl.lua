--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/data/point_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\data\\point_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
PointsList = PointsList or {}

PointsListCategoryDisabled = PointsListCategoryDisabled or {}

PointsCategory = PointsCategory or {}

net.Receive("points",function()
	PointsList = net.ReadTable()

	local tbl = {}

	for name,info in pairs(PointsList) do
		local category = PointsCategory[info.category]

		local cat

		if category then
			tbl[info.category] = tbl[info.category] or category

			cat = tbl[info.category]
		else
			tbl[name] = tbl[name] or {info[1]}

			cat = tbl[name]
		end

		cat.list = cat.list or {}
		cat.list[name] = info
	end

	PointsListCategory = tbl
end)

net.Receive("points category",function()
	PointsCategory = net.ReadTable()
end)

local hg_drawspawn = CreateClientConVar("hg_drawspawn","0",false,false)

local old

local white = Color(255,255,255,15)

hook.Add("HUDPaint","DrawSpawns",function()
	if not hg_drawspawn:GetBool() or not LocalPlayer():IsAdmin() then return end

	local lply_pos = EyePos()

	for name,info in pairs(PointsList) do
		if PointsListCategoryDisabled[info.category or name] then continue end

		local centerPos = Vector()

		for i,point in pairs(info.list) do
			local pos = point.pos
			
			centerPos:Add(pos)

			local dis = pos:Distance(lply_pos)
			if dis > 1000 then continue end

			pos = pos:ToScreen()
			if not pos.visible then continue end

			draw.SimpleText(name,"DefaultFixedDropShadow",pos.x,pos.y,info[1],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

			if dis > 250 then continue end

			draw.SimpleText("id:" .. i,"DefaultFixedDropShadow",pos.x,pos.y + 15,info[1],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

			if point.dis then draw.SimpleText("3: " .. tostring(point.dis),"DefaultFixedDropShadow",pos.x,pos.y + 30,info[1],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end
			if point.add then draw.SimpleText("add: " .. tostring(point.add),"DefaultFixedDropShadow",pos.x,pos.y + 55,info[1],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end
		end

		if #info.list > 1 then
			centerPos:Div(#info.list)

			if centerPos:Distance(lply_pos) > 1000 then continue end

			centerPos = centerPos:ToScreen()

			draw.SimpleText(#info.list,"H.25",centerPos.x,centerPos.y,info[1],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
	end

	local count = 0

	local active = input.IsMouseDown(MOUSE_LEFT)
	local click

	if old ~= active then
		old = active

		click = active
	end

	for name,info in pairs(PointsListCategory) do
		local catColor = info[1]

		local color = Color(0,0,0)
		color.r = catColor.r
		color.g = catColor.g
		color.b = catColor.b
		color.a = PointsListCategoryDisabled[name] and 125 or 255

		local x,y = ScrW() - 5,ScrH() - 50 - 15 * count

		surface.SetFont("ChatFont")
		local tw,th = surface.GetTextSize(name)

		if math.pointinbox(gui.MouseX(),gui.MouseY(),x - tw,y,tw,th) then
			draw.RoundedBox(0,x - tw,y,tw,th,white)

			if click then
				PointsListCategoryDisabled[name] = not PointsListCategoryDisabled[name]
				color.a = PointsListCategoryDisabled[name] and 125 or 255
			end
		end

		draw.SimpleText(name,"ChatFont",x,y,color,TEXT_ALIGN_RIGHT)
		
		count = count + 1

		if not PointsListCategoryDisabled[name] then
			local i = 1

			for name,info in pairs(info.list) do
				if #info.list == 0 then continue end

				draw.SimpleText(name,"ChatFont",x - 10,y - 15 * i,color,TEXT_ALIGN_RIGHT)
				draw.SimpleText(#info.list .. ".точек","ChatFont",x - 200,y - 15 * i,color,TEXT_ALIGN_RIGHT)
				local count = table.Count(info.pages)

				if count > 1 then
					draw.SimpleText(count .. ".листов","ChatFont",x - 300,y - 15 * i,color,TEXT_ALIGN_RIGHT)
				end
				
				count = count + 1
				i = i + 1
			end

			if i == 1 then PointsListCategory[name] = nil end
		end
	end

	local page = tonumber(GetGlobalVar("PointPage",0))

	if page ~= 0 then draw.SimpleText("сейчас поставлена " .. page .. " страница","ChatFont",ScrW() - 10 - 125,ScrH() - 30,nil,TEXT_ALIGN_CENTER) end
end)

local red,blue = Color(255,0,0),Color(0,0,255)
local ebalgmod = Color(0,0,0)
hook.Add("PostDrawTranslucentRenderables","DrawSpawns",function()
	if not hg_drawspawn:GetBool() or not LocalPlayer():IsAdmin() then return end

	render.SetColorMaterial()

	for name,info in pairs(PointsList) do
		if PointsListCategoryDisabled[info.category or name] then continue end

		local color = info[1]
		ebalgmod.r = color.r
		ebalgmod.g = color.g
		ebalgmod.b = color.b
		ebalgmod.a = 25

		for i,point in pairs(info.list) do
			render.DrawWireframeSphere(point.pos,point.dis or 6,16,16,ebalgmod)
		end
	end
end)

concommand.Add("hg_point_print",function()
	PrintTable(PointsList)
end)

concommand.Add("hg_pointcategory_print",function()
	PrintTable(PointsCategory)
end)
