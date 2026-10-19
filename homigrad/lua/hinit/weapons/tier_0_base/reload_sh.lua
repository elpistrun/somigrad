--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/weapons/tier_0_base/reload_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hinit/weapons/tier_0_base/tier_0_sh.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad\\lua\\hinit\\weapons\\tier_0_base\\reload_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Get("hg_wep")
if not SWEP then return end

SWEP.ReloadTime = 2

SWEP.Reload1 = "weapons/ak47/handling/ak47_magout.wav"
SWEP.Reload2 = "weapons/ak47/handling/ak47_magin.wav"
SWEP.Reload3 = "weapons/ak47/handling/ak47_boltback.wav"
SWEP.Reload4 = "weapons/ak47/handling/ak47_boltrelease.wav"

SWEP.ReloadMatrix = {
	[0] = function(self)
		local owner = self:GetOwner()

		local anim = owner:IsFlagSet(FL_ANIMDUCKING) and ACT_MP_RELOAD_CROUCH or ACT_MP_RELOAD_STAND

		if SERVER then
			if owner:IsNPC() then
				owner:RestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD,anim,true)
			else
				net.Start("wep reload gesture")//отправляем анимку
				net.WriteEntity(owner)
				net.WriteFloat(GESTURE_SLOT_ATTACK_AND_RELOAD)
				net.WriteFloat(anim)
				net.SendPVS(owner:GetPos())

				owner:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD,anim,true)
			end
		end
	end,
	[0.1] = function(self)//убираем магаз
		if CLIENT then
			if self.ClipBone then
				local gun = self:GetGun()

				-- Same trap as the R8 hammer: LookupBone answers nil for a bone the model does
				-- not have (a magazine bone that differs from the ARCCW Go convention), and
				-- ManipulateBoneScale(nil, ...) throws "number expected, got nil".
				local clip = gun:LookupBone(self.ClipBone)

				if clip then gun:ManipulateBoneScale(clip,Vector(0.01,0.01,0.01)) end
			end
		else
			sound.Emit(self:EntIndex(),self.Reload1,75,0.75)
		end
	end,
	[0.4] = function(self)//ставим магаз
		if CLIENT then
			if self.ClipBone then
				local gun = self:GetGun()
				local clip = gun:LookupBone(self.ClipBone)

				if clip then gun:ManipulateBoneScale(clip,Vector(1,1,1)) end
			end
		else
			sound.Emit(self:EntIndex(),self.Reload2,75,0.75)
		end
	end,
	[0.6] = function(self)//отводим затвор назад
		if self:GetNWInt("Chamber") == 0 then
			if SERVER then
				sound.Emit(self:EntIndex(),self.Reload3,75,0.75)
			else
				self:SetClipPos(1)
			end
		else
			self:SetNWFloat("GESTURE_RELOAD",CurTime() + 0.5)
			self:ReloadEnd()
			self.fightDelay = CurTime() + 0.35
		end
	end,
	[0.8] = function(self)//отводим затвор вперёд
		if SERVER then
			if self.Reload4 then sound.Emit(self:EntIndex(),self.Reload4,75,0.75) end
			self:SetClipPos(0)
			self.fightDelay = CurTime() + 0.1
		end
	end
}

function SWEP:DoAnimationEvent() return false end

SWEP:Event_Add("Think","Kill Reload Anim",function(self,owner,ft,time)//сбрасывает анимацию перезарядки
	if not self:IsLocal() or owner:IsNPC() then return end

	local anim_pos = self:GetNWFloat("GESTURE_RELOAD",0) - time

	if anim_pos > 0 then owner:AnimSetGestureWeight(GESTURE_SLOT_ATTACK_AND_RELOAD,anim_pos,true) end
end)

if SERVER then
	util.AddNetworkString("wep reload gesture")
else
	net.Receive("wep reload gesture",function()
		local owner = net.ReadEntity()
		if not IsValid(owner) then return end
		
		owner:AnimRestartGesture(net.ReadFloat(),net.ReadFloat(),true)
	end)
end

SWEP.reloadAnim = 0
SWEP.reloadAnimSet = 0
SWEP.reloadAnimDelay = 0

function SWEP:ReloadFunc()
	local clip,maxClip = self:Clip1(),self:GetMaxClip1()
	local ammoType = self:GetPrimaryAmmoType()
	local owner = self:GetOwner()
	local ammo = (owner:IsNPC() and maxClip) or owner:GetAmmoCount(ammoType)

	self:SetClip1(math.min(clip + ammo,maxClip))

	if not owner:IsNPC() then
		owner:SetAmmo(ammo - (self:Clip1() - clip),ammoType)
	end
end

function SWEP:ReloadSet(reloadFunc)
	if self.HoldTypeReload then self:SetStandType(self.HoldTypeReload) self:SetupStandType() end

	self:GetOwner():SetAnimation(PLAYER_RELOAD)

	self.reloadedStart = CurTime()
	self.reloadedDelay = self.reloadedStart + self.ReloadTime
	self.reloadedBlad = -1

	if SERVER then
		self:SetNWFloat("ReloadStart",self.reloadedStart)
		self:SetNWBool("Reload",true)

		self.dwr_reverbDisable = true

		self.reloadFunc = reloadFunc//вызывется при завершении перезарядки
	end
end

function SWEP:ReloadCan()
	return self:CanFight() and not self.reloadedDelay and (self.attackDelay or 0) < CurTime()
end

function SWEP:Reload()
	local owner = self:GetOwner()

	if self.reloadAnimSet == 1 then//для удержания затвора на дробовике
		self.reloadAnimDelay = CurTime() + 0.1
	end
	
	if owner:IsNPC() then
		if self:ReloadCan() then self:ReloadStart() return end

		return
	end

	if self:Clip1() > 0 then
		if not self.ChamberAuto then
			if owner:KeyDown(IN_WALK) then
				
			else
				if self:ReloadCan() and self:InsertChamber() then
					if self.Reload3 then self:SoundEmit(self.Reload3) end
			
					self:SetClipPos(1)
					self.reloadAnimSet = 1
					self.reloadAnimDelay = CurTime() + 0.1

					self.holdPieMenu = nil
				end
			end
		end
	end
end

function SWEP:ReloadStart()
	local owner = self:GetOwner()

	local clip,maxClip = self:Clip1(),self:GetMaxClip1()
	local ammo = (owner:IsNPC() and maxClip) or owner:GetAmmoCount(self:GetPrimaryAmmoType())

	if clip >= maxClip or ammo == 0 then return end

	self:ReloadSet(self.ReloadFunc)
end

function SWEP:ReloadEnd()
	local func = self.ReloadMatrix[1]
	if func then func(self) end
	
	if self.HoldTypeReload then self:SetStandType(self.HoldType) self:SetupStandType() end

	if SERVER then
		local func = self.reloadFunc
		self.reloadFunc = nil

		if func then func(self) end
	end

	self:SetNWBool("Reload",false)

	self.reloadedDelay = nil
	self.reloadedStart = nil

	if self.ChamberAuto then self:InsertChamber(true) end
end

SWEP:Event_Add("Think","Reload",function(self,owner,ft,time)
	if not self:IsLocal() then return end

	if owner:IsNPC() then
		local name = owner:GetSequenceName(owner:GetSequence())

		if name == "reload_low" then self:Reload() end//костыли
	end

	if self.reloadAnimSet == 1 and self.reloadAnimDelay < time then
		if self.Reload4 then self:SoundEmit(self.Reload4) end

		self:SetClipPos(0)

		self.reloadAnimSet = 0
	end

	self.reloadAnim = LerpFT(self.reloadAnimSet == 1 and 0.5 or 0.95,self.reloadAnim,self.reloadAnimSet)
	self:SetNWFloat("ReloadAnim",self.reloadAnim)
end)

SWEP:Event_Add("Can Primary Attack","ReloadAnim",function(self)
	if self.reloadAnimSet > 0.05 or self:GetNWFloat("ReloadAnim",0) > 0.05 then return false end
end)

SWEP:Event_Add("Think","Reload Magazune",function(self,owner,ft,time)
	if not self:IsLocal() then return end

	local start = self.reloadedStart
	if not start then return end

	local gun = self:GetGun()

	local anim_pos = time - start
	local mul = self.ReloadTime
	local owner = self:GetOwner()

	for t,func in pairs(self.ReloadMatrix) do
		if anim_pos >= t * mul and self.reloadedBlad < t then
			self.reloadedBlad = t

			func(self)
		end
	end

	if self.HoldTypeReload then self:SetStandType(self.HoldTypeReload) self:SetupStandType() end

	if self.reloadedDelay and self.reloadedDelay < time then
		self:ReloadEnd()
    end
end,1)

SWEP.reloadAnimAng = Angle()

if CLIENT then
	SWEP:Event_Add("Pre CalcView","Reload",function(self,owner)
		owner:AddBoneAng("rhand",-self.reloadAnimAng)
		owner:SetupBones()
		self:SetupGun()
	end)
	
	SWEP:Event_Add("Post CalcView","Reload",function(self,owner)
		owner:AddBoneAng("rhand",self.reloadAnimAng)
		owner:SetupBones()
		self:SetupGun()
	end)
end

if SERVER then
	util.AddNetworkString("weapon reload")

	net.Receive("weapon reload",function(len,ply)
		local wep = ply:GetActiveWeapon()
		if not IsValid(wep) or not wep.ReloadCan or not wep:ReloadCan() then return end

		wep:ReloadStart()
	end)
end

local abs = math.abs

SWEP:Event_Add("Think","Reload Menu",function(self,owner,ft,time)
	if not self:IsLocal() then return end

	if CLIENT then
		if input.IsKeyDown(KEY_R) then
			if not self.reloadedDelay and not PieMenu:IsOpen() and self.reloadAnimDelay < CurTime() then
				self.AmmoChek = 3

				if not self.holdPieMenu then self.holdPieMenu = time + 0.2 end

				if self.holdPieMenu <= time then
					self.holdPieMenu = nil
					
					PieMenu:Init()

					local option = PieMenu:CreateOption()
					option.title = "Разрядить"
					option.footer = "Добавляет патроны в инвентарь"
					option.icon = Material("ez_resource_icons/ammo.png")
					option.callback = function()
						if IsValid(self) then
							RunConsoleCommand("hg_wep_unload",tostring(self:EntIndex()))
						end
					end

					option:SetCondition(function() return IsValid(self) and self:Clip1() > 0 end)

					local option = PieMenu:CreateOption()

					option.title = "Выкинуть оружие"
					option.icon = Material("icon16/arrow_redo.png")
					option.callback = function()
						if IsValid(self) then
							RunConsoleCommand("hg_wep_drop",tostring(self:EntIndex()))
						end
					end
					option:SetCondition(function() return IsValid(self) and self:GetOwner() == LocalPlayer() end)

					PieMenu:Open()
				end
			end
		else
			if PieMenu:IsOpen() then
				PieMenu:Close()
			else
				if self.holdPieMenu then
					if self:ReloadCan() then//ну х3 мож чтоб серв присылал надо х3х3х3х3х
						net.Start("weapon reload")
						net.SendToServer()
						
						self:ReloadStart()
					end
				end
			end

			self.holdPieMenu = nil
		end
	end
end,-1)

if CLIENT then
	SWEP:Event_Add("Off","Reload",function() PieMenu:Close() end)
end

local blacklist = {
	["Weapon_357.RemoveLoader"] = true,
	["Weapon_357.OpenLoader"] = true,
	["Weapon_357.ReplaceLoader"] = true,
}

hook.Add("EntityEmitSound","RemoveShit",function(data)
	if blacklist[data.OriginalSoundName] then return false end
end)

SWEP:Event_Add("Holster","ReloadEnd",function(self,owner)
	self.reloadedDelay = nil
	self.reloadedStart = nil
	self:SetNWBool("Reload",false)

	if not owner:IsNPC() then owner:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD,0,true) end
end)

if SERVER then
	local reloadFunc = function(self)
		local ammoid = self:GetPrimaryAmmoType()
		
		local owner = self:GetOwner()
		owner:SetAmmo(owner:GetAmmoCount(ammoid) + self:Clip1(),ammoid)

		self:SetClip1(0)
	end

	util.AddNetworkString("wep unload")

    concommand.Add("hg_wep_unload",function(ply,cmd,args)
        local wep = Entity(tonumber(args[1] or 0))

        if ply:GetActiveWeapon() ~= wep then return end--BAAAAAAAAAAAAAN!!!11111

        local ammo = wep:Clip1()
		if ammo <= 0 then return end

		wep:SetNWInt("Chamber",0)
		wep:ReloadSet(reloadFunc)

		net.Start("wep unload")
		net.Send(ply)
    end)

    local function dropWeaponPlayer(ply,wep)
        if not IsValid(ply) or not ply:Alive() then return end
        if (ply.nextDropWep or 0) > CurTime() then return end
        ply.nextDropWep = CurTime() + 0.4

        wep = (IsValid(wep) and wep:GetOwner() == ply) and wep or ply:GetActiveWeapon()
        if not IsValid(wep) then return end

        local class = wep:GetClass()
        if class == "weapon_hands" or class == "weapon_fists" or class == "weapon_zombie" then return end

        if ply.DropWep then
            ply:DropWep(wep,nil,ply:EyeAngles():Forward() * 220 + Vector(0,0,30))
        else
            ply:DropWeapon(wep)
            local phys = wep:GetPhysicsObject()
            if IsValid(phys) then
                phys:Wake()
                phys:SetVelocity(ply:EyeAngles():Forward() * 220 + Vector(0,0,30))
                phys:AddAngleVelocity(VectorRand() * 60)
            end
        end

        timer.Simple(0,function()
            if IsValid(ply) and ply:Alive() and ply:HasWeapon("weapon_hands") then
                ply:SelectWeapon("weapon_hands")
            end
        end)
    end

    local function resolveWeaponArg(ply, arg1, arg2)
        local wep = tonumber(arg1) and Entity(tonumber(arg1))
        if not IsValid(wep) and arg2 and isstring(arg2) and arg2 ~= "" then
            wep = ply:GetWeapon(arg2)
        end
        if not IsValid(wep) and arg1 and isstring(arg1) and arg1 ~= "" then
            wep = ply:GetWeapon(arg1)
        end
        return wep
    end

    concommand.Add("hg_wep_drop",function(ply,cmd,args)
        local wep = resolveWeaponArg(ply, args[1], args[2])
        dropWeaponPlayer(ply,wep)
    end)

    concommand.Add("drop",function(ply,cmd,args)
        local wep = resolveWeaponArg(ply, args[1], args[2])
        dropWeaponPlayer(ply,wep)
    end)
else
	net.Receive("wep unload",function()
		local wep = LocalPlayer():GetActiveWeapon()
		wep:SetNWInt("Chamber",0)
		wep:ReloadSet()
	end)
end
