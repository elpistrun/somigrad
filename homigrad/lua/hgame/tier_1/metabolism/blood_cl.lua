--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/metabolism/blood_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\metabolism\\blood_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
AdminPanel_Command_Registry("fullup",{"players^"},"game",nil,"admin_operator")

local math_Clamp = math.Clamp
local tab2 = {
	[ "$pp_colour_addr" ] = 0,
	[ "$pp_colour_addg" ] = 0,
	[ "$pp_colour_addb" ] = 0,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] = 1,
	[ "$pp_colour_colour" ] = 1,
	[ "$pp_colour_mulr" ] = 0,
	[ "$pp_colour_mulg" ] = 0,
	[ "$pp_colour_mulb" ] = 0
}

local max = math.max

hook.Add("RenderScreenspaceEffects","Blood",function()
	local ply = LocalPlayer()
	if not ply:Alive() then return end

	if hook.Run("Should Draw Screenspace") == false then return end

	tab2["$pp_colour_colour"] = math.Clamp(ply:Health() / ply:GetMaxHealth(),0,1)

	DrawColorModify(tab2)

	local fraction = math_Clamp(1 - max(ply:GetNWFloat("blood",5000) - 3000,0) / 2000,0,1)
	fraction = math.max(fraction - 0.2,0) / 0.8

	if fraction > 0 then RenderScreenspaceEffects_DrawBlur(fraction) end
end)

hook.Add("ScalePlayerDamage","no_effects",function(ent,dmginfo) return true end)

local cvar = CreateClientConVar("hg_organisminfo","0")
local white = Color(255,255,255)

local function drawStates(ply,x,y,align)
	draw.SimpleText("health: " .. ply:Health(),"ChatFont",x,y,white,align)
	draw.SimpleText("pain: " .. ply:GetNWFloat("pain",0),"ChatFont",x,y + 25 * 1,white,align)
	draw.SimpleText("painlosing: " .. ply:GetNWFloat("painlosing",0),"ChatFont",x,y + 25 * 2,white,align)
	draw.SimpleText("adrenaline: " .. ply:GetNWFloat("adrenaline",0),"ChatFont",x,y + 25 * 3,white,align)
	draw.SimpleText("stamina: " .. ply:GetNWFloat("stamina",0),"ChatFont",x,y + 25 * 4,white,align)
	draw.SimpleText("bleed: " .. ply:GetNWFloat("bleed",0),"ChatFont",x,y + 25 * 5,white,align)
	draw.SimpleText("blood: " .. ply:GetNWFloat("blood",0),"ChatFont",x,y + 25 * 6,white,align)
	draw.SimpleText("impulse: " .. ply:GetNWFloat("impulse",0),"ChatFont",x,y + 25 * 7,white,align)
	draw.SimpleText("pulse: " .. 1 / ply:GetNWFloat("pulse",0),"ChatFont",x,y + 25 * 8,white,align)
	draw.SimpleText("otrub: " .. tostring(ply:GetNWBool("Otrub",false)),"ChatFont",x,y + 25 * 9,white,align)
	draw.SimpleText("hungry: " .. tostring(ply:GetNWFloat("hungry",0)),"ChatFont",x,y + 25 * 10,white,align)
	draw.SimpleText("o2: " .. tostring(ply:GetNWFloat("o2",0)),"ChatFont",x,y + 25 * 11,white,align)
	draw.SimpleText("brain: " .. tostring(ply:GetNWFloat("brain",0)),"ChatFont",x,y + 25 * 12,white,align)
	draw.SimpleText("poison: " .. tostring(ply:GetNWFloat("poison",0)),"ChatFont",x,y + 25 * 13,white,align)
	draw.SimpleText("healthreg: " .. tostring(ply:GetNWFloat("HealthReg",0)),"ChatFont",x,y + 25 * 14,white,align)
end

hook.Add("HUDPaint","Dev",function()
	local ply = LocalPlayer()

	if not ply:IsSuperAdmin() or not cvar:GetBool() then return end

	drawStates(ply,45,45)

	local ply = ply:GetEyeTrace().Entity
	if not IsValid(ply) then return end

	ply = RagdollOwner(ply) or ply 
	if not ply:IsPlayer() then return end

	drawStates(ply,scrw - 45,45,TEXT_ALIGN_RIGHT)
end)
