--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_2_world/render/lights/light_logic_cl.lua <
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

-- "addons\\homigrad_core\\lua\\shlib\\tier_2_world\\render\\lights\\light_logic_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ents_FindByClass = ents.FindByClass
local min,max = math.min,math.max

local cos,sin = math.cos,math.sin

local render_GetLightColor = render.GetLightColor
local util_IsSphereIntersectingCone = util.IsSphereIntersectingCone

local tr = {
    mask = MASK_SHOT - CONTENTS_WINDOW - CONTENTS_WATER--uff
}

local TraceLine = util.TraceLine
local pi = math.pi

function LightCalculate(pos,size,filter)//расчитывает цвет освещения, принимая параметры от ламп и динамического освещения (lamsp,dlight)
    local vec = render_GetLightColor(pos)
    local colorWorld = {}

    colorWorld[1] = min(vec[1] * 255 * 3,255)
    colorWorld[2] = min(vec[2] * 255 * 3,255)
    colorWorld[3] = min(vec[3] * 255 * 3,255)

    local r,g,b = 0,0,0

    local k = 0

    for ent in pairs(ProjectedTexture_Shared) do
        if not ent.nearz then continue end

        local posEnt = ent:GetPos()

        local dis = 1 - (posEnt:Distance(pos) / ent.farz)
        if dis <= 0 then continue end

        local forward = Vector(1,0,0):Rotate(ent:GetAngles())
        posEnt:Add(forward * ent.nearz)

        tr.filter = filter
        tr.start = posEnt
        tr.endpos = pos

        local result = TraceLine(tr)
        if result.Hit and result.Entity ~= ent then continue end

        local angle = (ent.lightfov / 180 * pi) * 0.47
        if not util_IsSphereIntersectingCone(pos,0,posEnt,forward,sin(angle),cos(angle)) then continue end

        local color = ent.lightcolor

        r,g,b = max(r,color[1] * dis),max(g,color[2] * dis),max(b,color[3] * dis)
        k = max(k,dis)
    end--lamp

    local Time = CTime

    for entid,obj in pairs(DynamicLightMap) do
        local t = (obj.dietime or 0) - Time
        if t <= 0 then DynamicLightMap[entid] = nil continue end--cring

        local posEnt = obj.pos

        local d = obj.d
        local dis = (1 - (posEnt:Distance(pos) / obj.size)) * (6 + obj.brightness) * (1 - (d - Time) / d)
        if dis <= 0 then continue end

        if obj.shadow then 
            tr.filter = filter
            tr.start = posEnt
            tr.endpos = pos

            local result = TraceLine(tr)
            if result.Hit and result.Entity ~= ent then continue end
        end
        
        r,g,b = max(r,obj.r * dis),max(g,obj.g * dis),max(b,obj.b * dis)
        k = max(k,dis)
    end--light

    return {colorWorld,{r,g,b}}
    //colorWorld
    //colorFlash (lamps,dlight)
    //максимальное значения (для нормализации)
    //самая ближнее растояние от точки освещения???777
end

//

function LightApply(matrix,r,g,b,mulFlash)
    local colorWorld = matrix[1]

    r = min(r,colorWorld[1])
    g = min(g,colorWorld[2])
    b = min(b,colorWorld[3])

    local colorFlash = matrix[2]

    r = max(r,colorFlash[1] * mulFlash)
    g = max(g,colorFlash[2] * mulFlash)
    b = max(b,colorFlash[3] * mulFlash)

    local max = max(r,g,b,255)

    return r / max * 255,g / max * 255,b / max * 255
end

//

concommand.Add("hg_debug_getect_lamp",function()
    local pos = LocalPlayer():GetEyeTrace().HitPos

    debugoverlay.Sphere(pos,0.5,1,Color(255,0,0))

    for i,ent in pairs(ents.FindByClass("class C_EnvProjectedTexture")) do
        local posEnt = ent:GetPos()
        local forward = ent:GetForward()
        posEnt:Add(forward * ent.nearz)

        local angle = (ent.lightfov / 180 * math.pi) * 0.47
        if not util.IsSphereIntersectingCone(pos,0,posEnt,forward,math.sin(angle),math.cos(angle)) then continue end

        LocalPlayer():EmitSound("buttons/bell1.wav")
        debugoverlay.Sphere(pos,1,1,Color(0,255,0))
    end
end)
