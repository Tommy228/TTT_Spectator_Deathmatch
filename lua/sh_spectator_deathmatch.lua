include("specdm_config.lua")
include("specdm_von.lua")

if SpecDM.AutoIncludeWeapons then
	local files, _ = file.Find("weapons/weapon_ghost_*.lua", "LUA")
	if (files) then
		table.Empty(SpecDM.Ghost_weapons.primary)
		table.Empty(SpecDM.Ghost_weapons.secondary)
		for _, filename in ipairs(files) do
			local str = file.Read("weapons/"..filename, "LUA")
			if (!str) then return end
			if (string.find(str, "%sSWEP.Kind%s=%sWEAPON_HEAVY")) then -- Use SWEP.Kind = WEAPON_HEAVY as indentification
				AddCSLuaFile("weapons/"..filename)
				table.insert(SpecDM.Ghost_weapons.primary, string.sub(filename, 0, -5))
			elseif (string.find(str, "%sSWEP.Kind%s=%sWEAPON_PISTOL") or string.find(str, "%sSWEP.HoldType%s=%s\"pistol\"")) then -- Use HoldType = "pistol" as second indentification since WEAPON_PISTOL isn't fully working
				AddCSLuaFile("weapons/"..filename)
				table.insert(SpecDM.Ghost_weapons.secondary, string.sub(filename, 0, -5))
			end
		end
	end
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
