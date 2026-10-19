--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_3_data_manager/tier_0_queue_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_3_data_manager\\tier_0_queue_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
//https://music.youtube.com/watch?v=0DP70eRfqtg&list=RDAMVM0DP70eRfqtg

threadList = threadList or {default = {}}

local example = {}

local err = function(err) ErrorNoHaltWithStack(err) end

function example:Insert(id)
    local thread = threadList[self.threadName]
    if not thread then
        thread = {}
        threadList[self.threadName] = thread
    end
    
    self:RemoveID()

    self.id = id
    table.insert(thread,id,self)
    for i = id,#thread do thread[i].id = i end

    if self.OnSetID then xpcall(self.OnSetID,err,self,id) end
end

function example:Send()
    if not self.id then
        local thread = threadList[self.threadName]
        if not thread then
            thread = {}
            threadList[self.threadName] = thread
        end

        self.id = #thread + 1
        thread[self.id] = self
    end

    if self.OnSetID then xpcall(self.OnSetID,err,self,self.id) end

    return self
end

function example:RemoveID()
    local thread = threadList[self.threadName]

    local id = self.id

    if id then
        if thread then
            table.remove(thread,id)
            for i = id,#thread do thread[i].id = i end
        end

        self.id = nil
    end

    if self.OnRemoveID then xpcall(self.OnRemoveID,err,self,id) end
end

local blacklist = {
    ["http://localhost:8000/ping/"] = true,
    ["http://localhost:8001/ping/"] = true  
}

function example:Remove()
    self.doing = false

    if self.id then
        self:RemoveID()
    end

    if not self.removed then
        self.removed = true
        
        if self.OnRemove then xpcall(self.OnRemove,err,self,id) end

        if queueLog then
            if not blacklist[self.url] then
                print("queue remove",self.url)
            end
        end
    end
end

function example:IsValid() return (self.id and self.threadName and threadList[self.threadName] and threadList[self.threadName][self.id] == self) or false end

function example:SetThread(threadName)
    local old

    if self.id then
        old = true

        self:RemoveID()
    end

    threadName = threadName or "default"

    if not threadList[threadName] then
        threadList[threadName] = thread
    end

    self.threadName = threadName

    if old then
        self:Send()
    end

    return self
end

function example:Name()
    return self.name
end

function queueAdd(tab)
    local tab = tab or {}

    for k,v in pairs(example) do tab[k] = v end

    tab.threadName = "default"

    return tab
end

function queueThreadRemove(threadName)
    local thread = threadList[threadName]
    if not thread then return end

    threadList[threadName] = nil

    for i,tab in pairs(thread) do
        tab:Remove()
    end
end

local delay = 0

local function err(err)
    ErrorNoHaltWithStack(err)
end

event.Add("Can Work Queue","InitPostEntity",function()
    if not InitPostEntity then return false else event.Remove("Can Work Queue","InitPostEntity") end
end)

hook.Add("Think","Queue",function()
    if event.Call("Can Work Queue") == false then return end

    for id,list in pairs(threadList) do
        local iteration = 0
        local isEmpty = false

        while true do
            iteration = iteration + 1

            local tab = list[iteration]
            if not tab then isEmpty = iteration == 1 break end

            if tab.err then
                tab.err = nil
                
                ErrorNoHalt("queue err ",tab.url)
                
                break
            end

            if not tab.doing then
                tab.doing = true
                tab.startDoing = RealTime()

                if queueLog then
                    if not blacklist[tab.url] then
                        print("queue start",tab.url or tab.name or "null")
                    end
                end

                local success = xpcall(tab.Do,err,tab)

                if not success then
                    tab:Remove()

                    break
                else
                    if tab.removed then iteration = iteration - 1 end
                    if tab.async then continue end
                end
            else
                if tab.async then continue end
            end

            break
        end

        if TypeID(id) == TYPE_TABLE and isEmpty then threadList[id] = nil end
    end
end)

//

local function Do(self)
    self:Remove()

    self:callback()
end

function qFunc(callback,async,thread)
    local tab = queueAdd()
    
    tab.name = "qFunc"
    tab.callback = callback
    tab.async = async
    tab.Do = Do
    tab:SetThread(thread)
    
    tab:Send()

    return tab
end

local PLAYER = FindMetaTable("Player")

function PLAYER:Queue(queue)
    self.thread = self.thread or {}

    if TypeID(queue) == TYPE_FUNCTION then
        local callback = queue

        queue = queueAdd()
        queue.Do = function()
            if not IsValid(self) then queue:Remove() return end
            
            queue.doing = false
            if callback() == false then return end

            queue:Remove()
        end
        queue:SetThread(self.thread)
        queue:Send()
        
        return
    end

    queue:SetThread(self.thread)

    return queue
end
