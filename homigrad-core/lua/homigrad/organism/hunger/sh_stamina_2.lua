--[[
Server Name: GOMIGRAD RU 1 JailBreak
Server IP:   194.147.90.16:24223
File Path:   addons/gomigrad-core/lua/homigrad/organism/hunger/sh_stamina.lua
		 __        __              __             ____     _                ____                __             __         
   _____/ /_____  / /__  ____     / /_  __  __   / __/____(_)__  ____  ____/ / /_  __     _____/ /____  ____ _/ /__  _____
  / ___/ __/ __ \/ / _ \/ __ \   / __ \/ / / /  / /_/ ___/ / _ \/ __ \/ __  / / / / /    / ___/ __/ _ \/ __ `/ / _ \/ ___/
 (__  ) /_/ /_/ / /  __/ / / /  / /_/ / /_/ /  / __/ /  / /  __/ / / / /_/ / / /_/ /    (__  ) /_/  __/ /_/ / /  __/ /    
/____/\__/\____/_/\___/_/ /_/  /_.___/\__, /  /_/ /_/  /_/\___/_/ /_/\__,_/_/\__, /____/____/\__/\___/\__,_/_/\___/_/     
                                     /____/                                 /____/_____/                                  
--]]

local value,gg

if CLIENT then
	value = 1

	net.Receive("info_staminamul",function()
		value = net.ReadFloat()
	end)
end

local jmod
if CLIENT then
	hook.Add("Move","homigrad",function(ply,mv)
		gg(ply,mv,value)
	end)
else
	hook.Add("Move","homigrad",function(ply,mv)
		gg(ply,mv,(ply.staminamul or 1))
	end)
end


gg = function(ply,mv,staminaValue)
    local baseSpeed = mv:GetMaxSpeed() * staminaValue
    
    local forwardSpeed = mv:GetForwardSpeed()
    if ply:IsSprinting() and forwardSpeed < 0 then
        local backwardsSprintMultiplier = 2.3
        baseSpeed = baseSpeed * backwardsSprintMultiplier
    end

    ply:SetRunSpeed(Lerp((ply:IsSprinting() and mv:GetForwardSpeed() > 1) and 0.05 or 1,ply:GetRunSpeed(),(ply:IsSprinting() and mv:GetForwardSpeed() > 1) and 750 or ply:GetWalkSpeed()))

    mv:SetMaxSpeed(baseSpeed)
    mv:SetMaxClientSpeed(baseSpeed)

    if ply.IsProne and ply:IsProne() then return end

    local armorValue = ply.EZarmor
    armorValue = armorValue and ply.EZarmor.speedfrac

    if armorValue and armorValue ~= 1 then
        armorValue = mv:GetMaxSpeed() * math.max(armorValue,0.75)
        mv:SetMaxSpeed(armorValue)
        mv:SetMaxClientSpeed(armorValue)
    end
end

hook.Remove("Move","JMOD_ARMOR_MOVE")