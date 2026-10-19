--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/fprofiler/lua/autorun/fprofiler.lua <
    > Callstack:  <
]]

-- "addons\\fprofiler\\lua\\autorun\\fprofiler.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
FProfiler = FProfiler or {}
FProfiler.Internal = {}
FProfiler.UI = {}

AddCSLuaFile()
AddCSLuaFile("fprofiler/cami.lua")
AddCSLuaFile("fprofiler/gather.lua")
AddCSLuaFile("fprofiler/report.lua")
AddCSLuaFile("fprofiler/util.lua")
AddCSLuaFile("fprofiler/prettyprint.lua")

AddCSLuaFile("fprofiler/ui/model.lua")
AddCSLuaFile("fprofiler/ui/frame.lua")
AddCSLuaFile("fprofiler/ui/clientcontrol.lua")
AddCSLuaFile("fprofiler/ui/servercontrol.lua")

include("fprofiler/cami.lua")

CAMI.RegisterPrivilege{
    Name = "FProfiler",
    MinAccess = "superadmin"
}


include("fprofiler/prettyprint.lua")
include("fprofiler/util.lua")
include("fprofiler/gather.lua")
include("fprofiler/report.lua")


if CLIENT then
    include("fprofiler/ui/model.lua")
    include("fprofiler/ui/frame.lua")
    include("fprofiler/ui/clientcontrol.lua")
    include("fprofiler/ui/servercontrol.lua")else
    -- the server half of the UI is not shipped with this copy of fprofiler
    if file.Exists( "fprofiler/ui/server.lua", "LUA" ) then
        include( "fprofiler/ui/server.lua" )
    end
end

