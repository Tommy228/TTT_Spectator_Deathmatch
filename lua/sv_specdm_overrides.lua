
local old_concommandAdd = concommand.Add
concommand.Add = function(command, func, help)
	if command == "ttt_spec_use" or command == "ttt_dropweapon" then
		local old_func = func
		func = function(ply, cmd, arg)
			if IsValid(ply) and ply:IsGhost() then return end
			return old_func(ply, cmd, arg)
		end
	end
	return old_concommandAdd(command, func, help)
end

hook.Add("PlayerTraceAttack", "PlayerTraceAttack_SpecDM", function(ply, dmginfo, dir, trace)
	if ply:IsGhost() then
		local _dmginfo = DamageInfo()
		_dmginfo:SetDamage(dmginfo:GetDamage())
		_dmginfo:SetDamagePosition(dmginfo:GetDamagePosition())
		if IsValid(dmginfo:GetAttacker()) then 
			_dmginfo:SetAttacker(dmginfo:GetAttacker()) 
		end
		if IsValid(dmginfo:GetInflictor()) then 
			_dmginfo:SetInflictor(dmginfo:GetInflictor()) 
		end
		ply.was_headshot = false
		local hs = trace.HitGroup == HITGROUP_HEAD
		if hs then
			ply.was_headshot = true
			local wep = util.WeaponFromDamage(_dmginfo)
			if IsValid(wep) then
				local s = wep:GetHeadshotMultiplier(ply, _dmginfo) or 2
				if s < 1 then s = 1 end
				if hit then s = s-0.2 end
				_dmginfo:ScaleDamage(s)
			end
		else 
			_dmginfo:ScaleDamage(0.55)
		end
		if not hit or hs then 
			ply:TakeDamageInfo(_dmginfo) 
		end
		return true
	end
end)

hook.Add("PlayerSpawn", "PlayerSpawn_SpecDM", function(ply)
	if ply:IsGhost() then
		ply.has_spawned = true
		ply:UnSpectate()
		hook.Call("PlayerSetModel", GAMEMODE, ply)
		return
	else
		ply:SetBloodColor(0)
	end	
end)

hook.Add("PlayerDeath", "PlayerDeath_SpecDM", function(victim, inflictor, attacker)
	if victim:IsGhost() then
		victim.spawning_ghost = true
		timer.Simple(SpecDM.RespawnTime, function()
			if IsValid(victim) then
				victim.spawning_ghost = false
				if victim:IsGhost() then
					victim:UnSpectate()
					victim:Spawn()
					victim:SetBloodColor(-1)
					victim:GiveGhostWeapons()
					SpecDM:RelationShip(victim)
				end
			end
			if SpecDM.GivePointshopPoints and IsValid(attacker) and attacker:IsPlayer() and attacker:IsGhost() and attacker != victim then
				attacker:PS_GivePoints(SpecDM.PointshopPoints )
			end
		end)
		return
	elseif GetRoundState() == ROUND_ACTIVE and victim:IsActive() then
		timer.Simple(1, function()
			net.Start("SpecDM_Autoswitch")
			net.Send(victim)
		end)
	end
end)

-- too many damn scripts override this function on Initialize
-- so I had the idea of putting this here
hook.Add("TTTBeginRound", "TTTBeginRound_Ghost", function()
	local old_haste = HasteMode
	local old_PlayerDeath = GAMEMODE.PlayerDeath
	function GAMEMODE:PlayerDeath(ply, infl, attacker)
		if ply:IsGhost() then
			HasteMode = function()
				return false
			end
		elseif GetRoundState() == ROUND_ACTIVE then
			if IsValid(attacker) and attacker:IsPlayer() then
				Damagelog_New(Format("KILL:\t %s [%s] killed %s [%s]", attacker:Nick(), attacker:GetRoleString(), ply:Nick(), ply:GetRoleString()))
			else
				Damagelog_New(Format("KILL:\t <something/world> killed %s [%s]", ply:Nick(), ply:GetRoleString()))
			end
		end
		old_PlayerDeath(self, ply, infl, attacker)
		HasteMode = old_haste
	end
	hook.Remove("TTTBeginRound", "TTTBeginRound_Ghost")
end)

hook.Add("Initialize", "Initialize_SpecDM", function()

	local old_KeyPress = GAMEMODE.KeyPress
	function GAMEMODE:KeyPress(ply, key)
		if IsValid(ply) and ply:IsGhost() then return end
		return old_KeyPress(self, ply, key)
	end
	
	local old_SpectatorThink = GAMEMODE.SpectatorThink
	function GAMEMODE:SpectatorThink(ply)
		if IsValid(ply) and ply:IsGhost() then return true end
		old_SpectatorThink(self, ply)		
	end
		
	local old_PlayerCanPickupWeapon = GAMEMODE.PlayerCanPickupWeapon
	function GAMEMODE:PlayerCanPickupWeapon(ply, wep)
		if not IsValid(ply) or not IsValid(wep) then return end
		if ply:IsGhost() then 
			return string.Left(wep:GetClass(), #"weapon_ghost") == "weapon_ghost"
		end
		return old_PlayerCanPickupWeapon(self, ply, wep)
	end
	
	local meta = FindMetaTable("Player")

	local old_SpawnForRound = meta.SpawnForRound
	function meta:SpawnForRound(dead_only)
		if self:IsGhost() then
			self:SetGhost(false)
		end
		return old_SpawnForRound(self, dead_only)
	end
	
	local old_ResetRoundFlags = meta.ResetRoundFlags
	function meta:ResetRoundFlags()
		if self:IsGhost() then return end
		old_ResetRoundFlags(self)
	end
	
	local old_spectate = meta.Spectate
	function meta:Spectate(mode)
		if self:IsGhost() then return end
		return old_spectate(self, mode)
	end
	
	local old_ShouldSpawn = meta.ShouldSpawn
	function meta:ShouldSpawn()
		if self:IsGhost() then return true end
		return old_ShouldSpawn(self)
	end
	
	local old_GiveLoadout = GAMEMODE.PlayerLoadout
	function GAMEMODE:PlayerLoadout(ply)
		if ply:IsGhost() then return end
		old_GiveLoadout(self, ply)
	end
	
	local old_KarmaHurt = KARMA.Hurt
	function KARMA.Hurt(attacker, victim, dmginfo)
		if (IsValid(attacker) and attacker:IsGhost()) or (IsValid(victim) and victim:IsGhost()) then return end
		return old_KarmaHurt(attacker, victim, dmginfo)
	end
	
	for k,v in pairs(scripted_ents.GetList()) do
		if v.ClassName == "base_ammo_ttt" then
			local old_PlayerCanPickup = v.PlayerCanPickup
			v.PlayerCanPickup = function(self, ply)
				if ply:IsGhost() then return false end
				return old_PlayerCanPickup(self, ply)
			end
		end
	end
		
	hook.Add("EntityTakeDamage", "EntityTakeDamage_Ghost", function(ent, dmginfo)
		if ent:IsPlayer() then
			local attacker = dmginfo:GetAttacker()
			if IsValid(attacker) and attacker:IsPlayer() then
				if (attacker:IsGhost() and not ent:IsGhost()) or (not attacker:IsGhost() and ent:IsGhost()) then
					dmginfo:ScaleDamage(0)
				elseif not attacker:IsGhost() and math.floor(dmginfo:GetDamage()) > 0 and GetRoundState() == ROUND_ACTIVE then
					Damagelog_New(Format("DMG: \t %s [%s] damaged %s [%s] for %d dmg", attacker:Nick(), attacker:GetRoleString(), ent:Nick(), ent:GetRoleString(), math.Round(dmginfo:GetDamage())))
				end
			end
		end
	end)
	
	local old_Damagelog = DamageLog
	function Damagelog_New(str)
		return old_Damagelog(str)
	end
	function DamageLog(str)
		if string.Left(str, 4) != "KILL" and string.Left(str, 3) != "DMG" then
			Damagelog_New(str)
		end
	end
	
	local old_BeginRound = BeginRound
	function BeginRound()
		old_BeginRound()
		for k,v in pairs(player.GetAll()) do
			if v:Alive() and not v:IsGhost() then
				v:SetNWBool("PlayedSRound", true)
			else
				v:SetNWBool("PlayedSRound", false)
			end
		end
	end
	
end)