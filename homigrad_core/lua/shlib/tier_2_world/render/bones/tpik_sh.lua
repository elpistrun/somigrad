--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_2_world/render/bones/tpik_sh.lua <
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

-- "addons\\homigrad_core\\lua\\shlib\\tier_2_world\\render\\bones\\tpik_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
//так сложно нормально написать код?

local cached_children = {}

local BonesManager_RecursiveGetChildren
BonesManager_RecursiveGetChildren = function(ent, bone, bones, endbone)
    local bone = isstring(bone) and ent:LookupBone(bone) or bone
    if not bone or isstring(bone) or bone == -1 then return end
    
    local children = ent:GetChildBones(bone)
    if #children > 0 then
        local id
        for i = 1, #children do
            id = children[i]
            if id == endbone then continue end
            BonesManager_RecursiveGetChildren(ent, id, bones, endbone)
            table.insert(bones, id)
        end
    end
end
_G.BonesManager_RecursiveGetChildren = BonesManager_RecursiveGetChildren

function BonesManager_GetChildren(ent, bone, endbone)
    local bones = {}
    local mdl = ent:GetModel()
    
    if cached_children[mdl] and cached_children[mdl][bone] then 
        return cached_children[mdl][bone] 
    end

    BonesManager_RecursiveGetChildren(ent, bone, bones, endbone)

    cached_children[mdl] = cached_children[mdl] or {}
    cached_children[mdl][bone] = bones

    return bones
end
local BonesManager_GetChildren = BonesManager_GetChildren

function BonesManager_ApplyMatrix(ent, bone, new_matrix, endbone)
    local bone = isstring(bone) and ent:LookupBone(bone) or bone
    if not bone or isstring(bone) or bone == -1 then return end

    local matrix = ent:GetBoneMatrix(bone)
    if not matrix then return end
    
    local inv_matrix = matrix:GetInverse()
    if not inv_matrix then return end

    local children = BonesManager_GetChildren(ent, bone, endbone)
    local translate = new_matrix * inv_matrix
    
    for i = 1, #children do
        local id = children[i]
        local mat = ent:GetBoneMatrix(id)
        if not mat then continue end
        ent:SetBoneMatrix(id, translate * mat)
    end

    ent:SetBoneMatrix(bone, new_matrix)
end
local BonesManager_ApplyMatrix = BonesManager_ApplyMatrix

function TPIK_Solve2PartIK(start_pos, end_pos, length0, length1, mat0, mat1, sign, torso_mat, aim_ang)
    local total_length = (start_pos - end_pos):Length()
    
    -- Если цель слишком далеко, растягиваем конечность
    if length0 + length1 < total_length then
        local stretch = total_length - length1 - length0

    end

    length0 = length0 * 2
    
    -- Вычисляем углы с помощью закона косинусов
    local cosAngle0 = math.Clamp((total_length^2 + length0^2 - length1^2) / (2 * total_length * length0), -1, 1)
    local angle0 = -math.deg(math.acos(cosAngle0))
    
    local cosAngle1 = math.Clamp((length1^2 + length0^2 - total_length^2) / (2 * length1 * length0), -1, 1)
    local angle1 = -math.deg(math.acos(cosAngle1))
    
    -- Вычисляем направление к цели
    local dir = (end_pos - start_pos):GetNormalized()
    local angle2 = math.deg(math.atan2(-math.sqrt(dir.x^2 + dir.y^2), dir.z)) - 90
    local angle3 = -math.deg(math.atan2(dir.x, dir.y)) - 90
    angle3 = math.NormalizeAngle(angle3)
    
    -- Корректируем углы с учетом ориентации туловища
    local torso_ang = torso_mat:GetAngles()
    local axis = dir:GetNormalized()
    
    local joint0_ang = Angle(angle0 + angle2, angle3, 0)
    local diff_angle = 90 + (sign > 0 and -30 or 30)
    
    joint0_ang:RotateAroundAxis(joint0_ang:Forward(), diff_angle)
    joint0_ang:RotateAroundAxis(axis, angle3 - (aim_ang.y + 120 * sign))
    
    local joint1_ang = Angle(angle0 + angle2 + 180 + angle1, angle3, 0)
    joint1_ang:RotateAroundAxis(joint1_ang:Forward(), diff_angle)
    joint1_ang:RotateAroundAxis(axis, angle3 - (aim_ang.y + 120 * sign))
    
    -- Вычисляем конечные позиции суставов
    local joint0_pos = start_pos + joint0_ang:Forward() * length0
    local joint1_pos = joint0_pos + joint1_ang:Forward() * length1
    
    return joint0_pos, joint1_pos, joint0_ang, joint1_ang
end

function TPIK_DoTPIK(ply,ent,targetPosLeft,targetPosRight)
    if not targetPosLeft and not targetPosRight then return end
    
    ent = IsValid(ent) and ent or ply

    local spine_index = ply:LookupBone("ValveBiped.Bip01_Spine4")
    if not spine_index then return end

    local spine_matrix = ent:GetBoneMatrix(spine_index)
    if not spine_matrix then return end

    local head_index = ply:LookupBone("ValveBiped.Bip01_Head1")
    if not head_index then return end
    local head_matrix = ent:GetBoneMatrix(head_index)

    //

    local eye_pos, eye_ang = ply:Eye()
    local head_pos = head_matrix:GetTranslation()

    if targetPosRight then
        local bone_r_clavicle = ply:LookupBone("ValveBiped.Bip01_R_Clavicle")
        local bone_r_upperarm = ply:LookupBone("ValveBiped.Bip01_R_UpperArm")
        local bone_r_forearm = ply:LookupBone("ValveBiped.Bip01_R_Forearm")
        local bone_r_hand = ply:LookupBone("ValveBiped.Bip01_R_Hand")

        local matrice_r_clavicle = ent:GetBoneMatrix(bone_r_clavicle)
        local matrice_r_upperarm = ent:GetBoneMatrix(bone_r_upperarm)
        local matrice_r_forearm = ent:GetBoneMatrix(bone_r_forearm)
        local matrice_r_hand = ent:GetBoneMatrix(bone_r_hand)

        local r_arm_start = matrice_r_upperarm:GetTranslation()
        local r_arm_end = targetPosRight

        local length_r_upperarm = ply:BoneLength(bone_r_upperarm) or 12
        local length_r_forearm = ply:BoneLength(bone_r_forearm) or 12

        local r_upperarm_pos, r_forearm_pos, r_upperarm_ang, r_forearm_ang = TPIK_Solve2PartIK(
            r_arm_start, r_arm_end, 
            length_r_upperarm, length_r_forearm, 
            matrice_r_upperarm, matrice_r_forearm, 
            -1, spine_matrix, eye_ang
        )

        matrice_r_upperarm:SetAngles(r_upperarm_ang)
        matrice_r_forearm:SetAngles(r_forearm_ang)
        matrice_r_forearm:SetTranslation(r_upperarm_pos)

        BonesManager_ApplyMatrix(ent,bone_r_upperarm,matrice_r_upperarm,bone_r_forearm)
        BonesManager_ApplyMatrix(ent,bone_r_forearm,matrice_r_forearm,bone_r_hand)
        matrice_r_hand:SetTranslation(r_forearm_pos)
        BonesManager_ApplyMatrix(ent,bone_r_hand,matrice_r_hand)
    end
    
    if targetPosLeft then
        local bone_l_clavicle = ply:LookupBone("ValveBiped.Bip01_L_Clavicle")
        local bone_l_upperarm = ply:LookupBone("ValveBiped.Bip01_L_UpperArm")
        local bone_l_forearm = ply:LookupBone("ValveBiped.Bip01_L_Forearm")
        local bone_l_hand = ply:LookupBone("ValveBiped.Bip01_L_Hand")

        local matrice_l_clavicle = ent:GetBoneMatrix(bone_l_clavicle)
        local matrice_l_upperarm = ent:GetBoneMatrix(bone_l_upperarm)
        local matrice_l_forearm = ent:GetBoneMatrix(bone_l_forearm)
        local matrice_l_hand = ent:GetBoneMatrix(bone_l_hand)

        local l_arm_start = matrice_l_upperarm:GetTranslation()
        local l_arm_end = targetPosLeft

        local length_l_upperarm = ply:BoneLength(bone_l_upperarm) or 12
        local length_l_forearm = ply:BoneLength(bone_l_forearm) or 12

        local l_upperarm_pos, l_forearm_pos, l_upperarm_ang, l_forearm_ang = TPIK_Solve2PartIK(
            l_arm_start, l_arm_end, 
            length_l_upperarm, length_l_forearm, 
            matrice_l_upperarm, matrice_l_forearm, 
            1,spine_matrix, eye_ang
        )

        matrice_l_upperarm:SetAngles(l_upperarm_ang)
        matrice_l_forearm:SetAngles(l_forearm_ang)
        matrice_l_forearm:SetTranslation(l_upperarm_pos)

        BonesManager_ApplyMatrix(ent,bone_l_upperarm,matrice_l_upperarm,bone_l_forearm)
        BonesManager_ApplyMatrix(ent,bone_l_forearm,matrice_l_forearm,bone_l_hand)
        matrice_l_hand:SetTranslation(l_forearm_pos)
        BonesManager_ApplyMatrix(ent,bone_l_hand, matrice_l_hand)
    end
end

local vector_zero = Vector(0,0,0)

local function doTPIK(ply,link)
    local targetPosLeft,targetPosRight = Vector(0,0,0),Vector(0,0,0)
    
    event.Call("TPIK",ply,ply,targetPosLeft,targetPosRight)

    local Pos,Ang = ply:Eye()
    
    if targetPosLeft == vector_zero then targetPosLeft = nil end
    if targetPosRight == vector_zero then targetPosRight = nil end

    TPIK_DoTPIK(ply,ply,targetPosLeft,targetPosRight)

    /*if targetPosLeft then
        debugoverlay.Sphere(targetPosLeft,1,0.1,Color(255,0,0),true)
    end

    if targetPosRight then
        debugoverlay.Sphere(targetPosRight,1,0.1,Color(255,0,0),true)
    end*/
end

if CLIENT then
    event.Add("PlayerDraw","TPIK",function(ply,tag,link)
        if tag then return end
        
        doTPIK(ply,link)
    end,-19)
else
    event.Add("Bones","TPIK",function(ply,link,ft,settingValue)
        doTPIK(ply,link,ft,settingValue)
    end,-19)
end

local function drawHitBox(ply)
    for i = 0,ply:GetHitBoxCount(0) - 1 do
        local mins,maxs = ply:GetHitBoxBounds(i,0)
        local bone = ply:GetHitBoxBone(i,0)
        local mat = ply:GetBoneMatrix(bone)

        //debugoverlay.BoxAngles(mat:GetTranslation(),mins,maxs,mat:GetAngles(),0.1,CLIENT and Color(255,125,0,0) or Color(0,0,255,0))
    end
end

event.Add("TPIK","IK",function(ply,link,targetPosLeft,targetPosRight)
    /*local PosLeft,Ang = ply:Eye()
    targetPosLeft:Set(PosLeft:Add(Vector(20,12,-2):Rotate(Ang)))

    local PosRight,Ang = ply:Eye()
    targetPosRight:Set(PosRight:Add(Vector(20,-12,-2):Rotate(Ang)))*/

    drawHitBox(ply)
end,9)


