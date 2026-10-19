--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/tools/lua/autorun/client/cl_permaload.lua <
    > Callstack:  <
]]

-- "addons\\tools\\lua\\autorun\\client\\cl_permaload.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
/*
   ____          _          _   ____          __  __       _ _                     
  / ___|___   __| | ___  __| | | __ ) _   _  |  \/  | __ _| | |__   ___  _ __ ___  
 | |   / _ \ / _` |/ _ \/ _` | |  _ \| | | | | |\/| |/ _` | | '_ \ / _ \| '__/ _ \ 
 | |__| (_) | (_| |  __/ (_| | | |_) | |_| | | |  | | (_| | | |_) | (_) | | | (_) |
  \____\___/ \__,_|\___|\__,_| |____/ \__, | |_|  |_|\__,_|_|_.__/ \___/|_|  \___/ 
                                      |___/                                        
*/
--пашол нахуй

if not PermaProps then PermaProps = {} end


for k, v in pairs(file.Find("permaprops/cl_*.lua", "LUA")) do
	
	include("permaprops/".. v)


end


for k, v in pairs(file.Find("permaprops/sh_*.lua", "LUA")) do
	
	include("permaprops/".. v)

end
