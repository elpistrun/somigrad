--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/levels/tier_0_base/util/winner_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hgamemode/roundsystem/levels/tier_0_base/tier_0_sh.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\levels\\tier_0_base\\util\\winner_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Level = oop.Get("level_base")
if not Level then return end

/*event.Add("Start Round","CloseWinnerVGUI",function()
    ActiveLevel:CloseWinnerVGUI()
end)*/

-- Level:SetEndType переехал в win_sh.lua: уровни зовут его из _sh-файлов,
-- а здесь он существовал только на клиенте и ронял загрузку уровня на сервере.

//

local start,getAnim
local wait = 0.5//pidorasi na 3vyki blaad

local black = Color(0,0,0,200)
local cframe1 = Color(255, 255, 255, 75)
local cframe2 = Color(0, 0, 0, 125)

function Level:StartWinnerVGUI(value)
    if IsValid(WinnerVGUI) then WinnerVGUI:Remove() end

    if not value then return end//lol типо
    
    start = RealTime()
    
    getAnim = function()
        local k = math.ease.InOutCirc(math.max(start + wait - RealTime(),0) / wait)

        return Lerp(k,1,0)
    end

    WinnerVGUI = oop.CreatePanel("v_panel"):ad(function(self,w,h)
        self:setSize(math.max(math.max(w * 0.3,500) * getAnim(),1),math.max(64,h * 0.075)):setPos(w / 2 - self:W() / 2,h * 0.1)
    end)

    local iconSize = WinnerVGUI:H()
    local corner = iconSize * 0.25

    WinnerVGUI:ad(function(self,w,h)
        self:setSize(self:W() + corner * 2,self:H() + corner * 2)
        self:setPos(w / 2 - self:W() / 2,h * 0.1)
    end)

    -- Resolve player & avatar information
    local targetPly = value.ply
    if not IsValid(targetPly) then
        if value.steamid64 and value.steamid64 ~= "" then
            targetPly = player.GetBySteamID64(tostring(value.steamid64))
        end
        if not IsValid(targetPly) and value.steamid and value.steamid ~= "" then
            targetPly = player.GetBySteamID(value.steamid)
        end
        if not IsValid(targetPly) and value.playerNick and value.playerNick ~= "" then
            for _, p in ipairs(player.GetAll()) do
                if p:Nick() == value.playerNick then
                    targetPly = p
                    break
                end
            end
        end
    end

    local targetSteamID64 = value.steamid64
    if (not targetSteamID64 or targetSteamID64 == "") and IsValid(targetPly) then
        targetSteamID64 = targetPly:SteamID64()
    end
    if (not targetSteamID64 or targetSteamID64 == "") and value.steamid and value.steamid ~= "" then
        targetSteamID64 = util.SteamIDTo64(value.steamid)
    end
    if (not targetSteamID64 or targetSteamID64 == "") and isstring(value.avatar) and string.match(value.avatar, "^7656119%d+$") then
        targetSteamID64 = value.avatar
    end

    local hasAvatar = IsValid(targetPly) or (targetSteamID64 ~= nil and targetSteamID64 ~= "") or (value.avatar ~= nil and value.avatar ~= false and value.avatar ~= "")
    if hasAvatar then
        value.avatar = true
    end

    local color = value.color

    function WinnerVGUI:Draw(w,h)
        local k = getAnim()

        surface.SetAlphaMultiplier(math.min(k * 7,1))

        surface.SetDrawColor(color.r,color.g,color.b,255 * (1 - k))

        DisableClipping(true)

        do//скобки внутрь
            local y = (h - h * 1.25) / 2
            local h = h * 1.25

            surface.SetDrawColor(color.r,color.g,color.b,25 * (1 - k))
            draw.GradientLeft(0,y,w / 10,h)
            draw.GradientRight(w - w / 10,y,w / 10,h)
        end

        do//раскрывающиеся
            local x = -w / 2
            local w = w * 2

            surface.SetDrawColor(color.r,color.g,color.b,255 * (1 - k))

            draw.GradientRight(x,0,w / 2,h)
            draw.GradientLeft(x + w / 2,0,w / 2,h)
        end

        DisableClipping(false)

        local x = value.avatar and (iconSize + corner * 2) or corner
        local y = corner
        h = h - corner * 2
        w = w - x

        -- Draw avatar box and frame on the left
        if hasAvatar then
            if IsValid(self.avatarImg) then
                self.avatarImg:SetAlpha(math.Clamp(k * 255, 0, 255))
                self.avatarImg:SetVisible(k > 0.05)
                self.avatarImg:SetPos(corner, corner)
                self.avatarImg:SetSize(iconSize, iconSize)
            end

            surface.SetDrawColor(color.r / 5, color.g / 5, color.b / 5, 255)
            surface.DrawRect(corner, corner, iconSize, iconSize)
            surface.SetDrawColor(color.r / 2, color.g / 2, color.b / 2, 255)
            draw.GradientRight(corner, corner, iconSize, iconSize)

            surface.SetDrawColor(cframe1)
            draw.GradientRight(corner, corner + 1, iconSize / 2, 1)
            draw.GradientLeft(corner + iconSize / 2, corner + 1, iconSize / 2, 1)

            surface.SetDrawColor(cframe2)
            draw.GradientRight(corner, corner + iconSize - 2, iconSize / 2, 1)
            draw.GradientLeft(corner + iconSize / 2, corner + iconSize - 2, iconSize / 2, 1)

            draw.Frame(corner, corner, iconSize, iconSize, cframe1, cframe2)
        end

        surface.SetDrawColor(color.r / 5,color.g / 5,color.b / 5,255)
        surface.DrawRect(x,y,w,h)
        surface.SetDrawColor(color.r / 2,color.g / 2,color.b / 2 ,255)
        draw.GradientRight(x,y,w,h)

        surface.SetDrawColor(cframe1)
        draw.GradientRight(x,y + 1,w / 2,1)
        draw.GradientLeft(x + w / 2,y + 1,w / 2,1)

        surface.SetDrawColor(cframe2)
        draw.GradientRight(x,y + h - 2,w / 2,1)
        draw.GradientLeft(x + w / 2,y + h - 2,w / 2,1)

        draw.Frame(x,y,w,h,cframe1,cframe2)

        draw.SimpleText(L(value.name or ""),"HS.18",x + 8,y + 6)

        local text = value.subtext

        if TypeID(text) == TYPE_TABLE then
            text = L(text[1],L(text[2] or ""))
        else
            text = L(text or "")
        end

        draw.SimpleText(text,"HS.12",x + 8,y + h - 6,nil,nil,TEXT_ALIGN_BOTTOM)

        local text = value.text

        if TypeID(text) == TYPE_TABLE then
            text = L(text[1],L(text[2] or ""))
        else
            text = L(text or "")
        end

        draw.SimpleText(text,"H.25",x + w / 2,y + h / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        self:PerformLayout()

        surface.SetAlphaMultiplier(1)
    end

    if hasAvatar then
        local avatarImg = vgui.Create("AvatarImage", WinnerVGUI)
        avatarImg:SetSize(iconSize, iconSize)
        avatarImg:SetPos(corner, corner)
        avatarImg:SetMouseInputEnabled(false)
        avatarImg:SetZPos(10)

        if IsValid(targetPly) then
            avatarImg:SetPlayer(targetPly, 128)
        elseif targetSteamID64 and targetSteamID64 ~= "" then
            avatarImg:SetSteamID64(targetSteamID64, 128)
        end

        avatarImg.PaintOver = function(pnl, pw, ph)
            surface.SetDrawColor(cframe1)
            draw.GradientRight(0, 1, pw / 2, 1)
            draw.GradientLeft(pw / 2, 1, pw / 2, 1)

            surface.SetDrawColor(cframe2)
            draw.GradientRight(0, ph - 2, pw / 2, 1)
            draw.GradientLeft(pw / 2, ph - 2, pw / 2, 1)

            draw.Frame(0, 0, pw, ph, cframe1, cframe2)
        end

        WinnerVGUI.avatarImg = avatarImg

        if value.avatarFrame and value.avatarFrame ~= "" and IS64BIT and isstring(value.avatar) and string.StartWith(value.avatar, "http") then
            local html = oop.CreatePanel("v_avatarlist", WinnerVGUI):ad(function(self, w, h)
                self:setSize(iconSize, iconSize)
                self:setPos(corner, corner)
            end)

            html:Setup(iconSize)
            html:SetMouseInputEnabled(false)
            html:SetZPos(20)

            html.OnReady = function()
                html:AddPanel("winner", value.name, value.avatar, value.avatarFrame, value.background, value.backgroundOpacity, value.backgroundY)
            end
        end
    end

    if value.sound then surface.PlaySound(value.sound) end

    timer.Simple(self.DelayStartRound,function()
        self:CloseWinnerVGUI()
    end)
end

function Level:CloseWinnerVGUI()
    start = RealTime()

    getAnim = function()
        local k = math.ease.InOutCirc(math.max(start + wait - RealTime(),0) / wait)

        k = Lerp(k,0,1)

        if k <= 0 then
            if IsValid(WinnerVGUI) then WinnerVGUI:Remove() end
        end

        return k
    end
end

/*local ply = player.GetAll()[1]
local color = math.random(1,2) == 1 and Color(255,0,0) or Color(0,255,0)

Level:StartWinnerVGUI({
    color = color,
    
    name = ply:Name(),
    avatar = ply:GetNWString("Avatar"),
    avatarFrame = ply:GetNWString("AvatarFrame"),
    text = "Winner!",
    sound = "homigrad/vgui/panorama/case_awarded_4_legendary_01.wav"
})*/
