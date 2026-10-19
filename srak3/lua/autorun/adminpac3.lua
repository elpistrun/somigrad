--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/srak3/lua/autorun/adminpac3.lua <
    > Callstack:  <
]]

if SERVER then
local ranks = {
	["superadmin"] = true,
}
hook.Add("PrePACConfigApply", "PACRankRestrict", function(ply)
	if not ranks[ply:GetUserGroup()] then
              return false,"Insufficient rank to use PAC."
        end
end)

hook.Add( "PrePACEditorOpen", "RestrictToSuperadmin", function( ply )
	if not ranks[ply:GetUserGroup()] then
        return false
  end
end )
end
