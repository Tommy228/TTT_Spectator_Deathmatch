if SERVER then
   AddCSLuaFile()
end
   
SWEP.HoldType = "pistol"
   

if CLIENT then
   SWEP.PrintName = "pistol_name"
   SWEP.Slot = 1

--   SWEP.Icon = "VGUI/ttt/icon_pistol"
end

SWEP.WeaponID = AMMO_PISTOL

SWEP.Base				= "weapon_ghost_base"
SWEP.Primary.Recoil	= 1.3
SWEP.Primary.Damage = 17
SWEP.Primary.Delay = 0.09
SWEP.Primary.Cone = 0.025
SWEP.Primary.ClipSize = 20
SWEP.Primary.Automatic = false
SWEP.Primary.DefaultClip = 80
SWEP.Primary.ClipMax = 60
SWEP.Primary.Ammo = "Pistol"

SWEP.ViewModel  = "models/weapons/v_pist_fiveseven.mdl"
SWEP.WorldModel = "models/weapons/w_pist_fiveseven.mdl"

SWEP.Primary.Sound = Sound( "Weapon_FiveSeven.Single" )
SWEP.IronSightsPos = Vector( 4.53, -4, 3.2 )

/*
--- TTT config values

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_PISTOL

-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2, then this gun can
-- be spawned as a random weapon. Of course this AK is special equipment so it won't,
-- but for the sake of example this is explicitly set to false anyway.
SWEP.AutoSpawnable = false

-- The NoAmmoEnt is the ammo entity that can be picked up when carrying this gun.
SWEP.NoAmmoEnt = "item_ammo_pistol_ttt"

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
*/