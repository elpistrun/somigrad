--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_0/sh_localize.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_0\\sh_localize.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
LOCALIZE = LOCALIZE or {}

local gmod_language = GetConVar("gmod_language")
local l

LanguageDefault = LanguageDefault or "ru"
function GetLanguage() return ForceLanguageGMOD or gmod_language:GetString() end

function updateL(value)
    l = LOCALIZE[value] or LOCALIZE[LanguageDefault] or {}

    local format = string.format
    function L(text,arg1,arg2,arg3) return format(l[text] or text,arg1 or "",arg2 or "",arg3 or "") end
    function LFast(text) return (l[text] or text) end
end

updateL(GetLanguage())

cvars.AddChangeCallback("gmod_language",function(_,old,new)
    timer.Simple(0,function() updateL(GetLanguage()) end)
end,"homigrad")

event.Add("Server Status Write","Localize",function(tbl)
    tbl.lang = GetLanguage()//sh_localize
end)
