include("specdm_config.lua")
include("specdm_von.lua")

local meta = FindMetaTable("Player")

function meta:IsGhost()
	return self:GetNWBool("SpecDM_Enabled", false)
end

hook.Add("PlayerFootstep", "PlayerFootstep_Ghost", function(ply, pos, foot, sound, volume, rf)
	if ply:IsGhost() then
		return true
	end
end)

hook.Add("OnEntityCreated", "OnEntityCreated_Ghost", function(ent)
	if ent:IsPlayer() then
		ent:SetCustomCollisionCheck(true)
	end
	if SERVER and ent:IsNPC() then
		for k,v in pairs(player.GetAll()) do
			if v:IsGhost() then
				ent:AddEntityRelationship(v, D_NU, 99)
			end
		end
	end
end)

hook.Add("ShouldCollide", "ShouldCollide_Ghost", function(ent1, ent2)
	if IsValid(ent1) and IsValid(ent2) then
		if ent1:IsPlayer() and (ent1.IsGhost and ent1:IsGhost()) and not (ent2:IsPlayer() and (ent2.IsGhost and ent2:IsGhost())) then
			return false
		end
		if ent2:IsPlayer() and (ent2.IsGhost and ent2:IsGhost()) and not (ent1:IsPlayer() and (ent1.IsGhost and ent1:IsGhost())) then
			return false
		end
	end
end)

local function WeaponCleanup(wep)
	-- The following things have to be handled by the weapon base.

	wep.PrimaryAttack      = nil
	wep.SecondaryAttack    = nil
	wep.ShootBullet        = nil
	wep.ShootEffects       = nil
	wep.DoImpactEffect     = nil
	wep.FireAnimationEvent = nil
	wep.DrawWorldModel     = nil

	wep.AutoSpawnable      = nil
	wep.AllowDrop          = nil
	wep.IsSilent           = nil
	wep.InLoadoutFor       = nil
	wep.CanBuy             = nil
	wep.fingerprints       = nil
	wep.AmmoEnt            = nil
end

local function GenerateSpecDMWeapons(weptable)
	for k,v in pairs(weptable) do
		if v.Base ~= "weapon_ghost_base" and v.Kind and (v.Kind == WEAPON_HEAVY or v.Kind == WEAPON_PISTOL) and not v.CanBuy then
			local classname = v.ClassName
			local wep = table.Copy(weapons.GetStored(classname))

			wep.Base = "weapon_ghost_base"

			-- Splitting cleanup in another function so the code is a bit more cleaner.
			WeaponCleanup(wep)

			local name = "weapon_ghost" .. classname
			if classname:sub(1, #"weapon_ttt_") == "weapon_ttt_" then
				name = "weapon_ghost_" .. classname:sub(#"weapon_ttt_", #classname)
			elseif classname:sub(1, #"weapon_") == "weapon_" then
				name = "weapon_ghost_" .. classname:sub(#"weapon_", #classname)
			end

			weapons.Register(wep, name)
		end
	end
end

if SpecDM.AutoIncludeWeapons then
	hook.Add("Initialize", "SharedInitialize_Ghost", function()
		table.Empty(SpecDM.Ghost_weapons.primary)
		table.Empty(SpecDM.Ghost_weapons.secondary)

		local weptable = weapons.GetList()

		if SpecDM.AutoGenerateWeapons then
			GenerateSpecDMWeapons(weptable)
			weptable = weapons.GetList()
		end

		for _, w in pairs(weptable) do
			if w and w.Kind and w.Base == "weapon_ghost_base" then
				if w.Kind == WEAPON_HEAVY then
					table.insert(SpecDM.Ghost_weapons.primary, w.ClassName)
				elseif w.Kind == WEAPON_PISTOL then
					table.insert(SpecDM.Ghost_weapons.secondary, w.ClassName)
				end
			end
		end
	end)
end
