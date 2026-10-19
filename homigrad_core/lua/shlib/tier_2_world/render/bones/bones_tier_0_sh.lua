--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_2_world/render/bones/bones_tier_0_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_2_world\\render\\bones\\bones_tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENTITY = FindMetaTable("Entity")

BonesManager_SimpleNameToFullName = {
    ["rclavicle"] = "ValveBiped.Bip01_R_Clavicle",
    ["rupperarm"] = "ValveBiped.Bip01_R_UpperArm",
    ["rforearm"] = "ValveBiped.Bip01_R_Forearm",
    ["rhand"] = "ValveBiped.Bip01_R_Hand",

    ["lclavicle"] = "ValveBiped.Bip01_L_Clavicle",
    ["lupperarm"] = "ValveBiped.Bip01_L_UpperArm",
    ["lforearm"] = "ValveBiped.Bip01_L_Forearm",
    ["lhand"] = "ValveBiped.Bip01_L_Hand",

    ["spine"] = "ValveBiped.Bip01_Spine",
    ["spine2"] = "ValveBiped.Bip01_Spine2",

    ["rthigh"] = "ValveBiped.Bip01_R_Thigh"
}

if not ENTITY.AddBoneAng then
    function ENTITY:AddBoneAng(name,ang)
        if not self.LookupBone then return end
        local boneName = BonesManager_SimpleNameToFullName and BonesManager_SimpleNameToFullName[name] or name
        local id = self:LookupBone(boneName)
        if not id then return end
        self:ManipulateBoneAngles(id, self:GetManipulateBoneAngles(id):Add(ang))
    end
end

if not ENTITY.SetBoneAng then
    function ENTITY:SetBoneAng(name,ang)
        if not self.LookupBone then return end
        local boneName = BonesManager_SimpleNameToFullName and BonesManager_SimpleNameToFullName[name] or name
        local id = self:LookupBone(boneName)
        if not id then return end
        self:ManipulateBoneAngles(id, ang)
    end
end

if not ENTITY.GetBoneAng then
    function ENTITY:GetBoneAng(name)
        if not self.LookupBone then return Angle(0,0,0) end
        local boneName = BonesManager_SimpleNameToFullName and BonesManager_SimpleNameToFullName[name] or name
        local id = self:LookupBone(boneName)
        if not id then return Angle(0,0,0) end
        return self:GetManipulateBoneAngles(id)
    end
end
