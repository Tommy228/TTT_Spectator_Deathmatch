---- Example TTT custom weapon

-- First some standard GMod stuff
if SERVER then
   AddCSLuaFile()
end

if CLIENT then
   SWEP.PrintName = "AK47"
   SWEP.Slot      = 2 -- add 1 to get the slot number key

   SWEP.ViewModelFOV  = 72
   SWEP.ViewModelFlip = true
--   SWEP.Icon = "VGUI/ttt/icon_ak47"
end

-- Always derive from weapon_tttbase.
SWEP.Base				= "weapon_ghost_base"

--- Standard GMod values

SWEP.HoldType			= "ar2"
SWEP.Kind = WEAPON_HEAVY

SWEP.AutoSpawnable = false

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






