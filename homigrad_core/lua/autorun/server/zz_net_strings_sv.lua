-- Registers every net message name that the client-side addons in this pack send,
-- so the server stops spamming:
--     Calling net.Start with unpooled message name! (Did you forget to call util.AddNetworkString serverside?)
--
-- Most of these belong to addons whose server half is missing here (glua-steal only
-- retrieves AddCSLuaFile'd files), so nothing ever calls util.AddNetworkString for them.
--
-- Registering is safe and idempotent: if another addon on the server already registered
-- the same name, GMod simply ignores the duplicate. This file intentionally does NOT add
-- any net.Receive handler, so it can never shadow a real handler shipped by an addon --
-- it only makes the name known to the string table.
--
-- Once the real server halves are back in place you can delete this file.

if not SERVER then return end

-- Deliberately excludes XEON.Auth / XEON.Error: that is the xeon-drm licensing backdoor
-- and we do not want to give it a working channel.
local names = {
	-- homigrad / homigrad_core
	"Construct respawn",
	"afk",
	"cvars_replicate",
	"database_global_token",
	"database_token",
	"event_comment_add",
	"event_comment_read",
	"event_create",
	"event_cursor",
	"event_group",
	"event_group_spawn",
	"event_playerstime_read",
	"event_plugin_cmd",
	"event_respawn",
	"event_team",
	"jailbreak_door",
	"jailbreak_point",
	"kick tos",
	"mutator_cmd",
	"nextbot_def",
	"prop_pickup_rotate",
	"radio_menu",
	"select_class",
	"shoot_tracer",
	"trade",
	"use",
	"wep deployed",
	"wep holstered",
	"wep holstered end",
	"want change team",

	-- homigrad_adminpanel
	"adminpanel_command",
	"map_block",

	-- homigrad_donat / seasons / missions
	"donat_inventory_outfit",
	"donat_inventory_sync",
	"donatinventory_item_cmd",
	"email_delivered",
	"email_get_items",
	"email_sync",
	"freedrop_sync",
	"mission_item_cmd",
	"mission_sync",
	"shop_buy",

	-- homigrad armour / vape / misc
	"Armor_Toggle",
	"DragonVapeIgnite",
	"VapeTalking",
	"dakimakuras-net",
	"rtxappend",
	"rtxappend2",
	"squid_dummy",

	-- simfphys
	"simfphys_blockcontrols",
	"simfphys_mousesteer",
	"simfphys_request_ppdata",

	-- facades / mapvote
	"rtv add map",
	"rtv vote",

	-- custom_chat
	"customchat.say",
	"customchat.set_emojis",
	"customchat.set_tags",
	"customchat.set_theme",

	-- fprofiler
	"FProfile_focusObj",
	"FProfile_fullModelUpdate",
	"FProfile_getSource",
	"FProfile_printFunction",
	"FProfile_startProfiling",
	"FProfile_stopProfiling",
	"FProfile_unsubscribe",

	-- JMod
	"JMod_ArmorColor",
	"JMod_ColorAndArm",
	"JMod_EZradio",
	"JMod_EZtoolbox",
	"JMod_EZweaponMod",
	"JMod_EZworkbench",
	"JMod_EquippableSync",
	"JMod_Friends",
	"JMod_Inventory",
	"JMod_MachineSync",
	"JMod_ModifyMachine",
	"JMod_NaturalResources",
	"JMod_NuclearBlast",
	"JMod_Ravebreak",
	"JMod_ResourceScanner",
	"JMod_SFX",
	"JMod_UniCrate",
	"JMod_VisionBlur",
	"JMod_VisualGunRecoil",

	-- Fireworks / weapons
	"gf2_cvar",
	"gf2_daynight",
	"wac_admin_setting",
}

for _, name in ipairs(names) do
	util.AddNetworkString(name)
end
