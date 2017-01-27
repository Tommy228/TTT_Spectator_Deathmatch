if SERVER then
	AddCSLuaFile()
	if SpecDM.LoadoutEnabled then
		resource.AddFile("materials/vgui/spec_dm/icon_sdm_galil.vmt")
	end
else
	SWEP.PrintName			= "Galil"
	SWEP.Slot      = 2

	SWEP.ViewModelFlip		= false
	SWEP.ViewModelFOV  = 72
	SWEP.Icon = "vgui/spec_dm/icon_sdm_galil"
end

SWEP.Base				= "weapon_ghost_base"

SWEP.HoldType			= "ar2"

SWEP.Primary.Delay       = 0.10
SWEP.Primary.Recoil      = 0.79
SWEP.Primary.Automatic   = true
SWEP.Primary.Damage      = 17
SWEP.Primary.Cone        = 0.025
SWEP.Primary.Ammo        = "smg1"
SWEP.Primary.ClipSize    = 20
SWEP.Primary.ClipMax     = 100
SWEP.Primary.DefaultClip = 120
SWEP.Primary.Sound       = Sound( "Weapon_GALIL.Single" )

SWEP.IronSightsPos = Vector(-5.1337, -3.9115, 2.1624)
SWEP.IronSightsAng = Vector(0.0873, 0.0006, 0)
SWEP.IronsightsFOV = 60

SWEP.ViewModel  = "models/weapons/v_rif_galil.mdl"
SWEP.WorldModel = "models/weapons/w_rif_galil.mdl"

SWEP.Kind = WEAPON_HEAVY
SWEP.AutoSpawnable = false