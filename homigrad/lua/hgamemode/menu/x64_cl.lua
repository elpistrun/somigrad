--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/menu/x64_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\menu\\x64_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local newVersion = 1

concommand.Add("hg_show_x64",function()
	if IsValid(framex64) then framex64:Remove() end
	framex64 = VguiCreateBlackScreen()

	function framex64:DrawContent(w,h)
        draw.SimpleText("У вас не стоит x86-64 [Chromium] версия Garry's mod!","HS.45",w/2,h * 0.1,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        draw.SimpleText("Для комфортной игры поставте эту бета-версию","HS.25",w/2,h * 0.1 + 60,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        draw.SimpleText("Узнайте в интернете как её поставить, это не сложно <3","HS.25",w/2,h * 0.925,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    local html = oop.CreatePanel("v_html",framex64):ad(function(self,w,h) self:setSize(w * 0.6,h * 0.6):setPos(w/2 - self:W()/2,h/2 - self:H()/2) end)

    html:SetHTML(HTMLDefaultStyle .. [[
        <body style="color: white;">
            <h1>Почему я должен её установить?</h1>
            <p>
            32 bit версия работает намноге хуже и медленее чем 64 bit<br>
            И ещё в 64 bit есть функции которые не доступны в 32 bit (приглушение звуков за стеной, анимированые аватарки)<br><br>
            Но в 64 bit есть проблемы<br>
            Если у вас крашится игра, советую полностью переустановить игру (не забудте про папку с data, если вы хотите сохранить ваши дубликаты!)<br>
            Возможно дело в оперативной памяти или не таком мощном процесоре, если честно я доконца незнаю в чём дело но (возможно, это не у всех) чем слабее ваш компъютер, тем выше шанс что ваша игра вылетет!<br><br>
            Если у вас есть такие проблемы то переход на 32 bit может решить проблемы с внезапным вылетом.
            </p>
        </body>
    ]])
    function framex64:OnMouse() end

    local butt = oop.CreatePanel("v_button",framex64):ad(function(self,w,h) self:setSize(w * 0.5,75):setPos(w/2 - self:W()/2,h * 0.8) end)
    butt:SetupDrawStyle("white_gradient"); butt.text = "Я ознакомился, дайте мне уже поиграть!"; butt.font = "HS.25"; butt.gradientSide = "bottom"
    butt:SetIsNotClickable(true)
    butt.backgroundColor = Color(25,25,25,25)
    butt.textColor = Color(255,255,255,25)
    
    timer.Simple(3,function()
        if not IsValid(butt) then return end
        
        butt.backgroundColor = nil
        butt.textColor = nil
        butt:SetIsNotClickable(false)
    end)

    function butt:OnClick()
        RunConsoleCommand("hg_show_x64_accept",newVersion)
        framex64:Close()
    end
end)

local version = CreateClientConVar("hg_show_x64_accept","0")

hook.Add("InitPostEntity","TOS",function()
	if not util.Is64Bit() and version:GetInt() ~= newVersion then
		RunConsoleCommand("hg_show_x64")
	end	
end)
