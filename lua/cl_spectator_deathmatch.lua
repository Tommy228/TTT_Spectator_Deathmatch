
include("sh_spectator_deathmatch.lua")
include("cl_specdm_hud.lua")
include("vgui/spec_dm_loadout.lua")
include("cl_stats.lua")
include("cl_quakesounds.lua")

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
hook.Add("RenderScreenspaceEffects", "RenderScreenspaceEffects_Ghost", function()
	if LocalPlayer():IsGhost() and color_modify:GetBool() then
		local tbl = {
			["$pp_colour_addr"] = 0,
			["$pp_colour_addg" ] = 0,
			["$pp_colour_addb" ] = 0,
			["$pp_colour_brightness" ] = 0,
			["$pp_colour_contrast" ] = 1,
			["$pp_colour_colour" ] = 0,
			["$pp_colour_mulr" ] = 0.05,
			["$pp_colour_mulg" ] = 0.05,
			["$pp_colour_mulb" ] = 0.05
		}
		DrawColorModify(tbl)
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

local COLOR_WHITE = Color(255,255,255,255)
local gray = Color(255, 255, 255, 100)

local showalive = CreateClientConVar("ttt_specdm_showaliveplayers", "1", FCVAR_ARCHIVE)
hook.Add("Think", "Think_Ghost", function()
	for k,v in ipairs(ents.FindByClass("prop_ragdoll")) do
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
            return true
        elseif ply:IsTerror() then
            ply:SetRenderMode(RENDERMODE_TRANSALPHA)
            ply:SetColor(gray)
        end
    else
        if ply:IsGhost() then
            return true
        else
            ply:SetRenderMode(RENDERMODE_NORMAL)
            ply:SetColor(COLOR_WHITE)
        end
    end
end)

local function SendHeartbeat()
	if not IsValid(LocalPlayer()) then return end
	if LocalPlayer():IsGhost() then
		for k,v in ipairs(player.GetHumans()) do -- Bots don't like SpecDM
			if v != LocalPlayer() and v:IsGhost() then
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
	hook.Add("TTTScoreGroups", "TTTScoreGroups_Ghost", function(parent_panel, player_group_panels)
			local t = vgui.Create("TTTScoreGroup", parent_panel)
			t:SetGroupInfo("Spectator Deathmatch", Color(255, 127, 39, 100), GROUP_DEATHMATCH)
			player_group_panels[GROUP_DEATHMATCH] = t
		end)

	local function ScoreGroupDM(p)
		if LocalPlayer():IsTerror() and p:GetNWBool("PlayedSRound",false) and p:IsGhost() then
			if p:GetNWBool("body_found", false) then
				return GROUP_FOUND
			elseif LocalPlayer():IsActiveTraitor() then
				return GROUP_NOTFOUND
			else
				return GROUP_TERROR
			end
		elseif p:IsGhost() and (LocalPlayer():IsSpec() or LocalPlayer():IsGhost()) then
			return GROUP_DEATHMATCH
		end
	end
	hook.Add("TTTScoreGroup", "TTTScoreGroup_Ghost", ScoreGroupDM)
	hook.Add("PostGamemodeLoaded", "PostGamemodeLoaded_Ghost", function() AddScoreGroup("DEATHMATCH") end)
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
		
		function overrideTargetID()
			local trace = LocalPlayer():GetEyeTrace(MASK_SHOT)
			local ent = trace.Entity
			if IsValid(ent) and ent:IsPlayer() and ((ent:IsGhost() and not LocalPlayer():IsGhost()) or (not ent:IsGhost() and LocalPlayer():IsGhost() and not showalive:GetBool())) then return end
		end
		hook.Add("HUDDrawTargetID", "SpecDMTargetID", overrideTargetID)


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

hook.Add("OnEntityCreated", "OnEntityCreated_SpecDMRagdoll", function(ent)
	if not (LocalPlayer().IsGhost and LocalPlayer():IsGhost()) and ent:GetClass() == "class C_HL2MPRagdoll" then 
		for k,v in pairs(player.GetAll()) do
			if v:GetRagdollEntity() == ent and v:IsGhost() then
				ent:SetNoDraw(true)
				break
			end
		end
	end 
end)
