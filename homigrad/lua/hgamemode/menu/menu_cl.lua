--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/menu/menu_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\menu\\menu_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
function Homigrad_PrePareHTML(code)
    return HTMLDefaultStyle .. [[
        <style>
            p {
                text-align: left;
                font-size: 1em;
    
                color: rgb(254,254,254);
    
                line-height: 1.45em;
                white-space: pre-wrap;
            }
        </style>
        <body style="color: white; overflow-y: hidden ">
            <div style="width: 50%; height: 100%; margin: 0 auto; overflow-y: auto">
        ]] .. code .. [[
             </div>
        </body>
        <script>
            for (let element of document.getElementsByTagName("a")) {
                element.href = ""
            }
        </script>
    ]]
end
