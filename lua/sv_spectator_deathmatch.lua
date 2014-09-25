
AddCSLuaFile("autorun/client/ttt_spec_dm_autorun.lua")
AddCSLuaFile("cl_spectator_deathmatch.lua")
AddCSLuaFile("sh_spectator_deathmatch.lua")
AddCSLuaFile("specdm_config.lua")
AddCSLuaFile("cl_specdm_hud.lua")
AddCSLuaFile("vgui/spec_dm_loadout.lua")
AddCSLuaFile("cl_stats.lua")
AddCSLuaFile("includes/von.lua")
AddCSLuaFile("cl_quakesounds.lua")

include("sh_spectator_deathmatch.lua")
include("sv_specdm_overrides.lua")
include("sv_resources.lua")
include("sv_stats.lua")
include("sv_quakesounds.lua")

util.AddNetworkString("SpecDM_Error")
util.AddNetworkString("SpecDM_Ghost")
util.AddNetworkString("SpecDM_Autoswitch")
util.AddNetworkString("SpecDM_SendLoadout")
util.AddNetworkString("SpecDM_GhostJoin")
util.AddNetworkString("BulletGhost")
util.AddNetworkString("SpecDM_AskStats")
util.AddNetworkString("SpecDM_SendStats")
util.AddNetworkString("SpecDM_OpenStats")
util.AddNetworkString("SpecDM_AskOpenStats")
util.AddNetworkString("SpecDM_QuakeSound")
util.AddNetworkString("SpecDM_Hitmarker")
util.AddNetworkString("SpecDM_CreateRagdoll")

hook.Add("PlayerSay", "PlayerSay_SpecDM", function(ply, text, public)
	if table.HasValue(SpecDM.Commands, string.lower(text)) then
		ply:WantsToDM()
		return ""
	end
end)

local meta = FindMetaTable("Player")

function meta:SpecDM_Error(error_str)
	net.Start("SpecDM_Error")
	net.WriteString(error_str)
	net.Send(self)
end

function meta:SetGhost(bool)
	self:SetNWBool("SpecDM_Enabled", bool)
end

function SpecDM:RelationShip(victim)
	for k,v in pairs(ents.FindByClass("npc_*")) do
		if v.AddEntityRelationship then
			v:AddEntityRelationship(v, D_NU, 99)
		end
	end
end

function meta:GiveGhostWeapons()
	if not SpecDM.LoadoutEnabled or not self.ghost_primary or self.ghost_primary == "random" then
		self:Give(table.Random(SpecDM.Ghost_weapons.primary))
	else
		self:Give(self.ghost_primary)
	end
	if not SpecDM.LoadoutEnabled or not self.ghost_secondary or self.ghost_secondary == "random" then
		self:Give(table.Random(SpecDM.Ghost_weapons.secondary))
	else
		self:Give(self.ghost_secondary)
	end
	self:Give("weapon_ghost_crowbar")
end

function meta:ManageGhost(spawn)
	self:SetGhost(spawn)
	if spawn then
		self:Spawn()
		self:SetBloodColor(-1)
		self:GiveGhostWeapons()
		SpecDM:RelationShip(self)
	else
		self:Kill()
		self:Spectate(OBS_MODE_ROAMING)
	end
	net.Start("SpecDM_Ghost")
	net.WriteUInt(spawn and 1 or 0, 1)
	net.Send(self)
	local tbl = player.GetHumans()
	for k,v in pairs(tbl) do
		if v == self then
			table.remove(tbl, k)
			break
		end
	end
	net.Start("SpecDM_GhostJoin")
	net.WriteUInt(spawn and 1 or 0, 1)
	net.WriteEntity(self)
	net.Send(tbl)
end

function meta:WantsToDM()
	local allowed = true
	if SpecDM.RestrictCommand then
		allowed = false
		for k,v in pairs(SpecDM.AllowedGroups) do
			if self:IsUserGroup(v) then
				allowed = true
				break
			end
		end
	end
	if allowed then
		if self:IsActive() then
			self:SpecDM_Error("You can't enter spectator deathmatch when you're alive.")
		elseif GetRoundState() != ROUND_ACTIVE then
			self:SpecDM_Error("Error : round inactive.")
		elseif not self.spawning_ghost then
			if tonumber(self.DMTimer) and self.DMTimer > 0 then
				self:SpecDM_Error("Wait "..tostring(self.DMTimer).." second(s) before using this command again!")
			else
				local self = self
				self:ManageGhost(not self:IsGhost())
				self.DMTimer = 10
				local timername = "SpecDM_Timer_"..tostring(self:UniqueID())
				timer.Create(timername, 1, 0, function()
					if not IsValid(self) then
						timer.Destroy(timername)
					else
						self.DMTimer = self.DMTimer - 1
						if self.DMTimer <= 0 then
							timer.Destroy(timername)
						end
					end
				end)
			end
		end
	else
		self:SpecDM_Error("Error : you are not allowed to enter Spectator Deathmatch")
	end
end

hook.Add("TTTEndRound", "TTTEndRound_Ghost", function()
	for k,v in pairs(player.GetAll()) do
		if v:IsGhost() then
			v:ManageGhost(false)
		end
	end
end)

net.Receive("SpecDM_SendLoadout", function(_, ply)
	local primary = net.ReadString()
	local secondary = net.ReadString()
	if not primary or not secondary then return end
	if primary != "random" and string.Left(primary, #"weapon_ghost") != "weapon_ghost" then return end
	if secondary != "random" and string.Left(secondary, #"weapon_ghost") != "weapon_ghost" then return end
	local list = weapons.GetList()
	for k,v in pairs(list) do
		if v.ClassName == primary and v.Kind == WEAPON_HEAVY then
			ply.ghost_primary = primary
		elseif v.ClassName == secondary and v.Kind == WEAPON_PISTOL then
			ply.ghost_secondary = secondary
		end
	end
end)

hook.Add("Tick", "Tick_Ghost", function()
	for k,v in pairs(player.GetAll()) do
		if v:IsGhost() then
			v:Extinguish()
			local wep = v:GetActiveWeapon()
			if IsValid(wep) and wep.GetIronsights and wep:GetIronsights() then
				v:SetSpeed(true)
			else
				v:SetSpeed(false)
			end
		end
	end
end)

hook.Add("EntityTakeDamage", "EntityTakeDamage_SpecDMHitmarker", function(ent, dmginfo)
	if ent:IsPlayer() and ent:IsGhost() then
		local att = dmginfo:GetAttacker()
		if IsValid(att) and att:IsPlayer() and att:IsGhost() then
			net.Start("SpecDM_Hitmarker")
			net.Send(att)
		end
	end
end)

hook.Add("DoPlayerDeath", "DoPlayerDeath_SpecDMRagdoll", function(ply)
	if ply:IsGhost() then
		ply:CreateRagdoll()
	end
end)

if SpecDM.HP_Regen then
	timer.Create("SpecDM_HPRegen", 1, 0, function()
		if GetRoundState() == ROUND_ACTIVE then
			for k,v in pairs(player.GetHumans()) do
				if v:IsGhost() and v:Health() < 100 then
					v:SetHealth(v:Health() + 1)
				end
			end
		end
	end)
end