--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_1/nwtable_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_1\\nwtable_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local ENTITY = FindMetaTable("Entity")

function ENTITY:SetNWTable(key,tbl)//разделяет таблицу на 10 чанков
    local tbl = util.TableToJSON(tbl)

    for i = 1,10 do
        local text = self:GetNWString(key .. i,"")
        if text == "" then break end

        self:SetNWString(key .. i,"")
    end

    for i = 1,math.ceil(#tbl / 199) do
        local text = string.sub(tbl,199 * (i - 1) + 1,199 * i)

        self:SetNWString(key .. i,text)
    end
end

local empty = {}

function ENTITY:GetNWTable(key,limitChunks,chunk,update)
    local tbl = (self.nwTables or empty)[key]

    if not tbl or chunk then
        self.nwTables = self.nwTables or {}

        local path = ""

        for i = 1,limitChunks or 10 do
            self:SetNWVarProxy(key .. i,function(_,_,_,chunk)
                if not IsValid(self) then return end---looool
                
                self:GetNWTable(key,i,chunk)
            end)

            local text = i == limitChunks and chunk or self:GetNWString(key .. i,"")
            path = path .. text
        end


        tbl = util.JSONToTable(path)
        self.nwTables[key] = tbl

        if tbl then
            local func = self["OnNWTable_" .. key]
            
            if func then func(self,tbl) end
        end

        if update then update(self,tbl) end
    end

    return tbl
end
