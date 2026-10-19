--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_1/oop/vgui/content/scrollpage_cl.lua <
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

-- "addons\\homigrad_core\\lua\\shlib\\tier_1\\oop\\vgui\\content\\scrollpage_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local PANEL = oop.Reg("v_scrollpage","v_panel")
if not PANEL then return end

function PANEL:OnInit()
    self.pages = {}

    self.page = 1
    self.setPage = 1
    self.Lerp = 1

    self.canvasPanel = oop.CreatePanel("v_panel",self)
end

function PANEL:SetHorizontal(horizontal)
    self.horizontal = horizontal

    if horizontal then
        self.canvasPanel:ad(function(canvas,w,h) canvas:setSize(w * #self.pages,h) end)
    else
        self.canvasPanel:ad(function(canvas,w,h) canvas:setSize(w,h * #self.pages) end)
    end
end

function PANEL:Step()
    self.page = LerpFTLess(self.Lerp,self.page,self.setPage,0.001)

    if self.horizontal then
        self.canvasPanel:setPos(-self:W() * (self.page - 1),0)
    else
        self.canvasPanel:setPos(0,-self:H() * (self.page - 1))
    end
end

function PANEL:Add()
    local page = oop.CreatePanel("v_panel",self.canvasPanel)
    local id = #self.pages
    page.id = id + 1

    if self.horizontal then
        page:ad(function(canvas,w,h) page:setSize(self:W(),h):setPos(self:W() * id,0) end)
    else
        page:ad(function(canvas,w,h) page:setSize(w,self:H()):setPos(0,self:H() * id) end)
    end

    self.pages[#self.pages + 1] = page

    self:Event_Call("Update Page",#self.pages,page)

    return page
end

function PANEL:Set(page,fast)
    self.setPage = page
    if fast then self.page = page end

    if self.OnPage then self:OnPage(page) end
    self:Event_Call("Page",page)
end

function PANEL:Clear()
    for i,panel in pairs(self.canvasPanel:GetChildren()) do
        panel:Remove()
    end

    self.pages = {}
end
