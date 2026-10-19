--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_2_world/render/lights/lamp_cl.lua <
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

-- "addons\\homigrad_core\\lua\\shlib\\tier_2_world\\render\\lights\\lamp_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
ProjectedTexture_Client = ProjectedTexture_Client or {}--кстате это имба
ProjectedTexture_Server = ProjectedTexture_Server or {}
ProjectedTexture_Shared = ProjectedTexture_Shared or {}

local example = {}

function example:SetFOV(value)
    self.lightfov = value
    self.self:SetFOV(value)
end

function example:SetNearZ(value)
    self.nearz = value
    self.self:SetNearZ(value)
end

function example:SetFarZ(value)
    self.farz = value
    self.self:SetFarZ(value)
end

function example:SetColor(value)
    value = value or Color(255,255,255)
    self.lightcolor = {value.r,value.g,value.b}
    self.self:SetColor(value)
end

function example:Remove()
    self.self:Remove()

    ProjectedTexture_Client[self] = nil
    ProjectedTexture_Server[self] = nil//незнаю зачем...
    ProjectedTexture_Shared[self] = nil
end

function example:IsValid() return IsValid(self.self) end

local list = {
    "SetPos",
    "SetAngles",
    "GetPos",
    "GetAngles",

    "GetColor",

    "SetEnableShadows",
    "SetConstantAttenuation",
    "SetHorizontalFOV",
    "SetVerticalFOV",
    "SetTexture",
    "SetLightWorld",
    "SetLinearAttenuation",
    "SetOrthographic",
    "SetQuadraticAttenuation",
    "SetShadowDepthBias",
    "SetShadowFilter",
    "SetShadowSlopeScaleDepthBias",
    "SetTargetEntity",
    "SetTextureFrame",
    "SetBrightness",

    "Update"
}

for _,name in pairs(list) do
    example[name] = function(self,...) return self.self[name](self.self,...) end
end

if not HProjectedTexture then HProjectedTexture = ProjectedTexture end
function ProjectedTexture()
    local obj = {self = HProjectedTexture()}--cring

    for k,v in pairs(example) do obj[k] = v end

    ProjectedTexture_Client[obj] = true

    obj:SetNearZ(obj.self:GetNearZ())
    obj:SetColor(obj.self:GetColor())

    return obj
end

LampsThink = LampsThink or {}
function example:AddThink() LampsThink[self] = true end

hook.Add("Think","Lamps",function()
    for obj in pairs(LampsThink) do
        if not IsValid(obj) then LampsThink[obj] = nil continue end

        obj:Think()
    end
end)

-- shared

local function removeFromTable(self) ProjectedTexture_Server[self] = nil end

event.Add("Entity Create","Light",function(ent)
    if ent:GetClass() ~= "class C_EnvProjectedTexture" then return end

    if ent:EntIndex() <= -1 then

    else
        ent:GetNWTable("lampValues")
        ent.OnNWTable_lampValues = function(self,tbl)
            for key,value in pairs(tbl) do
                if key == "lightcolor" then
                    local split = string.Split(value," ")
                    
                    value = {tonumber(split[1]),tonumber(split[2]),tonumber(split[3]),tonumber(split[4])}
                end
            
                self[key] = value
            end
        end

        ProjectedTexture_Server[ent] = true
        ProjectedTexture_Shared[ent] = true

        ent:CallOnDelete("lamp",removeFromTable)
    end
end)

/*
    enableshadows	=	1
    farz	=	1024
    lightcolor	=	1020 1020 1020 255
    lightfov	=	90
    nearz	=	12
*/

hook.Add("PostCleanupMap","Remove Lamp",function()
    for tab in pairs(ProjectedTexture_Client) do tab:Remove() end
    
    for k in pairs(ProjectedTexture_Server) do ProjectedTexture_Server[k] = nil end--я добропорядочный человек, а не ебаное быдло блядь и поэтому я забочусь о памяти моих клиентов
    for k in pairs(ProjectedTexture_Shared) do ProjectedTexture_Shared[k] = nil end
end)

concommand.Add("hg_lamp_clear_cache",function()
    local count = 0

    for tab in pairs(ProjectedTexture_Client) do tab:Remove() count = count + 1 end

    print(count)
end)

concommand.Add("hg_lamp_getinfo",function()
    print("client lamp: " .. table.Count(ProjectedTexture_Client))
    print("server lamp: " .. table.Count(ProjectedTexture_Server))
    print("shared lamp: " .. table.Count(ProjectedTexture_Shared))
end)
