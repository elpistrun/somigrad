--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/nextbots/contents/touhou/npc_yuyuko_sh.lua <
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

-- "addons\\homigrad\\lua\\hinit\\nextbots\\contents\\touhou\\npc_yuyuko_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("npc_yuyuko","npc_fumo")
if not ENT then return end

if SERVER then resource.AddWorkshop("2892187389") end

ENT.PrintName = "yuyuko"
ENT.IconOverride = "homigrad/scp/touhou/npc_yuyuko.png"

ENT.Speed = 800
ENT.Acceleration = 1000
ENT.Deceleration = 1000

ENT.FastSpeed = 1250
ENT.FastAcceleration = 1250
ENT.FastDeceleration = 1250

ENT.JumpSound = Sound("npc_yuyuko/jump.mp3")
ENT.JumpHighSound = Sound("homigrad/scp/yuyuko/spring.wav")

ENT.AttackSounds = {
	Sound("homigrad/scp/sakuya/pieceofcake.mp3"),
}

ENT.TauntSounds = {
	Sound("homigrad/scp/yuyuko/comeback.wav"),
	Sound("homigrad/scp/yuyuko/gotcha.wav"),
	Sound("homigrad/scp/yuyuko/hahey.wav"),
	Sound("homigrad/scp/yuyuko/hello.wav"),
	Sound("homigrad/scp/yuyuko/pieceofcake.wav")
}

ENT.Music =  Sound("npc_yuyuko/panic.mp3")
ENT.SpriteMat = Material("homigrad/scp/touhou/npc_yuyuko.png","smooth mips")
