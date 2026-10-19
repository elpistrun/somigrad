--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/drgbase/lua/drgbase/modules/coroutine.lua <
    > Callstack: addons/drgbase/lua/autorun/drgbase.lua:93
addons/drgbase/lua/autorun/drgbase.lua:110 <
]]


local INCR_ID = 0
local COROUTINES = {}
hook.Add("Think", "DrGBaseCoroutines", function()
	for id, todo in pairs(COROUTINES) do
		local status = coroutine.status(todo.cor)
		if status == "suspended" then
			local ok, args = coroutine.resume(todo.cor)
			if coroutine.status(todo.cor) == "dead" and
			isfunction(todo.call) then
				todo.call(ok, args)
			end
		elseif status == "dead" then
			coroutine.DrG_Remove(id)
		end
	end
end)

function coroutine.DrG_Create(todo, call)
	local cor = coroutine.create(todo)
	local id = INCR_ID
	INCR_ID = INCR_ID+1
	COROUTINES[id] = {
		cor = cor, call = call
	}
	return cor, id
end
function coroutine.DrG_Remove(id)
	COROUTINES[id] = nil
end

