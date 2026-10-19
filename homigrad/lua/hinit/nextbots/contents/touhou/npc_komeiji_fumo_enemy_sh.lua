--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/nextbots/contents/touhou/npc_komeiji_fumo_enemy_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad\\lua\\hinit\\nextbots\\contents\\touhou\\npc_komeiji_fumo_enemy_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("npc_komeiji_fumo_enemy","npc_fumo")
if not ENT then return end

if SERVER then resource.AddWorkshop("2830488783") end

ENT.PrintName = "komeiji enemy"
ENT.IconOverride = "homigrad/scp/touhou/komeiji.png"

ENT.Speed = 800
ENT.Acceleration = 800
ENT.Deceleration = 800

ENT.FastSpeed = 1250
ENT.FastAcceleration = 1250
ENT.FastDeceleration = 1250

ENT.JumpSound = Sound("npc_komeiji_fumo_friendly/jump.mp3")

ENT.AttackSounds = {
	Sound("homigrad/scp/sakuya/jump.mp3")
}

ENT.TauntSounds = {
	Sound("homigrad/scp/komeiji/enemy/fumo.wav")
}

ENT.Music = Sound("homigrad/scp/komeiji/enemy/panic.wav3")
ENT.SpriteMat = Material("homigrad/scp/touhou/komeiji.png","smooth mips")

ENT.MaxHealth = 6000
