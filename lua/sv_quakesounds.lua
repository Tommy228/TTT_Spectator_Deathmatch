
local function SpecDM_SendQuake(ply)
	if not tonumber(ply.specdm_killrows) or not tonumber(ply.specdm_close_kills) then return end
	net.Start("SpecDM_QuakeSound")
	net.WriteEntity(ply)
	net.WriteUInt(ply.specdm_killrows, 19)
	net.WriteUInt(ply.specdm_close_kills, 19)
	local tbl = {}
	for k,v in pairs(player.GetAll()) do
		if v:IsGhost() then
			table.insert(tbl, v)
		end
	end
	net.Send(tbl)
end

function SpecDM_Quake(victim, killer)
	if not tonumber(killer.specdm_close_kills) then
		killer.specdm_close_kills = 1
	elseif killer.specdm_lastkill and CurTime() - killer.specdm_lastkill < 7 then
		killer.specdm_close_kills = killer.specdm_close_kills + 1
	else
		killer.specdm_close_kills = 1
	end
	killer.specdm_lastkill = CurTime()
	victim.specdm_lastkill = nil
	if killer.specdm_killrows >= 3 or killer.specdm_close_kills >= 2 then
		SpecDM_SendQuake(killer)
	end
end
