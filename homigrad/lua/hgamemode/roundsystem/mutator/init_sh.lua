--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/mutator/init_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\mutator\\init_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
//https://music.youtube.com/watch?v=zQkDun6VPbY&si=a0Oc2ad-Bb_GKDQH

_MutatorClasses = _MutatorClasses or {}
MutatorClasses = MutatorClasses or {}

function Mutator_Reg(class,base,isFolder) return oop.Reg(class,base,isFolder,0,_MutatorClasses) end
function Mutator_Get(class) return oop.Get(class,_MutatorClasses) end

AdminPanel_Command_Registry("mutator")
