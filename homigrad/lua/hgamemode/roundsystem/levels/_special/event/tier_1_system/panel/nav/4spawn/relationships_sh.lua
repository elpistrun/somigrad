--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/levels/_special/event/tier_1_system/panel/nav/4spawn/relationships_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
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

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\levels\\_special\\event\\tier_1_system\\panel\\nav\\4spawn\\relationships_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
EventGroupRealships = EventGroupRealships or {}

local function addEdit(name,data)
    EventGroupRealships[name] = data
end

if SERVER then
    event.Add("Event Group Create","RelationShips",function(group,groupID)
        for name,edit in pairs(EventGroupRealships) do edit.createGroup(group) end
    end)

    function EventSpawnRelationshipsCMD(cmd,group,groupID,args)
        print(cmd,group,groupID,args)

        local edit = EventGroupRealships[cmd]
        if not edit then return end

        local groupLink = args[1]
        table.remove(args,1)
        
        edit.cmd(group,groupLink,args)
    end
end

addEdit("cantdamage",{
    title = "event_relationships_cantdamage",
    cmd = function(group,groupLink,args)
        group.cantDamage[groupLink] = (tonumber(args[1] or 0) or 0) > 0
    end,
    createGroup = function(group)
        group.cantDamage = {[group.link] = true}
    end,
    getText = function(group,groupSelect)
        return tostring(group.cantDamage[groupSelect.link])
    end
})

if SERVER then
    event.Add("Damage","Event Group",function(dmgTab)
        if not Event_Claimed then return end

        local ply = dmgTab.target
        if not ply:IsPlayer() then return end
        
        local att = dmgTab.att
        if not IsValid(att) or not att:IsPlayer() then return end

        local group = ply.eventGroup
        if not group then return end

        local attGroup = att.eventGroup
        if attGroup.cantDamage[group.link] then return false end
    end,-5)
end
