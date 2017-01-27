if SERVER then
	AddCSLuaFile()
	if SpecDM.LoadoutEnabled then
		resource.AddFile("materials/vgui/spec_dm/icon_sdm_smg.vmt")
	end
else
	SWEP.PrintName			= "SMG"
	SWEP.Slot      = 2

	SWEP.ViewModelFlip		= false
	SWEP.ViewModelFOV = 60
	SWEP.Icon = "vgui/spec_dm/icon_sdm_smg"
end

SWEP.Base				= "weapon_ghost_base"

SWEP.HoldType = "ar2"

SWEP.Kind = WEAPON_HEAVY
SWEP.WeaponID = AMMO_MAC10

SWEP.Primary.Damage      = 12
SWEP.Primary.Delay       = 0.065
SWEP.Primary.Cone        = 0.03
SWEP.Primary.ClipSize    = 30
SWEP.Primary.ClipMax     = 60
SWEP.Primary.DefaultClip = 90
SWEP.Primary.Automatic   = true
SWEP.Primary.Ammo        = "smg1"
SWEP.Primary.Recoil      = 1.15
SWEP.Primary.Sound 		= Sound("Weapon_SMG1.Single")

SWEP.AutoSpawnable = false

SWEP.ViewModel  = "models/weapons/v_smg1.mdl"
SWEP.WorldModel = "models/weapons/w_smg1.mdl"

SWEP.IronSightsPos 		= Vector (-6.4318, -2.0031, 2.5371)
SWEP.IronSightsAng 		= Vector (0, 0, 0)
SWEP.RunArmOffset 		= Vector (9.071, 0, 1.6418)
SWEP.RunArmAngle 	    = Vector (-12.9765, 26.8708, 0)

-- Add some zoom to ironsights for this gun
function SWEP:SecondaryAttack()
   if not self.IronSightsPos then return end
   if self.Weapon:GetNextSecondaryFire() > CurTime() then return end

   local bIronsights = not self:GetIronsights()

   self:SetIronsights( bIronsights )

   self.Weapon:SetNextSecondaryFire(CurTime() + 0.3)
end

function SWEP:PreDrop()
   self:SetIronsights(false)
   return self.BaseClass.PreDrop(self)
end

function SWEP:Holster()
   self:SetIronsights(false)
   return true
end

function SWEP:Reload()
    if !( ( self.Weapon:Clip1() ) < ( self.Weapon:Ammo1() ) ) then return end
    if !( ( self.Weapon:Clip1() ) < ( self.Primary.ClipSize ) ) then return end
    if !( self.Weapon:Ammo1() >= 0 ) then return end
    if !( self.Weapon:Clip1() >= 0 ) then return end

    self.Weapon:DefaultReload( ACT_VM_RELOAD )
    self:SetIronsights( false )
    if CLIENT and LocalPlayer() == self.Owner then
        self:EmitSound( "Weapon_SMG1.Reload" )
    else
        local filter = RecipientFilter()
        for k,v in pairs(player.GetHumans()) do
            if v != self.Owner and v:IsGhost() then
                filter:AddPlayer(v)
            end
        end
        net.Start("SpecDM_BulletGhost")
        net.WriteString("Weapon_SMG1.Reload")
        net.WriteVector(self:GetPos())
        net.WriteUInt(45, 19)
        net.Send(filter)
    end
end