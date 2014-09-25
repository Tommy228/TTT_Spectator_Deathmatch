if SERVER then
   AddCSLuaFile()
end
SWEP.HoldType			= "crossbow"


if CLIENT then

   SWEP.PrintName			= "H.U.G.E-249"

   SWEP.Slot				= 2

--   SWEP.Icon = "VGUI/ttt/icon_m249"

   SWEP.ViewModelFlip		= false
end


SWEP.Base				= "weapon_ghost_base"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AutoSpawnable = false

SWEP.Kind = WEAPON_HEAVY
SWEP.WeaponID = AMMO_M249


SWEP.Primary.Damage = 13
SWEP.Primary.Delay = 0.05
SWEP.Primary.Cone = 0.09
SWEP.Primary.ClipSize = 150
SWEP.Primary.ClipMax = 150
SWEP.Primary.DefaultClip	= 300
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "AirboatGun"
SWEP.Primary.Recoil			= 1.9
SWEP.Primary.Sound			= Sound("Weapon_m249.Single")
SWEP.ViewModel			= "models/weapons/v_mach_m249para.mdl"
SWEP.WorldModel			= "models/weapons/w_mach_m249para.mdl"

SWEP.HeadshotMultiplier = 2.2

SWEP.IronSightsPos 		= Vector( -4.4, -3, 2 )
