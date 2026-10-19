--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/mutator/tier_0_base/event_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hgamemode/roundsystem/mutator/tier_0_base/tier_0_sh.lua:5
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\mutator\\tier_0_base\\event_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local MUTATOR = Mutator_Get("base")
if not MUTATOR then return end

MUTATOR.EventPlug = {}
MUTATOR.HookPlug = {}

MUTATOR:Event_Add("On","Event",function(self)
    for name,nameFunc in pairs(self.EventPlug) do
        if not nameFunc then continue end
        event.Add(name,"Mutator",function(...) return self[nameFunc](self,...) end)
    end

    for name,nameFunc in pairs(self.HookPlug) do
        if not nameFunc then continue end
        hook.Add(name,"Mutator",function(...) return self[nameFunc](self,...) end)
    end
end,-1)

MUTATOR:Event_Add("Off","Event",function(self)
    for name,nameFunc in pairs(self.EventPlug) do
        if not nameFunc then continue end
        event.Remove(name,"Mutator")
    end

    for name,nameFunc in pairs(self.HookPlug) do
        if not nameFunc then continue end
        hook.Remove(name,"Mutator")
    end
end,1)

