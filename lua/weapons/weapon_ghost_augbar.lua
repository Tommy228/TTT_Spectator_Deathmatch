if SERVER then
	AddCSLuaFile()
    
	if SpecDM.LoadoutEnabled then
		resource.AddFile("materials/vgui/spec_dm/icon_sdm_aug.vmt")
	end
else
	SWEP.PrintName = "AUG"
	SWEP.Slot = 2

	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60
	SWEP.Icon = "vgui/spec_dm/icon_sdm_aug"
	SWEP.IconLetter = "e"
end

SWEP.Base = "weapon_ghost_base"

SWEP.HoldType = "crossbow"
SWEP.AutoSpawnable = false
SWEP.AdminSpawnable = true

SWEP.Kind = WEAPON_HEAVY
SWEP.WeaponID = AMMO_AUGBAR

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Primary.Sound = Sound("Weapon_AUG.Single")
SWEP.Primary.Recoil = 3
SWEP.Primary.Damage = 12
SWEP.Primary.Delay = 0.11
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.02
SWEP.Primary.ClipSize = 50
SWEP.Primary.DefaultClip = 200
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "AirboatGun"
SWEP.HeadshotMultiplier = 2.5

SWEP.Secondary.Automatic = false
SWEP.UseHands = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Sound = Sound("Default.Zoom")

SWEP.ScopeZooms = {1}
SWEP.ViewModel = Model("models/weapons/cstrike/c_rif_aug.mdl")
SWEP.WorldModel = Model("models/weapons/w_rif_aug.mdl")

SWEP.IronSightsPos = Vector(5, -15, -2)
SWEP.IronSightsAng = Vector(2.6, 1.37, 3.5)
SWEP.IronSightZoom = 1

function SWEP:SetZoom(state)
    if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
        if state then
            self:GetOwner():SetFOV(20, 0.3)
        else
            self:GetOwner():SetFOV(0, 0.2)
        end
	end
end

-- Add some zoom to ironsights for this gun
function SWEP:SecondaryAttack()
    if not self.IronSightsPos then return end
    
    if self.Weapon:GetNextSecondaryFire() > CurTime() then return end

    local bIronsights = not self:GetIronsights()

    self:SetIronsights(bIronsights)
    self:SetZoom(bIronsights)
    
	if CLIENT then
		self:EmitSound(self.Secondary.Sound)
	end

    self.Weapon:SetNextSecondaryFire(CurTime() + 0.3)
end

function SWEP:PreDrop()
    self:SetZoom(false)
    self:SetIronsights(false)
    
    return self.BaseClass.PreDrop(self)
end

function SWEP:Reload()
	if self:Clip1() == self.Primary.ClipSize or self:GetOwner():GetAmmoCount(self.Primary.Ammo) <= 0 then return end
    
    self.Weapon:DefaultReload(ACT_VM_RELOAD)
    
    self:SetIronsights(false)
    self:SetZoom(false)
end

function SWEP:Holster()
    self:SetIronsights(false)
    self:SetZoom(false)
    
    return true
end

if CLIENT then
   local scope = surface.GetTextureID("sprites/scope")
   
   function SWEP:DrawHUD()
      if self:GetIronsights() then
         surface.SetDrawColor(0, 0, 0, 255)
         
         local scrW = ScrW()
         local scrH = ScrH()

         local x = scrW / 2.0
         local y = scrH / 2.0
         local scope_size = scrH

         -- crosshair
         local gap = 80
         local length = scope_size
         
         surface.DrawLine(x - length, y, x - gap, y)
         surface.DrawLine(x + length, y, x + gap, y)
         surface.DrawLine(x, y - length, x, y - gap)
         surface.DrawLine(x, y + length, x, y + gap)

         gap = 0
         length = 50
         
         surface.DrawLine(x - length, y, x - gap, y)
         surface.DrawLine(x + length, y, x + gap, y)
         surface.DrawLine(x, y - length, x, y - gap)
         surface.DrawLine(x, y + length, x, y + gap)


         -- cover edges
         local sh = scope_size / 2
         local w = (x - sh) + 2
         
         surface.DrawRect(0, 0, w, scope_size)
         surface.DrawRect(x + sh - 2, 0, w, scope_size)
         
         -- cover gaps on top and bottom of screen
         surface.DrawLine(0, 0, scrW, 0)
         surface.DrawLine(0, scrH - 1, scrW, scrH - 1)

         surface.SetDrawColor(255, 0, 0, 255)
         surface.DrawLine(x, y, x + 1, y + 1)

         -- scope
         surface.SetTexture(scope)
         surface.SetDrawColor(255, 255, 255, 255)

         surface.DrawTexturedRectRotated(x, y, scope_size, scope_size, 0)
      else
         return self.BaseClass.DrawHUD(self)
      end
   end

   function SWEP:AdjustMouseSensitivity()
      return (self:GetIronsights() and 0.2) or nil
   end
end
