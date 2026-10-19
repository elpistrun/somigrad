--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/use_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\use_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local halosColor = Color(255,255,255,75)

local target

local tbl = {}

hook.Add("PreDrawHalos","HudTarget",function()
	tbl[1] = target

	halo.Add(tbl,halosColor,1,1,1)
end)

local lerpK = {}

local old

hook.Add("HUDPaint","HudTarget",function()
	local lply = LocalPlayer()

	if not lply:Alive() or lply:GetNWBool("Fake") then return end

	local pos,ang = lply:Eye()

	local trace = util.TraceLine({
		start = pos,
		endpos = pos + ang:Forward():Mul(PlayerDisUse),
		mask = MASK_SHOT,
		filter = lply
	})

	target = nil

	local w,h = ScrW(),ScrH()
	
	halosColor.a = 255
	halosColor.g = 255
	halosColor.b = 255
	halosColor.a = 75

	if trace then
		local ent = trace.Entity

		if IsValid(ent) then
			local a = lply:KeyDown(IN_USE)
			
			if old ~= a then
				old = a

				if a then
					net.Start("use")
					net.WriteEntity(ent)
					net.SendToServer()
				end
			end

			local k = lerpK[ent]

			local result = hook.Run("HUD Target",ent,k or 0,w,h)
			
			if not result and ent.HUDTarget then
				result = ent:HUDTarget(ent,k or 0,w,h)
				if result == nil then result = true end
			end
		
			if result then
				if IsColor(result) then
					halosColor.r = result.r
					halosColor.g = result.g
					halosColor.b = result.b
					halosColor.a = result.a
				end

				target = ent

				if not k then lerpK[ent] = 0 end
			end
		end
	end

	for ent,k in pairs(lerpK) do
		if not IsValid(ent) then lerpK[ent] = nil continue end

		local active = target == ent and 1 or 0

		k = LerpFT(0.26,k,active)

		lerpK[ent] = k

		if active == 0 then
			if hook.Run("HUD Target",ent,k,w,h) ~= true then
				ent:HUDTarget(ent,k or 0,w,h)
			end

			if k <= 0.01 then lerpK[ent] = nil end
		end
	end
end)

local white = Color(255,255,255)

local tbl = {
	["prop_door_rotating"] = "door",
	["class C_BaseEntity"] = "button" // будем надеется что это кнопка
}

hook.Add("HUD Target","Buttons",function(ent,k,w,h)
	local text = tbl[ent:GetClass()]

	if text then
		white.a = 255 * k

		draw.SimpleText(L(text),"HS.18",w / 2,h / 2 - 50 * (1 - k),white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

		return true
	end
end)

hook.Add("CreateMove","Prop Pickup",function(cmd)
	local lply = LocalPlayer()
	if lply:Alive() and IsValid(lply:GetNWEntity("holdPickupObject")) and lply:KeyDown(IN_USE) then
		net.Start("prop_pickup_rotate",true)
		net.WriteString(tostring(cmd:GetMouseX() / 100))
		net.WriteString(tostring(cmd:GetMouseY() / 100))
		net.SendToServer()
	end
end)

hook.Add("InputMouseApply","Prop Pickup",function(cmd)
	local lply = LocalPlayer()
	if lply:Alive() and IsValid(lply:GetNWEntity("holdPickupObject")) and lply:KeyDown(IN_USE) then
		return true
	end
end)
