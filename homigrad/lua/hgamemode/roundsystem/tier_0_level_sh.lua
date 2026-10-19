--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/tier_0_level_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\tier_0_level_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
Levels = Levels or {}

local xpcall = xpcall
local err = function(err) ErrorNoHaltWithStack(err) end
local empty = {}

function TableLevel(name) return Levels[name or roundActiveName] or empty end

function LevelCall(event,...)
    //local result = level:Event_Call(event,...)
    //if result ~= nil then return result end

    if not ActiveLevel then return end

    local func = ActiveLevel[event]
    if not func then return end

    -- xpcall первым значением отдаёт статус: если вернуть его как есть,
    -- вызывающий получает true вместо данных уровня (из-за этого EndData
    -- всегда терялся и roundDataEnd уходил клиенту пустым).
    local ok,result = xpcall(func,err,ActiveLevel,...)
    if not ok then return end

    return result
end
