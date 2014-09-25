if SERVER then
   AddCSLuaFile()
end

SWEP.HoldType			= "ar2"

if CLIENT then

   SWEP.PrintName			= "Silent Tmp"
   SWEP.Slot				= 2
--   SWEP.Icon = "VGUI/ttt/icon_gw_tmp"
end


SWEP.Base				= "weapon_ghost_base"

SWEP.Primary.Damage      = 22
SWEP.Primary.Delay       = 0.12
SWEP.Primary.Cone        = 0.06
SWEP.Primary.ClipSize    = 30
SWEP.Primary.ClipMax     = 120
SWEP.Primary.DefaultClip = 150
SWEP.Primary.Automatic   = true
SWEP.Primary.Ammo        = "smg1"
SWEP.Primary.Recoil      = 1.7
SWEP.Primary.Sound       = Sound( "Weapon_mac10.Single" )
SWEP.AutoSpawnable = false

SWEP.Kind = WEAPON_HEAVY

SWEP.NoAmmoEnt = "item_ammo_smg1_ttt"

SWEP.NoSights = false
SWEP.IsSilent = true

SWEP.ViewModel			= "models/weapons/v_smg_tmp.mdl"
SWEP.WorldModel			= "models/weapons/w_smg_tmp.mdl"

SWEP.Primary.Sound = Sound( "Weapon_tmp.Single" )
SWEP.Primary.SoundLevel = 50

SWEP.IronSightsPos = Vector( 5, -5, 2.2091 )
SWEP.IronSightsAng = Vector( 5, -1.5, 0 )
