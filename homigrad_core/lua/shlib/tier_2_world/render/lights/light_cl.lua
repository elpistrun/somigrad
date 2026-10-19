--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_2_world/render/lights/light_cl.lua <
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

-- "addons\\homigrad_core\\lua\\shlib\\tier_2_world\\render\\lights\\light_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
if not HDynamicLight then HDynamicLight = DynamicLight end

DynamicLightMap = {}
local DynamicLightMap = DynamicLightMap

local timer_Create = timer.Create
local CurTime = CurTime
local max = math.max

local function Spawn(self)
    local entid = self.entid

    timer.GameSimpleRemove(self.timerID)

    local ent = Entity(entid)
    if not IsValid(ent) or ent:IsDormant() then return end--x3x3

    self.pos = self.pos or self.Pos or ent:GetPos()
    self.decay = self.decay or self.Decay
    self.brightness = self.brightness or self.Brightness--pizdes
    self.dietime = self.dietime or self.DieTime or (CurTime() + 1000 / self.decay)
    self.size = self.size or self.Size
    self.d = 1000 / self.decay

    //

    local obj = HDynamicLight(entid,self.elight)
    obj.pos = self.pos
    obj.brightness = self.brightness 
    obj.decay = self.decay
    obj.dietime = self.dietime
    obj.size = self.size
    obj.r = self.r
    obj.g = self.g
    obj.b = self.b
    
    obj.noworld = self.noworld
    obj.nomodel = self.nomodel

    //

    if not self.nolight then DynamicLightMap[entid] = self end

    timer_Create("dlight" .. entid,self.d,1,function() DynamicLightMap[entid] = nil end)
end

function DynamicLight(entid,elight)
    local self = {}
    local ent

    if TypeID(entid) == TYPE_ENTITY then
        ent = entid
        entid = ent:EntIndex()
    end

    self.ent = ent
    self.entid = entid
    self.elight = elight
    self.Spawn = Spawn

    self.timerID = timer.GameSimple(0,Spawn,self)

	return self
end

concommand.Add("hg_light_getinfo",function()
    print("dlight count " .. table.Count(DynamicLightMap))
end)
