--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/client/scoreboard/pages/settings/game_cl.lua <
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

-- "addons\\homigrad\\lua\\hgamemode\\client\\scoreboard\\pages\\settings\\game_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Page = {}
SettingsPages[1] = Page
Page.Name = "game"

function Page.Open(panel)
    local cat = panel:AddCategory(L("settings_camera"))
    cat:AddSlider("FOV","hg_fov",nil,nil,1)
    /*cat:AddSwitch("Плавная камера","hg_camera_smooth")
    cat:AddSwitch("Трясущееся камера","hg_camera_movement")*/
    cat:AddSwitch("Body Camera","hg_bodycam_enable")
    cat:AddSwitch("Body Camera Sound","hg_bodycam_dsp")
    local cat = panel:AddCategory("HUD")
    cat:AddSwitch("Chat History On HUD","hg_chat_visible")
    cat:AddSwitch("Spectate HUD","hg_show_hudspectate")
    cat:AddSwitch("Voice HUD","hg_show_voicehud")
    cat:AddSwitch(L("settings_playsound_startround"),"hg_sound_round",n)
    cat:AddSwitch("Streamer Mode","hg_streamer_mode")
    cat:AddSwitch("Ragdoll always E","hg_fake_always_e")

    local block = cat:AddBlock(40,"v_button")
    function block:Draw(w,h)
        surface.SetDrawColor(0,0,0,125)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(125,125,125,25)
        local wide = w * (0.25 + self.lerpHover * 0.25)
        draw.GradientLeft(0,0,wide,h)
        draw.GradientRight(w - wide,0,wide + 1,h)

        draw.SimpleText("GLide Settings","HS.18",w / 2,h / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    function block:OnClick() RunConsoleCommand("glide_settings") end
end

cvars.CreateOption("hg_chat_visible","1")

local PLAYER = FindMetaTable("Player")

if not HNameStreamerMode then HNameStreamerMode = PLAYER.Name end

cvars.CreateOption("hg_streamer_mode","0",function(value)
    if tonumber(value) > 0 then
        PLAYER.Name = function(self) return tostring(self:UserID()) end
        PLAYER.Nick = PLAYER.Name

        StreamMode = true
    else
        PLAYER.Name = HNameStreamerMode
        PLAYER.Nick = PLAYER.Name

        StreamMode = false
    end
end)
