
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
		_dmginfo:SetReportedPosition(dmginfo:GetReportedPosition())
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
		timer.Simple(0.1, function() if IsValid(ply) and ply:IsGhost() and ply:GetWeapons() == nil then ply:GiveGhostWeapons() end end)
		hook.Call("PlayerSetModel", GAMEMODE, ply)
		return
	else
		ply:SetBloodColor(0)
	end
end)

local function SpecDM_Respawn(ply)
	ply:SetNWFloat("SpecDM_RespawnedIn", -2)
	ply:SetNWFloat("SpecDM_AbleToRespawnIn", -2)
	if ply:IsGhost() then
		ply:UnSpectate()
		ply:Spawn()
		ply:GiveGhostWeapons()
		SpecDM:RelationShip(ply)
	end
end

hook.Add("PlayerDeath", "PlayerDeath_SpecDM", function(victim, inflictor, attacker)
	if victim:IsGhost() then
		if SpecDM.GivePointshopPoints and IsValid(attacker) and attacker:IsPlayer() and attacker:IsGhost() and attacker != victim then
			attacker:PS_GivePoints(SpecDM.PointshopPoints)
		end
		if SpecDM.RespawnTime == 0 then
			timer.Simple(1, function()
				SpecDM_Respawn(victim)
			end)
			return false
		end
		victim:SetNWFloat("SpecDM_AbleToRespawnIn", CurTime() + SpecDM.RespawnTime)
		timer.Simple(SpecDM.RespawnTime, function()
			if IsValid(victim) and !victim:Alive() and SpecDM.AutomaticRespawnTime ~= 0 then
				victim:SetNWFloat("SpecDM_RespawnedIn", CurTime() + SpecDM.AutomaticRespawnTime)
			end
		end)
		if SpecDM.AutomaticRespawnTime > -1 then
			timer.Simple(SpecDM.AutomaticRespawnTime + SpecDM.RespawnTime, function()
				if IsValid(victim) and !victim:Alive() then
					SpecDM_Respawn(victim)
				end
			end)
		end
		return false
	elseif GetRoundState() == ROUND_ACTIVE and victim:IsActive() then
		timer.Simple(2, function()
			if IsValid(victim) then
				net.Start("SpecDM_Autoswitch")
				net.Send(victim)
			end
		end)
	end
end)

-- too many damn scripts override this function on Initialize
-- so I had the idea of putting this here (Some scripts override this, too...)
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
		if IsValid(ply) and ply:IsGhost() then
			if !ply:Alive() and ply:GetNWFloat("SpecDM_RespawnedIn", -2) ~= -2 then
				SpecDM_Respawn(ply)
			end
			return
		end
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

			if ent:IsGhost() and dmginfo:GetInflictor():GetClass() == "trigger_hurt" then
				return true
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
end)

local fallsounds = {
   Sound("player/damage1.wav"),
   Sound("player/damage2.wav"),
   Sound("player/damage3.wav")
};

hook.Add("OnPlayerHitGround", "HitGround_SpecDM", function(ply, in_water, on_floater, speed)
	if IsValid(ply) and ply:IsPlayer() and ply:IsGhost() then
		if in_water or speed < 450 or not IsValid(ply) then return true end

		-- Everything over a threshold hurts you, rising exponentially with speed
		local damage = math.pow(0.05 * (speed - 420), 1.75)

		-- I don't know exactly when on_floater is true, but it's probably when
		-- landing on something that is in water.
		if on_floater then damage = damage / 2 end

		-- if we fell on a dude, that hurts (him)
		local ground = ply:GetGroundEntity()
		if IsValid(ground) and ground:IsPlayer() then
			if math.floor(damage) > 0 then
				local att = ply

				-- if the faller was pushed, that person should get attrib
				local push = ply.was_pushed
				if push then
					-- TODO: move push time checking stuff into fn?
					if math.max(push.t or 0, push.hurt or 0) > CurTime() - 4 then
						att = push.att
					end
				end

				local dmg = DamageInfo()

				if att == ply then
					-- hijack physgun damage as a marker of this type of kill
					dmg:SetDamageType(DMG_CRUSH + DMG_PHYSGUN)
				else
					-- if attributing to pusher, show more generic crush msg for now
					dmg:SetDamageType(DMG_CRUSH)
				end

				dmg:SetAttacker(att)
				dmg:SetInflictor(att)
				dmg:SetDamageForce(Vector(0,0,-1))
				dmg:SetDamage(damage)

				ground:TakeDamageInfo(dmg)
			end

			-- our own falling damage is cushioned
			damage = damage / 3
		end

		if math.floor(damage) > 0 then
			local dmg = DamageInfo()
			dmg:SetDamageType(DMG_FALL)
			dmg:SetAttacker(game.GetWorld())
			dmg:SetInflictor(game.GetWorld())
			dmg:SetDamageForce(Vector(0,0,1))
			dmg:SetDamage(damage)

			ply:TakeDamageInfo(dmg)

			-- play CS:S fall sound if we got somewhat significant damage
			if damage > 5 then
				local filter = RecipientFilter()
				for k,v in pairs(player.GetHumans()) do -- bots don't need to hear the sound
					if v:IsGhost() then
						filter:AddPlayer(v)
					end
				end
				net.Start("SpecDM_BulletGhost")
				net.WriteString(fallsounds[math.random(1, 3)])
				net.WriteVector(ply:GetShootPos())
				net.WriteUInt(55 + math.Clamp(damage, 0, 50), 19)
				net.Send(filter)
			end
		end
		return true
	end
end)

hook.Add("TTTBeginRound", "BeginRound_SpecDM", function()
	for k,v in ipairs(player.GetAll()) do
		if v:IsTerror() then
			v:SetNWBool("PlayedSRound", true)
		else
			v:SetNWBool("PlayedSRound", false)
		end
	end
end)

hook.Add("AcceptInput", "AcceptInput_Ghost", function(ent, name, activator, caller, data)
	if IsValid(caller) and caller:GetClass() == "ttt_logic_role" then
		if IsValid(activator) and activator:IsPlayer() and activator:IsGhost() then
			return true
		end
	end
end)

hook.Add("EntityEmitSound", "EntityEmitSound_SpecDM", function(t)
	if t.Entity and t.Entity:IsPlayer() and t.Entity:IsGhost() and t.OriginalSoundName == "HL2Player.BurnPain" then
		return false
	else
		return
	end
end)

local function BlockFlashlight(ply, state)
	if ply:IsGhost() then
		return false
	else
		return true
	end
end
