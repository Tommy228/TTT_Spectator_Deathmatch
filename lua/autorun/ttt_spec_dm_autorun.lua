-- TTT Spectator Deathmatch Copyright (C) 2017 Ismail Ouazzany
-- This program comes with ABSOLUTELY NO WARRANTY; for details view LICENSE.

-- GitHub Repository:
--		https://github.com/Tommy228/TTT_Spectator_Deathmatch
SpecDM = {}

if SERVER then
	include("sv_spectator_deathmatch.lua")
else
	include("cl_spectator_deathmatch.lua")
end
