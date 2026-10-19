--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/nextbots/contents/touhou/npc_sakuyanextbot_sh.lua <
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

-- "addons\\homigrad\\lua\\hinit\\nextbots\\contents\\touhou\\npc_sakuyanextbot_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("npc_sakuyanextbot","npc_fumo")
if not ENT then return end

if SERVER then resource.AddWorkshop("2828448531") end

ENT.PrintName = "sakuyanextbot"
ENT.IconOverride = "homigrad/scp/touhou/sakuya.png"

ENT.Speed = 900
ENT.Acceleration = 900
ENT.Deceleration = 900

ENT.RandomDashInterval = {7,8}

ENT.FastSpeed = 1250
ENT.FastAcceleration = 1250
ENT.FastDeceleration = 1250

ENT.AngrySpeed = 1500
ENT.Acceleration = 1500
ENT.Deceleration = 1500

ENT.ScanTargetDistance = 9999
ENT.MusicDistance = 9999

ENT.JumpSound = Sound("homigrad/scp/sakuya/jump.mp3")
ENT.JumpHighSound = Sound("homigrad/scp/yuyuko/spring.wav")

ENT.AttackSounds = {
	Sound("homigrad/scp/sakuya/pieceofcake.mp3"),
}

ENT.Music = Sound("npc_sakuyanextbot/panic.mp3")
ENT.SpriteMat = Material("homigrad/scp/touhou/sakuya.png","smooth mips")
