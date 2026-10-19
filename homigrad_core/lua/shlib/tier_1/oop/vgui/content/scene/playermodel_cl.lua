--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_1/oop/vgui/content/scene/playermodel_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_1\\oop\\vgui\\content\\scene\\playermodel_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local PANEL = oop.Reg("v_playermodel","v_scene")
if not PANEL then return end

VGUIPlayerModel = {}

PANEL:Event_Add("Init","PlayerModel",function(self)
    self.fovMin = 7
    self.fovMax = 20

    self.cameraFOV = self.fovMax

    self.cameraAng = Angle(0,180,0)
    self.cameraPos = Vector(125,0,0)

    self.znear = 1
    self.mdlColor = Vector(1,1,1)

    VGUIPlayerModel[self] = true
end)

PANEL:Event_Add("Remove","Remove Link VGUI",function(self)
    VGUIPlayerModel[self] = nil
end)

function PANEL:SetPlayer(ply,ent)
    ent = ent or ply

    local mdl = self:SetModel(ent:GetModel())
    mdl.GetPlayerColor = function() return ply:GetPlayerColor() end
    mdl:SetSkin(ent:GetSkin())

	for k,v in pairs(ent:GetBodyGroups()) do
		mdl:SetBodygroup(v.id,ent:GetBodygroup(v.id))
	end

    self.ply = ply

    return mdl
end

function PANEL:SetModel(model)
    if IsValid(self.mdl) then self.mdl:Remove() end
    self.mdl = nil
    self.mdlName = nil
    
    if not model then return end

    local mdl = ClientsideModel(model,RENDERGROUP_OTHER)
    mdl.GetPlayerColor = function() return self.mdlColor end
    mdl:ResetSequence(mdl:LookupSequence("walk_all"))
    mdl:SetIK(false)

    self.mdl = mdl
    self.mdlName = model
    self:InsertInScene(mdl)

    mdl:SetupBones()
    local pos = mdl:GetBonePosition(0)
    mdl:SetPos(Vector(0,0,-pos[3] + 2.5))

    return mdl
end

function PANEL:Draw(w,h)
    if self.PreDraw then self:PreDraw(w,h) end
    
    local mdl = self.mdl
    local ply = self.ply

    if IsValid(mdl) then
        mdl:SetEyeTarget(Vector(300,0,0))
        mdl:SetupBones()
    end
    
    if IsValid(ply) then
        local vec = ply:Eye()
        
        for i = 0,ply:GetFlexNum() - 1 do
            mdl:SetFlexWeight(i,ply:GetFlexWeight(i))
        end
    end

    self:OpenScene(w,h)
    self:DrawObjects()
    if IsValid(self.ply) then 
        event.Call("PlayerDraw",self.mdl,"vgui_inventory",self.ply)
    end
    self:CloseScene()
end

function PANEL:OnWheel(wheel)
    if input.IsButtonDown(KEY_LSHIFT) then
        self.cameraFOV = math.Clamp(self.cameraFOV - wheel * 2,self.fovMin,self.fovMax)
    else
        self.cameraPos[3] = self.cameraPos[3] + wheel * 5
    end
end

function PANEL:Step()
    if self.mouse[MOUSE_RIGHT] then
        local mdl = self.mdl
        if not IsValid(mdl) then return end
        
        local ang = mdl:GetAngles()
        ang[2] = ang[2] - mousedx
        ang:Normalize()

        mdl:SetAngles(ang)
        self:SetCursor("sizewe")
    else
        self:SetCursor("arrow")
    end
end
