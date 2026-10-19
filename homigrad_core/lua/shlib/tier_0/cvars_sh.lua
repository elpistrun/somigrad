--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_0/cvars_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_0\\cvars_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
function cvars.TransformationArgs(args)
	local newArgs = {}
	local waitClose,waitCloseText

	for i,text in pairs(args) do
		if not waitClose and (string.sub(text,1,1) == "'" or string.sub(text,1,1) == "\"") then
			waitClose = true

			if (string.sub(text,#text,#text) == "'" or string.sub(text,#text,#text) == "\'") then
				newArgs[#newArgs + 1] = string.sub(text,2,#text - 1)

				waitClose = nil
			else
				waitCloseText = string.sub(text,2,#text)
			end

			continue
		end

		if waitClose then
			if (string.sub(text,#text,#text) == "'" or string.sub(text,#text,#text) == "\'") then
				waitClose = nil

				newArgs[#newArgs + 1] = waitCloseText .. " " .. string.sub(text,1,#text - 1)
			else
				waitCloseText = waitCloseText .. " " .. string.sub(text,1,#text)
			end

			continue
		end

		newArgs[#newArgs + 1] = text
	end

	return newArgs
end

//

cvarsOptions = cvarsOptions or {}

local init = Initialize

function cvars.CreateOption(name,def,change,min,max)
    local function update(_,_,value)
		if not init then return end

        if change then change(value) end
    end

    cvarsOptions[name] = cvarsOptions[name] or {}
    cvarsOptions[name]["main"] = change

    cvars.AddChangeCallback(name,update,"option")

    local convar = CreateClientConVar(name,def,true,false,"",tonumber(min),tonumber(max))

    if Initialize then
		if change then change(convar:GetString()) end
	end

    return convar
end

function cvars.Hook(name,change,id)
    local function update(_,_,value)
		if not init then return end

		change(value)
	end

    cvarsOptions[name] = cvarsOptions[name] or {}
    cvarsOptions[name][id] = change

    cvars.AddChangeCallback(name,update,id)

    if Initialize then change(GetConVar(name):GetString()) end
end

hook.Add("OnGamemodeLoaded","CVars Option",function()//vgui в Initialize не загружены...
    print("setup cvars value")
	
	init = true
	
    for name,list in pairs(cvarsOptions) do
        local convar = GetConVar(name)
        if not convar then print("invalid convar " .. name) continue end
        
        local v = convar:GetString()
    
        for id,update in pairs(list) do update(v,true) end
    end

    print("done") 
end)

//

if CLIENT then
	CreateClientConVar("hg_developer","0",true)

	cvars.Hook("hg_developer",function(value)
		developer = tonumber(value) or 0
	end,"main")
end

cvars.Hook("developer",function(value)
    developer = tonumber(value) or 0

	if SERVER then
		if developer <= 0 then developer = 1 end//для вывода ошибок
	else
		local v = GetConVar("hg_developer"):GetInt()

		if v ~= developer then developer = v end
	end
end,"main")

//

