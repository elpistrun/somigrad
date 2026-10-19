--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/fireworks/settings_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad\\lua\\hinit\\fireworks\\settings_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Created = false;

local function garrysfireworkssettings( CPanel )
	sounds={}
	sounds[1]="vo/npc/male01/answer39.wav"
	sounds[2]="vo/npc/male01/answer35.wav"
	sounds[3]="vo/npc/male01/doingsomething.wav"
	sounds[4]="vo/npc/male01/answer38.wav"
	Created = true;

	local logo = vgui.Create( "DImageButton" );
	logo:SetImage( "hud/garrysfw2.png" );
	logo:SetSize( 250, 300 );
	LocalPlayer().clicks = 0
	logo.DoClick = function()
		LocalPlayer().clicks = LocalPlayer().clicks + 1
		if LocalPlayer().clicks >=5 then
			LocalPlayer():ConCommand("kill")
			LocalPlayer():ConCommand("say I'm a click-whore \n")
			LocalPlayer().clicks = 0
			local snd = Sound( "vo/npc/male01/answer11.wav");
			surface.PlaySound( snd );
			
		else			
			local snd = Sound( table.Random(sounds) );
			surface.PlaySound( snd );
		end
	end

	CPanel:AddPanel( logo );
		

	local Night= vgui.Create( "DButton" )
	Night:SetPos( 40, 40 )
	Night:SetText( "Set time to Night" )
    Night:SetSize( 300, 20 )
	Night.DoClick = function()
		net.Start( "gf2_daynight" );
			net.WriteString( "night" );
		net.SendToServer();		
	end
	CPanel:AddPanel( Night )

	local Night= vgui.Create( "DButton" )
	Night:SetPos( 40, 40 )
	Night:SetText( "Set time to Afternoon" )
    Night:SetSize( 300, 20 )
	Night.DoClick = function()
		net.Start( "gf2_daynight" );
			net.WriteString( "day" );
		net.SendToServer();		
	end
	CPanel:AddPanel( Night )	
	
	
	
	local FlareDamage = CPanel:AddControl( "CheckBox", { Label = "Enable destructive flare damage", Command = "gf2_flare_damage" } );
	FlareDamage.OnChange = function( panel, bVal ) 
		if( LocalPlayer():IsSuperAdmin() and !Created ) then
			if( ( bVal and 1 or 0 ) == cvars.Number( "gf2_flare_damage" ) ) then return end
			net.Start( "gf2_cvar" );
				net.WriteString( "gf2_flare_damage" );
				net.WriteFloat( bVal and 1 or 0 );
			net.SendToServer();
		end
	end
	
	local FireworksDamage = CPanel:AddControl( "CheckBox", { Label = "Enable basic fireworks damage", Command = "gf2_damage" } );
	FireworksDamage.OnChange = function( panel, bVal ) 
		if( LocalPlayer():IsSuperAdmin() and !Created ) then
			if( ( bVal and 1 or 0 ) == cvars.Number( "gf2_damage" ) ) then return end
			net.Start( "gf2_cvar" );
				net.WriteString( "gf2_flare_damage" );
				net.WriteFloat( bVal and 1 or 0 );
			net.SendToServer();
		end
	end
	
	local DynamicLight = CPanel:AddControl( "CheckBox", { Label = "Enable fireworks lighting (GPU Intensive)", Command = "gf2_dynamic_light" } );
	DynamicLight.OnChange = function( panel, bVal ) 
		if( LocalPlayer():IsSuperAdmin() and !Created ) then
			if( ( bVal and 1 or 0 ) == cvars.Number( "gf2_dynamic_light" ) ) then return end
			net.Start( "gf2_cvar" );
				net.WriteString( "gf2_dynamic_light" );
				net.WriteFloat( bVal and 1 or 0 );
			net.SendToServer();
		end
	end
	
	local Unwelding = CPanel:AddControl( "CheckBox", { Label = "Enable fireworks un-welding effect", Command = "gf2_deleteconstraints" } );
	Unwelding.OnChange = function( panel, bVal ) 
		if( LocalPlayer():IsSuperAdmin() and !Created ) then
			if( ( bVal and 1 or 0 ) == cvars.Number( "gf2_deleteconstraints" ) ) then return end
			net.Start( "gf2_cvar" );
				net.WriteString( "gf2_deleteconstraints" );
				net.WriteFloat( bVal and 1 or 0 );
			net.SendToServer();
		end
	end
		
	timer.Simple( 0.1, function() 
		if( FlareDamage ) then
			FlareDamage:SetValue(GetConVarNumber( "gf2_flare_damage" ) );
		end
		if( FireworksDamage ) then
			FireworksDamage:SetValue(GetConVarNumber( "gf2_damage" ) );
		end
		if( DynamicLight ) then
			FlareDamage:SetValue(GetConVarNumber( "gf2_dynamic_light" ) );
		end
		if( Unwelding ) then
			FlareDamage:SetValue(GetConVarNumber( "gf2_deleteconstraints" ) );
		end
		Created = false;

	end );

end




hook.Add( "PopulateToolMenu", "PopulateGF2Menus", function()

	spawnmenu.AddToolMenuOption( "Options", "Garry's Fireworks 2", "GF2Settings", "Settings", "", "", garrysfireworkssettings )

end );

hook.Add( "AddToolMenuCategories", "CreateGF2Categories", function()

	spawnmenu.AddToolCategory( "Options", "Garry's Fireworks 2", "Garry's Fireworks 2" );

end );




if (CLIENT) then
	net.Receive( "gf2_daynight_cl", function( len, pl ) 
		timer.Simple(0.5, function()
			render.RedownloadAllLightmaps()
		end)

	
	end )
end

