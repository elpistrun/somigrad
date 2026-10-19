--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/granade/tier_1_content/hl2_explosive_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\granade\\tier_1_content\\hl2_explosive_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local EXP = oop.Reg("explosive_hl2","explosive_base")
if not EXP then return end

EXP.Damage = 100
EXP.RadiusDamage = 500//наносит урон от взрывной волны
EXP.RadiusStun = 600//оглушает взрывной волной

EXP.FragCount = 800
EXP.FragDamage = 45
EXP.FragMaxDistance = 3500

// Client

EXP.ParticleGround = "100lb_air"
EXP.ParticleAir = "100lb_air"

EXP.Earrape = true
EXP.ExplosiveWave = false
EXP.ExplosivePunch = true

EXP.Power = 0

function EXP:EmitSound()
    sound.Emit(nil,"weapons/m67/m67_detonate_0" .. math.random(1,3) .. ".wav",120,1,100,self.pos)
    sound.Emit(nil,"snd_jack_fragsplodeclose.wav",120,1,100,self.pos)
end
