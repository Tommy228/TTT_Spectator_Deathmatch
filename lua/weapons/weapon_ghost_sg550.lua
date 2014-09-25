if SERVER then
   AddCSLuaFile()
end

if CLIENT then
   SWEP.PrintName = "SG552"
   SWEP.Slot      = 2 -- add 1 to get the slot number key
--   SWEP.Icon = "VGUI/ttt/icon_sg552"
   SWEP.ViewModelFOV  = 72
   SWEP.ViewModelFlip = true
end


-- Always derive from weapon_tttbase.
SWEP.Base				= "weapon_ghost_base"

--- Standard GMod values

SWEP.HoldType			= "ar2"

SWEP.Primary.Delay       = 0.13
SWEP.Primary.Recoil      = 0.9
SWEP.Primary.Automatic   = true
SWEP.Primary.Damage      = 19
SWEP.Primary.Cone        = 0.025
SWEP.Primary.Ammo        = "smg1"
SWEP.Primary.ClipSize    = 30
SWEP.Primary.ClipMax     = 120
SWEP.Primary.DefaultClip = 150
SWEP.Primary.Sound       = Sound( "Weapon_SG552.Single" )

SWEP.IronSightsPos = Vector (-0.5419, -3.3774, 1.5757)
SWEP.IronSightsAng = Vector (0, 0, 0)

SWEP.ViewModel  = "models/weapons/v_rif_sg552.mdl"
SWEP.WorldModel = "models/weapons/w_rif_sg552.mdl"
resource.AddFile("models/weapons/v_rif_sg552.mdl")
resource.AddFile("models/weapons/w_rif_sg552.mdl")



--- TTT config values

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_HEAVY

-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2, then this gun can
-- be spawned as a random weapon. Of course this AK is special equipment so it won't,
-- but for the sake of example this is explicitly set to false anyway.
SWEP.AutoSpawnable = false

-- The NoAmmoEnt is the ammo entity that can be picked up when carrying this gun.
SWEP.NoAmmoEnt = "item_ammo_smg1_ttt"

-- CanBuy is a table of ROLE_* entries like ROLE_TRAITOR and ROLE_DETECTIVE. If
-- a role is in this table, those players can buy this.

-- InLoadoutFor is a table of ROLE_* entries that specifies which roles should
-- receive this weapon as soon as the round starts. In this case, none.
SWEP.InLoadoutFor = nil

-- If LimitedStock is true, you can only buy one per round.
SWEP.LimitedStock = false

-- If AllowDrop is false, players can't manually drop the gun with Q
SWEP.AllowDrop = true

-- If IsSilent is true, victims will not scream upon death.
SWEP.IsSilent = false

-- If NoSights is true, the weapon won't have ironsights
SWEP.NoSights = false

-- Equipment menu information is only needed on the client