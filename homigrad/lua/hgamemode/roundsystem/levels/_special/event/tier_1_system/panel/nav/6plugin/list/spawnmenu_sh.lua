--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/levels/_special/event/tier_1_system/panel/nav/6plugin/list/spawnmenu_sh.lua <
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
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\levels\\_special\\event\\tier_1_system\\panel\\nav\\6plugin\\list\\spawnmenu_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Plugin = EventPlugin_Reg("spawnmenu","base")
if not Plugin then return end

Plugin.PrintName = "Spawnmenu"

Plugin.EventPlug = {
    ["Can Use Spawn"] = "CanUseSpawn",
}

Plugin.HookPlug = {
    ["PhysgunPickup"] = "PhysgunPickup",
    ["OnPhysgunReload"] = "OnPhysgunReload"
}

function Plugin:PhysgunPickup(ply,ent)
    if Event_CanAccess(ply) then return end
    
    if ent:GetNWString("OwnerSteamID") != ply:SteamID() then return false end
end

function Plugin:Sync(data)
    if SERVER then
        data.prop_max_scale = self.prop_max_scale
    else
        self.prop_max_scale = data.prop_max_scale
    end
end

if SERVER then
    Plugin.EventPlug["Spawn Object"] = "SpawnObject"

    function Plugin:SpawnObject(ply,type,ent)
        if ent:OBBMins():Length() + ent:OBBMaxs():Length() > (self.prop_max_scale or 0) then
            ent:Remove()

            ply:SendNotify("Слишком большой объект.",NOTIFY_ERROR,5)

            return
        end

        ent:SetNWString("OwnerSteamID",ply:SteamID())
    end

    function Plugin:OnPhysgunReload(wep,ply)
        if not Event_CanAccess(ply) then return false end
    end

    function Plugin:CanUseSpawn(ply,type,model,tr)
        if not ply:Alive() or Event_CanAccess(ply) then return end//lol
        if type == "tool" and tr.Entity:GetNWString("OwnerSteamID") != ply:SteamID() then return false end

        if type != "prop" and type != "tool" then ply:SendNotify("Запрещено.",NOTIFY_ERROR,5) return false end
        if (ply.pluginSpawnmenu_delay or 0) > RealTime() then ply:SendNotify("Подождите секунду.",NOTIFY_ERROR,5) return false end
        if type == "prop" and ExplosiveModel[model] then ply:SendNotify("Запрещено.",NOTIFY_ERROR,5) return false end

        ply.pluginSpawnmenu_delay = RealTime() + 1
    
        return true
    end

    Plugin:AddCMD("prop_max_scale",function(self,ply,args)
        self.prop_max_scale = tonumber(args[1] or 0) or 0

        return true,tostring(self.prop_max_scale)
    end)

else
    function Plugin:CanUseSpawn(ply,type)
        if ply:Alive() then return true end
    end

    function Plugin:Create(page)
        page:AddEdit("prop_max_scale")
    end
end
