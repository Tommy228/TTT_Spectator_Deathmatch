

-- Chat commands
SpecDM.Commands = {
	"!deathmatch",
	"!dm",
	"!specdm"
}

-- Respawn time when ghosts die
SpecDM.RespawnTime = 4

-- Set this to true if you have a custom scoreboard
-- (a completely fresh one, not a modification like rank column, spykr's addons or logo change)
SpecDM.IsScoreboardCustom = false

-- Force all players to join the specdm when they die?
SpecDM.ForceDeathmatch = false

-- If SpecDM.ForceDeathmatch is disabled, open a small pop up asking them if they want to join deathmatch?
SpecDM.PopUp = false

-- Display a chat message when a player dies to let him know he can deathmatch
SpecDM.DisplayMessage = true

-- Enable join/leave messages
SpecDM.EnableJoinMessages = true

-- Mute alive players by default when you join the specdm
SpecDM.MuteAlive = false

-- F-Key to open the statistics menu
SpecDM.StatsFKey = KEY_F7

-- Enable HP regeneration
SpecDM.HP_Regen = true

-- list of weapons
-- make sure you use the base weapon_ghost_base if you want to create your own one, but it must be a regular weapon
SpecDM.Ghost_weapons = {
	secondary = {
		"weapon_ghost_glock",
		"weapon_ghost_pistol",
		"weapon_ghost_revolver",
		"weapon_ghost_magnum"
	},
	primary = {
		"weapon_ghost_ak47",
		"weapon_ghost_augbar",
		"weapon_ghost_awp",
		"weapon_ghost_famas",
		"weapon_ghost_galil",
		"weapon_ghost_sledge",
		"weapon_ghost_mac10",
		"weapon_ghost_hl2smg",
		"weapon_ghost_m16",
		"weapon_ghost_mp5",
		"weapon_ghost_p90",
		"weapon_ghost_sg550",
		"weapon_ghost_siltmp",
		"weapon_ghost_shotgun",
		"weapon_ghost_rifle",
	}
}

-- Enabled the loadout and allow players to select their favorite weapons?
SpecDM.LoadoutEnabled = true

-- Enable quake sounds
SpecDM.QuakeSoundsEnabled = true

-- Icons on the F1 loadout if the loadout is enabled
SpecDM.Loadout_Icons = {
	weapon_ghost_revolver = "VGUI/ttt/icon_deagle",
	weapon_ghost_glock = "VGUI/ttt/icon_glock",
	weapon_ghost_pistol = "VGUI/ttt/icon_pistol",
	weapon_ghost_magnum = "VGUI/spec_dm/icon_sdm_revolver",
	weapon_ghost_rifle = "VGUI/ttt/icon_scout",
	weapon_ghost_sg550 = "VGUI/spec_dm/icon_sdm_sg550",
	weapon_ghost_ak47 = "VGUI/spec_dm/icon_sdm_ak47",
	weapon_ghost_sledge = "VGUI/ttt/icon_m249",
	weapon_ghost_mac10 = "VGUI/ttt/icon_mac",
	weapon_ghost_augbar = "VGUI/spec_dm/icon_sdm_aug",
	weapon_ghost_m16 = "VGUI/ttt/icon_m16",
	weapon_ghost_hl2pistol = "VGUI/spec_dm/icon_sdm_pistol",
	weapon_ghost_hl2smg = "VGUI/spec_dm/icon_sdm_smg",
	weapon_ghost_shotgun = "VGUI/ttt/icon_shotgun",
	weapon_ghost_p90 = "VGUI/spec_dm/icon_sdm_p90",
	weapon_ghost_awp = "VGUI/spec_dm/icon_sdm_awp",
	weapon_ghost_galil = "VGUI/spec_dm/icon_sdm_galil",
	weapon_ghost_famas = "VGUI/spec_dm/icon_sdm_famas",
	weapon_ghost_mp5 = "VGUI/spec_dm/icon_sdm_mp5",
	weapon_ghost_siltmp = "VGUI/spec_dm/icon_sdm_stmp"
}

-- If you're using _Undefined's pointshop you can enable this to give ghosts points when they kill other ghosts
SpecDM.GivePointshopPoints = false
SpecDM.PointshopPoints = 5

-- Whitelist
SpecDM.RestrictCommand = false

-- List of allowed ranks if you enabled the whitelist
SpecDM.AllowedGroups = {
	"admin",
	"superadmin"
}
