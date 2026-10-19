--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/mlg_weapons_1214787279/lua/weapons/weapon_katana/shared.lua <
    > Callstack:  <
]]

-- "addons\\mlg_weapons_1214787279\\lua\\weapons\\weapon_katana\\shared.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
//Katana...
SWEP.base = "weapon_base"
SWEP.Category = "MLG"
SWEP.Author = "Hobo_Gus"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "M1 - slash! M2 - dash! E + M2 - Steel Circle! Hold E - bullet block! R - Holster!"
SWEP.PrintName = "Katana"
SWEP.Slot = 0
SWEP.SlotPos = 0
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = false;
SWEP.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"
SWEP.ShowWorldModel = false
SWEP.ViewModelFOV = 55
SWEP.UseHands = true
SWEP.HoldType = "knife"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Weight = 0
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Recoil = 1
SWEP.Primary.Spread = 0.1
SWEP.Primary.Delay = 0.8
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Sound = "weapons/irifle/irifle_fire2.wav";
SWEP.Primary.TakeAmmo = 1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Delay = 0.5
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"
SWEP.ReloadDelay = 0.8

SWEP.Dash = 0
SWEP.IronCircle = 0
SWEP.IronTime = 0
SWEP.Normal = 1
SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_R_Clavicle"] = { scale = Vector(1, 1, 1), pos = Vector(-2.497, 0, -2), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_R_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-23.632, -23.685, 44.812) },
	["v_weapon.Knife_Handle"] = { scale = Vector(0.09, 0.09, 0.09), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

local blockbullets = 0

if ( CLIENT ) then

end
function SWEP:HolsterThink()
if self.Weapon:GetNetworkedBool( "Holster", true ) then
self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
self.Weapon:SetNextPrimaryFire(CurTime() + 0.3)
self.Weapon:SetNextSecondaryFire(CurTime() + 0.3)
self:SetWeaponHoldType( "normal" )	
self.WElements["katana+"].size = Vector(1, 1, 1)
self.WElements["katana"].size = Vector(0, 0, 0)
else
self.WElements["katana+"].size = Vector(0, 0, 0)
self.WElements["katana"].size = Vector(1, 1, 1)
end
end

function SWEP:Think()	

self:HolsterThink()
self:IronThink()
if self.Owner:KeyDown(IN_USE) then
self.Weapon:SetNetworkedBool( "Holster", false )
blockbullets = 1
self.Weapon:SetNetworkedInt( "Some1", 10 )
//self.Weapon:SetNetworkedBool( "Ironsights", true )
else//if self.IronCircle == 0 and self.Dash == 0 then
//self.Weapon:SetNetworkedBool( "Ironsights", false )
blockbullets = 0
end

if self.IronCircle >= 1 then
self.Weapon:SetNetworkedBool( "Holster", false )
self.IronCircle = self.IronCircle - 1
self.Weapon:SetNetworkedInt( "Some1", 10 )
self.Weapon:SetHoldType("knife")
self.Owner:SetAnimation( PLAYER_ATTACK1 )
		local eyeangle 	= self.Owner:EyeAngles()
		eyeangle.yaw 	= eyeangle.yaw - 13
		eyeangle.pitch 	= 10
		self.Owner:SetEyeAngles(eyeangle)
		local trace = self.Owner:GetEyeTrace()
		    local dmginfo = DamageInfo()
            dmginfo:SetDamageForce( self.Owner:GetAimVector() * 100)
            dmginfo:SetDamage(550)
            dmginfo:SetAttacker(self.Owner)
            dmginfo:SetInflictor(self)
            dmginfo:SetDamageType(DMG_ALWAYSGIB)
         //local trace = self.Owner:GetEyeTrace()
         if trace.HitPos:Distance(self.Owner:GetShootPos()) <= 90 then
		   if SERVER then
			   trace.Entity:TakeDamageInfo(dmginfo)
		                end
	                if ((trace.Entity:IsNPC() and trace.MatType == MAT_FLESH )) or (trace.Entity:IsPlayer() and trace.MatType == MAT_FLESH) then
		            local fx 		= EffectData()
					fx:SetOrigin(trace.HitPos)
					fx:SetNormal(VectorRand(), VectorRand(), VectorRand())
					util.Effect( "hg_katana_blood_hit" ,fx)	
					local randomsounds = {
   					"katana/katana2.wav",
    				"katana/katana.wav"
    					}
			local random = math.random(1, #randomsounds)
  			self.Owner:EmitSound(randomsounds[random])
	else
	//if (math.random(0,2) == 0) 
		util.Decal( "ManhackCut",( trace.HitPos - trace.HitNormal ),( trace.HitPos + trace.HitNormal ) )
	if trace.MatType == MAT_METAL then
	local effectdata = EffectData()
		effectdata:SetOrigin(trace.HitPos)
		effectdata:SetNormal(trace.HitNormal)
		effectdata:SetScale(10)
		util.Effect("MetalSpark", effectdata)
	end
	//end
		end
end
	//self.IronSightsPos = Vector(-10.561, 0.201, 4.26)
	//self.IronSightsAng = Vector(-18.996, -40.102, 12.663)
end
//end
//CAMERA EFFECT DELETED!

if self.Dash > 0 then
self.Weapon:SetNetworkedBool( "Holster", false )
local trace = self.Owner:GetEyeTrace()
self.Dash = self.Dash - 1
		    local dmginfo = DamageInfo()
            dmginfo:SetDamageForce( self.Owner:GetAimVector() * 100)
            dmginfo:SetDamage(15)
            dmginfo:SetAttacker(self.Owner)
            dmginfo:SetInflictor(self)
            dmginfo:SetDamageType(DMG_ALWAYSGIB)
         //local trace = self.Owner:GetEyeTrace()
         if trace.HitPos:Distance(self.Owner:GetShootPos()) <= 80 then
		   if SERVER then
			   trace.Entity:TakeDamageInfo(dmginfo)
		end
	if (( trace.Entity:IsPlayer() or (trace.Entity:IsNPC() and trace.MatType == MAT_FLESH )) or (trace.Entity:IsPlayer() and trace.MatType == MAT_FLESH)) and math.random(0,2) == 0 then
		local fx 		= EffectData()
		fx:SetOrigin(trace.HitPos)
		fx:SetNormal(VectorRand(), VectorRand(), VectorRand())
		util.Effect( "hg_katana_blood_hit" ,fx)	
		local randomsounds = {
    "katana/katana2.wav",
    "katana/katana.wav"
    }
	local random = math.random(1, #randomsounds)
   self.Owner:EmitSound(randomsounds[random])
	else
	//if (math.random(0,2) == 0) 
	util.Decal( "ManhackCut",( trace.HitPos - trace.HitNormal ),( trace.HitPos + trace.HitNormal ) )
	if trace.MatType == MAT_METAL then
	local effectdata = EffectData()
		effectdata:SetOrigin(trace.HitPos)
		effectdata:SetNormal(trace.HitNormal)
		effectdata:SetScale(10)
		util.Effect("MetalSpark", effectdata)
	end
	end
end
end

end

hook.Add("PlayerTraceAttack","PlayerTraceAttackForKatanaCykaBlyat",function( ply, dmginfo, dir, trace )
if blockbullets == 1 then
local effectdata = EffectData()
		effectdata:SetOrigin(trace.HitPos)
		effectdata:SetNormal(trace.HitNormal)
		effectdata:SetScale(120)
		util.Effect("StunstickImpact", effectdata)
	ply:EmitSound("physics/metal/metal_solid_impact_bullet"..math.random(1,4)..".wav")
	local tst = ((trace.HitPos - ply:GetPos()):Angle())
	ply:SetEyeAngles(tst - Angle(-90, 0, 0) )
		local holdtype = {
   		"knife",
    	"melee",
		"melee2"
    				}
	local random = math.random(1, #holdtype)
  	local katana = ply:GetActiveWeapon()
	katana:SetHoldType(holdtype[random])
ply:ViewPunch( Angle( 5,0,0 ) )
	//print(tst)
	
	return true
else
return false
end

end)

SWEP.VElements = {
	["katana"] = { type = "Model", model = "models/weapons/melee/v_katana.mdl", bone = "v_weapon.Knife_Handle", rel = "", pos = Vector(-3.5, -47.5, 3), angle = Angle(75, -90, -175), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["katana"] = { type = "Model", model = "models/weapons/melee/v_katana.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(-39, -11, 18), angle = Angle(-100, -25, -8), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["katana+"] = { type = "Model", model = "models/weapons/melee/v_katana.mdl", bone = "ValveBiped.Bip01_Spine2", rel = "", pos = Vector(4, 8, 50), angle = Angle(-157, 5, -5), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.IronSightsPos = Vector(-6.43, -0.603, 7.96) //Vector(-18.521, -0.603, 9.399)
SWEP.IronSightsAng = Vector(-30.251, -13.367, -15.478) //Vector(0, -51.357, -44.322)

SWEP.SteelRoundPos = Vector(-6.43, -0.603, 7.96)
SWEP.SteelRoundAng = Vector(-30.251, -13.367, -15.478)

SWEP.HolsterPos = Vector(-11.48, 0, -8.24)
SWEP.HolsterAng = Vector(0, 23.92, -70)

function SWEP:PrimaryAttack()
if !self.Owner:KeyDown(IN_USE) then
if self.Owner:KeyDown(IN_SPEED) then
self.Weapon:SetNextPrimaryFire(CurTime() + 0.3)
else
self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
end
//self.Owner:SetAngle(Angle(-23.632, -23.685, 44.812))

local a = math.random(0,1)
if a == 0 then
self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
end
if a == 1 then
self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
end
	local holdtype = {
   		"knife",
    	"melee",
		"melee2"
    				}
	local random = math.random(1, #holdtype)
  	self.Weapon:SetHoldType(holdtype[random])
	local rnda = 2
	local rndb = 2 * math.random(-1, 1)
self.Owner:ViewPunch( Angle( rnda,rndb,rnda ) )
self.Dash = 10
local trace = self.Owner:GetEyeTrace()
		    local dmginfo = DamageInfo()
            dmginfo:SetDamageForce( self.Owner:GetAimVector() * 50)
            dmginfo:SetDamage(15)
            dmginfo:SetAttacker(self.Owner)
            dmginfo:SetInflictor(self)
            dmginfo:SetDamageType(DMG_ALWAYSGIB)
         //local trace = self.Owner:GetEyeTrace()
         if trace.HitPos:Distance(self.Owner:GetShootPos()) <= 85 then
		    if SERVER then
			   trace.Entity:TakeDamageInfo(dmginfo)
			end
			if !( trace.Entity:IsPlayer() or trace.Entity:IsNPC() or trace.MatType == MAT_FLESH ) then
				//else
				util.Decal( "ManhackCut",( trace.HitPos - trace.HitNormal ),( trace.HitPos + trace.HitNormal ) )
			end
        self.Owner:SetAnimation( PLAYER_ATTACK1 );
    local randomsounds = {
    "katana/katana2.wav",
    "katana/katana.wav"
    }
   local random = math.random(1, #randomsounds)
   self.Owner:EmitSound(randomsounds[random])
else
	self.Weapon:EmitSound("katana/slash.wav")
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self.Owner:SetAnimation( PLAYER_ATTACK1 )
end
	
end
end

local IRONSIGHT_TIME = 0.17

function SWEP:SecondaryAttack()
if !self.Owner:KeyDown(IN_USE) then
self.Owner:ViewPunch( Angle( 5,0,0 ) )
self.Weapon:SetNetworkedInt( "Some1", 50 )
self.Weapon:SetNextSecondaryFire(CurTime() + 2)
self.Dash = 20
self.Owner:SetVelocity(self.Owner:GetForward() * 600)
//local test = self.Owner:EyeAngles(y)//.y 
//self.Owner:SetAngle(test + 5)
	elseif self.Owner:KeyDown(IN_USE) then
	self.Weapon:SetNextSecondaryFire(CurTime() + 5)
	self.IronCircle = 56
end
end

function SWEP:IronThink()
if self.Weapon:GetNetworkedInt( "Some1" ) > 0 then
//self.IronSightsPos = self.SteelRoundPos
//self.IronSightsAng = self.SteelRoundAng
self.Weapon:SetNetworkedBool( "Ironsights", true )
self.Weapon:SetNetworkedInt( "Some1", self.Weapon:GetNetworkedInt( "Some1" ) - 1 )
//print(self.Weapon:GetNetworkedInt( "Some1" ))
end
if self.Weapon:GetNetworkedInt( "Some1" ) == 0 then
self.Weapon:SetNetworkedBool( "Ironsights", false )
end
end


	local Mul = 0
	local mul21 = 0
function SWEP:GetViewModelPosition( pos, ang )

	if ( !self.IronSightsPos ) then return pos, ang end

	local bIron = self.Weapon:GetNetworkedBool( "Ironsights" )
	
	if ( bIron != self.bLastIron ) then
	
		self.bLastIron = bIron 
		self.fIronTime = CurTime()
		
		if ( bIron ) then 
			self.SwayScale 	= 0.3
			self.BobScale 	= 0.1
		else 
			self.SwayScale 	= 1.0
			self.BobScale 	= 1.0
		end
	
	end
	
	local fIronTime = self.fIronTime or 0
	
	local FT = FrameTime()
	
	if bIron then
		Mul = Lerp(FT*15, Mul, 1)
		//mul21 = math.Approach(mul21, 1, FrameTime()*5)
	else
		Mul = Lerp(FT*7.5, Mul, 0)
		//mul21 = math.Approach(mul21, 0, FrameTime()*5)
	end


	local Offset	= self.IronSightsPos
	
	if ( self.IronSightsAng ) then
	
		ang = ang * 1
		ang:RotateAroundAxis( ang:Right(), 		self.IronSightsAng.x * Mul )
		ang:RotateAroundAxis( ang:Up(), 		self.IronSightsAng.y * Mul )
		ang:RotateAroundAxis( ang:Forward(), 	self.IronSightsAng.z * Mul )
	
	
	end
	
	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()
	
	

	pos = pos + Offset.x * Right * Mul
	pos = pos + Offset.y * Forward * Mul
	pos = pos + Offset.z * Up * Mul

	return pos, ang
	
end

function SWEP:Deploy()
self:SetWeaponHoldType( "normal" )	
self.Weapon:SetNetworkedBool( "Ironsights", false )
self.Weapon:SetNetworkedBool( "Holster", false )
self.ReloadDelay = (CurTime() + 0.8)
	self:SendWeaponAnim( ACT_VM_DRAW )
	self:SetNextPrimaryFire( CurTime() + self:SequenceDuration() )
	//self.Weapon:EmitSound("weapons/draw_melee.wav")

	return true
end 

function SWEP:Reload()
if self.ReloadDelay <= CurTime() then
self.ReloadDelay = (CurTime() + 0.8)
self:SetWeaponHoldType( "normal" )	
self.Weapon:SetNetworkedBool( "Holster", !self.Weapon:GetNetworkedBool( "Holster" ) )
end
end

function SWEP:Initialize()

	// other initialize code goes here

	if CLIENT then

		self:SetWeaponHoldType( self.HoldType )	
		// Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels
		
		// init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				
				--[[// Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					// we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255,255,255,1))
					// ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					// however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")			
				end]]--
			end
		end
	end
end
function SWEP:Holster()
	blockbullets = 0
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	
	return true
end

function SWEP:OnRemove()
	self:Holster()
end

if CLIENT then

	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end
		
		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then
			
			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end

		for k, name in ipairs( self.vRenderOrder ) do
		
			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
			
			if (!pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		
		if (!self.WElements) then return end
		
		if (!self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		
		if self.ViewModelBoneMods then
			
			if (!vm:GetBoneCount()) then return end
			
			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
			end
			// !! ----------- !! //
			
			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				
				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms
				// !! ----------- !! //
				
				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end
		   
	end
	 
	function SWEP:ResetBonePositions(vm)
		
		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end
		
	end

	/**************************
		Global utility code
	**************************/

	// Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	// Does not copy entities of course, only copies their reference.
	// WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
	function table.FullCopy( tab )

		if (!tab) then return nil end
		
		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		
		return res
		
	end
	
end
print('Katana')
