if SERVER then
   AddCSLuaFile()
end
   
SWEP.HoldType			= "pistol"

if CLIENT then
   SWEP.PrintName			= "Magnum"			
   SWEP.Author				= "TTT"

   SWEP.Slot				= 1
   SWEP.SlotPos			= 1

   SWEP.Icon = "VGUI/ttt/magnumnew"		

   SWEP.ViewModelFOV  = 54
   SWEP.ViewModelFlip = false
end

SWEP.Tracer = "AR2Tracer"

SWEP.Base				= "weapon_ghost_base"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.Kind = WEAPON_PISTOL
SWEP.WeaponID = AMMO_MAGNUM

SWEP.Primary.Delay         = 0.9       
SWEP.Primary.ClipSize = 6;
SWEP.Primary.Recoil         =  6.5  
SWEP.Primary.DefaultClip = 36;
SWEP.Primary.Cone         = 0    
SWEP.Primary.Automatic = false;
SWEP.Primary.Ammo       = "AlyxGun" -- hijack an ammo type we don't use otherwise

SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo = "none";

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
SWEP.ViewModel = Model("models/weapons/v_357.mdl");
SWEP.WorldModel = Model("models/weapons/w_357.mdl");
SWEP.IronSightsPos = Vector (-5.6917, -3.2203, 2.3961)
SWEP.IronSightsAng = Vector (0.6991, -0.1484, 0.8356)

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[
Pistolet (gros calibre)
Recul : Élevé
Dégâts moyens : 50
Chargeur : 6 balles
Cadence de tir : 1,3 balles/sec]]
    };

function SWEP:WasBought(buyer)
   if IsValid(buyer) then -- probably already self.Owner
      buyer:GiveAmmo( 6, "AlyxGun" )
   end
end

