--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_2_world/render/lights/lightshadows_cl.lua <
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

-- "addons\\homigrad_core\\lua\\shlib\\tier_2_world\\render\\lights\\lightshadows_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
LightMapList = LightMapList or {}

for tab in pairs(LightMapList) do
    pcall(tab.Remove,tab)

    LightMapList[tab] = nil
end

local example = {}

function example:CallFunction(name,...)
    for i,lamp in pairs(self.lamps) do lamp[name](lamp,...) end
end

function example:SetPos(pos)
    self.pos = pos
    self:CallFunction("SetPos",pos)
end

function example:SetDis(dis) self:CallFunction("SetFarZ",dis) self.size = dis return self end
function example:Update(pos) self:CallFunction("Update") end
function example:SetTexture(texture) self:CallFunction("SetTexture",texture) return self end
function example:SetColor(color)
    self:CallFunction("SetColor",color)
    
    self.r = color.r
    self.g = color.g
    self.b = color.b

    return self
end

function example:SetBrightness(value)
    self.brightness = value

    self:CallFunction("SetBrightness",value)

    return self
end

function example:Remove()
    if self.removed then return end
    
    LightMapList[self] = nil
    self.removed = true

    for i,lamp in pairs(self.lamps) do lamp:Remove() end
end

function example:IsValid() return not self.removed end

function example:Think()
    if not self.spawned then return end
    if not self.start then self.start = RealTime() end

    local decay = (1000 / self.decay)
    local k = (self.start + decay - RealTime()) / decay
    k = math.Clamp(k * self.k,0,1)
    
    if k <= 0 then self:Remove() return end

    /*self:TranslationUpdate()--follow or part shit func
    self:CallFunction("SetBrightness",math.Clamp(self.brightness * k,0,self.brightness))

    self:Update()*/
end

function example:Spawn()
    self.spawned = true
    self:Update()
end

function example:AddLamp()
    self.lamps[#self.lamps + 1] = HProjectedTexture()
end 

local selector = {
    Angle(0,0,0),
    Angle(0,120,0),
    Angle(0,240,0),
    Angle(90,0,0),
    Angle(-90,0,0),
}

local Rand = math.Rand

function DynamicLamp(pos,dis,decay,k,drawZ)
    local tab = {lamps = {}}
    LightMapList[tab] = true

    for k,v in pairs(example) do tab[k] = v end

    for i = 1,(drawZ and 4 or 5) do tab:AddLamp() end

    tab:CallFunction("SetNearZ",1)
    tab:CallFunction("SetEnableShadows",true)
    tab:CallFunction("SetFOV",140)

    tab.k = k or 1

    local k = Rand(-180,180)

    for i,lamp in pairs(tab.lamps) do
        lamp:SetAngles(selector[i] + Angle(0,k,Rand(-45,45)))
    end
    
    tab.decay = decay or 1000
    tab.d = 1000 / decay
    tab.dietime = CurTime() + tab.d
    tab.shadow = true

    tab:SetDis(dis)
    tab:SetPos(pos)
    tab:SetTexture("effects/flashlight001")
    tab:SetBrightness(1)
    tab:Update()

    DynamicLightMap[tab] = tab

    return tab
end

hook.Add("PreDrawOpaqueRenderables","LightMapList",function()
    for tab in pairs(LightMapList) do tab:Think() end
end)

/*timer.Create("Test",1 / 55,0,function()//херли тогда лагает блядь если ему тут похуй
    DynamicLamp(Vector(321.960632,-1639.224487,350),512,0.1,100,true):Spawn()
end)*/

--применять для очень быстрого появления освещения, иначе лагать будет.

hook.Add("PostCleanupMap","Remove LightShadow",function()
    for tab in pairs(LightMapList) do
        pcall(tab.Remove,tab)
    
        LightMapList[tab] = nil
    end
end)

concommand.Add("hg_lightshadow_getinfo",function()
    print("lightshadow count " .. table.Count(LightMapList))
end)
