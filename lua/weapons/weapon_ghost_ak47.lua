if SERVER then
	AddCSLuaFile()
	if SpecDM.LoadoutEnabled then
		resource.AddFile("materials/vgui/spec_dm/icon_sdm_ak47.vmt")
	end
else
	SWEP.PrintName = "AK47"
	SWEP.Slot      = 2

	SWEP.ViewModelFOV  = 72
	SWEP.ViewModelFlip = true
	SWEP.Icon = "vgui/spec_dm/icon_sdm_ak47"
end

SWEP.Base				= "weapon_ghost_base"

SWEP.HoldType			= "ar2"
SWEP.Kind = WEAPON_HEAVY

SWEP.Primary.Delay       = 0.12
SWEP.Primary.Recoil      = 2.9
SWEP.Primary.Automatic   = true
SWEP.Primary.Damage      = 20
SWEP.Primary.Cone        = 0.030
SWEP.Primary.Ammo        = "smg1"
SWEP.Primary.ClipSize    = 20
SWEP.Primary.ClipMax     = 100
SWEP.Primary.DefaultClip = 120
SWEP.Primary.Sound       = Sound( "Weapon_AK47.Single" )

SWEP.IronSightsPos = Vector( 6.05, -5, 2.4 )
SWEP.IronSightsAng = Vector( 2.2, -0.1, 0 )

SWEP.ViewModel  = "models/weapons/v_rif_ak47.mdl"
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"