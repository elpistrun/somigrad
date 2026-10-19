--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/menu/tos_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\menu\\tos_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local newVersion = 2

concommand.Add("hg_show_termsofservice",function()
	if IsValid(frametos) then frametos:Remove() end

	frametos = oop.CreatePanel("v_frame"):setDSize(1,1)
	frametos:MakePopup()
	frametos:SetZPos(100)

	local html = oop.CreatePanel("v_html",frametos):ad(function(self,w,h) self:setSize(w,h * 0.8):setPos(0,h * 0.1) end)

	function frametos:Draw(w,h)
		surface.SetDrawColor(28,28,28)
		surface.DrawRect(0,0,w,h)

		if not html.Ready then
			draw.SimpleText("Загружаем страницу TOS" .. string.rep(".",RealTime() % 4),"HS.45",w/2,h * 0.125,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			draw.SimpleText("Если этого не происходит, значит что-то не так.","HS.18",w/2,h * 0.125 + 45,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

			DrawLoading(w/2,h/2,h/2)
		end

		RunConsoleCommand("stopsound")
	end

	function frametos:DrawOver(w,h)
		draw.SimpleText("SOMIGRAD.SU","HS.45",w/2,h * 0.05,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

	local req = queueHTTP("https://homigrad.com/tos",function(res)
		local body = res.body
		body = string.sub(body,string.find(body,'<div class="word">') + 18,nil)
		body = string.sub(body,1,string.find(body,"</html>") - 22)

		html:SetHTML(Homigrad_PrePareHTML(body))

		function html:OnDocumentReady()
			self.Ready = true
		end
	end):Send()

	local buttYes = oop.CreatePanel("v_button",frametos):ad(function(self,w,h) self:setSize(w * 0.4,75):setPos(w/2 - self:W(),h* 0.9) end)
	buttYes:SetupDrawStyle("white_gradient"); buttYes.text = "Перейти к правилам"; buttYes.font = "HS.45"; buttYes.gradientSide = "bottom"

	local buttNo = oop.CreatePanel("v_button",frametos):ad(function(self,w,h) self:setSize(w * 0.4,75):setPos(w/2,h* 0.9) end)
	buttNo:SetupDrawStyle("white_gradient"); buttNo.text = "Я не соглашаюсь"; buttNo.font = "HS.45"; buttNo.gradientSide = "bottom"

	function buttNo:OnClick()
		net.Start("kick tos")
		net.SendToServer()
	end

	function buttYes:OnClick()
		buttYes:SetIsNotClickable(true)
		buttYes.backgroundColor = Color(25,25,25,25)
		buttYes.textColor = Color(255,255,255,25)
		buttYes.text = "Я ознакомился с правилами"

		timer.Simple(3,function()
			if not IsValid(buttYes) then return end
			
			buttYes:SetIsNotClickable(false)
			buttYes.backgroundColor = nil
			buttYes.textColor = nil
		end)

		function buttYes:OnClick()
			RunConsoleCommand("hg_termsofservice_accept",newVersion)
			frametos:Remove()
		end

		html:OpenURL("https://homigrad.com/wiki/rules/")
	end
end)

local version = CreateClientConVar("hg_termsofservice_accept","0")

hook.Add("InitPostEntity","TOS",function()
	if version:GetInt() ~= newVersion then
		RunConsoleCommand("hg_show_termsofservice")
	end	
end)
