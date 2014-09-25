if SERVER then
   AddCSLuaFile()
end

if CLIENT then
   SWEP.PrintName = "GALIL"
   SWEP.Slot      = 2 -- add 1 to get the slot number key

   SWEP.ViewModelFOV  = 72
   SWEP.ViewModelFlip = false
--   SWEP.Icon = "VGUI/ttt/icon_mtg_galil"
end

if SERVER then
   resource.AddFile("materials/VGUI/ttt/icon_mtg_galil.vmt")
end


-- Always derive from weapon_tttbase.
SWEP.Base				= "weapon_ghost_base"

--- Standard GMod values

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