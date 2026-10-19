--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/radio/weapon_event_speaker/tier_0_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\radio\\weapon_event_speaker\\tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Reg("weapon_event_speaker","weapon_transmitter",false)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName 				= "Event Speaker"
SWEP.Instructions			= "Общение со всеми"
SWEP.Category 				= L("weapon_category_item")

if SERVER then
    function SWEP:Relaod()
    end

    SWEP:Event_Add("Step","Main",function(self,owner)
        local hold = self:PlayerHoldTalk()
        local lerp = LerpFT(0.5,self:GetNWFloat("PlayerAnim",0),(self.modeMenu or hold) and 1 or 0)
        self:SetNWFloat("PlayerAnim",lerp)

        self:SetNWBool("EnableSound",hold)
    end)

    event.Add("Player Can Lisen","Radio Event Speaker",function(output,input,isChat)
        local wep = output:GetWeapon("weapon_event_speaker")
        if not IsValid(wep) then return end

        if wep:PlayerHoldTalk() then return true,false end
    end)

    return
end

surface.CreateFont("DigitalCyrilic_35",{
    font = "DigitalCyrillic1",
    size = 35,
})

local black = Color(0,0,0,255)
local gray = Color(0,0,0,125)

function SWEP:DrawLED(w,h)
    surface.SetDrawColor(0,255,151)
    surface.DrawRect(0,0,w,h)
    
    draw.SimpleText("EVENT SPEAKER","DigitalCyrilic_35",w/2,h/2,self:GetNWBool("EnableSound") and black or gray,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
end
