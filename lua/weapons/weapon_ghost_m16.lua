if SERVER then
   AddCSLuaFile()
end

SWEP.HoldType			= "ar2"


if CLIENT then

   SWEP.PrintName			= "M4A1"
   SWEP.Slot				= 2

--   SWEP.Icon = "VGUI/ttt/icon_m16"
end



SWEP.Base				= "weapon_ghost_base"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.Kind = WEAPON_HEAVY
SWEP.WeaponID = AMMO_M4A1

SWEP.Primary.Delay			= 0.11
SWEP.Primary.Recoil			= 1.4
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"
SWEP.Primary.Damage = 18
SWEP.Primary.Cone = 0.018
SWEP.Primary.ClipSize = 20
SWEP.Primary.ClipMax = 100
SWEP.Primary.DefaultClip = 120
SWEP.AutoSpawnable = false
SWEP.NoAmmoEnt = "item_ammo_smg1_ttt"
SWEP.ViewModel			= "models/weapons/v_rif_m4a1.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_m4a1.mdl"

SWEP.Primary.Sound = Sound( "Weapon_M4A1.Single" )

SWEP.IronSightsPos 		= Vector( 6, 0, 0.95 )
SWEP.IronSightsAng 		= Vector( 2.6, 1.37, 3.5 )


function SWEP:SetZoom(state)
   if CLIENT then return end
   if state then
      self.Owner:SetFOV(35, 0.5)
   else
      self.Owner:SetFOV(0, 0.2)
   end
end

-- Add some zoom to ironsights for this gun
function SWEP:SecondaryAttack()
   if not self.IronSightsPos then return end
   if self.Weapon:GetNextSecondaryFire() > CurTime() then return end

   bIronsights = not self:GetIronsights()

   self:SetIronsights( bIronsights )

   if SERVER then
      self:SetZoom(bIronsights)
   end

   self.Weapon:SetNextSecondaryFire(CurTime() + 0.3)
end

function SWEP:PreDrop()
   self:SetZoom(false)
   self:SetIronsights(false)
   return self.BaseClass.PreDrop(self)
end

function SWEP:Reload()
   self.Weapon:DefaultReload( ACT_VM_RELOAD );
   self:SetIronsights( false )
   self:SetZoom(false)
end


function SWEP:Holster()
   self:SetIronsights(false)
   self:SetZoom(false)
   return true
end


