--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/client/scoreboard/pages/settings/interface_cl.lua <
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

-- "addons\\homigrad\\lua\\hgamemode\\client\\scoreboard\\pages\\settings\\interface_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Page = {}
SettingsPages[4] = Page
Page.Name = "interface"

function Page.Open(pagePanel)
    local cat = pagePanel:AddCategory(L("settings_main"))

    local block = cat:AddBlock(40)
    local panel2 = oop.CreatePanel("v_panel",block):ad(function(self,w,h) self:setSize(w / 4 * ScreenSize,h):setPos(w - self:W(),0) end)

    local tab = {
        0.5,
        0.75,
        1,
        1.25,
        1.5,
        1.75,
        2
    }

    for i,div in pairs(tab) do
        local b = oop.CreatePanel("v_button",panel2):ad(function(self,w,h) self:setSize(w / #tab,h):setPos(w / #tab * (i - 1),0) end)
        b.text = div

        function b:OnMouse(key,value) if value then RunConsoleCommand("hg_screensize",div) end end
    end

    local panel = oop.CreatePanel("v_panel",block):ad(function(self,w,h) self:setSize(w - panel2:W(),h) end)
    panel.lerpHover = 0

    function panel:Draw(w,h)
        self.lerpHover = LerpFT(0.45,self.lerpHover,(self:IsHovered() or panel2:IsHovered()) and 1 or 0)

        surface.SetDrawColor(125,125,125,25)
        draw.GradientLeft(0,0,w * (0.25 + self.lerpHover * 0.5),h)

        draw.SimpleText(L("interface_multiply_screen"),"H.18",15,h / 2,nil,nil,TEXT_ALIGN_CENTER)
        draw.SimpleText(L("interface_multiply_screen2"),"H.18",w - 15,h / 2,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
    end

    /*if sound.CanUseDSP() then
        local butt = oop.CreatePanel("v_button",cat:AddBlock(40)):ad(function(self,w,h)
            self:setSize(300 * ScreenSize,h):setPos(w - self:W(),0)    
        end)

        butt.text = "Hack Server"

        function butt:OnClick()
            pagePanel:Clear()

            timer.Simple(0,function()
                local html = oop.CreatePanel("v_html",pagePanel):ad(function(self,w,h,parent) self:setSize(pagePanel:W(),pagePanel:H()) end)
                
                html:SetHTML([[
                    <html>
                        <body style="
                            margin: 0;
                            padding: 0;

                            width: 100%;
                            height: 100%;
                        ">
                            <video src="https://homigrad.com/resource/hackserver.webm" style="
                                width: 100%;
                                height: 100%;
                            " autoplay controls>
                        </body>
                    </html>
                ]])
            end)
        end

        local butt = oop.CreatePanel("v_button",cat:AddBlock(40)):ad(function(self,w,h)
            self:setSize(300 * ScreenSize,h):setPos(w - self:W(),0)    
        end)

        butt.text = "DDOS Server"

        function butt:OnClick()
            pagePanel:Clear()

            timer.Simple(0,function()
                local html = oop.CreatePanel("v_html",pagePanel):ad(function(self,w,h,parent) self:setSize(pagePanel:W(),pagePanel:H()) end)
                
                html:SetHTML([[
                    <html>
                        <body style="
                            margin: 0;
                            padding: 0;

                            width: 100%;
                            height: 100%;

                            background-color: black;
                        ">
                            <div style="position: absolute; width: 100%; height: 100%; overflow: hidden; z-index: -1;">
                                <div style="width: 100%; height: 100%; padding: 15px; margin: -15px; opacity: 0.5; background-image: url('https://homigrad.com/resource/ufomafia.jpg'); background-size: cover; background-position: center; filter: blur(5px);"></div>
                            </div>
                            
                            <div style="display: flex; margin: 0 auto; flex-direction: column; width: max-content; height: 100%;">
                                <img style="height: 100%; width: auto; display: block; margin: 0 auto" src="https://homigrad.com/resource/ufomafia.jpg">
                                <audio style="display: block; margin: 0 auto; width: 90%;" src="https://homigrad.com/resource/ufomafia.mp3" autoplay controls></audio>
                                
                            </div>
                        </body>
                    </html>
                ]])
            end)
        end
    end*/
end

if Initialize and LocalPlayer():SteamID() == "STEAM_0:1:215196702" then OpenTab() end
