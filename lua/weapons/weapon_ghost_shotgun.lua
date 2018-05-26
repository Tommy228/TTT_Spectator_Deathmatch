if SERVER then
	AddCSLuaFile()
else
	SWEP.PrintName = "shotgun_name"
	SWEP.Slot = 2
	SWEP.Icon = "vgui/ttt/icon_shotgun"
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 54
	SWEP.IconLetter = "B"
end

DEFINE_BASECLASS "weapon_ghost_base"

SWEP.HoldType = "shotgun"

SWEP.Base = "weapon_ghost_base"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.Kind = WEAPON_HEAVY
SWEP.WeaponID = AMMO_SHOTGUN

SWEP.Primary.Ammo = "Buckshot"
SWEP.Primary.Damage = 11
SWEP.Primary.Cone = 0.085
SWEP.Primary.Delay = 0.8
SWEP.Primary.ClipSize = 8
SWEP.Primary.ClipMax = 32
SWEP.Primary.DefaultClip = 32
SWEP.Primary.Automatic = true
SWEP.Primary.NumShots = 8
SWEP.AutoSpawnable = false
SWEP.NoAmmoEnt = "item_box_buckshot_ttt"

SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/cstrike/c_shot_xm1014.mdl"
SWEP.WorldModel = "models/weapons/w_shot_xm1014.mdl"
SWEP.Primary.Sound = Sound("Weapon_XM1014.Single")
SWEP.Primary.Recoil = 7

SWEP.IronSightsPos = Vector(-6.881, -9.214, 2.66)
SWEP.IronSightsAng = Vector(-0.101, -0.7, -0.201)

SWEP.reloadtimer = 0

function SWEP:SetupDataTables()
   self:NetworkVar("Bool", 0, "Reloading")
   self:NetworkVar("Float", 0, "ReloadTimer")

   return BaseClass.SetupDataTables(self)
end

function SWEP:Reload()
    if self:GetReloading() then return end
	if self.Weapon:Clip1() < self.Primary.ClipSize and self:GetOwner():GetAmmoCount(self.Primary.Ammo) > 0 then

	    if self:StartReload() then
            return
        end
    end
end

function SWEP:StartReload()
   if self:GetReloading() then
      return false
   end

   self:SetIronsights(false)

   self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

   local ply = self:GetOwner()

   if not ply or ply:GetAmmoCount(self.Primary.Ammo) <= 0 then
      return false
   end

   local wep = self.Weapon

   if wep:Clip1() >= self.Primary.ClipSize then
      return false
   end

   wep:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)

   self:SetReloadTimer(CurTime() + wep:SequenceDuration())
   self:SetReloading(true)

   return true
end

function SWEP:PerformReload()
   local ply = self:GetOwner()

   -- prevent normal shooting in between reloads
   self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

   if not ply or ply:GetAmmoCount(self.Primary.Ammo) <= 0 then return end

   if self:Clip1() >= self.Primary.ClipSize then return end

   self:GetOwner():RemoveAmmo(1, self.Primary.Ammo, false)

   self.Weapon:SetClip1(self.Weapon:Clip1() + 1)

   self:SendWeaponAnim(ACT_VM_RELOAD)

   self:SetReloadTimer(CurTime() + self:SequenceDuration())
end

function SWEP:FinishReload()
   self:SetReloading(false)

   self.Weapon:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
   self:SetReloadTimer(CurTime() + self.Weapon:SequenceDuration())
end

function SWEP:CanPrimaryAttack()
    if self.Weapon:Clip1() <= 0 then
        if CLIENT and LocalPlayer() == self:GetOwner() then
            self:EmitSound("Weapon_Shotgun.Empty")
        else
            local filter = RecipientFilter()

            for _, v in ipairs(player.GetHumans()) do
                if v ~= self:GetOwner() and v:IsGhost() then
                    filter:AddPlayer(v)
                end
            end

            net.Start("SpecDM_BulletGhost")
            net.WriteString("Weapon_Shotgun.Empty")
            net.WriteVector(self:GetPos())
            net.WriteUInt(45, 19)
            net.Send(filter)
        end

        self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

        return false
    end

    return true
end

function SWEP:Think()
   BaseClass.Think(self)

   if self:GetReloading() then
      if self:GetOwner():KeyDown(IN_ATTACK) then
         self:FinishReload()

         return
      end

      if self:GetReloadTimer() <= CurTime() then
         if self:GetOwner():GetAmmoCount(self.Primary.Ammo) <= 0 then
            self:FinishReload()
         elseif self.Weapon:Clip1() < self.Primary.ClipSize then
            self:PerformReload()
         else
            self:FinishReload()
         end

         return
      end
   end
end

function SWEP:Deploy()
   self:SetReloading(false)
   self:SetReloadTimer(0)

   return BaseClass.Deploy(self)
end

-- The shotgun's headshot damage multiplier is based on distance. The closer it
-- is, the more damage it does. This reinforces the shotgun's role as short
-- range weapon by reducing effectiveness at mid-range, where one could score
-- lucky headshots relatively easily due to the spread.
function SWEP:GetHeadshotMultiplier(victim, dmginfo)
   local att = dmginfo:GetAttacker()

   if not IsValid(att) then
      return 3
   end

   local dist = victim:GetPos():Distance(att:GetPos())
   local d = math.max(0, dist - 140)

   -- decay from 3.1 to 1 slowly as distance increases
   return 1 + math.max(0, (2.1 - 0.002 * (d ^ 1.25)))
end

function SWEP:SecondaryAttack()
   if self.NoSights or not self.IronSightsPos or self:GetReloading() then return end

   self:SetIronsights(not self:GetIronsights())

   self:SetNextSecondaryFire(CurTime() + 0.3)
end
