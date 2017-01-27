if SERVER then
	AddCSLuaFile()
else
	SWEP.PrintName			= "Glock"
	SWEP.Slot      = 1

	SWEP.Icon = "vgui/ttt/icon_glock"
end

SWEP.HoldType = "pistol"

SWEP.Kind = WEAPON_PISTOL
SWEP.WeaponID = AMMO_GLOCK

SWEP.Base				= "weapon_ghost_base"
SWEP.Primary.Recoil	= 0.7
SWEP.Primary.Damage = 21
SWEP.Primary.Delay = 0.15
SWEP.Primary.Cone = 0.028
SWEP.Primary.ClipSize = 20
SWEP.Primary.Automatic = true
SWEP.Primary.DefaultClip = 120
SWEP.Primary.ClipMax = 100
SWEP.Primary.Ammo = "Pistol"
SWEP.AutoSpawnable = false

SWEP.ViewModel  = "models/weapons/v_pist_glock18.mdl"
SWEP.WorldModel = "models/weapons/w_pist_glock18.mdl"

SWEP.Primary.Sound = Sound( "Weapon_Glock.Single" )
SWEP.IronSightsPos = Vector( 4.33, -4.0, 2.9 )

SWEP.HeadshotMultiplier = 1.75