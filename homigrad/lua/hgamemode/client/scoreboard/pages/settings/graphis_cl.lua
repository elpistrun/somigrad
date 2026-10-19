--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/client/scoreboard/pages/settings/graphis_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
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

-- "addons\\homigrad\\lua\\hgamemode\\client\\scoreboard\\pages\\settings\\graphis_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Page = {}
SettingsPages[2] = Page
Page.Name = "graphics"

local function ShowRadius(radius)
    local white = Color(255,255,255)

    timee = CurTime() + 3

    local mat = Material("models/wireframe")
    
    hook.Add("PostDrawOpaqueRenderables","Show Distance Graphishch",function()
        white.a = 255 * math.Clamp(timee - CurTime(),0,1)
    
        render.SetMaterial(mat)
        render.DrawSphere(EyePos(),-radius,16,16,white)
    end)

    timer.Create("ShowRadius",3,1,function()
        hook.Remove("PostDrawOpaqueRenderables","Show Distance Graphishch")
    end)
end

function Page.Open(panel)
    local cat = panel:AddCategory(L("graphics_draw"))
    cat:AddSwitch(L("graphics_drawarmor"),"hg_draw_armor")
    cat:AddSwitch(L("graphics_drawbackweapons"),"hg_draw_backweapons")
    cat:AddSwitch(L("graphics_draw3dskybox"),"r_3dsky")
    cat:AddSlider(L("graphics_drawbloom"),"hg_draw_bloom")
    cat:AddSlider(L("graphics_smoothmove"),"mat_motion_blur_enabled")
    cat:AddSlider(L("graphics_decals"),"r_decals",nil,nil,1,nil,0,8096)
    cat:AddSlider(L("graphics_mp_decals"),"mp_decals",nil,nil,1,nil,0,8096)

    local cat = panel:AddCategory(L("graphics_material"))
    cat:AddSwitch(L("graphics_cubemap"),"hg_mat_env")
    cat:AddSwitch(L("graphics_bumbmap"),"mat_bumpmap",nil,L("graphics_freeze"))
    cat:AddSwitch(L("graphics_specular"),"mat_specular",nil,L("graphics_freeze"))
    cat:AddSwitch(L("graphics_pixeltexture"),"mat_filtertextures",true,L("graphics_pixeltexture2"))
    
    local cat = panel:AddCategory(L("graphics_shadow_and_lights"))
    cat:AddSwitch(L("graphics_shadowsoflamp"),"r_flashlightdepthtexture",nil,L("graphics_freeze"))
    cat:AddSlider(L("grahpics_quality_of_lamps"),"r_flashlightdepthres",nil,nil,1,nil,0,1024)
    cat:AddSwitch(L("graphics_pixel_lights"),"mat_filterlightmaps",true,L("graphics_pixel_lights2"))

    local cat = panel:AddCategory(L("graphics_optimize"))
    cat:AddSwitch(L("graphics_theard"),"hg_thread",nil,L("graphics_theard2"))
    cat:AddSlider(L("graphics_bones_framerate"),"hg_bones_framerate",nil,L("graphics_bones_framerate2"),1)
    

    local cat = panel:AddCategory(L("graphics_other"))
    cat:AddSwitch(L("graphics_bullets"),"zippyimpacts_enable")
    cat:AddSwitch(L("graphics_speak_moth"),"hg_voiceflex")
    cat:AddSwitch(L("graphics_best_scope"),"hg_best_scope")
    cat:AddSlider(L("graphics_shotfire"),"hg_best_weaponlight",nil,L("graphics_shotfire2"),1)
    cat:AddSlider(L("graphics_shells"),"hg_best_shells",nil,L("graphics_shells2"),1)
    cat:AddSlider(L("graphics_quality_flashlight"),"hg_best_flashlight",nil,L("graphics_quality_flashlight2"),1)
    cat:AddSlider(L("graphics_best_explosive"),"hg_best_explosive",nil,L("graphics_best_explosive_desc"),1)
end

local re = RunConsoleCommand
local g = GetConVar

local function add(name,convarList,def,invert)
    cvars.CreateOption(name,def or "1",function(value)
        if tonumber(value) > 0 then
            for i,name in pairs(convarList) do re(name,(invert and "0") or GetConVar(name):GetDefault()) end
        else
            for i,name in pairs(convarList) do re(name,(invert and GetConVar(name):GetDefault()) or "0") end
        end
    end)
end

local function addSlider(name,convar,def,min,max,change)
    if TypeID(convar) ~= TYPE_TABLE then convar = {convar} end

    cvars.CreateOption(name,def,function(value)
        for i,name in pairs(convar) do
            re(name,tostring(value))
        end
        
        if change then change(tostring(value)) end
    end,min,max)
end

add("hg_mat_env",{"mat_envmapsize","mat_envmaptgasize"})
addSlider("hg_draw_bloom",{"mat_bloomscale","mat_bloom_scalefactor_scalar"},"0.15",0,1)

//mat_reducefillrate  0
//mat_reduceparticles 0

local list = {//https://steamcommunity.com/sharedfiles/filedetails/?id=3334367687
    {
        threadpool_affinity = 64,
        mat_powersavingsmode = 0,

        snd_mix_async = 1,
        snd_async_fullyasync = 1,
        snd_async_minsize = 0,

        r_queued_ropes = 1,
        mat_queue_mode = 2,
        studio_queue_mode = 1,
        ai_expression_optimization = 1,
        filesystem_max_stdio_read = 64,
        r_radiosity = 4,
        
        mat_frame_sync_enable = 0,
        mat_framebuffercopyoverlaysize = 0,
        mat_managedtextures = 0,
        fast_fogvolume = 1,
        lod_TransitionDist = 2000,
        filesystem_unbuffered_io = 0,

        cl_threaded_bone_setup = 1,
        cl_threaded_client_leaf_system = 1,
        r_threaded_renderables = 1,
        r_threaded_client_shadow_manager = 1,
        r_threaded_particles = 1,

        snd_mix_async = 1
    },
    {
        r_queued_ropes = 0,
        mat_queue_mode = -1,
        studio_queue_mode = 0,

        cl_threaded_bone_setup = 0,
        cl_threaded_client_leaf_system = 0,
        r_threaded_client_shadow_manager = 0,
        r_threaded_particles = 0,
        
        snd_mix_async = 0
    }
}

cvars.CreateOption("hg_thread","1",function(value,runNow)
    if not runNow then print("\t\t\t\t hg_thread " .. tostring(value)) end
    
    if tonumber(value or 0) > 0 then
        for cmdName,value in pairs(list[1]) do
            if not runNow then print(string.sub(cmdName .. string.rep(" ",50),1,50) .. tostring(value)) end

            RunConsoleCommand(cmdName,value)
        end
    else
        for cmdName,value in pairs(list[2]) do
            if not runNow then print(string.sub(cmdName .. string.rep(" ",50),1,50) .. tostring(value)) end

            RunConsoleCommand(cmdName,value)
        end
    end
end)

local graph = 0

cvars.CreateOption("hg_graph","0",function(value) graph = tonumber(value) end)

local white = Color(255,255,255,255)

local v = 0
local fps = 0

hook.Add("HUDPaint","Graph",function()
    if graph == 1 then
        v = v + 1

        if v > 2 then
            v = 0
            fps = math.Round(1 / FrameTime())
        end

        draw.SimpleText(fps,"H.18",ScrW() / 2,ScrH(),white,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
    end
end)
