include("specdm_config.lua")
include("specdm_von.lua")

if SpecDM.AutoIncludeWeapons then
	table.Empty(SpecDM.Ghost_weapons.primary)
	table.Empty(SpecDM.Ghost_weapons.secondary)
	table.Empty(SpecDM.Loadout_Icons)
	hook.Add("Initialize", "SharedInitialize_Ghost", function()
		for _, w in pairs(weapons.GetList()) do
			if w and w.Kind and w.Base == "weapon_ghost_base" and (w.Kind == WEAPON_HEAVY or w.Kind == WEAPON_PISTOL) then
				if w.Kind == WEAPON_HEAVY then
					table.insert(SpecDM.Ghost_weapons.primary, w.ClassName)
				else
					table.insert(SpecDM.Ghost_weapons.secondary, w.ClassName)
				end
				if w.Icon then
					SpecDM.Loadout_Icons[w.ClassName] = w.Icon
				end
			end
		end
	end)
end

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
		for k,v in ipairs(player.GetAll()) do
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
