if SERVER then
	AddCSLuaFile()
	if SpecDM.LoadoutEnabled then
		resource.AddFile("materials/vgui/spec_dm/icon_sdm_revolver.vmt")
	end
else
	SWEP.PrintName			= "Magnum"
	SWEP.Slot      = 1

	SWEP.ViewModelFlip		= false
	SWEP.ViewModelFOV  = 54
	SWEP.Icon = "vgui/spec_dm/icon_sdm_revolver"
end

SWEP.HoldType			= "pistol"
SWEP.Tracer = "AR2Tracer"

SWEP.Base				= "weapon_ghost_base"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.Kind = WEAPON_PISTOL
SWEP.WeaponID = AMMO_MAGNUM

SWEP.Primary.Delay         = 0.9
SWEP.Primary.ClipSize = 6
SWEP.Primary.Recoil         =  6.5
SWEP.Primary.DefaultClip = 36
SWEP.Primary.Cone         = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo       = "AlyxGun" -- hijack an ammo type we don't use otherwise

SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Sound = Sound ("weapon_357.Single")
SWEP.Primary.Damage = 50
SWEP.Spread = 0.02
SWEP.Primary.NumShots = 1
SWEP.Delay = 0.6
SWEP.Primary.ClipMax = 36

SWEP.HeadshotMultiplier = 4

SWEP.AutoSpawnable      = false
SWEP.NoAmmoEnt = "item_ammo_revolver_ttt"
SWEP.Primary.Sound = Sound( "weapon_357.Single" )
SWEP.ViewModel = Model("models/weapons/v_357.mdl")
SWEP.WorldModel = Model("models/weapons/w_357.mdl")
SWEP.IronSightsPos = Vector (-5.6917, -3.2203, 2.3961)
SWEP.IronSightsAng = Vector (0.6991, -0.1484, 0.8356)