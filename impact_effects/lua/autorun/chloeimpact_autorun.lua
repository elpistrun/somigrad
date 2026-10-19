--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/impact_effects/lua/autorun/chloeimpact_autorun.lua <
    > Callstack:  <
]]

-- "addons\\impact_effects\\lua\\autorun\\chloeimpact_autorun.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
--CreateClientConVar("chloeimpact_max_scale", 300, true, false, "Maximum scale for impact effects")
CreateClientConVar("chloeimpact_max_debris_props", 25, true, false, "Maximum debris chunks for impact effects")
CreateClientConVar("chloeimpact_max_debris_effects", 100, true, false, "Maximum dust clouds for impact effects")
CreateClientConVar("chloeimpact_impact_lifetime", 5, true, false, "Time in seconds for impact effects to last")
CreateClientConVar("chloeimpact_impact_debris_lifetime", 5, true, false, "Time in seconds for physical impact effects to last")

local VelScale = CreateConVar("chloeimpact_velocity_scale", 1, FCVAR_ARCHIVE, "Scale for velocity for impacts")
local DmgScale = CreateConVar("chloeimpact_damage_scale", 1, FCVAR_ARCHIVE, "Scale for damage taken from velocity")
local AllowPropImpact = CreateConVar("chloeimpact_prop_impact", 0, FCVAR_ARCHIVE, "(EXPERIMENTAL) Prop/Ragdoll Impact")
local AllowPropLodge = CreateConVar("chloeimpact_prop_lodge", 0, FCVAR_ARCHIVE, "(EXPERIMENTAL) Prop/Ragdoll Lodging")
local AllowPlayerLodge = CreateConVar("chloeimpact_player_lodging", 0, FCVAR_ARCHIVE, "Player Wall Lodging")


if SERVER then return end

function ChloeOptions(panel)
	local box = panel:Help("Clientside options")
	--box = panel:NumSlider("Maximum scale for impact effects", "chloeimpact_max_scale", 1, 1000, 5)
	box = panel:NumSlider("Max derbis", "chloeimpact_max_debris_props", 1, 1000, 5)
	box = panel:NumSlider("Max cloud effect", "chloeimpact_max_debris_effects", 1, 1000, 5)
	--box = panel:NumSlider("Scale of model effects", "chloeimpact_effects_scale", 0.01, 5, 5)
	box = panel:NumSlider("Debris lifetime", "chloeimpact_impact_debris_lifetime", 1, 1000, 5)
	box = panel:NumSlider("Life time", "chloeimpact_impact_lifetime", 1, 1000, 5)
	box = panel:Help("Serverside options")
	box = panel:NumSlider("Scale for velocity thresholds for impacts", "chloeimpact_velocity_scale", 0, 15, 5)
	box = panel:NumSlider("Scale for damage taken from velocity", "chloeimpact_damage_scale", 0, 15, 5)
	box = panel:CheckBox( "Player Wall Lodging", "chloeimpact_player_lodging") 
	box:SetValue(true)
	box = panel:CheckBox( "(EXPERIMENTAL) Prop/Ragdoll Impacts", "chloeimpact_prop_impact") 
	box:SetValue(false)
	box = panel:CheckBox( "(EXPERIMENTAL) Prop/Ragdoll Lodging", "chloeimpact_prop_lodge") 
	box:SetValue(false)
	
end

function ChloeMenu()
	spawnmenu.AddToolMenuOption("Options", "ChloeImpact", "ChloeOptions", "Options", "", "", ChloeOptions)
end

hook.Add("PopulateToolMenu", "ChloeMenu", ChloeMenu)
