--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/autorun/shlib.lua <
    > Callstack:  <
]]

-- "addons\\homigrad_core\\lua\\autorun\\shlib.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
print("\tshlib start.")
    include("shlib/loader.lua")
    IncludeDir("shlib/")
print("\tslib end")

IncludeDir("hlocalize/")

print("\thomigrad admin panel start.")
    IncludeDir("hadminpanel/")
print("\thomigrad admin panel end.")
