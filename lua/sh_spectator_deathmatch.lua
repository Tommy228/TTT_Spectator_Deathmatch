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

local function GenerateSpecDMWeapons(weptable)
	for k,v in pairs(weptable) do
		if v.Kind and (v.Kind == WEAPON_HEAVY or v.Kind == WEAPON_PISTOL) and not v.CanBuy then
			local wep = table.Copy(weapons.GetStored(k))
			wep.Base = "weapon_ghost_base"
			for k,v in pairs(wep) do
				if isfunction(v) then
					wep[k] = nil	
				end
			end
			local name = "weapon_ghost" .. k
			if k:sub(1, #"weapon_ttt_") == "weapon_ttt_" then
				name = "weapon_ghost_" .. k:sub(#"weapon_ttt_", #k)
			elseif k:sub(1, #"weapon_") == "weapon_" then
				name = "weapon_ghost_" .. k:sub(#"weapon_", #k)
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
