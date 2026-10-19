--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/mlg_weapons_1214787279/lua/weapons/hobogus_base/shared.lua <
    > Callstack:  <
]]

-- "addons\\mlg_weapons_1214787279\\lua\\weapons\\hobogus_base\\shared.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal

SWEP.Base = "weapon_base"

SWEP.AdminSpawnable = true

SWEP.AutoSwitchTo = false
SWEP.Slot = 2
SWEP.PrintName = "BASE!"
SWEP.Author = "internet"
SWEP.Spawnable = false
SWEP.AutoSwitchFrom = false
SWEP.Weight = 5
SWEP.DrawCrosshair = false
SWEP.CustomCrosshair = false
SWEP.Category = "Hobo_Gus"
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.QuadAmmoCounter = false
SWEP.AmmoQuadColor = Color(84,196,247,255)
SWEP.Instructions = "Use it as base"
SWEP.Contact = "uwotm8"
SWEP.Purpose = "BRUTAL LUA RAPE"
SWEP.HoldType = "smg"
SWEP.ViewModelFOV = 55
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/c_smg1.mdl"
SWEP.WorldModel = "models/weapons/w_smg1.mdl"
SWEP.UseHands = true
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.LaserSight = 0
SWEP.Dissolve = 0
SWEP.Acid = 0
SWEP.Hitmarker = true
SWEP.HitmarkerSound = true
SWEP.IronsightTime = 0.17
SWEP.DisableMuzzle = 0
SWEP.HealingBullets = false
SWEP.HealAmount = 5
SWEP.ViewModelBoneMods = {
}

SWEP.IronSightsPos = Vector(-7.56, 0, -0.04)
SWEP.IronSightsAng = Vector(0, 0, 0)

SWEP.PrimarySound = Sound("weapons/ar1/ar1_dist2.wav")
SWEP.ReloadSound = Sound("common/null.wav")

SWEP.FirstView = true

SWEP.Primary.Damage = 11
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 45
SWEP.Primary.Ammo = "ar2"
SWEP.Primary.DefaultClip = 154
SWEP.Primary.Spread = 1
SWEP.Primary.Cone = 0.3
SWEP.IronCone = 0.05
SWEP.DefaultCone = 0.3
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = 0.5
SWEP.Primary.Delay = 0.10
SWEP.Primary.Force = 3
SWEP.CrossColor = Color( 0, 255, 0, 255 )
SWEP.CSGOstyle = false
//1 - AR2, 2 - Air Boat Gun, 3 - Tool tracer, 4 - Gauss tracer, 5 - Gunship tracer, 6 - Default, 7 - Tool tracer 2.
//След пули. Какой он может быть смотри выше
SWEP.Tracer = 2
SWEP.CustomTracerName = "Tracer"
SWEP.ShotEffect = "hg_muzzle_plasmav2"


SWEP.IronFOV = 55

SWEP.MarkerOpacity = 0

function SWEP:Deploy()
self:OnDeploy()
	self.Weapon:SetNetworkedBool( "IronBool", false )
	self:SendWeaponAnim( ACT_VM_DRAW )
	self:SetNextPrimaryFire( CurTime() + self:SequenceDuration() )
	self:SetHoldType( self.HoldType )	
	self:SetIronsights(false)
	self.Zoomed = false
	self.Primary.Cone = self.DefaultCone
	self.Weapon:SetNWBool("Reloading", false)
	return true
end

function SWEP:OnDeploy()

end

function SWEP:Think()
self:SecondThink()
if self.CSGOstyle == true then
	if self.Owner:IsOnGround() then
		self.Primary.Cone = self.DefaultCone
		if self.Owner:KeyDown(IN_FORWARD) or self.Owner:KeyDown(IN_MOVELEFT) or self.Owner:KeyDown(IN_MOVERIGHT) or self.Owner:KeyDown(IN_BACK) then
		self.Primary.Cone = self.DefaultCone + (self.DefaultCone*2)//0.5
			if self.Owner:KeyDown(IN_SPEED) then
			self.Primary.Cone = self.DefaultCone + (self.DefaultCone*3)//1
			end
			if self.Owner:KeyDown(IN_WALK) then
			self.Primary.Cone = self.DefaultCone + (self.DefaultCone/4)//0.3
			end
		end
		if self.Owner:KeyDown(IN_DUCK) then
		self.Primary.Cone = self.DefaultCone - (self.DefaultCone/3)//0.5
		end
		elseif !self.Owner:IsOnGround() then
		self.Primary.Cone = self.DefaultCone + (self.DefaultCone*4)//3
	end
end
end

//This needed to hide ammo display.
//Это нужно чтобы скрывать худ с патронами.
function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay = self.AmmoDisplay or {} 
 
	self.AmmoDisplay.Draw = self.DrawAmmo 
 
	if self.Primary.ClipSize > 0 then
		self.AmmoDisplay.PrimaryClip = self:Clip1() 
		self.AmmoDisplay.PrimaryAmmo = self:Ammo1() 
	end
	if self.Secondary.ClipSize > 0 then
		self.AmmoDisplay.SecondaryClip = self:Clip2()
		self.AmmoDisplay.SecondaryAmmo = self:Ammo2()
	end
 
	return self.AmmoDisplay
end

function SWEP:SecondThink()
end

function SWEP:PrimaryCall()//Если надо что-то приписать к выстрелу, но не нужен весь код
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	self:PrimaryCall()
	self:ShootBulletInfo()
	local rnda = self.Primary.Recoil
	local rndb = self.Primary.Recoil * math.random(-1, 1)
	self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() + self.Primary.Delay )
	self:ShootEffects()
		local fx 		= EffectData()
		fx:SetEntity(self.Weapon)
		fx:SetOrigin(self.Owner:GetShootPos())
		fx:SetNormal(self.Owner:GetAimVector())
		fx:SetAttachment("1")
		util.Effect( self.ShotEffect ,fx)
self.Owner:EmitSound(self.PrimarySound)
if self.Owner:IsPlayer() then
	self.Owner:ViewPunch( Angle( -rnda,rndb,rndb ) )
end
	self:TakePrimaryAmmo(self.Primary.TakeAmmo)
	if !self.Owner:IsNPC() then
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	else
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay*2 )
	end
	if !self.Owner:IsNPC() and ( self.Primary.Recoil > 1 ) then
		local shotang 	= self.Owner:EyeAngles()
		shotang.pitch 	= shotang.pitch - self.Primary.Recoil/2
		self.Owner:SetEyeAngles(shotang)
	end
end

function SWEP:NPCShoot_Primary( ShootPos, ShootDir )
	if ( !self:CanPrimaryAttack() ) then return end
	self:PrimaryAttack()
end

SWEP.Secondary.Ammo = "none"

SWEP.VElements = {
}
SWEP.WElements = {
	
}

/*---------------------------------------------------------
   Name: GetViewModelPosition
   Desc: Allows you to re-position the view model
---------------------------------------------------------*/
	local Mul = 0

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


/*---------------------------------------------------------
	SetIronsights
---------------------------------------------------------*/
function SWEP:SetIronsights( b )

	self.Weapon:SetNetworkedBool( "Ironsights", b )

end

function SWEP:Holster()
self:SetIronsights( false )
self.Zoomed = false
end

SWEP.NextSecondaryAttack = 0
/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()

	if ( !self.IronSightsPos ) then return end
	if ( self.NextSecondaryAttack > CurTime() ) then return end
	
	bIronsights = !self.Weapon:GetNetworkedBool( "Ironsights", false )
	
	self:SetIronsights( bIronsights )
	
	self.NextSecondaryAttack = CurTime() + 0.2
	
 	if !self.Zoomed then 
		self.Zoomed = true 
		if SERVER then
			self.Weapon:SetNetworkedBool( "IronBool", true )
			self.Owner:SetFOV( self.IronFOV, 0.3 )
			self.Primary.Cone = self.IronCone
		end
	else
		self.Zoomed = false
		if SERVER then
			self.Weapon:SetNetworkedBool( "IronBool", false )
			self.Owner:SetFOV( 0, 0.3 )
			self.Primary.Cone = self.DefaultCone
		end
	end
end
	
function SWEP:Equip()
	self:SetHoldType(self.HoldType)
end	
	
function SWEP:OnRestore()

	self.NextSecondaryAttack = 0
	self:SetIronsights( false )
	
end

function SWEP:Reload()
if not IsValid(self) then return end if not IsValid(self.Owner) then return end
	self.Weapon:DefaultReload(ACT_VM_RELOAD)
	
if (self.Weapon:Clip1() < self.Primary.ClipSize) and (!self.Owner:IsNPC() and (self.Owner:GetAmmoCount(self.Primary.Ammo) > 0)) then
			self.Weapon:SetNWBool("Reloading", true)
			self.Weapon:SetNetworkedBool( "IronBool", false )
			self.Owner:EmitSound(self.ReloadSound)
end
		self:SetIronsights(false)		
				self.Zoomed = false
				self.Primary.Cone = self.DefaultCone
		if SERVER then
			self.Owner:SetFOV( 0, 0.3 ) 
		end
		
		if not (CLIENT) then

			self.Owner:DrawViewModel(true)

		end
		local waitdammit = (self.Owner:GetViewModel():SequenceDuration())
	timer.Simple(waitdammit + .1, 
	function() 
		if self.Weapon == nil then return end
		self.Weapon:SetNWBool("Reloading", false)
	end)
	
end

function SWEP:ShootBullet()

	if self.Tracer == 1 then
		TracerName = "Ar2Tracer"
	elseif self.Tracer == 2 then
		TracerName = "AirboatGunHeavyTracer"
	elseif self.Tracer == 3 then
		TracerName = "ToolTracer"
	elseif self.Tracer == 4 then
		TracerName = "GaussTracer"
	elseif self.Tracer == 5 then
	    TracerName = "GunshipTracer"
	elseif self.Tracer == 7 then
	    TracerName = "ToolTracer"
	elseif self.Tracer == 10 then
	    TracerName = self.CustomTracerName
	else
		TracerName = "Tracer"
	end
	
	local bullet = {}
		bullet.Num 		= self.Primary.NumberofShots
		bullet.Src 		= self.Owner:GetShootPos()	
		bullet.Dir 		= self.Owner:GetAimVector()		
if	self.Owner:IsNPC() then
		bullet.Spread 	= Vector( 0.1 , 0.1, 0.1)	
	else
		bullet.Spread 	= Vector( self.Primary.Cone * 0.1 , self.Primary.Cone * 0.1, self.Primary.Cone * 0.1)	
end		
		bullet.Tracer	= 1						// Show a tracer on every x bullets
		bullet.TracerName = TracerName
		bullet.Force	= self.Primary.Force
		bullet.Damage	= self.Primary.Damage
		bullet.Callback	= function(attacker, tracedata, dmginfo) 
		if self.Dissolve == 1 then 
		dmginfo:SetDamageType( bit.bor( DMG_ENERGYBEAM, DMG_DISSOLVE ) )
		end
		if self.Acid == 1 then
		dmginfo:SetDamageType( bit.bor( DMG_ACID, DMG_ACID ) )
		end
				return self:HitCallback(attacker, tracedata, dmginfo) 
		end

	self.Owner:FireBullets(bullet)

end

function SWEP:ShootBulletInfo()

	local CurrentDamage
	local CurrentRecoil
	local CurrentCone
	local basedamage

	local damagedice = math.Rand(.85,1.3)
	
	basedamage = self.Primary.Damage
	CurrentDamage = basedamage * damagedice
	CurrentRecoil = self.Primary.Recoil
	self:ShootBullet(CurrentDamage, CurrentRecoil, self.Primary.NumShots, CurrentCone)
	
end

function SWEP:HitCallback(attacker, tr, dmginfo)
	
	if not IsFirstTimePredicted() then
	return {damage = false, effects = false}
	end
		
	local DoDefaultEffect = true
	if (tr.HitSky) then return end
	self:CustomHitFunc( attacker, tr, dmginfo )
			if ((tr.Entity:IsNPC()) or (tr.Entity:IsPlayer())) then
		
				
					if self.HealingBullets == true then
					tr.Entity:SetHealth( math.min( tr.Entity:GetMaxHealth(), tr.Entity:Health() + self.HealAmount ) )
					tr.Entity:EmitSound("items/medshot4.wav")
					end
				
					
				return 
			end
		if self.Tracer == 0 or self.Tracer == 1 or self.Tracer == 2 or self.Tracer == 3 or self.Tracer == 4 then
			local effectdata = EffectData()
				effectdata:SetOrigin(tr.HitPos)
				effectdata:SetNormal(tr.HitNormal)
				effectdata:SetScale(20)
			util.Effect("AR2Impact", effectdata)
		elseif self.Tracer == 5 or self.Tracer == 7 then
			local effectdata = EffectData()
				effectdata:SetOrigin(tr.HitPos)
				effectdata:SetNormal(tr.HitNormal)
				effectdata:SetScale(20)
			util.Effect("StunstickImpact", effectdata)
		elseif self.Tracer == 6 then

		return 
	end
	return {damage = true, effects = DoDefaultEffect}
end

function SWEP:CustomHitFunc( attacker, tr, dmginfo )
end

function SWEP:CustomFireEvent( pos, ang, event, options )

end

function SWEP:FireAnimationEvent( pos, ang, event, options )
self:CustomFireEvent( pos, ang, event, options )
if self.DisableMuzzle == 1 then
	-- Disables animation based muzzle event
	if ( event == 21 ) then return true end	
	if ( event == 20 ) then return true end	

	-- Disable thirdperson muzzle flash
	if ( event == 5001 ) then return true end
	if ( event == 5003 ) then return true end
	if ( event == 5011 ) then return true end
	if ( event == 5021 ) then return true end
	if ( event == 5031 ) then return true end
	if ( event == 6001 ) then return true end
end
end

function SWEP:CustomHud()//Функция для худа, если нужно оставить базовый код
end

function SWEP:DrawHUD()
self:CustomHud()
	if self.CustomCrosshair == true and !self.Weapon:GetNetworkedBool( "Ironsights", false ) then
		local x = ScrW() / 2.0
		local y = ScrH() / 2.0
		local scale = self.Primary.Cone * 5

		local LastShootTime = self.Weapon:GetNetworkedFloat( "LastShootTime", 0 )
		scale = scale * (2 - math.Clamp( (CurTime() - LastShootTime) * 5, 0.0, 1.0 ))
	
		local gap = 5 * scale
		local length = gap + 2.5 * scale
		surface.SetDrawColor( self.CrossColor )
		surface.DrawLine( x - length, y, x - gap, y )
		surface.DrawLine( x + length, y, x + gap, y )
		surface.DrawLine( x, y - length, x, y - gap )
		surface.DrawLine( x, y + length, x, y + gap )
	end
	


end



function SWEP:Initialize()

	if SERVER then
	self:SetWeaponHoldType( self.HoldType )
	if self.Owner:IsNPC() then //Shitty code for NPC...
		self:SetNPCMinBurst(1)
		self:SetNPCMaxBurst(5)
		self:SetNPCFireRate(self.Primary.Delay)
		self:SetNPCMinRest(20)
		self:SetNPCMaxRest(35)
		self.Weapon:SetupWeaponHoldTypeForAI("ar2")
		self.Weapon.Owner:Fire("DisableWeaponPickup")
		self.Weapon.Owner:SetKeyValue("spawnflags","155") // Long Visibility/Shoot
		self.Weapon.Owner:SetKeyValue("FireRate","5")
		self.Owner:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_VERY_GOOD )
	end
 end
	
	if CLIENT then

	self:SetWeaponHoldType( self.HoldType )	
	
	if self.QuadAmmoCounter == true then
		self.VElements["ammocounter"].draw_func = function( weapon )
			//surface.SetDrawColor(quadInnerColor)
			draw.SimpleText(weapon:Clip1(), "Trebuchet24", 0, 0, self.AmmoQuadColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(weapon:Ammo1(), "Trebuchet24", 0, 25, self.AmmoQuadColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end

		
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels

		if IsValid(self.Owner) and self.Owner:IsPlayer() then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				
			end
		end
	end
end
function SWEP:Holster()
	
	if CLIENT and IsValid(self.Owner) and self.Owner:IsPlayer() then
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

function SWEP:CustomDrawn()
end

function SWEP:CustomWorldDrawn()
end

if CLIENT then

	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		self:CustomDrawn()
		//self:LaserDraw()
		local vm = self.Owner:GetViewModel()
		
		if ( IsValid( vm ) ) and self.LaserSight == 1 then
	local tr = self.Owner:GetEyeTrace()
	local lsize = math.random(9,15)
		    render.SetMaterial( Material( "effects/redflare" ) )
            render.DrawSprite( tr.HitPos,lsize,lsize,Color( 255,255,255 ) )
		end
		
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end
		
		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then

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
		self:CustomWorldDrawn()
		if self.Owner:IsValid() and self.LaserSight == 1 then
	local tr = self.Owner:GetEyeTrace()
	local lsize = math.random(9,15)
		          render.SetMaterial( Material( "effects/redflare" ) )
                  render.DrawSprite( tr.HitPos,lsize,lsize,Color( 255,255,255 ) )
		end
		
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
				ang.r = -ang.r 
			end
		
		end
		
		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

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

print ('LUA BRUTALLY RAPED')
