--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/levels/tdm/tier_0_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\levels\\tdm\\tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Level = oop.Reg("level_tdm","level_base",true)
if not Level then return INCLUDE_BREAK end

Level.ShouldSpawnLoot = true
Level.PropBreakLoot = true
Level:SetEndType("team")

Level.red = {
	"terrorist",Color(255,75,75),
	weapons = {"weapon_transmitter","weapon_hands","med_band","med_band","med_kit","med_painkiller"},
	classes = {
		{
			"class_solder",
			main_weapon = {"wep_ak47","wep_m4a1","wep_scar","wep_val"},
			armors = {
				"ent_jack_gmod_ezarmor_zshhelm",
				"Medium-Vest",
				"ent_jack_gmod_ezarmor_thunderbolt"
			}
		},
		{
			"class_scout",
			main_weapon = {"wep_bizon","wep_mp5","wep_mac10"},
			armors = {
				"Medium-Helmet",
				"Light-Vest",
				"ent_jack_gmod_ezarmor_commandoblack"
			}
		},
		{
			"class_support",
			main_weapon = {"wep_870","wep_xm1014","wep_mag7","wep_neg"},
			armors = {
				"ent_jack_gmod_ezarmor_6b47chehol",
				"Medium-Vest",
				"ent_jack_gmod_ezarmor_thunderbolt",
				"ent_jack_gmod_ezarmor_llshoulder",
				"ent_jack_gmod_ezarmor_lrshoulder",
				"ent_jack_gmod_ezarmor_slforearm",
				"ent_jack_gmod_ezarmor_srforearm",
				"ent_jack_gmod_ezarmor_redutt5pelvis",
				"ent_jack_gmod_ezarmor_twexfilshieldb"
			}
		}
	},
	selectLink = 1,
	secondary_weapon = {"wep_fiveseven","wep_glock" , "wep_deagl"},
	models = Level.StandardPlayerModels
}

Level.blue = {
	"contr_terrorist",Color(75,75,255),
	weapons = Level.red.weapons,
	classes = Level.red.classes,
	selectLink = 1,
	secondary_weapon = Level.red.secondary_weapon,
	armors = Level.red.armors,
	models = Level.red.models
}

Level.teamEncoder = {
	[1] = "red",
	[2] = "blue"
}

if SERVER then return end

function Level:HUDPaint(white)
    local lply = LocalPlayer()
	local name,color = self:GetTeamName(lply)

    self:DrawLoadScreen()
	self:DrawRoundTime()
	self:DrawCenter()
end

function Level:DrawScreen(lply,k)
    local name,color = self:GetTeamName(lply)

    local w,h = ScrW(),ScrH()

	draw.DrawText(L("you",L(lply:GetNWString("ClassName"))),"H.25",w / 2,h / 2 - h / 6,cname,TEXT_ALIGN_CENTER)
 
    draw.DrawText(L("you_team",L(name)),"H.25",w / 2,h / 2,cname,TEXT_ALIGN_CENTER)
    draw.DrawText(L("level_tdm"),"H.45",w / 2,h / 8,cblue,TEXT_ALIGN_CENTER)

    draw.DrawText(L("tdm_loadscreen"), "H.25",w / 2,h / 1.2,cgray,TEXT_ALIGN_CENTER)
end
