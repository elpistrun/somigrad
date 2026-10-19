--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/drgbase/lua/drgbase/dpanels.lua <
    > Callstack: addons/drgbase/lua/autorun/drgbase.lua:93
addons/drgbase/lua/autorun/drgbase.lua:108 <
]]

if SERVER then return end

function DrGBase.DListView(columns, options)
	if not istable(options) then options = {} end
	local dlist = vgui.Create("DListView")
	for i, column in ipairs(columns) do dlist:AddColumn(column) end
	if isstring(options.convar) then
		local convar = GetConVar(options.convar)
		if convar then
			local old_AddLine = dlist.AddLine
			local old_Clear = dlist.Clear
			cvars.AddChangeCallback(options.convar, function(convar, old, new)
				if old == new then return end
				new = util.JSONToTable(new)
				old_Clear(dlist)
				for i, line in ipairs(new) do
					old_AddLine(dlist, unpack(line))
				end
			end)
			function dlist:AddLine(...)
				local tbl = util.JSONToTable(convar:GetString())
				table.insert(tbl, {...})
				convar:SetString(util.TableToJSON(tbl))
			end
			function dlist:RemoveLine(id)
				local tbl = util.JSONToTable(convar:GetString())
				table.remove(tbl, id)
				convar:SetString(util.TableToJSON(tbl))
			end
			function dlist:Clear()
				convar:SetString("[]")
			end
		end
	end
	return dlist
end

