--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/mutator/tier_0_base/init_cl.lua <
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

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\mutator\\tier_0_base\\init_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local MUTATOR = Mutator_Get("base")
if not MUTATOR then return end

function MUTATOR:CoreStart()
    self:ConstructPlug(true)
    self:Start()
end

function MUTATOR:CoreEnd()
    self:ConstructPlug(false)
    self:End()
end

local delaySound = 0

function MUTATOR:InputData(data)
    if self.enabled ~= data.enabled then
        self.enabled = data.enabled

        if self.enabled then
            self:Event_Call("On")
        else
            self:Event_Call("Off")
        end
    end

    if self.Sync then self:Sync(data) end
end

net.Receive("mutator_data",function()
    local className,data = net.ReadString(),net.ReadTable()

    MutatorClasses[className]:InputData(data)
end)

function MUTATOR:SendCMD(cmdName,args)
    net.Start("mutator_cmd")
    net.WriteString(self.ClassName)
    net.WriteString(cmdName)
    net.WriteTable(args)
    net.SendToServer()
end
