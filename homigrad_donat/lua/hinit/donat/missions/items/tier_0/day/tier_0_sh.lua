--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_donat/lua/hinit/donat/missions/items/tier_0/day/tier_0_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad_donat\\lua\\hinit\\donat\\missions\\items\\tier_0\\day\\tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
//https://on.soundcloud.com/FyAC6QJvgDkgiPEd8

local Mission = MissionItem_Reg("day","base",true)
if not Mission then return INCLUDE_BREAK end

//

Mission.raryType = "uncommon"
Mission.ResetTime = 60 * 60 * 18
Mission.Category = "mission_category_1"

Mission.Config = {
    ended = {
        name = "donat_mission_day1",
        max = MissionLimits.day - 1,
        Think1 = function(self)
            local count = 0

            for id,mission in pairs(MissionList[self.owner]) do
                if mission.class != self.class then continue end
                if mission.data.canComplete then count = count + 1 end
            end

            self:SetProgress(count)
        end,
        items = MissionDayItems
    },
    {
        name = "donat_mission_day2",
        desc = "donat_mission_day2_desc",
        max = 3,
        PlayerKill = function(self,ply,dmgTab)
            if dmgTab.hitgroup != HITGROUP_HEAD and ply != dmgTab.att then return end
            self:AddProgress(1)
        end
    },
    {
        name = "donat_mission_day3",
        desc = "donat_mission_day3_desc",
        PlayerKill = function(self,ply,dmgTab)
            if ply != dmgTab.att or not IsValid(dmgTab.wep) or not dmgTab.wep.IsFireWeapon then return end
            self:WriteCanComplete()
        end
    },
    {
        name = "donat_mission_day4",
        desc = "donat_mission_day4_desc",
        max = 10,
        PlayerDeath = function(self,ply,dmgTab)
            self:AddProgress(1)
        end
    },
    {
        name = "donat_mission_day5",
        RoundEnd = function(self,winner)
            if roundActiveName == "level_tdm" and winner == self.ownerPly:Team() then self:WriteCanComplete() end
        end
    },
    {
        name = "donat_mission_day6",
        RoundEnd = function(self,winner)
            if roundActiveName == "level_homicide" and ((self.ownerPly.roleT and winner == 2) or (not self.ownerPly.roleT and winner == 1)) then
                self:WriteCanComplete()
            end
        end
    },
    {
        name = "donat_mission_day7",
        desc = "donat_mission_day7_desc",
        RoundEnd = function(self,winner)
            if roundActiveName == "level_homicide" and winner == 1 and self.ownerPly.roleT then self:WriteCanComplete() end
        end
    },
    {
        name = "donat_mission_day8",
        desc = "donat_mission_day8_desc",
        PlayerEat = function(self,wep)
            if wep.Value == 0 then self:WriteCanComplete() end
        end
    },
    {
        name = "donat_mission_day9",
        desc = "donat_mission_day9_desc",
        max = 3,
        PlayerKill = function(self,ply,dmgTab)
            local wep = dmgTab.wep
            if not IsValid(wep) or not wep.IsMelee then return end
            self:AddProgress(1)
        end
    },
    {
        name = "donat_mission_day10",
        desc = "donat_mission_day10_desc",
        PlayerKill = function(self,ply,dmgTab)
            local wep = dmgTab.wep
            if ply != dmgTab.att and dmgTab.isExplosive and wep == "explosive_hidebomb" then
                self:WriteCanComplete()
            end
        end
    },
    {
        name = "donat_mission_day11",
        desc = "donat_mission_day11_desc",
        PlayerKill = function(self,ply,dmgTab)
            if self.max and ply != dmgTab.att and dmgTab.reasons.poison then
                self:AddProgress(1)
            end
        end,
        RoundStart = function(self)
            self:SetMax(self.ownerPly.roleT and 1 or false)
        end
    },
    {
        name = "donat_mission_day12",
        desc = "donat_mission_day12_desc",
        PlayerHeal = function(self,target,wep)
            if target == self.ownerPly then return end

            self:WriteCanComplete()
        end
    }
}

local missing = {
    name = "Missing",
    desc = "this type self doesn't exists"
}

function Mission:GetInfo()
    return self.Config[self.data.missionID] or missing
end

function Mission:GetPrintName() return self:GetInfo().name end
function Mission:GetDesc() return self:GetInfo().desc or "" end
function Mission:GetRaryType() return self.raryType end
function Mission:GetItems() return self.items or self:GetInfo().items or MissionCategories[self.Category].items end

function Mission:GetProgress() return self.data.progress or self.progress or 0 end
function Mission:GetMax()
    local value = self.data.max
    if value != nil then return value end

    value = self.max
    if value != nil then return value end

    value = self:GetInfo().max
    if value != nil then return value end
end

local blacklist = {
    ["level_jailbreak"] = true,
    ["level_event"] = true,
    ["level_construct"] = true
}

function Mission:CanWork()
    if ActiveLevel.DontMission or blacklist[roundActiveName] then return false end

    return true
end

if SERVER then return end

net.Receive("mission_sync_key",function()
    local id,info = tonumber(net.ReadString()),net.ReadTable()
    MissionList[LocalPlayer():SteamID64()][id][info[1]] = info[2]
end)

function Mission:Collect()
    self:StartUserCommand()
    net.SendToServer()
end

local delaySoundHover = 0

local colorGray = Color(165,165,165,165)

function Mission:DrawIcon(w,h,panel,butt)
    panel.zoom = LerpFTLess(0.8,panel.zoom or 0,panel:IsHovered() and 1 or 0,0.01)

    local raryType = self:GetRaryType()
    local raryData = DonatItemsRaryData[raryType]
    if raryType != "common" then
        surface.SetDrawColor(0,0,0,200)
        surface.DrawRect(0,0,w,h)
    end

    local color = raryData[1]
    surface.SetDrawColor(color.r / 2.5,color.g / 2.5,color.b / 2.5,125)
    surface.DrawRect(0,0,w,h)

    surface.SetDrawColor(color.r / 2.5,color.g / 2.5,color.b / 2.5,raryType != "common" and 190 or 100)
    surface.SetBG(raryData[4])
    draw.BG2(2,2,w - 4,h - 4)

    local size = w / 1.2
    if raryType != "common" then
        size = size * (1 - math.cos(RealTime()) * 0.25)
    end
    surface.SetDrawColor(color.r,color.g,color.b,64)
    draw.GradientLeft(0,0,size,h)

    if not self.data.complete and self.data.canComplete then
        surface.SetDrawColor(255,255,255,64)
        draw.GradientLeft(0,0,w/12,h)
    end

    self:DrawObject(w,h,panel)

    local H = (fontText == "H.12" and 20 or 28)
    surface.SetDrawColor(color.r,color.g,color.b,255)
    surface.DrawRect(0,0,w,H)

    draw.SimpleText(L(self:GetPrintName()),fontText or "H.18",H/2,H/2,raryData[2],nil,TEXT_ALIGN_CENTER)
    markup.Parse("<font=HS.18>" .. L(self:GetDesc()),w):Draw(H/2,H + H/4,w,h)

    draw.SimpleText("#" .. self.id,"HS.12",w - 8,h - 8,colorGray,TEXT_ALIGN_RIGHT,TEXT_ALIGN_BOTTOM)

    draw.SimpleText(L("donat_ui_less_time2",DonatGetTimeLess(self.data.createTime + self.ResetTime - os.time())),"H.18",w - 16,H/2,raryData[2],TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)

    local max = self:GetMax()

    local height = 12
    local weight = w * 0.35
    local y = butt.y + butt:H()/2 - height/2
    local x = butt.x + butt:W() + height * 2

    if max then
        surface.SetDrawColor(0,0,0,100)

        surface.DrawRect(x,y,weight,height)
        surface.SetDrawColor(0,0,0,125)
        draw.GradientLeft(x,y,weight,height)

        local progress = self:GetProgress()
        local k = math.min(progress / max,1)

        surface.SetDrawColor(255,255,255,255)
        surface.DrawRect(x,y,weight * k,height)
        
        draw.SimpleText(progress .. " / " .. max,"HS.18",x + weight + 16,y + height/2 - 1,nil,nil,TEXT_ALIGN_CENTER)
    elseif max == false then
        surface.SetDrawColor(255,0,0,255)
        local y = butt.y - height/2
        local height = h - y - 1
        draw.GradientLeft(1,y,weight,height)

        draw.SimpleText("НЕЛЬЗЯ ВЫПОЛНИТЬ","HS.18",x,y + height/2 - 1,nil,nil,TEXT_ALIGN_CENTER)
    end

    draw.Frame(0,0,w,H,cframe1,cframe2)
    draw.Frame(0,0,w,h,cframe1,cframe2)

    if panel:IsHovered() then
        if not panel.hover then
            panel.hover = true

            if delaySoundHover < RealTime() then
                delaySoundHover = RealTime() + 0.025

                self:EmitSoundHover()
            end
        end
    else
        panel.hover = nil
    end
end

function Mission:DrawObject(w,h,panel)

end

function Mission:EmitSoundHover()
    if self.data.complete then return end

    local snds = DonatItemsRaryData[self:GetRaryType()][4]

    LocalPlayer():EmitSound(TypeID(snds) == TYPE_TABLE and snds[math.random(1,#snds)] or snds,45,math.random(243,255),0.05)
end
