--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_2_world/render/cl_csm.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_2_world\\render\\cl_csm.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
ChacheClientsideModelsByID = ChacheClientsideModelsByID or {}

local listID = ChacheClientsideModelsByID

local IsValid = IsValid

local ENTITY = FindMetaTable("Entity")
if not HSetNoDraw then HSetNoDraw = ENTITY.SetNoDraw end

function ENTITY:SetNoDraw(value)
    if self.isNoDraw ~= value then HSetNoDraw(self,value) end
    self.isNoDraw = value
end

local function removeChache(ent,id)
    ChacheClientsideModelsByID[id] = nil
end

local function remove(ent,mdl)
    mdl:Remove()
end

event.Add("Pre Render","CSMWorld",function()
    local time = RealTime()

    for id,mdl in pairs(ChacheClientsideModelsByID) do
        if mdl.renderTime < time then mdl:Remove() end
    end
end)

function CSMById(mdlpath,id,isWorldModel)
    local mdl = listID[id]

    if not IsValid(mdl) then
        mdl = ClientsideModel(mdlpath,RENDERGROUP_OPAQUE)
        if not IsValid(mdl) then return end
        
        mdl:CallOnRemove("RemoveFromChache",removeChache,id)

        mdl.renderTime = RealTime() + 0.15
        
        mdl:SetNoDraw(true)

        listID[id] = mdl

        return mdl,true
    end

    mdl.renderTime = RealTime() + 0.15

    return mdl
end

//

concommand.Add("hg_csm_chache_clear",function()
    local count = 0

    for id,mdl in pairs(listID) do
        if IsValid(mdl) then mdl:Remove() end

        count = count + 1
    end

    print("\tremoved " .. count .. " client side models")
end)

concommand.Add("hg_csm_chache",function()
    local count = 0

    for id,mdl in pairs(listID) do
        print(id)
        
        count = count + 1
    end

    print(count)
end)

if Initialize then RunConsoleCommand("hg_csm_chache_clear") end

