--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/levels/_special/event/tier_1_system/panel/nav/6plugin/0_base/tier_0_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\levels\\_special\\event\\tier_1_system\\panel\\nav\\6plugin\\0_base\\tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Plugin = EventPlugin_Reg("base",nil,true)
if not Plugin then return INCLUDE_BREAK end

util.tableLink(Plugin,oop.listClass.lib_event[1])

Plugin.ClassName = "base"

function Plugin:Sync(data) end

Plugin:Event_Add("Construct","EventPluginsClasses",function(self)
    if not EventPluginsClasses[self.ClassName] then
        EventPluginsClasses[self.ClassName] = {}
    end

    util.tableLink(EventPluginsClasses[self.ClassName],self[1])
end)

if SERVER then return end

function Plugin:InputData(data)
    if self.enabled ~= data.enabled then
        if data.enabled then
            self:Event_Call("On")
        else
            self:Event_Call("Off")
        end
    end

    self.enabled = data.enabled
    
    self:Sync(data)
end

function Plugin:SendCMD(cmdName,args)
    net.Start("event_plugin_cmd")
    net.WriteString(self.ClassName)
    net.WriteString(cmdName)
    net.WriteTable(args)
    net.SendToServer()
end

net.Receive("event_plugin",function()
    local plugin = EventPluginsClasses[net.ReadString()]

    plugin:InputData(net.ReadTable())
    event.Call("Event Plugin Sync",plugin)
end)

