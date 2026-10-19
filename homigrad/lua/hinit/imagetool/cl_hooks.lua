--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/imagetool/cl_hooks.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad\\lua\\hinit\\imagetool\\cl_hooks.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
--[[
        © AsterionStaff 2022.
        This script was created from the developers of the AsterionTeam.
        You can get more information from one of the links below:
            Site - https://asterion.games
            Discord - https://discord.gg/CtfS8r5W3M
        
        developer(s):
            Selenter - https://steamcommunity.com/id/selenter

        ——— Chop your own wood and it will warm you twice.

        //https://music.youtube.com/watch?v=IACPtnopv3o&list=OLAK5uy_lYn6eB45YWaSUVdEyFniDjBYm-bCYuknE
        ЖУКИ НАХОДИТСЯ НА ВАШЕМ АНДРОИДЕ
]]--


-- Создаем конвар с настройкой прорисовки

-- Менюшка с настройкой
hook.Add( "PopulateToolMenu", "ImageTool.Menu", function()
    local l = "imagetool_"

    spawnmenu.AddToolMenuOption("Options", "Image Tool", "imagetoolsettings", "Image Tool Settings", nil, nil, function(CPanel)
        CPanel:ClearControls()

        CPanel:AddControl("Header",{
            Description = "In this menu you can change the settings for the ImageTool."
        })

        CPanel:AddControl("Slider", {
            Label = "Draw distance:",
            Command = "imagetool_dist",
            Min = 0,
            Max = 10000
        })

        local SettingsReset = vgui.Create("DButton")
        SettingsReset:SetText("Return to default settings")
        SettingsReset.DoClick = function()
            RunConsoleCommand(l .. "dist", ImageTool.dist:GetDefault())
        end
        CPanel:AddPanel(SettingsReset)

        local HistoryReset = vgui.Create("DButton")
        HistoryReset:SetText("Clear the history")
        HistoryReset.DoClick = function()
            ImageTool:SaveHistory({})

            timer.Simple(0.5, function()
                RunConsoleCommand("spawnmenu_reload")
            end)

            LocalPlayer():ChatPrint(ImageTool.prefix .. " You have successfully cleared your history!")
        end
        CPanel:AddPanel(HistoryReset)

        local ImageReset = vgui.Create("DButton")
        ImageReset:SetText("Delete all pictures on the map")
        ImageReset.DoClick = function()
            RunConsoleCommand(l .. "delete_all")
        end
        CPanel:AddPanel(ImageReset)
    end)
end)

hook.Add("PostDrawTranslucentRenderables", "ImageTool.PostDrawTranslucentRenderables", function()
    ImageTool:DrawImageTool() -- Тул-Ган отрисовка
end)
