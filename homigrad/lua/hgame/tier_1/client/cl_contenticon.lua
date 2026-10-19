--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/client/cl_contenticon.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\client\\cl_contenticon.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local white = Color(255,255,255)

local vecZero = Vector(0,0,0)
local angZero = Angle(0,0,0)
local cameraPos,cameraAng
local angRotate = Angle(0,0,0)
local _cameraPos = Vector(0,100,0)
local _cameraAng = Angle(0,0,0)

local cam_Start3D = cam.Start3D

local render_SetLightingOrigin = render.SetLightingOrigin
local render_ResetModelLighting = render.ResetModelLighting
local render_SetColorModulation = render.SetColorModulation
local render_SetBlend = render.SetBlend

local render_SetModelLighting = render.SetModelLighting

local render_SetColorModulation = render.SetColorModulation
local render_SetBlend = render.SetBlend
local render_SuppressEngineLighting = render.SuppressEngineLighting

local cam_IgnoreZ = cam.IgnoreZ

local cam_End3D = cam.End3D

local ClientsideModel = ClientsideModel
local RealTime = RealTime

WeaponByModel = {}
WeaponByModel.weapon_physgun = {
    WorldModel = "models/weapons/w_physics.mdl",
    PrintName = "Physgun"
}

local function PrintWeaponInfo(self,x,y,alpha)
	return
end

local white = Color(255,255,255)

local empty = {}

DrawWeaponSelectionEX = function(self,x,y,wide,tall,notPrint,addFov,allowRotate,lightColor,lightSide)
    local cameraPos = self.dwsPos or _cameraPos
    local mdl = self.WorldModel or (self.GetModel and self:GetModel())

    if allowRotate == nil then allowRotate = self.dwsRotate end
    
    lightColor = lightColor or white

    if mdl then
        local DrawModel,create = CSMById(mdl,mdl .. "RENDER_GROUP_OPAQUE_ENTITY")
        DrawModel:SetNoDraw(true)
        
        DrawModel:SetModelScale(self.WorldScale or 1)
        DrawModel:SetMaterial(self.WorldMaterial or "")
        DrawModel:SetSkin(self.WorldSkin or 0)
        DrawModel:SetColor(self.WorldColor or white)

        for id,value in pairs(self.WorldBodygroups or empty) do
            DrawModel:SetBodygroup(id,value)
        end

        cam_Start3D(cameraPos,(-cameraPos):Angle() - (self.cameraAng or _cameraAng),20 + (self.dwsItemFOV or 0) + (addFov or 0),x,y,wide,tall)
            render_SuppressEngineLighting(true)

            render_SetLightingOrigin(vecZero)
            render_ResetModelLighting(50 / 255,50 / 255,50 / 255)
            render_SetModelLighting(lightSide or 4,lightColor.r / 255,lightColor.g / 255,lightColor.b / 255)

            angRotate:Set(angZero)
            local ang = self.dwsItemAng or angZero
            angRotate:RotateAroundAxis(angRotate:Right(),ang[1])
            angRotate:RotateAroundAxis(angRotate:Up(),(allowRotate and RealTime() * 60 % 360 or 0) + ang[2])
            angRotate:RotateAroundAxis(angRotate:Forward(),ang[3])
    
            local dir = Vector(0,0,0)
            dir:Set(self.dwsItemPos or vecZero)
            dir:Rotate(angRotate)

            DrawModel:SetAngles(angRotate)
            DrawModel:SetPos(dir)
            DrawModel:SetupBones()
            DrawModel:DrawModel()

            render_SetColorModulation(1,1,1)
           // render_SetBlend(1)
            render_SuppressEngineLighting(false)
            //render.DrawSphere(Vector(),1,16,16,white)
        cam_End3D()
    end

	if not notPrint and self.PrintWeaponInfo then PrintWeaponInfo(self,x + wide,y + tall,alpha) end
end

local white = Color(255,255,255)
DrawWeaponSelection = function(self,x,y,w,h,alpha) DrawWeaponSelectionEX(self,x,y,w,h + 35) end

OverridePaintIcon = true

hook.Add("Content Icon Paint","Homigrad",function(panel,w,h)
    local table = scripted_ents.Get(panel:GetSpawnName()) or weapons.Get(panel:GetSpawnName())  
    if not table then return end

    if table.OverridePaintIcon then
        local x,y = panel:LocalToScreen(0,0)

        DrawWeaponSelectionEX(table,x + 5,y + 5,w - 10,h - 30,true)
    elseif table.DrawSpawnIcon then
        table.DrawSpawnIcon(table,5,5,w - 10,h - 30)
    end
end)

list.Set("ContentCategoryIcons","Other","icon16/box.png")
