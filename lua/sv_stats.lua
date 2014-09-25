
local function encode_weapons(tbl)
	local to_implode = {}
	for k,v in pairs(tbl) do
		table.insert(to_implode, k.."="..v)
	end
	return string.Implode(",", to_implode)
end

local function decode_weapons(str)
	local exploded = string.Explode(",", str)
	local tbl = {}
	for k,v in pairs(exploded) do
		local temp = string.Explode("=", v)
		tbl[temp[1]] = temp[2]
	end
	return tbl
end

if not sql.TableExists("specdm_stats") then
	sql.Query("DROP TABLE specdm_stats")
end
if not sql.TableExists("specdm_stats_new") then
	sql.Query("CREATE TABLE specdm_stats_new (steamid varchar(255), name varchar(255), time_dm int, time_playing int, kills int, deaths int, kill_row int, weapons longtext )")
end

hook.Add("PlayerAuthed", "PlayerAuthed_SpecDMStats", function(ply, steamid, uniqueid)
	local player_exists = sql.QueryValue("SELECT steamid FROM specdm_stats_new WHERE steamid = '"..steamid.."'")
	if player_exists == steamid then
		ply.specdm_stats_new = sql.QueryRow("SELECT time_dm, time_playing, kills, deaths, kill_row FROM specdm_stats_new WHERE steamid = '"..steamid.."'")
		ply.specdm_wepstats = decode_weapons(sql.QueryValue("SELECT weapons FROM specdm_stats_new WHERE steamid = '"..steamid.."'"))
		local name = sql.QueryValue("SELECT name FROM specdm_stats_new WHERE steamid = '"..steamid.."'")
		if name != ply:Nick() then
			sql.Query("UPDATE specdm_stats_new SET name = "..sql.SQLStr(ply:Nick()).." WHERE steamid = '"..steamid.."'")
		end
	else
		local query = "INSERT INTO specdm_stats_new(`steamid`,`name`,`time_dm`,`time_playing`,`kills`,`deaths`,`kill_row`,`weapons`) "
		query = query..string.format("VALUES ('%s', %s, 0, 0, 0, 0, 0, '')", steamid, sql.SQLStr(ply:Nick()))
		local a = sql.Query(query)
		ply.specdm_stats_new = {
			time_dm = 0,
			time_playing = 0,
			kills = 0,
			deaths = 0,
			kill_row = 0
		}
		ply.specdm_wepstats = {}
	end
end)

local meta = FindMetaTable("Player")

function meta:SpecDM_EnableUpdate(str)
	if not self.specdm_stats_newupdates then
		self.specdm_stats_newupdates = {}
	end
	if not self.specdm_stats_newupdates[str] then
		self.specdm_stats_newupdates[str] = true
	end
end

function meta:SpecDM_CheckKillRows()
	if tonumber(self.specdm_killrows) and self.specdm_stats_new and tonumber(self.specdm_stats_new.kill_row) and self.specdm_killrows > tonumber(self.specdm_stats_new.kill_row) then
		self.specdm_stats_new.kill_row = self.specdm_killrows
		self:SpecDM_EnableUpdate("kill_row")
	end
end

timer.Create("SpecDM_Time", 1, 0, function()
	if GetRoundState() == ROUND_ACTIVE then
		for k,v in pairs(player.GetHumans()) do
			if not v.specdm_stats_new then continue end
			if v:IsGhost() and v.specdm_stats_new.time_dm then
				v.specdm_stats_new.time_dm = v.specdm_stats_new.time_dm + 1
				v:SpecDM_EnableUpdate("time_dm")
			elseif v:IsActive() and v.specdm_stats_new.time_playing then
				v.specdm_stats_new.time_playing = v.specdm_stats_new.time_playing + 1	
				v:SpecDM_EnableUpdate("time_playing")				
			end
		end
	end
end)

hook.Add("PlayerDeath", "PlayerDeath_SpecDMStats", function(ply, killer, inflictor)
	if not ply:IsBot() then 
		ply:SpecDM_CheckKillRows() 
	end
	if ply.specdm_killrows then
		ply.specdm_killrows = 0
	end
	if GetRoundState() == ROUND_ACTIVE and IsValid(killer) and killer:IsPlayer()  then
		if ply:IsGhost() and not (ply == killer) then
			killer.specdm_killrows = (killer.specdm_killrows and killer.specdm_killrows or 0) + 1
			if killer.specdm_stats_new and killer.specdm_stats_new.kills then
				killer.specdm_stats_new.kills = killer.specdm_stats_new.kills + 1
				killer:SpecDM_EnableUpdate("kills")
			end
			if ply.specdm_stats_new then
				if ply.specdm_stats_new.deaths then
					ply.specdm_stats_new.deaths = ply.specdm_stats_new.deaths + 1
					ply:SpecDM_EnableUpdate("deaths")
				end
				ply:SpecDM_CheckKillRows()
			end
			local weapon = killer:GetActiveWeapon()
			local dmg = {
				GetInflictor = function()
					return inflictor
				end,
				IsDamageType = function()
					return false
				end
			}
			local weapon = util.WeaponFromDamage(dmg)
			local base = "weapon_ghost"
			if weapon and weapon.GetClass and string.Left(weapon:GetClass(), #base) == base and killer.specdm_wepstats then
				if killer.specdm_wepstats[weapon:GetClass()] then
					killer.specdm_wepstats[weapon:GetClass()] = killer.specdm_wepstats[weapon:GetClass()] + 1
				else
					killer.specdm_wepstats[weapon:GetClass()] = 1
				end
				killer:SpecDM_EnableUpdate("weapons")
			end
			SpecDM_Quake(ply, killer)
		end
	end
end)

hook.Add("TTTEndRound", "TTTEndRound_SpecDMStats", function()
	for k,v in pairs(player.GetHumans()) do
		if not v.specdm_stats_newupdates then continue end
		for column,update in pairs(v.specdm_stats_newupdates) do
			if not update then continue end
			local update_str
			if column == "weapons" and v.specdm_wepstats then
				update_str = encode_weapons(v.specdm_wepstats)
			elseif column != "weapons" and v.specdm_stats_new then
				update_str = v.specdm_stats_new[column]
			end
			if not update_str then continue end
			sql.Query("UPDATE specdm_stats_new SET "..column.." = '"..update_str.."' WHERE steamid = '"..v:SteamID().."'")
		end
	end
end)

local general_sorted = {
	"name",
	"kills",
	"kill_row",
	"deaths",
	"time_dm",
	"time_playing"
}

net.Receive("SpecDM_AskStats", function(_, ply)
	local Update_General = net.ReadUInt(1) == 1
	if Update_General then
		local General_page = net.ReadUInt(32)
		local sort = net.ReadUInt(32)
		local General_sort = general_sorted[sort] or "kills"
		local General_order = net.ReadUInt(1) == 1 and "ASC" or "DESC"
		local General_filter = net.ReadUInt(1) == 1
		if General_filter then
			General_filter = net.ReadString()
		end
		local limit = General_page*15 - 15
		local query_str = "SELECT name,kills,kill_row,deaths,time_dm,time_playing FROM specdm_stats_new WHERE time_dm > 0 "
		if General_filter then
			query_str = query_str.."AND name LIKE "..sql.SQLStr("%"..General_filter.."%").." "
		end
		query_str = query_str.."ORDER BY "..General_sort.." "..General_order.." LIMIT "..limit..",15"
		local query = sql.Query(query_str)
		if not query then return end
		local encoded = von.serialize(query)
		if not encoded then return end
		local compressed = util.Compress(encoded)
		if not compressed then return end
		net.Start("SpecDM_SendStats")
		net.WriteUInt(1,1)
		local count
		if General_filter then
			count = sql.QueryValue("SELECT COUNT(steamid) FROM specdm_stats_new WHERE name LIKE "..sql.SQLStr("%"..General_filter.."%"))
		else
			count = sql.QueryValue("SELECT COUNT(steamid) FROM specdm_stats_new")
		end
		if not count then return end
		net.WriteUInt(count, 32)
		net.WriteUInt(#compressed, 32)
		net.WriteData(compressed, #compressed)
		net.Send(ply)
	end
end)

net.Receive("SpecDM_AskOpenStats", function(_, ply)
	local query = sql.QueryValue("SELECT COUNT(steamid) FROM specdm_stats_new")
	local weapons = sql.QueryValue("SELECT weapons FROM specdm_stats_new WHERE steamid = '"..ply:SteamID().."'")
	if not query or not weapons then return end
	weapons = decode_weapons(weapons)
	net.Start("SpecDM_OpenStats")
	net.WriteUInt(query, 32)
	net.WriteTable(weapons)
	net.Send(ply)
end)