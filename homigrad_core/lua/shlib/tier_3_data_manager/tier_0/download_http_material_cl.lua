--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_3_data_manager/tier_0/download_http_material_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_3_data_manager\\tier_0\\download_http_material_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local chache = {}

file.CreateDir("homigrad")
file.CreateDir("homigrad/chache")

local removeSpecSumbol = {
    "?",
    "/",
    "\\",
    ":",
    "<",
    ">",
    ",",
    "\"",
    "|"
}

local function bakeMaterial(path,callback)
    local tab = queueAdd()
    tab:SetThread("material")
    tab.name = path

    tab.Do = function() 
        callback(Material(path))

        tab:Remove()
    end

    tab:Send()
end//хотел сделать возможность написать обработчик, но чот заметил что и так лагает нахуй кароче

function GetHTTPMaterial(url)
    if not url or url == true then return end
    
    local mat = chache[url]

    if mat == nil or mat == "load" then
        if mat == "load" then return end

        local path = RemoveSpecialSumbolsFromURL(url)
        
        mat = file.Read("homigrad/chache/" .. path .. ".png")//нахуя мне кеш подгружать, он на то и кеш долбаёб блядь.
        
        if not mat then
            chache[url] = "load"

            local tab = queueAdd()
            tab.name = "download http material"
            tab.async = true
            tab:SetThread("download")

            tab.name = url
            tab.url = url
            tab.method = "GET"
            tab.failed = function(err)
                chache[url] = {false,tostring(err),tostring(url)}
                tab:Remove()

                if developer > 0 then ErrorNoHalt("download_http: err " .. tostring(err) .. "\n" .. tostring(url) .. "\n") end
            end

            tab.success = function(code,body)
                tab:Remove()

                if code ~= 200 then
                    chache[url] = {false,url,tostring(url)}

                    if developer > 0 then ErrorNoHalt("download_http: backend err " .. url .. "\n" .. tostring(url) .. "\n") end//не думаю что это кому-то надо....

                    return
                end

                file.Write("homigrad/chache/" .. path .. ".png",body)
                bakeMaterial("data/homigrad/chache/" .. path .. ".png",function(mat) chache[url] = mat end)
            end

            tab.Do = function()
                tab.doing = true

                HTTP(tab)
            end

            tab:Send()

            return
        else
            chache[url] = "load"

            bakeMaterial("data/homigrad/chache/" .. path .. ".png",function(mat) chache[url] = mat end)

            return
        end
    end

    if TypeID(mat) == TYPE_TABLE then
        return false,mat
    else
        return mat
    end
end

function SetHTTPMaterial(url,data)
    local path = url
    for _,sum in pairs(removeSpecSumbol) do path = string.gsub(path,sum,"") end

    file.Write("homigrad/chache/" .. path .. ".png",data)
    chache[url] = Material("data/homigrad/chache/" .. path .. ".png")
end

function DrawHTTPMaterial(x,y,w,h,url)
    local mat = GetHTTPMaterial(url)
    
    if not mat then
        DrawLoading(x + w / 2,y + h / 2,math.min(w,h) / 2)
    else
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(x,y,w,h)
    end
end

function DrawHTTPMaterialCenter(x,y,w,h,url)
    local mat = GetHTTPMaterial(url)
    
    if not mat then
        DrawLoading(x + w / 2,y + h / 2,math.min(w,h) / 2)
    else
        local mw,mh = mat:Width(),mat:Height()
        local maxLength = math.max(w,h) / math.max(mw,mh)

        mw = mw * maxLength
        mh = mh * maxLength

        surface.SetMaterial(mat)
        surface.DrawTexturedRect(x + -(mw - w)/2,y + -(mh - h)/2,mw,mh)
    end
end

local mat_loading = Material("homigrad/vgui/loading.png")

function DrawLoading(x,y,size)
    local size = size

    surface.SetMaterial(mat_loading)
    surface.SetDrawColor(255,255,255,255)
    surface.DrawTexturedRectRotated(x,y,size,size,-(RealTime() * 360) % 360)
end

threadList.download = threadList.download or {}

local old = 0

hook.Add("PostRenderVGUI","Download HTTP",function()
    local queue = threadList.download[1]
    if not queue then return end

    draw.SimpleText(queue.name,"DefaultFixedDropShadow",0,0)
    
    if #threadList.download > 1 then
        old = math.max(old,#threadList.download)

        surface.SetDrawColor(0,0,0)
        surface.DrawRect(0,0,ScrW(),1)

        surface.SetDrawColor(0,255,0)
        surface.DrawRect(0,0,ScrW() * (1 - #threadList.download / old),1)

        draw.SimpleText((old - #threadList.download) .. "/" .. old,"DefaultFixedDropShadow",ScrW(),0,nil,TEXT_ALIGN_RIGHT)
    else
        old = 0
    end
end)

concommand.Add("hg_download_clearchache",function()
    local files = file.Find("homigrad/chache/*","DATA")

    local count = 0

    for _,f in pairs(files) do
        file.Delete("homigrad/chache/" .. f)

        count = count + 1
    end

    chache = {}

    print("remove " .. count .. " files.")

    for k in pairs(threadList.download) do threadList.download[k] = nil end
end)
