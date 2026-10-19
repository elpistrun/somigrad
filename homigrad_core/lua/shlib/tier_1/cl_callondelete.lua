--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_1/cl_callondelete.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_1\\cl_callondelete.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENTITY = FindMetaTable("Entity")

function ENTITY:CallOnDelete(id,func)
    self._callondeletelist[id] = func
end

function ENTITY:RemoveCallOnDelete(id,func)
    self._callondeletelist[id] = nil
end

local err = function(err) ErrorNoHaltWithStack(err) end

hook.Add("OnEntityCreated","Realy call when remove",function(ent)
    if not IsValid(ent) then return end

    event.Call("Entity Create",ent)
end)

hook.Add("EntityRemoved","Realy call when remove",function(ent,fullUpdate)
    if fullUpdate then return end--https://www.youtube.com/watch?v=alOsTZlgxqQ

    event.Call("Entity Remove",ent)
end)

event.Add("Entity Create","Really call when remove",function(ent)
    ent._callondeletelist = {}
end,-10)

event.Add("Entity Remove","Really call when remove",function(ent)
    local tbl = ent._callondeletelist
    if not tbl then return end//mdam

    for id,func in pairs(tbl) do xpcall(func,err,ent) end
end)
