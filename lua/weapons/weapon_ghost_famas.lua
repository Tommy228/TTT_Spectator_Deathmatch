if SERVER then
   AddCSLuaFile()
end

if CLIENT then
   SWEP.PrintName = "FAMAS"
   SWEP.Slot      = 2 -- add 1 to get the slot number key

   SWEP.ViewModelFOV  = 72
   SWEP.ViewModelFlip = false
--   SWEP.Icon = "VGUI/ttt/icon_tuna_famas"
end


-- Always derive from weapon_tttbase.
SWEP.Base				= "weapon_ghost_base"

--- Standard GMod values

SWEP.HoldType			= "ar2"

SWEP.Primary.Delay       = 0.12
SWEP.Primary.Recoil      = 0.91
SWEP.Primary.Automatic   = true
SWEP.Primary.Damage      = 19
SWEP.Primary.Cone        = 0.031
SWEP.Primary.Ammo        = "smg1"
SWEP.Primary.ClipSize    = 20
SWEP.Primary.ClipMax     = 100
SWEP.Primary.DefaultClip = 120
SWEP.Primary.Sound       = Sound( "Weapon_FAMAS.Single" )

SWEP.IronSightsPos = Vector (-4.6856, 0, 1.144)
SWEP.IronSightsAng = Vector (0, 0, -1.2628)

SWEP.ViewModel  = "models/weapons/v_rif_famas.mdl"
SWEP.WorldModel = "models/weapons/w_rif_famas.mdl"
resource.AddFile("models/weapons/v_rif_famas.mdl")
resource.AddFile("models/weapons/w_rif_famas.mdl")

SWEP.Kind = WEAPON_HEAVY
SWEP.AutoSpawnable = false
