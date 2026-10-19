--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hinit/weapons/tier_0_base/cl_camera.lua <
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

-- "addons\\homigrad\\lua\\hinit\\weapons\\tier_0_base\\cl_camera.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local SWEP = oop.Get("hg_wep")
if not SWEP then return end

function SWEP:GetCameraTransform()
	if IsValid(self:GetNWEntity("Fake")) then return end

	local pos,ang = self:GetMuzzlePos()
    if not pos then return end
    
	return pos:Add(self.CameraPos:Clone():Rotate(ang)),ang
end

ScopeLerp = ScopeLerp or 0
FightLerp = FightLerp or 0

local angZero = Angle()

local oldAng = Angle()

local hg_camera_smooth = GetConVar("hg_camera_smooth")
local immersive3 = 0

local oldScope = 0

local function canFight(self)
	local owner = self:GetOwner()

	if owner:GetNWBool("fake") or self:IsHolstered() then return false end
	if owner:IsSprinting() or self.isClose then return false end
	
	return true
end

function SWEP:SetupGunPost(gun) end

SWEP.applyAngleHead = Angle()

SWEP:Event_Add("Pre CalcView","HandUp",function(self,owner)//Убираем анимацию выстрела (для норм позиции камеры), она прописана в файле анимации
    owner:AddBoneAng("rhand",-self.applyAngleHead)
    owner:SetupBones()
    self:SetupGun()
end)

SWEP:Event_Add("Post CalcView","HandUp",function(self,owner)//Возвращаем обратно анимацию выстрела
    owner:AddBoneAng("rhand",self.applyAngleHead)
    owner:SetupBones()
    self:SetupGun()
end)

SWEP.CImersiveSetL = 0.2

local addFovRecoil = 0

event.Add("PreCalcView","ScopeZero",function(ply,view)
    if ScopeHold then
        ScopeHold = nil 
    else
        ScopeLerp = LerpFT(0.5,ScopeLerp,0)
    end

    if FightHold then
        FightHold = nil
    else
        FightLerp = LerpFT(0.15,FightLerp,0)
    end
end,-10)

event.Add("PreCalcView","Weapons",function(ply,view)
    if not ply:Alive() then return end

    local wep = ply:GetActiveWeapon()
    wep = IsValid(wep) and wep

    local vec,ang = view.vec,view.ang
    local vecWep,angWep = vec:Clone(),ang:Clone()
    local isPistol

	if wep and wep.GetCameraTransform then
        wep:Event_Call("Pre CalcView",ply)

        //wep:DrawFromPlayer(ply)//Сетапим кости игрока, вызывается PreCalcView до вызова рендера сцены
        //теперь не нужно потому-что перед рендером кости игрока уже вычеслены и готовы
        
        vecWep,angWep = wep:GetCameraTransform()
        if not vecWep then return end--lol?

        wep:Event_Call("Post CalcView",ply)
	else
        return
    end

    ScopeHold = true
    
    if canFight(wep) then
        FightHold = 1
        FightLerp = LerpFT(0.15,FightLerp,1)
    end//WTF

    view.mulMovement = 1 - ScopeLerp
    
    local scope = wep:IsScope()

    local recoil = wep.recoil
    ScopeLerp = LerpFT(scope and wep.ScopeLerp or wep.ScopeLerpOut or wep.ScopeLerp,ScopeLerp,scope and 1 or 0)

    CameraLandSet:LerpFT(ScopeLerp,Vector())
    CameraLand:LerpFT(ScopeLerp,Vector())

    local CImersiveSetL = wep.CImersiveSetL
    if CImersiveSetL then
        CImersiveSetL = Lerp(ScopeLerp,CImersiveSetL,wep.CImersiveSetL_Scope or CImersiveSetL)
        view.imersiveSetL = Lerp(FightLerp,view.imersiveSetL,CImersiveSetL)
    end

    local CImersiveL = wep.CImersiveL
    if CImersiveL then view.imersiveL = Lerp(ScopeLerp,CImersiveL,wep.CImersiveL_Scope or CImersiveL) end

    local diff = oldAng - ang
    diff:Normalize()

    oldAng = ang:Clone()

    if angWep then
        if true then
            immersive3 = immersive3 - diff[2] / 2

            local vel = ply:GetVelocity()
            local diff = (vel:Angle() - ang)
            diff:Normalize()
            diff:Mul(math.Clamp(vel:Length(),0,1))

            immersive3 = immersive3 + CalcSideK(diff[2])
            immersive3 = math.Clamp(LerpFT(0.01,immersive3,0),-5,5)

            angWep[3] = angWep[3] + immersive3
        end

        if ScopeLerp > oldScope  then
            angWep[1] = angWep[1] - 5 * (1 - math.Clamp(ScopeLerp * 2,0,1))
            angWep[2] = angWep[2] - 5 * (1 - ScopeLerp)
            angWep[3] = angWep[3] + 5 * (1 - ScopeLerp)
        end
    end
    
    oldScope = ScopeLerp

    vec:Lerp(ScopeLerp,vecWep or vec)
    ang:Lerp(ScopeLerp,angWep or ang)

    if not BodyCamMode then
        addFovRecoil = math.min(addFovRecoil + recoil / 4,1)

        view.fov = Lerp(ScopeLerp,view.fov,FOV - 25)
	    view.fov = view.fov - (recoil + addFovRecoil) * ScopeLerp
        
        addFovRecoil = math.max(addFovRecoil - 4 * FrameTime(),0)
    end
    
    ang[3] = ang[3] + recoil * wep.randAbs * wep.CR3 * 1.25

    view.znear = Lerp(ScopeLerp,1,0.5)

    local posRecoil = Vector(Lerp(ScopeLerp,wep.CR,wep.CR_Scope) * recoil,0,0):Rotate((angWep or ang))
    vec:Add(posRecoil)

    ang:Lerp(FightLerp - ScopeLerp,ang + wep.CFightAng)
    vec:Lerp(FightLerp - ScopeLerp,vec + wep.CFightVec:Clone():Rotate(ang))

    if wep.ChangeCalcView then wep:ChangeCalcView(ply,view) end
end)


