--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/client/scoreboard/pages/settings/sound_cl.lua <
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

-- "addons\\homigrad\\lua\\hgamemode\\client\\scoreboard\\pages\\settings\\sound_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Page = {}
SettingsPages[3] = Page
Page.Name = "sound"

function Page.Open(panel)
    local cat = panel:AddCategory(L("settings_main"))

    if not util.Is64Bit() then
        cat:AddText("DSP Sound change","Нужен BRANCH x86-64")
        cat:AddText("DSP Sound","Нужен BRANCH x86-64")
    else
        cat:AddSwitch("DSP Sound change","hg_sound_dsp_change")
        cat:AddSwitch("DSP Sound","hg_sound_dsp")
    end

    cat:AddSlider(L("settings_volume_shootgun"),"hg_volume_shoot",nil,nil,100)
    cat:AddSlider(L("settings_radio_volume"),"hg_radio_volume",nil,nil,100)

    local cat = panel:AddCategory("Dynamic Weapon Reverb")
    cat:AddSwitch(L("settings_dwr"),"cl_dwr_disable_reverb",true)
    cat:AddSlider(L("settings_dwr_volume"),"cl_dwr_volume",nil,nil,100)
    cat:AddSlider(L("settings_best_soundtrace"),"hg_best_soundtrace",nil,nil,1)
     
    //cat:AddSlider("Количество лучей","cl_dwr_occlusion_rays",nil,nil,1)
    //cat:AddSlider("Количество отражающих лучей","cl_dwr_occlusion_rays_reflections",nil,nil,1)
end
