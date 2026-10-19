--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_0/tier_0/net/tier_0_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_0\\tier_0\\net\\tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SafeFromSend
SafeFromSend = function(parent)
    local type = TypeID(parent)

    if type == TYPE_FUNCTION then
        return nil
    elseif type == TYPE_DAMAGEINFO then
        return nil
    elseif type == TYPE_TABLE then
        for k,v in pairs(parent) do
            k = SafeFromSend(k)
            if not k then parent[k] = nil continue end

            parent[k] = SafeFromSend(v)
        end
    end

    return parent
end

function net.SafeFromSend(tbl)
    local new = util.tableCopy(tbl)
    
    SafeFromSend(new)

    return new
end
