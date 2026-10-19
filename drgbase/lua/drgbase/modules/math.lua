--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/drgbase/lua/drgbase/modules/math.lua <
    > Callstack: addons/drgbase/lua/autorun/drgbase.lua:93
addons/drgbase/lua/autorun/drgbase.lua:110 <
]]

-- Misc --

function math.DrG_Cycle(min, max, rate, offset)
	if not isnumber(min) then min = 0 end
	if not isnumber(max) then max = min+1 end
	if min > max then return math.DrG_Cycle(max, min, rate, offset) end
	local pi2 = math.pi*2
	return (((math.sin(((CurTime()-(offset or 0))*pi2*(rate or 1))%pi2)+1)/2)*(max-min))+min
end

