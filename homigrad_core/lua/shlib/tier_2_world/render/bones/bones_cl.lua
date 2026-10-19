--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_2_world/render/bones/bones_cl.lua <
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

-- "addons\\homigrad_core\\lua\\shlib\\tier_2_world\\render\\bones\\bones_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENTITY = FindMetaTable("Entity")

local simpleNameToBoneName = BonesManager_SimpleNameToFullName

function ENTITY:AddBoneAng(name,ang)
    name = self:LookupBone(simpleNameToBoneName[name])
    if not name then return end
    
    self:ManipulateBoneAngles(name,self:GetManipulateBoneAngles(name):Add(ang))
end

function ENTITY:SetBoneAng(name,ang)
    name = self:LookupBone(simpleNameToBoneName[name])

    self:ManipulateBoneAngles(name,ang)
end

function ENTITY:GetBoneAng(name)
    return self.GetManipulateBoneAngles(self:LookupBone(simpleNameToBoneName[name]))
end

local ang_zero = Angle(0,0,0)

local listName = {}
for simpleName,fullName in pairs(BonesManager_SimpleNameToFullName) do listName[#listName + 1] = fullName end

function ResetBones(ply)
    for i = 1,#listName do
        if not ply:LookupBone(listName[i]) then continue end
        
        ply:ManipulateBoneAngles(ply:LookupBone(listName[i]),ang_zero)
    end
end

//

local ResetBones = ResetBones

local listDrawEntities = {}

event.Add("PlayerDraw","BonesManager",function(ply,tag)
    if tag or ply:GetPos():Distance(EyePos()) > 1000 then return end

    if not listDrawEntities[ply] then
        ResetBones(ply)

        event.Run("Bones",ply,ply,FrameTime(),0)
    end

    listDrawEntities[ply] = RealTime() + 0.1
end,-10)

local hg_bones_framerate = 0

cvars.CreateOption("hg_bones_framerate","90",function(value)
    hg_bones_framerate = tonumber(value or 0) or 0

    if hg_bones_framerate != 0 then
        hg_bones_framerate = 1 / hg_bones_framerate
    end
end,"0","180")

local delay,lat = 0,0

event.Add("Think","Bones",function()
    if not InitNET then return end
    
    local sysTime = SysTime()
    if delay > sysTime then return end

    local ft = sysTime - (last or (sysTime + 1 / 60))
    last = sysTime
    
    delay = sysTime + hg_bones_framerate

    local time2 = RealTime()

    for ply,time in pairs(listDrawEntities) do//обробатываем тех, кого видим.
        if not IsValid(ply) then listDrawEntities[ply] = nil continue end

        ResetBones(ply)
        
        if time < time2 then
            listDrawEntities[ply] = nil

            continue
        end

        event.Run("Bones",ply,ply,ft,hg_bones_framerate)
    end
end,10)

//

local chacheMatrix = {}

event.Add("Pre Render","Chache Matrix Bone Clear",function()
    chacheMatrix = {}
end)

function GetBoneMatrix(ent,bone)
    local matrix = chacheMatrix[ent]

    if not matrix then
        matrix = {}
        chacheMatrix[ent] = matrix
    end

    matrix = matrix[bone]

    if matrix == nil then
        matrix = ent:GetBoneMatrix(bone)

        chacheMatrix[ent][bone] = matrix or false
    end

    return matrix
end
