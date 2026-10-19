--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/hinit/devtools/nettrafic_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad_core\\lua\\hinit\\devtools\\nettrafic_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
//поприколу стряпал

//Write

local vars = {
    "Angle",
    "Bit",
    "Data",
    "Double",
    "Float",
    "Int",
    "Normal",
    "Matrix",
    "String",
    "UInt",
    "UInt64",
    "Vector"
}

for _,var in pairs(vars) do
    if not _G["HNetWrite" .. var] then _G["HNetWrite" .. var] = net["Write" .. var] end
end

local vars2 = {
    "Incoming",
    "Start",
    "Abort",
    "Send",
    "SendPAS",
    "SendPVS",
    "Broadcast",
    "SendToServer"
}

for _,var in pairs(vars2) do
    if not _G["HNet" .. var] then _G["HNet" .. var] = net[var] end
end

local varsAbort = {
    "Abort",
    "Send",
    "SendPAS",
    "SendPVS",
    "Broadcast",
    "SendToServer"
}

local nets = {}
local screenshoot = {}

timer.Create("NET Trafic",1,0,function()
    if not NetCatchTrafic then return end

    local old = screenshoot
    screenshoot = {}

    event.Run("Net Trafic Update",old)
end)

function net.CatchTrafic(value)
    net.Abort()

    net.TraficClear()

    print("NET TRAFIC CATCHED: " .. tostring(value))

    if SERVER then
        SetGlobalVar("NetTrafic",value)
    end

    NetCatchTrafic = value
    
    if value then
        net.Start = function(channel,unreliable)
            HNetStart(channel,unreliable)

            unreliable = unreliable and true or false

            screenshoot[unreliable] = screenshoot[unreliable] or {}
            screenshoot[unreliable][channel] = screenshoot[unreliable][channel] or {}
            NetScreenChannel = screenshoot[unreliable][channel]

            NetScreenChannel[#NetScreenChannel + 1] = {}
            NetScreen = NetScreenChannel[#NetScreenChannel]
        end

        for _,var in pairs(varsAbort) do
            local handle = _G["HNet" .. var]

            net[var] = function(...)
                handle(...)
            end
        end

        net.Abort = function()
            HNetAbort()

            NetScreenChannel[#NetScreenChannel] = nil
        end

        //

        for _,var in pairs(vars) do
            local handle = _G["HNetWrite" .. var]

            net["Write" .. var] = function(data,a1)
                handle(data,a1)

                if TypeID(data) == TYPE_VECTOR or TypeID(data) == TYPE_ANGLE then
                    local bytes = #tostring(data[1]) + #tostring(data[2]) + #tostring(data[3])

                    NetScreen[var] = (NetScreen[var] or 0) + bytes
                elseif TypeID(data) == TYPE_COLOR then
                    local bytes = #tostring(data.r) + #tostring(data.g) + #tostring(data.b) + (a1 and #tostring(data.a) or 0)
                 
                    NetScreen[var] = (NetScreen[var] or 0) + bytes
                else
                    local bytes = #tostring(data)

                    NetScreen[var] = (NetScreen[var] or 0) + bytes
                end
            end
        end

        net.Incoming = function(len,ply)
            HNetIncoming(len,ply)
        end
    else
        for _,var in pairs(vars) do net["Write" .. var] = _G["HNetWrite" .. var] end
        for _,var in pairs(vars2) do net[var] = _G["HNet" .. var] end

        net.Incoming = HNetIncoming
    end
end

function net.GetTrafic() return nets end
function net.TraficClear() nets = {} end
