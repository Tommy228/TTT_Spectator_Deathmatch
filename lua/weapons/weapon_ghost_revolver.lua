if SERVER then
	AddCSLuaFile()
else
	SWEP.PrintName			= "Deagle"
	SWEP.Slot      = 1
	SWEP.ViewModelFOV	= 54
	SWEP.ViewModelFlip		= false

	SWEP.Icon = "vgui/ttt/icon_deagle"
end

SWEP.HoldType			= "pistol"
SWEP.Author				= "TTT"

SWEP.Base				= "weapon_ghost_base"

SWEP.Spawnable = true
SWEP.AutoSpawnable = false

SWEP.Kind = WEAPON_PISTOL
SWEP.WeaponID = AMMO_DEAGLE

SWEP.Primary.Ammo       = "AlyxGun" -- hijack an ammo type we don't use otherwise
SWEP.Primary.Recoil			= 6
SWEP.Primary.Damage = 24
SWEP.Primary.Delay = 0.5
SWEP.Primary.Cone = 0.02
SWEP.Primary.ClipSize = 8
SWEP.Primary.ClipMax = 28
SWEP.Primary.DefaultClip = 36
SWEP.Primary.Automatic = true
SWEP.UseHands				= true
SWEP.HeadshotMultiplier = 5

SWEP.Primary.Sound			= Sound( "Weapon_Deagle.Single" )
SWEP.ViewModel				= "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel				= "models/weapons/w_pist_deagle.mdl"

SWEP.IronSightsPos			= Vector(-6.361, -3.701, 2.15)
SWEP.IronSightsAng			= Vector(0, 0, 0)