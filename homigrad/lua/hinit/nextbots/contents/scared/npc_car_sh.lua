--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/nextbots/contents/scared/npc_car_sh.lua <
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

-- "addons\\homigrad\\lua\\hinit\\nextbots\\contents\\scared\\npc_car_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENT = oop.Reg("npc_car","npc_kevin")
if not ENT then return end

ENT.PrintName = "car"
ENT.IconOverride = "homigrad/scp/scared/car.png"

ENT.FootStep = false

ENT.JumpSound = Sound("npc_flandrenextbot/jump.mp3")
ENT.JumpHighSound = Sound("npc_flandrenextbot/spring.mp3")
ENT.TauntSounds = {
	{
		Sound("homigrad/scp/kevin/killed1.wav"),
		0,
		function(ent)
			local pos = ent:GetPos() + ent:OBBCenter()

			blood_Explode(pos,pos + Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)))
			blood_Explode(pos,pos + Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)))

			net.Start("kevin impact",true)
			net.WriteVector(pos)
			net.Broadcast()
		end
	},
	{
		Sound("homigrad/scp/kevin/killed3.wav"),
		0,
		function(ent)
			local pos = ent:GetPos() + ent:OBBCenter()

			blood_Explode(pos,pos + Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)))
			blood_Explode(pos,pos + Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)))

			net.Start("kevin impact",true)
			net.WriteVector(pos)
			net.Broadcast()
		end
	},
	{
		Sound("homigrad/scp/kevin/killed4.wav"),
		0,
		function(ent)
			local pos = ent:GetPos() + ent:OBBCenter()
			
			blood_Explode(pos,pos + Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)))
			blood_Explode(pos,pos + Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)))

			net.Start("kevin impact",true)
			net.WriteVector(pos)
			net.Broadcast()
		end
	},
}

ENT.Music = Sound("homigrad/scp/car/pain.wav")
ENT.SpriteMat = Material("homigrad/scp/scared/car.png")

ENT.MusicFade = 5

function ENT:DrawSprite(pos,normal,size,color,rot)
	local follow = self:GetNWString("State") == "Follow"
	if LocalPlayer():Alive() and not follow then return end

	if not LocalPlayer():Alive() then
		render.DrawQuadEasy(pos,normal,size * 2 + math.Rand(-1,1) * 25,follow and size * 3 + math.Rand(-1,1) * 25 or size,color,rot + math.sin(CurTime() * 1000 + math.Rand(-1,1)) * 2)
	else
		local volume = oop.listClass[self.ClassName][1]--OMG
		volume = volume.panicMusic and volume.panicMusic.volume or 1
		
		size = size * volume

		size = size * (math.Clamp((1000 - pos:Distance(EyePos())) / 1000,0,1) * 4)

		render.DrawQuadEasy(pos,normal,size * 5 + math.Rand(-1,1) * 25,follow and size * 3 + math.Rand(-1,1) * 25 or size,color,rot + math.sin(CurTime() * 1000 + math.Rand(-1,1)) * 2)
	end
end

