
include("specdm_config.lua")
include("includes/von.lua")

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
	if ent1:IsPlayer() and (ent1.IsGhost and ent1:IsGhost()) and not (ent2:IsPlayer() and (ent2.IsGhost and ent2:IsGhost())) then
		return false
	end
	if ent2:IsPlayer() and (ent2.IsGhost and ent2:IsGhost()) and not (ent1:IsPlayer() and (ent1.IsGhost and ent1:IsGhost())) then
		return false
	end
end)
