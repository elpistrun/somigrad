--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_1/cvars_replicate_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_1\\cvars_replicate_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
cvars.replicates = cvars.replicates or {}

function cvars.SendValue(name,value)
    net.Start("cvars_replicate")
    net.WriteString(name)
    net.WriteString(value)
    net.SendToServer()
end

function cvars.CreateReplicateOption(name,def,change,min,max,typeRep)
    cvars.replicates[name] = typeRep and 1 or 0

    cvars.CreateOption(name,def,function(value,first)
        if first then return end

        cvars.SendValue(name,value)
    end,min,max)
end

event.Add("Send Data","cvars_replicate",function()
    for name,typeRep in pairs(cvars.replicates) do
        if typeRep == 1 then continue end

        cvars.SendValue(name,GetConVar(name):GetString())
    end
end)


