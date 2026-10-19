--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_0/ulx_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_0\\ulx_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local CATEGORY_NAME = "HAPPY-Power"
if not ulx then return end

function ulx.setName( calling_ply, target_ply, name )
local PlayerNick = target_ply:Nick() 
    target_ply:SetNWString("Nick",name)
    ulx.fancyLogAdmin( calling_ply, "#A set "..PlayerNick.." Name to "..name, target_ply, name )
end
local setName = ulx.command( CATEGORY_NAME, "ulx setname", ulx.setName, "!setname" )
setName:addParam{ type=ULib.cmds.PlayerArg }
setName:addParam{ type=ULib.cmds.StringArg, hint="name", ULib.cmds.takeRestOfLine }
setName:defaultAccess( ULib.ACCESS_ADMIN )
setName:help( "Sets target's Name \n SetName By Happy friend1337" )

function ulx.giveAllWeapon(calling_ply, weapon_class)
    if not ULib.ucl.query(calling_ply, "ulx giveallweapon") then
        ULib.tsayError(calling_ply, "сосе лох тупой", true)
        return
    end
    
    for _, ply in ipairs(player.GetAll()) do
        if ply:Alive() then
            ply:Give(weapon_class)
        end
    end
    ulx.fancyLogAdmin(calling_ply, "#A выдал оружие #s всем игрокам", weapon_class)
end

local giveAllWeapon = ulx.command("Fun", "ulx giveallweapon", ulx.giveAllWeapon, "!giveallweapon")
giveAllWeapon:addParam{ type=ULib.cmds.StringArg, hint="weapon_class" }
giveAllWeapon:defaultAccess(ULib.ACCESS_OPERATOR)
giveAllWeapon:help("Выдает указанное оружие всем игрокам.")


function ulx.giveWeapon(calling_ply, target_ply, weapon_class)
    if not ULib.ucl.query(calling_ply, "ulx giveweapon") then
        ULib.tsayError(calling_ply, "сосе лох тупой", true)
        return
    end
    
    if target_ply:Alive() then
        target_ply:Give(weapon_class)
        ulx.fancyLogAdmin(calling_ply, "#A выдал оружие #s игроку #T", weapon_class, target_ply)
    else
        ULib.tsayError(calling_ply, target_ply:Nick() .. " мертв и не может получить оружие.", true)
    end
end

local giveWeapon = ulx.command("Fun", "ulx giveweapon", ulx.giveWeapon, "!giveweapon")
giveWeapon:addParam{ type=ULib.cmds.PlayerArg }
giveWeapon:addParam{ type=ULib.cmds.StringArg, hint="weapon_class" }
giveWeapon:defaultAccess(ULib.ACCESS_OPERATOR)
giveWeapon:help("Выдает указанное оружие конкретному игроку.")

//

function ulx.playermodelall(calling_ply, model)
    if not util.IsValidModel(model) then
        ULib.tsayError(calling_ply, "Invalid model!", true)
        return
    end

    for _, v in ipairs(player.GetAll()) do
        v:SetModel(model)
    end
    ulx.fancyLogAdmin(calling_ply, "#A changed the model of all players to #s", model)
end

local playermodelall = ulx.command("Utility", "ulx playermodelall", ulx.playermodelall, "!playermodelall")
playermodelall:addParam{ type=ULib.cmds.StringArg, hint="model" }
playermodelall:defaultAccess(ULib.ACCESS_ADMIN)
playermodelall:help("Change the model of all players.")

function ulx.playermodel(calling_ply, target_ply, model)
    if not util.IsValidModel(model) then
        ULib.tsayError(calling_ply, "Invalid model!", true)
        return
    end

    target_ply:SetModel(model)
    ulx.fancyLogAdmin(calling_ply, "#A changed the model of #T to #s", target_ply, model)
end

local playermodel = ulx.command("Utility", "ulx playermodel", ulx.playermodel, "!playermodel")
playermodel:addParam{ type=ULib.cmds.PlayerArg, hint="nickname" }
playermodel:addParam{ type=ULib.cmds.StringArg, hint="model" }
playermodel:defaultAccess(ULib.ACCESS_ADMIN)
playermodel:help("Change the model of a specific player.")

function ulx.setmodel( calling_ply, target_plys, message )
	if not ULib.fileExists( message  ) or string.Explode("/",message)[1] != "models" then
		ULib.tsayError( calling_ply, "That model doesn't exist on the server!", true )
		return
	end

	if not message or message == "model path" or message == "" then 
		ULib.tsayError( calling_ply, "No model path given.", true )
		return 
	end

	// I know, the following code looks shitty and inefficient. But is will do for now. If you have suggestions that can improve it, while 
	// maintaining its current functionality, please let me know. It is 3am and I want to sleep :D

	// Names of the players that already have the choosen model.
	local already = {}

	// Players that already have the choosen model.
	local already2 = {}

	local message = string.lower(message)
	
	for k,v in pairs(target_plys) do
		local playermodel = string.lower(target_plys[k]:GetModel())
		if playermodel == message then 
			// Adds some juicy players to the tables (if they already have the choosen model).
			already[#already+1] = v:GetName()
			already2[#already2+1] = v
		else
			// Sets the models of the targeted players (if they don't already have it).
			target_plys[k]:SetModel(tostring(message))
			local string = message
		end
	end
	// Are you still reading this? This tells the calling player that the targeted players already have the choosen model.
	local already_string = table.concat(already, ", ", 1, #already)
	if already_string and already_string != "" then
		ULib.tsay( calling_ply, already_string.." already has/have this model!", true )
	end
	// This removes the players that already have the choosen model from the targeted players. Only the ones that don't have the choosen model remain.
	for k,v in pairs(already2) do
		table.RemoveByValue(target_plys, v)	
	end
	// This logs the executed command in the usual ULX fashion. Nice and easy.
	ulx.fancyLog( {calling_ply }, "#P changed the model of #T to #s", calling_ply, target_plys, message )	
end

local setmodel = ulx.command("Other", "ulx setmodel", ulx.setmodel, "!setmodel", true )
setmodel:addParam{ type=ULib.cmds.PlayersArg}
setmodel:addParam{ type=ULib.cmds.StringArg, hint="model path" }
setmodel:defaultAccess( ULib.ACCESS_ADMIN )
setmodel:help( "Set the model of a player." )
