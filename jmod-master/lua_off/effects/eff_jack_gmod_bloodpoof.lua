--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/jmod-master/lua/effects/eff_jack_gmod_bloodpoof.lua <
    > Callstack:  <
]]

function EFFECT:Init(data)
	local NumParticles = 3000
	local emitter = ParticleEmitter(data:GetOrigin())
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end

