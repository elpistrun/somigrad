--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_0/tier_0/player/init_protocol_loadscreen_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_0\\tier_0\\player\\init_protocol_loadscreen_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
LoadscreenRequestWait = LoadscreenRequestWait or {}

event.Add("Token Read","LoadScreen",function(req)
    if InitNET then return end

    LoadscreenRequestWait[#LoadscreenRequestWait + 1] = req
end)

event.Add("Setup World","LoadScreen",function(req)
    LoadscreenRequestWait = {}
end)

event.Add("initProtocol_3()","Wating Token",function()
    for i,req in pairs(LoadscreenRequestWait) do
        if IsValid(req) then return false,"wait token" end
    end
end)

if not InitNET then
    hook.Add("CreateMove","InitProtocol",function(cmd)
        cmd:ClearMovement()
        cmd:ClearButtons()

        return true
    end)

    event.Add("Setup World","RemoveMoveHook",function()
        hook.Remove("CreateMove","InitProtocol")
    end,-11)
end

event.Add("Pre Render","!NET Protocol",function()
    if InitNET then return end

    RunConsoleCommand("stopsound")
    
    local w,h = ScrW(),ScrH()
    
	cam.Start2D()
		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect(0,0,w,h)

        draw.SimpleText(L("loadscreen_welcome"),"H.45",w / 2,h * 0.1,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        draw.SimpleText(tostring(InitProtocol),"H.45",w / 2,h / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        if initProtocol_3_WaitReason then
            if initProtocol_3_WaitReason == "wait token" then
                local success = 0
                local curretReq

                for i,req in pairs(LoadscreenRequestWait) do
                    if not IsValid(req) then
                        success = success + 1
                    else
                        curretReq = req

                        break
                    end
                end

                if curretReq then
                    draw.SimpleText(curretReq:Name(),"HS.25",w/2,h/2 + 50,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                end

                draw.SimpleText(success .. " / " .. #LoadscreenRequestWait,"HS.25",w/2,h/2 + 90,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            else
                draw.SimpleText(initProtocol_3_WaitReason,"HS.25",w/2,h/2 + 50,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            end
        end
        
        draw.SimpleText(L("loadscreen_wait"),"H.25",w /2 ,h - h / 4,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        draw.SimpleText(L("loadscreen_what_me_do"),"H.25",w /2 ,h - h / 4 + 45,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    cam.End2D()

    return false
end)

/*if Initialize and InitNET then
    InitNET = nil

    InitProtocol = "waitSourceReady"
    Start = RealTime()
    
    timer.Simple(1,function()
        InitProtocol = "waitResponseFromServer"
        net.Start("initProtocol")
        net.SendToServer()
    end)

    RunConsoleCommand("init_protocol_restart")
end*/
