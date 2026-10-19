--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/nextbots/tier_0_npc_alternate/tier_0_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad\\lua\\hinit\\nextbots\\tier_0_npc_alternate\\tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("npc_alternate",{"base_nextbot","lib_event"},true)
if not ENT then return INCLUDE_BREAK end

NextBotSpeedMul = 0.5

ENT.PrintName = "Alternate"
ENT.Category = "NextBot"
ENT.Spawnable = false
ENT.IconOverride = "homigrad/scp/scared/alternate.png"

//

ENT.JumpSound = false
ENT.JumpHighSound = false

ENT.TauntInterval = 15

ENT.AttackSounds = {
	Sound("homigrad/scp/alternate/pieceofcake.mp3")
}

ENT.SpriteSize = 128
ENT.SpriteMat = Material("homigrad/scp/scared/alternate.png")

ENT.Music = Sound("homigrad/scp/alternate/panic.mp3")
ENT.MusicDistance = 3000
ENT.MusicLevel = 125
ENT.MusicVolume = 1
ENT.MusicRestartDelay = 2
ENT.MusicHide = true

// Move

ENT.Speed = 750
ENT.Acceleration = 800
ENT.Deceleration = 800

ENT.DamageDoor = 10

ENT.AttackDistance = 80
ENT.AttackForce = 800
ENT.AttackInterval = 0.2
ENT.AttackProps = true

ENT.AllowJump = true

ENT.DashInAir = true
ENT.DashInterval = 3
ENT.DashSpeed = 1024
ENT.DashNonGravityInterval = 0.25
ENT.RandomDashInterval = {10,15}

ENT.ScanHiddingInterval = 3
ENT.RepathHiddingInterval = 1

ENT.ScanTargetInterval = 1
ENT.ScanTargetDistance = 2500
ENT.RepathInterval = 0.1

ENT.PathInfractionTimeout = 5

ENT.MaxHealth = 1e8

ENT.PhysgunDisabled = true
ENT.AutomaticFrameAdvance = false

function ENT:CanSee(ent,pos)
	local pen = sound.Trace((ent or self):GetPos(),1024,5,{[self] = true},pos)

	if pen <= 0.1 then
		return true
	else
		return false
	end
end

NextBotsClassList = NextBotsClassList or {}

ENT:Event_Add("Construct","NextBot",function(class)
	local class = class[1]

	list.Set("NPC",class.ClassName,{
		Name = class.PrintName,
		Class = class.ClassName,
		Category = class.Category,
		AdminOnly = false,
		IconOverride = class.IconOverride
	})

	NextBotsClassList[class.ClassName] = class
end)
