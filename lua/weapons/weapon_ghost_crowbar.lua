
if SERVER then
   AddCSLuaFile()
   
end

SWEP.HoldType			= "melee"

if CLIENT then
   SWEP.PrintName			= "crowbar_name"

   SWEP.Slot				= 0

   SWEP.Icon = "vgui/ttt/icon_cbar"   
   SWEP.ViewModelFOV = 54
end

SWEP.UseHands			= true
SWEP.Base				= "weapon_tttbase"
SWEP.ViewModel			= "models/weapons/c_crowbar.mdl"
SWEP.WorldModel			= "models/weapons/w_crowbar.mdl"
SWEP.Weight			= 5
SWEP.DrawCrosshair		= false
SWEP.ViewModelFlip		= false
SWEP.Primary.Damage = 20
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Delay = 0.5
SWEP.Primary.Ammo		= "none"
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo		= "none"
SWEP.Secondary.Delay = 5

SWEP.Kind = WEAPON_MELEE
SWEP.WeaponID = AMMO_CROWBAR

SWEP.NoSights = true
SWEP.IsSilent = true

SWEP.AutoSpawnable = false

SWEP.AllowDelete = false -- never removed for weapon reduction
SWEP.AllowDrop = false

local sound_single = Sound("Weapon_Crowbar.Single")
local sound_open = Sound("DoorHandles.Unlocked3")

if SERVER then
   CreateConVar("ttt_crowbar_unlocks", "1", FCVAR_ARCHIVE)
   CreateConVar("ttt_crowbar_pushforce", "395", FCVAR_NOTIFY)
end

-- only open things that have a name (and are therefore likely to be meant to
-- open) and are the right class. Opening behaviour also differs per class, so
-- return one of the OPEN_ values
local function OpenableEnt(ent)
   local cls = ent:GetClass()
   if ent:GetName() == "" then
      return OPEN_NO
   elseif cls == "prop_door_rotating" then
      return OPEN_ROT
   elseif cls == "func_door" or cls == "func_door_rotating" then
      return OPEN_DOOR
   elseif cls == "func_button" then
      return OPEN_BUT
   elseif cls == "func_movelinear" then
      return OPEN_NOTOGGLE
   else
      return OPEN_NO
   end
end


local function CrowbarCanUnlock(t)
   return not GAMEMODE.crowbar_unlocks or GAMEMODE.crowbar_unlocks[t]
end

-- will open door AND return what it did
function SWEP:OpenEnt(hitEnt)
   -- Get ready for some prototype-quality code, all ye who read this
   if SERVER and GetConVar("ttt_crowbar_unlocks"):GetBool() then
      local openable = OpenableEnt(hitEnt)

      if openable == OPEN_DOOR or openable == OPEN_ROT then
         local unlock = CrowbarCanUnlock(openable)
         if unlock then
            hitEnt:Fire("Unlock", nil, 0)
         end

         if unlock or hitEnt:HasSpawnFlags(256) then
            if openable == OPEN_ROT then
               hitEnt:Fire("OpenAwayFrom", self.Owner, 0)
            end
            hitEnt:Fire("Toggle", nil, 0)
         else
            return OPEN_NO
         end
      elseif openable == OPEN_BUT then
         if CrowbarCanUnlock(openable) then
            hitEnt:Fire("Unlock", nil, 0)
            hitEnt:Fire("Press", nil, 0)
         else
            return OPEN_NO
         end
      elseif openable == OPEN_NOTOGGLE then
         if CrowbarCanUnlock(openable) then
            hitEnt:Fire("Open", nil, 0)
         else
            return OPEN_NO
         end
      end
      return openable
   else
      return OPEN_NO
   end
end

function SWEP:PrimaryAttack()
   self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

   if not IsValid(self.Owner) then return end

   if self.Owner.LagCompensation then -- for some reason not always true
      self.Owner:LagCompensation(true)
   end

   local spos = self.Owner:GetShootPos()
   local sdest = spos + (self.Owner:GetAimVector() * 70)

   local tr_main = util.TraceLine({start=spos, endpos=sdest, filter=self.Owner, mask=MASK_SHOT_HULL})
   local hitEnt = tr_main.Entity

  if CLIENT and LocalPlayer() == self.Owner then
      self.Weapon:EmitSound(sound_single, self.Primary.SoundLevel )
   else
      local tbl = {}
      for k,v in pairs(player.GetAll()) do
         if v != self.Owner and v:IsGhost() then
	        table.insert(tbl, v)
         end
      end
      net.Start("BulletGhost")
      net.WriteString(sound_single)
      net.WriteVector(self:GetPos())
      net.WriteUInt(self.Primary.SoundLevel or 0, 19)
      net.Send(tbl)
   end


   if IsValid(hitEnt) and hitEnt.IsGhost and hitEnt:IsGhost() then
      self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )

      if not (CLIENT and (not IsFirstTimePredicted())) then
         local edata = EffectData()
         edata:SetStart(spos)
         edata:SetOrigin(tr_main.HitPos)
         edata:SetNormal(tr_main.Normal)
         edata:SetSurfaceProp(tr_main.SurfaceProps)
         edata:SetHitBox(tr_main.HitBox)
         --edata:SetDamageType(DMG_CLUB)
         edata:SetEntity(hitEnt)

         if hitEnt:IsPlayer() then

            -- does not work on players rah
            --util.Decal("Blood", tr_main.HitPos + tr_main.HitNormal, tr_main.HitPos - tr_main.HitNormal)

            -- do a bullet just to make blood decals work sanely
            -- need to disable lagcomp because firebullets does its own
            self.Owner:LagCompensation(false)
            self.Owner:FireBullets({Num=1, Src=spos, Dir=self.Owner:GetAimVector(), Spread=Vector(0,0,0), Tracer=0, Force=1, Damage=0})
         else
            util.Effect("Impact", edata)
         end
      end
   else
      self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
   end


   if CLIENT then
      -- used to be some shit here
   else -- SERVER

      -- Do another trace that sees nodraw stuff like func_button
      local tr_all = nil
      tr_all = util.TraceLine({start=spos, endpos=sdest, filter=self.Owner})
      
      self.Owner:SetAnimation( PLAYER_ATTACK1 )

      if hitEnt and hitEnt:IsValid() and hitEnt:IsPlayer() and hitEnt:IsGhost() then

         local dmg = DamageInfo()
         dmg:SetDamage(self.Primary.Damage)
         dmg:SetAttacker(self.Owner)
         dmg:SetInflictor(self.Weapon)
         dmg:SetDamageForce(self.Owner:GetAimVector() * 1500)
         dmg:SetDamagePosition(self.Owner:GetPos())
         dmg:SetDamageType(DMG_CLUB)
		 hitEnt:TakeDamageInfo(dmg)

--         self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )         

--         self.Owner:TraceHullAttack(spos, sdest, Vector(-16,-16,-16), Vector(16,16,16), 30, DMG_CLUB, 11, true)
--         self.Owner:FireBullets({Num=1, Src=spos, Dir=self.Owner:GetAimVector(), Spread=Vector(0,0,0), Tracer=0, Force=1, Damage=20})
      
      else
--         if tr_main.HitWorld then
--            self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
--         else
--            self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
--         end

         -- See if our nodraw trace got the goods
         if tr_all.Entity and tr_all.Entity:IsValid() then
            self:OpenEnt(tr_all.Entity)
         end
      end
   end

   if self.Owner.LagCompensation then
      self.Owner:LagCompensation(false)
   end
end

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:DrawWorldModel()
	if LocalPlayer():IsGhost() then
		self:DrawModel()
	else
		return
	end
end
