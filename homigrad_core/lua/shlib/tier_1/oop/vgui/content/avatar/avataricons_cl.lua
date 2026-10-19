--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_1/oop/vgui/content/avatar/avataricons_cl.lua <
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
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_1\\oop\\vgui\\content\\avatar\\avataricons_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local PANEL = oop.Reg("v_avataricons","v_avatarlist")
if not PANEL then return end

function PANEL:GetHTMLCode()
    return [[
    <html>
        <head>
        </head>
        <body style="
            margin: 0;
            padding: 0;
            
            overflow-x: hidden;
            overflow-y: hidden;

            position: relative;

            display: flex;
            align-content: flex-start;
            flex-wrap: wrap;
        ">
        </body>
        
        <script>
            let height = ]] .. self.iconSize .. [[;
            let wide = height * 0.25

            setScrollY = function(value) {
                document.body.style.bottom = value + "px"
            }

            let list = {}

            addPanel = function(id,avatar,avatarFrame) {
                let panel = document.createElement("div")
                document.body.appendChild(panel)
                panel.style = `
                    width: auto;
                    height: ` + height + `px;
                    margin: ` + wide + `px;
                `

                list[id] = panel

                let avatarPanel = document.createElement("div")
                panel.appendChild(avatarPanel)
                avatarPanel.style = `
                    background-size: cover;
                    background-image: url("` + avatar + `");
                    width: ` + height + `px;
                    height: 100%;
                `

                let avatarFrameAnchor = document.createElement("div")
                avatarPanel.appendChild(avatarFrameAnchor)
                avatarFrameAnchor.style = `
                    width: 0px;
                    height: 0px;

                    position: absolute;
                `

                let avatarFramePanel = document.createElement("div")
                avatarFrameAnchor.appendChild(avatarFramePanel)
                avatarFramePanel.style = `
                    background-size: cover;
                    background-image: url("` + avatarFrame + `");

                    width: ` + (height + wide) + `px;
                    height: ` + (height + wide) + `px;

                    position: relative;
                    left: ` + (-wide / 2) + `px;
                    top: ` + (-wide / 2) + `px;
                `
            }

            removePanel = function(id) {
                list[id].remove()

                delete list[id]
            }

            setAlpha = function(id,k) {
                if (!list[id] || !list[id].style) {return}

                list[id].style.opacity = k
            }

            clear = function() {
                for (let id in list) {
                    list[id].remove()
                }

                list = {}
            }

            let parent = document.body

            setY = function(id,value) {
                let panel1 = list[id]
                let panel2 = parent.children[value]

                if (panel1 == panel2) {return}

                if (!panel2) {
                    if (value <= 0) {
                        panel2 = parent.children[1]
                    } else {
                        panel2 = parent.children[parent.children.length - 1]
                    }
                }

                if (panel1 == panel2 || !panel1 || !panel2) {return}

                let temp = document.createElement("div")

                parent.replaceChild(temp,panel1)
                parent.replaceChild(panel1,panel2)
                parent.replaceChild(panel2,temp)

                temp.remove()
            }
        </script>
    </html>
    ]]
end

function PANEL:AddPanel(id,avatar,avatarFrame)
    if not self.Ready then
        local tab = queueAdd()
        tab:SetThread(self)
        tab.Do = function()
            if not IsValid(self) then tab:Remove() return end
            if not self.Ready then tab.doing = false return end

            tab:Remove()

            self:RunJavascript('addPanel("' .. id .. '","' .. (avatar or "") .. '","' .. (avatarFrame or "") .. '")')
        end

        tab.async = true
        tab:Send()
        tab.OnRemove = function()
            if IsValid(self) then
                self.listIDQueue[id] = nil
            end
        end

        self.listIDQueue[id] = tab
    else
        self:RunJavascript('addPanel("' .. id .. '","' .. (avatar or "") .. '","' .. (avatarFrame or "") .. '")')
    end
end
