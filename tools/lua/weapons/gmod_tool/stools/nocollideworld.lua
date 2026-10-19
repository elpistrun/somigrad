--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/tools/lua/weapons/gmod_tool/stools/nocollideworld.lua <
    > Callstack: gamemodes/sandbox/entities/weapons/gmod_tool/stool.lua:159
[C]:-1
gamemodes/sandbox/entities/weapons/gmod_tool/shared.lua:390
[C]:-1
gamemodes/sandbox/entities/weapons/gmod_tool/cl_init.lua:11 <
]]

-- "addons\\tools\\lua\\weapons\\gmod_tool\\stools\\nocollideworld.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
TOOL.Category        = "Construction"
TOOL.Name            = "#No Collide World"
TOOL.Command        = nil
TOOL.ConfigName		= ""

if CLIENT then
	language.Add("Tool.nocollideworld.name", "No Collide World")
	language.Add("Tool.nocollideworld.desc", "Make a prop not collide with anything, including the world")
	language.Add("Tool.nocollideworld.0", "Left click on an object to make it not collide with anything. Right click to return an object to normal.")
end

function TOOL:LeftClick( trace )

    if (!trace.Entity ) then return end
    if (!trace.Entity:IsValid()) then return end
	if (trace.Entity:IsPlayer()) then return end
	
	local PhysObj = trace.Entity:GetPhysicsObject()
    
    if ( CLIENT ) then return true end
    
    if ( trace.Entity.CollisionGroup != COLLISION_GROUP_WORLD && PhysObj:IsCollisionEnabled() ) then
    
        trace.Entity:SetCollisionGroup( COLLISION_GROUP_WORLD )
        trace.Entity.CollisionGroup = COLLISION_GROUP_WORLD
		PhysObj:EnableCollisions(false)
        
    end
    
    return true
    
end

function TOOL:RightClick( trace )

    if (!trace.Entity ) then return end
    if (!trace.Entity:IsValid()) then return end
	if (trace.Entity:IsPlayer()) then return end
	
	local PhysObj = trace.Entity:GetPhysicsObject()
    
    if ( CLIENT ) then return true end
    
    if ( trace.Entity.CollisionGroup == COLLISION_GROUP_WORLD && !PhysObj:IsCollisionEnabled() ) then
    
        trace.Entity:SetCollisionGroup( COLLISION_GROUP_NONE )
        trace.Entity.CollisionGroup = COLLISION_GROUP_NONE
		PhysObj:EnableCollisions(true)
        
    end
    
    return true
    
end
