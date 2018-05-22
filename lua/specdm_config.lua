-- Chat commands
SpecDM.Commands = {
	"!dm",
	"!deathmatch",
	"!specdm"
}

-- Minimum time before ghosts can respawn. Set to 0 for autorespawn
SpecDM.RespawnTime = 4

-- Period after the ghosts are automatically respawned. Set to -1 to disable this behavior
SpecDM.AutomaticRespawnTime = 0

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
SpecDM.MuteAlive = true

-- F-Key to open the statistics menu
SpecDM.StatsFKey = KEY_F7

-- Enable HP regeneration
SpecDM.HP_Regen = true

-- When set to true all valid ghost weapons and icons will be inserted automatically
SpecDM.AutoIncludeWeapons = true

-- When AutoIncludeWeapons is set to true the table will be emptied before adding all ghost weapons
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
		"weapon_ghost_galil",
		"weapon_ghost_sledge",
		"weapon_ghost_mac10",
		"weapon_ghost_hl2smg",
		"weapon_ghost_mp5",
		"weapon_ghost_shotgun",
		"weapon_ghost_rifle"
	}
}

-- Enabled the loadout and allow players to select their favorite weapons?
SpecDM.LoadoutEnabled = true

-- Enable quake sounds (clients can deactivate them)
SpecDM.QuakeSoundsEnabled = true

-- Should the hitmarker be red on death shots?
SpecDM.DeadlyHitmarker = true

-- Icons on the F1 loadout if the loadout is enabled
SpecDM.Loadout_Icons = {
	weapon_ghost_revolver = "vgui/ttt/icon_deagle",
	weapon_ghost_glock = "vgui/ttt/icon_glock",
	weapon_ghost_pistol = "vgui/ttt/icon_pistol",
	weapon_ghost_magnum = "vgui/spec_dm/icon_sdm_revolver",
	weapon_ghost_rifle = "vgui/ttt/icon_scout",
	weapon_ghost_ak47 = "vgui/spec_dm/icon_sdm_ak47",
	weapon_ghost_sledge = "vgui/ttt/icon_m249",
	weapon_ghost_mac10 = "vgui/ttt/icon_mac",
	weapon_ghost_augbar = "vgui/spec_dm/icon_sdm_aug",
	weapon_ghost_hl2smg = "vgui/spec_dm/icon_sdm_smg",
	weapon_ghost_shotgun = "vgui/ttt/icon_shotgun",
	weapon_ghost_awp = "vgui/spec_dm/icon_sdm_awp",
	weapon_ghost_galil = "vgui/spec_dm/icon_sdm_galil",
	weapon_ghost_mp5 = "vgui/spec_dm/icon_sdm_mp5"
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
