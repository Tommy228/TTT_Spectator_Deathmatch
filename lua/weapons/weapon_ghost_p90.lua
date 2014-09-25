if SERVER then
   AddCSLuaFile()
end

SWEP.HoldType			= "smg"


if CLIENT then

   SWEP.PrintName			= "P90"
   SWEP.Slot				= 2

--   SWEP.Icon = "VGUI/ttt/icon_ninjah_p90"
end


SWEP.Base				= "weapon_ghost_base"
SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.Kind = WEAPON_HEAVY
SWEP.WeaponID = AMMO_P90

SWEP.Primary.Delay			= 0.07
SWEP.Primary.Recoil			= 0.9
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"
SWEP.Primary.Damage = 13
SWEP.Primary.Cone = 0.0325
SWEP.Primary.ClipSize = 50
SWEP.Primary.ClipMax = 150
SWEP.Primary.DefaultClip = 200
SWEP.AutoSpawnable = false
SWEP.NoAmmoEnt = "item_ammo_smg1_ttt"
SWEP.ViewModel = "models/weapons/v_smg_p90.mdl"
SWEP.WorldModel = "models/weapons/w_smg_p90.mdl"

SWEP.Primary.Sound = Sound( "Weapon_P90.Single" )

SWEP.InLoadoutFor = nil
SWEP.AllowDrop = true
SWEP.IsSilent = false
SWEP.NoSights = true

SWEP.Secondary.Sound = Sound("Default.Zoom")

SWEP.IronSightsPos      = Vector( 500, -1005, -200 )
SWEP.IronSightsAng      = Vector( 200.6, 100.37, 300.5 )

function SWEP:SetZoom(state)
    if CLIENT then 
       return
    else
       if state then
          self.Owner:SetFOV(20, 0.3)
       else
          self.Owner:SetFOV(0, 0.2)
       end
    end
end

-- Add some zoom to ironsights for this gun

