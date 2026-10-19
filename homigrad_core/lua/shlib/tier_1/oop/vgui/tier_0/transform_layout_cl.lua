--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_1/oop/vgui/tier_0/transform_layout_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad_core/lua/shlib/tier_1/oop/vgui/tier_0/tier_0_cl.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_1\\oop\\vgui\\tier_0\\transform_layout_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local PANEL = oop.Get("v_panel")
if not PANEL then return end

if true then return end//хуёвая затея блядь
//онет он что не разобрался в чём-тоо??? фу ебать лох😈😈😈😈

PANEL:Event_Add("Child Added","Construct",function(self,child)
    self:StartConstruct(nil,"childAdded")
end,-10)

PANEL:Event_Add("Child Remove","Construct",function(self,child)
    self:StartConstruct(nil,"childRemove")
end,-10)

PANEL:Event_Add("Init","Construct",function(self)
    self:StartConstruct(nil,"init")
end,-10)

function PANEL:setSize(w,h)
    if self:W() == w and self:H() == h then return end

    self:StartConstruct()
    self:SetSize(w,h)

    return self,true
end

//

CONSTRUCTELEMENTS = {}

function PANEL:StartConstruct(now,callerType)
    if now then
        local isFirst = not CONSTRUCTLAYOUT
        if isFirst then CONSTRUCTLAYOUT = true end

        self:Event_Call("Perform",w,h)

        for i,child in pairs(self:GetChildren()) do
            if child.StartConstruct then child:StartConstruct(true) end
        end

        self:Event_Call("Perform End",w,h)

        if isFirst then CONSTRUCTLAYOUT = nil end
    else
        if CONSTRUCTLAYOUT then return end
        
        local panelCaller = self
        local parent = self:GetParent()
        if IsValid(parent) and parent.StartConstruct then panelCaller = parent end
    
        //panelCaller.constructCallerType = callerType
        CONSTRUCTELEMENTS[panelCaller] = true
    end
end

local countOperation = 0

local function clear(panel)
    //countOperation = countOperation + 1

    for _,child in pairs(panel:GetChildren()) do
        clear(child)
        
        CONSTRUCTELEMENTS[child] = nil
    end
end

hook.Add("PreRender","CONSTRUCTVGUIELEMENTS",function()//мне не ясна логика performlayout и я её в рот ебал поэтому свою сделал х3, главное чтоб не лагало и похуй ваще
    //countOperation = 0

    CONSTRUCTLAYOUT = true

    for panel in pairs(CONSTRUCTELEMENTS) do
        if not IsValid(panel) then continue end

        local parent = panel:GetParent()
        local start,startID

        for i = 1,200 do
            //countOperation = countOperation + 1

            local newParent = parent:GetParent()
            if not IsValid(newParent) then break end

            if CONSTRUCTELEMENTS[newParent] then
                if not startID or startID < i then
                    start = newParent
                    startID = i
                end

                CONSTRUCTELEMENTS[newParent] = nil
            end
            
            parent = newParent
        end

        if start then
            clear(start)
            panel = start
        end

        panel:StartConstruct(true)
    end

    CONSTRUCTLAYOUT = nil
    CONSTRUCTELEMENTS = {}

    //if countOperation > 0 then print(countOperation) end
end)
