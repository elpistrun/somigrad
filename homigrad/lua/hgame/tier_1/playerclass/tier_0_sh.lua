--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/playerclass/tier_0_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\playerclass\\tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
player.classList = player.classList or {}
local classList = player.classList

AdminPanel_Command_Registry("playerclass",{"players","string"})

local PlayerMeta = FindMetaTable("Player")

local empty = {}
function PlayerMeta:GetPlayerClass(class)
    class = classList[class or self.PlayerClassName or ""]
    if class then return class[1] end
end

local meta
function PlayerMeta:PlayerClassEvent(name,...)
    meta = self:GetPlayerClass()

   
    if meta and meta[name] then return meta[name](self,...) end
end

function player.RegClass(class,base,isFolder)
    return oop.Reg(class,base,isFolder,0,classList)
end

function player.GetClass(class)
    return oop.Get(class,classes)
end

DEFAULT_VIEW_OFFSET = Vector(0,0,70)
DEFAULT_VIEW_OFFSET_DUCKED = Vector(0,0,32)

DEFAULT_JUMP_POWER = 185 --284
DEFAULT_STEP_SIZE = 18
DEFAULT_MASS = 80
DEFAULT_MODELSCALE = 1

DEFAULT_HULLSIZE = 9

local empty = {}

hook.Add("Think","PlayerClass",function()
    local list = {}

    for i,ply in pairs(player.GetAll()) do
        local class = ply:GetPlayerClass()
        if not class then continue end

        list[class] = list[class] or {}
        list[class][ply] = true
    end

    for name,class in pairs(classList) do
        local func = class.GlobalThink
        if func then func(list) end
        local func = class.Think

        if not func then continue end

        for ply in pairs(list[class] or empty) do
            class.Think(ply,list)
        end
    end
end)

function player.EventPoint(pos,name,radius,...)
    for i,ply in pairs(player.GetAll()) do
        if ply:GetPos():Distance(pos) > radius then continue end

        ply:PlayerClassEvent("EventPoint",name,pos,radius,...)
    end
end

function player.Event(ply,name,...)
    ply:PlayerClassEvent("Event",name,...)
end

if SERVER then return end

net.Receive("setupclass",function()
    local ply = net.ReadEntity()
    if not IsValid(ply) then return end--lol

    local oldClass = ply.PlayerClassName
    if oldClass then
        oldClass = ply:GetPlayerClass(oldClass)

        if oldClass and oldClass.Off then oldClass.Off(self) end
    end

    ply.PlayerClassName = net.ReadString()
    ply:PlayerClassEvent("On")
end)
