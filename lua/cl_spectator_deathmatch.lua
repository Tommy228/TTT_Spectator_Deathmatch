include("sh_spectator_deathmatch.lua")
include("cl_specdm_hud.lua")
include("vgui/spec_dm_loadout.lua")
include("cl_stats.lua")
include("cl_quakesounds.lua")

hook.Add("HUDPaint", "SpecDM_RespawnMessage", function()
	if !IsValid(LocalPlayer()) or !LocalPlayer():IsGhost() or LocalPlayer():Alive() then return end
	if LocalPlayer():GetNWFloat("SpecDM_RespawnedIn", -2) ~= -2 then
		if SpecDM.AutomaticRespawnTime > -1 then
			draw.DrawText("Press a key to respawn!\nYou will be automaticly respawned in "..math.Round(LocalPlayer():GetNWFloat("SpecDM_RespawnedIn") - CurTime()).." second(s)", "Trebuchet24", ScrW()/2, ScrH()/4, Color(255,255,255,255), TEXT_ALIGN_CENTER)
		else
			draw.DrawText("Press a key to respawn!", "Trebuchet24", ScrW()/2, ScrH()/4, Color(255,255,255,255), TEXT_ALIGN_CENTER)
		end
	elseif LocalPlayer():GetNWFloat("SpecDM_AbleToRespawnIn", -2) ~= -2 then
		local waittime = math.Round(LocalPlayer():GetNWFloat("SpecDM_AbleToRespawnIn") - CurTime())
		if waittime > -1 then
			draw.DrawText("You need to wait "..waittime.." second(s) before you can respawn", "Trebuchet24", ScrW()/2, ScrH()/4, Color(255,255,255,255), TEXT_ALIGN_CENTER)
		end
	end
end)

net.Receive("SpecDM_Error", function()
	local error_str = net.ReadString()
	chat.AddText(Color(255, 62, 62, 255), error_str)
end)

net.Receive("SpecDM_Ghost", function()
	local enabled = net.ReadUInt(1) == 1
	if enabled then
		TIPS.Hide()
		if SpecDM.MuteAlive then
			RunConsoleCommand("ttt_mute_team", TEAM_TERROR)
		end
	else
		TIPS:Show()
	end
end)

net.Receive("SpecDM_GhostJoin", function()
	local joined = net.ReadUInt(1) == 1
	local ply = net.ReadEntity()
	if not IsValid(LocalPlayer()) then return end
	if not LocalPlayer():IsSpec() or not SpecDM.EnableJoinMessages or not IsValid(ply) then return end
	chat.AddText(Color(255,128,0), ply:Nick().." has ", joined and "joined" or "left", " the deathmatch!")
end)

local emitter
local color_modify = CreateClientConVar("ttt_specdm_enablecoloreffect", "1", FCVAR_ARCHIVE)
local color_tbl = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 0,
	["$pp_colour_mulr"] = 0.05,
	["$pp_colour_mulg"] = 0.05,
	["$pp_colour_mulb"] = 0.05
}
hook.Add("RenderScreenspaceEffects", "RenderScreenspaceEffects_Ghost", function()
	if LocalPlayer():IsGhost() and color_modify:GetBool() then
		DrawColorModify(color_tbl)
		cam.Start3D(EyePos(), EyeAngles())
			for k,v in ipairs(player.GetAll()) do
				if v:IsGhost() and v:Alive() then
					render.SuppressEngineLighting( true )
					render.SetColorModulation(1,1,1)
					if emitter then
						emitter:Draw()
					end
					v:DrawModel()
					render.SuppressEngineLighting( false )
				end
			end
		cam.End3D()
	end
end)

local RagdollEntities = {}

hook.Add("OnEntityCreated", "AddRagdolls_SpecDM", function(ent)
	if ent:GetClass() == "prop_ragdoll" and !RagdollEntities[ent:EntIndex()] then
		RagdollEntities[ent:EntIndex()] = ent
	end
	
	if not (LocalPlayer().IsGhost and LocalPlayer():IsGhost()) and ent:GetClass() == "class C_HL2MPRagdoll" then
		for k,v in pairs(player.GetAll()) do
			if v:GetRagdollEntity() == ent and v:IsGhost() then
				ent:SetNoDraw(true)
				break
			end
		end
	end
end)

hook.Add("EntityRemoved", "RemoveRagdolls_SpecDM", function(ent)
	if ent:GetClass() == "prop_ragdoll" and RagdollEntities[ent:EntIndex()] then
		RagdollEntities[ent:EntIndex()] = nil
	end
end)

local COLOR_WHITE = Color(255,255,255,255)
local gray = Color(255, 255, 255, 100)

local showalive = CreateClientConVar("ttt_specdm_showaliveplayers", "1", FCVAR_ARCHIVE)
hook.Add("Think", "Think_Ghost", function()
	for k,v in ipairs(RagdollEntities) do
		if LocalPlayer():IsGhost() then
			v:SetRenderMode(RENDERMODE_TRANSALPHA)
			v:SetColor(gray)
		else
			v:SetColor(COLOR_WHITE)
		end
	end
end)

hook.Add("PrePlayerDraw", "PrePlayerDraw_SpecDM", function(ply)
    if IsValid(LocalPlayer()) and LocalPlayer():IsGhost() then
        if not ply:IsGhost() and not showalive:GetBool() then
            ply:DrawShadow(false)
            return true
        elseif ply:IsTerror() then
            ply:SetRenderMode(RENDERMODE_TRANSALPHA)
            ply:SetColor(gray)
            ply:DrawShadow(true)
        end
    else
        if ply:IsGhost() then
            ply:DrawShadow(false)
            return true
        else
            ply:SetRenderMode(RENDERMODE_NORMAL)
            ply:SetColor(COLOR_WHITE)
            ply:DrawShadow(true)
        end
    end
end)

local function SendHeartbeat()
	if not IsValid(LocalPlayer()) then return end
	if LocalPlayer():IsGhost() then
		for k,v in ipairs(player.GetAll()) do
			if v != LocalPlayer() and v:IsGhost() and v:Alive() then
				emitter = ParticleEmitter(LocalPlayer():GetPos())
				local heartbeat = emitter:Add("sprites/light_glow02_add_noz", v:GetPos() + Vector(0,0,50))
				heartbeat:SetDieTime(0.5)
				heartbeat:SetStartAlpha(255)
				heartbeat:SetEndAlpha(0)
				heartbeat:SetStartSize(50)
				heartbeat:SetEndSize(0)
				heartbeat:SetColor(255,0,0)
			end
		end
	end
end
timer.Create( "SpecDMHeartbeat", 5, 0, SendHeartbeat )

if not SpecDM.IsScoreboardCustom then
	hook.Add("TTTScoreGroups", "TTTScoreGroups_GhostDM", function(can, pg)
		if not GROUP_DEATHMATCH then
			AddScoreGroup("DEATHMATCH")
		end

		local t = vgui.Create("TTTScoreGroup", can)
		t:SetGroupInfo("Spectator Deathmatch", Color(255, 127, 39, 100), GROUP_DEATHMATCH)
		pg[GROUP_DEATHMATCH] = t
	end)

	hook.Add("InitPostEntity", "InitPostEntity_ScoreboardOverride", function()
		local sgtbl = vgui.GetControlTable("TTTScoreGroup")
		function sgtbl:AddPlayerRow(ply)
			if (self.group == GROUP_DEATHMATCH or ScoreGroup(ply) == self.group) and not self.rows[ply] then
				local row = vgui.Create("TTTScorePlayerRow", self)
				row:SetPlayer(ply)
				self.rows[ply] = row
				self.rowcount = table.Count(self.rows)

				self:PerformLayout()
			end
		end

		function sgtbl:UpdatePlayerData()
			local to_remove = {}
			for k, v in pairs(self.rows) do
				if IsValid(v) and IsValid(v:GetPlayer()) and (self.group == GROUP_DEATHMATCH and v:GetPlayer():IsGhost() and LocalPlayer():IsSpec() or ScoreGroup(v:GetPlayer()) == self.group) then
					v:UpdatePlayerData()
				else
					table.insert(to_remove, k)
				end
			end

			if #to_remove == 0 then return end

			for k, ply in pairs(to_remove) do
				local pnl = self.rows[ply]

				if IsValid(pnl) then
					pnl:Remove()
				end

				self.rows[ply] = nil
			end

			self.rowcount = table.Count(self.rows)

			self:UpdateSortCache()

			self:InvalidateLayout()
		end

		local sbtbl = vgui.GetControlTable("TTTScoreboard")
		local old_UpdateScoreboard = sbtbl["UpdateScoreboard"]
		function sbtbl:UpdateScoreboard(force)
			if not force and not self:IsVisible() then return end

			for k, v in pairs(player.GetAll()) do
				if v:IsGhost() and LocalPlayer():IsSpec() then
					if self.ply_groups[GROUP_DEATHMATCH] and not self.ply_groups[GROUP_DEATHMATCH]:HasPlayerRow(v) then
						self.ply_groups[GROUP_DEATHMATCH]:AddPlayerRow(v)
					end
				end
			end

			old_UpdateScoreboard(self, force)
		end
	end)
end

hook.Add("Initialize", "Initialize_Ghost", function()

	-- nobody overrides this function anyway
	function GAMEMODE:PlayerBindPress(ply, bind, pressed)
		if not IsValid(ply) then return end
		if bind == "invnext" and pressed then
			if ply:IsSpec() and not (ply.IsGhost and ply:IsGhost()) then
				TIPS.Next()
			else
				WSWITCH:SelectNext()
			end
			return true
		elseif bind == "invprev" and pressed then
			if ply:IsSpec() and not (ply.IsGhost and ply:IsGhost()) then
				TIPS.Prev()
			else
				WSWITCH:SelectPrev()
			end
			return true
		elseif bind == "+attack" then
			if WSWITCH:PreventAttack() then
				if not pressed then
					WSWITCH:ConfirmSelection()
				end
				return true
			end
		elseif bind == "+sprint" then
			ply.traitor_gvoice = false
			RunConsoleCommand("tvog", "0")
			return true
		elseif bind == "+use" and pressed then
			if ply:IsSpec() then
				RunConsoleCommand("ttt_spec_use")
				return true
			elseif TBHUD:PlayerIsFocused() then
				return TBHUD:UseFocused()
			end
		elseif string.sub(bind, 1, 4) == "slot" and pressed then
			local idx = tonumber(string.sub(bind, 5, -1)) or 1
			if RADIO.Show then
				RADIO:SendCommand(idx)
			else
				WSWITCH:SelectSlot(idx)
			end
			return true
		elseif string.find(bind, "zoom") and pressed then
			RADIO:ShowRadioCommands(not RADIO.Show)
			return true
		elseif bind == "+voicerecord" then
			if not VOICE.CanSpeak() then
				return true
			end
		elseif bind == "gm_showteam" and pressed and ply:IsSpec() then
			local m = VOICE.CycleMuteState()
			RunConsoleCommand("ttt_mute_team", m)
			return true
		elseif bind == "+duck" and pressed and (ply:IsSpec() and not (ply.IsGhost and ply:IsGhost())) then
			if not IsValid(ply:GetObserverTarget()) then
				if GAMEMODE.ForcedMouse then
					gui.EnableScreenClicker(false)
					GAMEMODE.ForcedMouse = false
				else
					gui.EnableScreenClicker(true)
					GAMEMODE.ForcedMouse = true
				end
			end
		elseif bind == "noclip" and pressed then
			if not GetConVar("sv_cheats"):GetBool() then
				RunConsoleCommand("ttt_equipswitch")
				return true
			end
		elseif (bind == "gmod_undo" or bind == "undo") and pressed then
			RunConsoleCommand("ttt_dropammo")
			return true
		end
	end

	function ScoreGroup(p)
		if not IsValid(p) then return -1 end

		local group = hook.Call("TTTScoreGroup", nil, p)

		if group then
			return group
		end

		local client = LocalPlayer()

		if p:IsGhost() then
			if not p:GetNWBool("PlayedSRound", false) then
				return GROUP_SPEC
			end

			if p:GetNWBool("body_found", false) then
				return GROUP_FOUND
			else
				if client:IsSpec() or client:IsActiveTraitor() or ((GAMEMODE.round_state ~= ROUND_ACTIVE) and client:IsTerror()) then
					return GROUP_NOTFOUND
				else
					return GROUP_TERROR
				end
			end
		end

		if DetectiveMode() then
			if p:IsSpec() and p:GetNWBool("PlayedSRound", false) and not p:Alive() then
				if p:GetNWBool("body_found", false) then
					return GROUP_FOUND
				else
					if client:IsSpec() or client:IsActiveTraitor() or ((GAMEMODE.round_state ~= ROUND_ACTIVE) and client:IsTerror()) then
						return GROUP_NOTFOUND
					else
						return GROUP_TERROR
					end
				end
			end
		end

		return p:IsTerror() and GROUP_TERROR or GROUP_SPEC
	end

	local function overrideTargetID()
		local old_HUDDrawTargetID = GAMEMODE.HUDDrawTargetID
		function GAMEMODE:HUDDrawTargetID()
			local trace = LocalPlayer():GetEyeTrace(MASK_SHOT)
			local ent = trace.Entity
			if IsValid(ent) and ent:IsPlayer() then
				if (ent:IsGhost() and not LocalPlayer():IsGhost()) or (not ent:IsGhost() and LocalPlayer():IsGhost() and not showalive:GetBool()) then
					return
				end
			end
			old_HUDDrawTargetID(self)
		end
	end

	function TargetIDChangeCallback()
		local old_DrawPropSpecLabels = DrawPropSpecLabels_New
		function DrawPropSpecLabels_New(client)
			if not showalive:GetBool() then return end
			return old_DrawPropSpecLabels(client)
		end
		overrideTargetID()
	end

	-- fuck you ttt and fuck your local functions
	-- you are making me write the most stupid code ever
	local targetid = file.Read(GAMEMODE.FolderName.."/gamemode/cl_targetid.lua", "LUA")
	if targetid then
		targetid = string.gsub(targetid, "function GM:", "function GAMEMODE:")
		targetid = string.gsub(targetid, "local function DrawPropSpecLabels", "function DrawPropSpecLabels")
		targetid = string.gsub(targetid, "DrawPropSpecLabels", "DrawPropSpecLabels_New")
		targetid = targetid.." TargetIDChangeCallback()"
		RunString(targetid)
	else
		overrideTargetID()
	end
end)

local primary = CreateClientConVar("ttt_specdm_primaryweapon", "random", FCVAR_ARCHIVE)
local secondary = CreateClientConVar("ttt_specdm_secondaryweapon", "random", FCVAR_ARCHIVE)
local force_deathmatch = CreateClientConVar("ttt_specdm_forcedeathmatch", "1", FCVAR_ARCHIVE)
local autoswitch = CreateClientConVar("ttt_specdm_autoswitch", "0", FCVAR_ARCHIVE)

function SpecDM.UpdateLoadout()
	net.Start("SpecDM_SendLoadout")
	net.WriteString(primary:GetString())
	net.WriteString(secondary:GetString())
	net.SendToServer()
end
hook.Add("InitPostEntity", "SpecDM_InitPostEntity", SpecDM.UpdateLoadout)
cvars.AddChangeCallback("ttt_specdm_primaryweapon", SpecDM.UpdateLoadout)
cvars.AddChangeCallback("ttt_specdm_secondaryweapon", SpecDM.UpdateLoadout)


hook.Add("TTTSettingsTabs", "SpecDM_TTTSettingsTab", function(dtabs)

	-- rip from damagelog menu and thanks hobbes
	local padding = dtabs:GetPadding()
	padding = padding * 2

	local dsettings = vgui.Create("DPanelList", dtabs)
	dsettings:StretchToParent(0,0,padding,0)
	dsettings:EnableVerticalScrollbar(true)
	dsettings:SetPadding(10)
	dsettings:SetSpacing(10)

	if SpecDM.LoadoutEnabled then

		local primary_loadout = vgui.Create("SpecDM_LoadoutPanel")
		primary_loadout.cvar = "ttt_specdm_primaryweapon"
		primary_loadout:SetCategory("Primary weapons")
		primary_loadout:SetWeapons(SpecDM.Ghost_weapons.primary)
		dsettings:AddItem(primary_loadout)

		local secondary_loadout = vgui.Create("SpecDM_LoadoutPanel")
		secondary_loadout.cvar = "ttt_specdm_secondaryweapon"
		secondary_loadout:SetCategory("Secondary weapons")
		secondary_loadout:SetWeapons(SpecDM.Ghost_weapons.secondary)
		dsettings:AddItem(secondary_loadout)

	end

	local dgui = vgui.Create("DForm", dsettings)
	dgui:SetName("General settings")
	if not SpecDM.ForceDeathmatch then
		dgui:CheckBox("Enable autoswitch", "ttt_specdm_autoswitch")
	else
		dgui:CheckBox("Always go to deathmatch mode after dying", "ttt_specdm_forcedeathmatch")
	end
	dgui:CheckBox("Enable Quake sounds + texts", "ttt_specdm_quakesounds")
	dgui:CheckBox("Show alive players", "ttt_specdm_showaliveplayers")
	dgui:CheckBox("Enable the color effect", "ttt_specdm_enablecoloreffect")
	dgui:CheckBox("Enable the hitmarker", "ttt_specdm_hitmarker")
	dsettings:AddItem(dgui)

	dtabs:AddSheet("Spectator Deathmatch", dsettings, "icon16/gun.png", false, false, "Spectator deathmatch related settings")

end)

net.Receive("SpecDM_Autoswitch", function()
	local spawned = false
	if ((SpecDM.ForceDeathmatch and force_deathmatch:GetBool()) or (not SpecDM.ForceDeathmatch and autoswitch:GetBool())) and GetRoundState() == ROUND_ACTIVE and not LocalPlayer():IsGhost() then
		spawned = true
		RunConsoleCommand("say_team", SpecDM.Commands[1])
	elseif not SpecDM.ForceDeathmatch and SpecDM.PopUp then
		local frame = vgui.Create("DFrame")
		frame:SetSize(250, 120)
		frame:SetTitle("Spectator Deathmatch")
		frame:Center()
		local reason = vgui.Create("DLabel", frame)
		reason:SetText("You can play while you are dead!")
		reason:SizeToContents()
		reason:SetPos(5, 32)
		local report = vgui.Create("DButton", frame)
		report:SetPos(5, 55)
		report:SetSize(240, 25)
		report:SetText("Join the Spectator Deathmatch")
		report.DoClick = function()
			RunConsoleCommand("say_team", SpecDM.Commands[1])
			frame:Close()
		end
		local report_icon = vgui.Create("DImageButton", report)
		report_icon:SetMaterial("materials/icon16/report_go.png")
		report_icon:SetPos(1, 5)
		report_icon:SizeToContents()
		local close = vgui.Create("DButton", frame)
		close:SetPos(5, 85)
		close:SetSize(240, 25)
		close:SetText("No, stay as a spectator")
		close.DoClick = function()
			frame:Close()
		end
		local close_icon = vgui.Create("DImageButton", close)
		close_icon:SetPos(2, 5)
		close_icon:SetMaterial("materials/icon16/cross.png")
		close_icon:SizeToContents()
		frame:MakePopup()
	end
	if SpecDM.DisplayMessage and not spawned then
		chat.AddText(Color(255, 62, 62), "[DM] ", color_white, "You've died! Type ", Color(98,176,255), SpecDM.Commands[1], Color(255, 255, 255), " to enter deathmatch mode and ", Color(255,62,62), "keep killing", Color(255, 255, 255), "!")
		-- Now this will say !dm instead of !deathmatch. (see specdm_config.lua)
	end
end)

local hitmarker_enabled = false
local hitmarker = CreateClientConVar("ttt_specdm_hitmarker", "1", FCVAR_ARCHIVE)
hook.Add("HUDPaint", "HUDPaint_SpecDMHitmarker", function()
	if hitmarker:GetBool() and hitmarker_enabled then
		local x = ScrW() / 2
		local y = ScrH() / 2
		surface.SetDrawColor(Color(225, 225, 225, 200))
		surface.DrawLine( x+7, y-7, x+15, y-15 )
		surface.DrawLine( x-7, y+7, x-15, y+15 )
		surface.DrawLine( x+7, y+7, x+15, y+15 )
		surface.DrawLine( x-7, y-7, x-15, y-15 )
	end
end)

net.Receive("SpecDM_Hitmarker", function()
	hitmarker_enabled = true
	if timer.Exists("SpecDM_Hitmarker") then
		timer.Remove("SpecDM_Hitmarker")
	end
	timer.Create("SpecDM_Hitmarker", 0.35, 1, function()
		hitmarker_enabled = false
	end)
end)