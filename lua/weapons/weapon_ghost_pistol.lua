if SERVER then
	AddCSLuaFile()
else
	SWEP.PrintName			= "pistol_name"
	SWEP.Slot      = 1

	SWEP.Icon = "vgui/ttt/icon_pistol"
end

SWEP.HoldType = "pistol"

SWEP.Kind = WEAPON_PISTOL
SWEP.WeaponID = AMMO_PISTOL

SWEP.Base				= "weapon_ghost_base"
SWEP.Primary.Recoil	= 1.3
SWEP.Primary.Damage = 17
SWEP.Primary.Delay = 0.15
SWEP.Primary.Cone = 0.025
SWEP.Primary.ClipSize = 20
SWEP.Primary.Automatic = false
SWEP.Primary.DefaultClip = 80
SWEP.Primary.ClipMax = 60
SWEP.Primary.Ammo = "Pistol"

SWEP.ViewModel  = "models/weapons/v_pist_fiveseven.mdl"
SWEP.WorldModel = "models/weapons/w_pist_fiveseven.mdl"

SWEP.Primary.Sound = Sound( "Weapon_FiveSeven.Single" )
SWEP.IronSightsPos = Vector( 4.53, -4, 3.2 )