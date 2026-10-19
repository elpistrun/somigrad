--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_2_world/render/particles/particles_light_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_2_world\\render\\particles\\particles_light_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local min,max = math.min,math.max

local calculateLightMin,calculateLightMax
cvars.CreateOption("hg_particle_calculatelight_min","0.4",function(value) calculateLightMin = tonumber(value) end,0,1)
cvars.CreateOption("hg_particle_calculatelight_max","0.5",function(value) calculateLightMax = tonumber(value) end,0,1)

local changeColorMin,changeColorMax
cvars.CreateOption("hg_particle_changecolor_min","0.1",function(value) changeColorMin = tonumber(value) end,0,1)
cvars.CreateOption("hg_particle_changecolor_max","0.25",function(value) changeColorMax = tonumber(value) end,0,1)

//

local Rand,random = math.Rand,math.random
local Lerp = Lerp

local lerpK = 0.5

ParticleLightGet = function(self,time)
    if not self.fR then//first Color
        self.fR = self.r
        self.fG = self.g
        self.fB = self.b
    end

    local t = 1 - max((self.create + self.dietime - time) / self.dietime,0)
    local matrix = LightCalculate(self:GetPos(),Lerp(t,self.startSize,self.endSize) / 2)
    return LightApply(matrix,self.fR,self.fG,self.fB,Lerp(t,self.startAlpha,self.endAlpha) / 255 * self.LightFlashMul)
end

local ParticleLightGet = ParticleLightGet

ParticleLight_Fast = function(self,time)
    local sR,sG,sB = ParticleLightGet(self,time)

    local lerpK = lerpK
    if not self.firstColorTime then lerpK = 1 self.firstColorTime = true end//чтоб при спавне сразу сетать ему цвет
    self:SetColor(Lerp(lerpK,self.r,sR),Lerp(lerpK,self.g,sG),Lerp(lerpK,self.b,sB))
end

ParticleLight_Slow = function(self,time)
    if (self.computeLightTime or 0) <= time then
        self.computeLightTime = time + Rand(calculateLightMin,calculateLightMax)

        local sR,sG,sB = ParticleLightGet(self,time)
        self.sR = sR
        self.sG = sG
        self.sB = sB
    end
    
    if (self.computeSetColor or 0) <= time then
        self.computeSetColor = time + Rand(changeColorMin,changeColorMax)

        local lerpK = lerpK
        if not self.firstColorTime then lerpK = 1 self.firstColorTime = true end//чтоб при спавне сразу сетать ему цвет
        self:SetColor(Lerp(lerpK,self.r,self.sR),Lerp(lerpK,self.g,self.sG),Lerp(lerpK,self.b,self.sB))
    end
end
