--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/drgbase/lua/drgbase/modules/string.lua <
    > Callstack: addons/drgbase/lua/autorun/drgbase.lua:93
addons/drgbase/lua/autorun/drgbase.lua:110 <
]]


function string.DrG_Number(nb, size)
	nb = tostring(nb)
	while #nb < size do
		nb = "0"..nb
	end
	return nb
end

