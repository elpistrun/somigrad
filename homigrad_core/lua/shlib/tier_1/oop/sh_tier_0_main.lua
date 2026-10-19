--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_1\\oop\\sh_tier_0_main.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
oop = oop or {}--sasi
--эт лиш регистрация классов
--уоопъ

oop.listClass = oop.listClass or {}
local listClass = oop.listClass

function oop.Inherit(class,table)
    local listClass = table or listClass
    local oldBase = class.oldBase
    if oldBase then
        class.oldBase = nil

        for i,base in pairs(oldBase) do
            base = listClass[base]
            base.baseChildrens[class.ClassName] = nil--shut the fuck up!
        end
    end

    local content = class[1]
    local base = class.base
    if not base then return end

    local copyContent = util.tableCopy(content)

    for i,base in pairs(base) do
        base = listClass[base]
        base.baseChildrens[class.ClassName] = class

        util.tableLink(content,base[1])
    end

    util.tableLink(content,copyContent)
end--veru simple.. maybe,я на таком чиле это делаю🤙

function oop.InheritChildren(base,table)
    local contentBase = base[1]

    for className,class in pairs(base.baseChildrens) do
        oop.Get(className,table)
    end
end

function oop.RegEx(className,base,table)
    if type(base) ~= "table" then base = {base} end--hihihah

    local listClass = table or listClass

    local class = listClass[className]
    if not class then
        class = {
            {}, --content
            {}, --non inherit content
            {}, --files includd
            baseChildrens = {}
        }

        class.ClassName = className
        listClass[className] = class
    end

    class.oldBase = class.base
    class.base = base

    local content = class[1]

    if not content.noClear then
        for k in pairs(content) do content[k] = nil end
        
        local nonInheritContent = class[2]
        for k in pairs(nonInheritContent) do nonInheritContent[k] = nil end
    end

    content.ClassName = className

    oop.Inherit(class,table)

    return class
end

--

function oop.InsertFile(class,isFolder,add)
    local pathInsert = GetPath(2 + (add or 0))
    local listFiles = class[3]

    if isFolder then pathInsert = string.GetPathFromFilename(pathInsert) end

    for i,path in pairs(listFiles) do
        if path == pathInsert then return end
    end

    listFiles[#listFiles + 1] = pathInsert
end

oop.override = {}
local override = oop.override

/*local overflow = {}

timer.Create("OOP Overflow reset",1,0,function() for k in pairs(overflow) do overflow[k] = nil end end)*/

function oop.Include(class,isFirst,table)
    local className = class.ClassName
   /*overflow[className] = (overflow[className] or 0) + 1

    if overflow[className] > 1024 then
        error("wtf is going on? with " .. className)
    end*/

    for i,path in pairs(class[3]) do
        if string.sub(path,#path - 3,#path) == ".lua" then
            include(path)
        else
            IncludeDir(path)
        end

        if isFirst then override[className] = nil return end
    end

    local func = class[1].Construct
    if func then func(class) end

    oop.InheritChildren(class,table)

    override[className] = nil
end

function oop.GetClassName(className)
    if not className then
        return string.gsub(string.GetFileFromFilename(GetPath(2)),".lua","")
    else
        return className
    end
end

--

function oop.Reg(className,base,isFolder,add,table)
    className = oop.GetClassName(className)
    local overrideClass = override[className]
    if overrideClass then return overrideClass[1],overrideClass[2] end

    local class = oop.RegEx(className,base,table)
    oop.InsertFile(class,isFolder,add)
    override[className] = class
    timer.Create("unoverride_" .. tostring(className),0,1,function() override[className] = nil end)//если произошла ошибка в коде, нехочу через pcall делать (для dev)
    oop.Include(class,nil,table)
end

function oop.RegConnect(className,isFolder,table)
    className = oop.GetClassName(className)
    local overrideClass = override[className]
    if overrideClass then return overrideClass[1],overrideClass[2] end

    local class = (table and table[className]) or listClass[className]
    if not class then error("invalid class " .. className) end

    oop.InsertFile(class,isFolder,add)
    oop.Include(class,true,table)
end

function oop.Get(className,table)
    className = oop.GetClassName(className)
    local overrideClass = override[className]
    if overrideClass then return overrideClass[1],overrideClass[2] end

    local listClass = table or listClass
    local class = listClass[className]
    if not class then error("invalid class " .. className) end

    oop.Include(class,true,table)
end

function oop.Create(className,...)
    local class = listClass[className]

    local obj = util.tableCopy(class[1])
    util.tableLink(obj,class[2])

    if obj.Create then obj:Create(...) end

    return obj
end

function oop.CreateFromTable(class,...)
    local obj = util.tableCopy(class[1])
    util.tableLink(obj,class[2])

    if obj.Create then obj:Create(...) end

    return obj
end
