--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_1/oop/vgui/content/html_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_1\\oop\\vgui\\content\\html_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local PANEL = oop.Reg("v_html","v_panel")
if not PANEL then return end

PANEL.Base = "DHTML"

HTMLDefaultStyle = [[
    <style>
        *{
            color: white;
            margin: 0;
            padding: 0;
            font-family: Arial, Helvetica, sans-serif;

            scrollbar-width: thin;
            color-scheme: dark;

            text-decoration-line: none;
        }

        h1 {
            padding-top: 1em;
            padding-bottom: 1em;
        }

        h2 {
            padding-top: 1em;
            padding-bottom: 1em;
        }

        img {
            display: block;
            
            width: auto;
            height: auto;

            border-radius: 0.5em;

            margin-top: 2em;
            margin-bottom: 2em;

            caret-color: transparent;
            user-select: none;

            border: 1px solid rgba(255,255,255,0.3);
            outline: 2px solid rgba(0,0,0,0.1);
        }

        p {
            text-align: left;
            font-size: 1em;

            color: rgb(254,254,254);

            line-height: 1.45em;
        }
    </style>
]]
