
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
			for k,v in pairs(player.GetAll()) do
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

local showalive = CreateClientConVar("ttt_specdm_showaliveplayers", "1", FCVAR_ARCHIVE)
local nextheartbeat = false
hook.Add("Think", "Think_Ghost", function()
	if not IsValid(LocalPlayer()) then return end
	if LocalPlayer():IsGhost() then
		if not nextheartbeat or CurTime() > nextheartbeat then
			nextheartbeat = CurTime() + 5
			for k,v in pairs(player.GetAll()) do
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
	for k,v in pairs(player.GetAll()) do
		if v:IsGhost() then
			if LocalPlayer():IsGhost() then
				v:SetNoDraw(false)
			else
				v:SetNoDraw(true)
			end
		else
			if v:IsSpec() and not v:IsGhost() then
				v:SetNoDraw(true)
			else
				if LocalPlayer():IsGhost() then
					v:SetRenderMode(RENDERMODE_TRANSALPHA)
					if showalive:GetBool() then
						v:SetColor(Color(255, 255, 255, 100))
						v:SetNoDraw(false)
					else
						v:SetNoDraw(true)
					end
				else
					v:SetNoDraw(false)
					v:SetColor(Color(255, 255, 255, 255))
				end
			end
		end
	end
	for k,v in pairs(ents.FindByClass("prop_ragdoll")) do
		if LocalPlayer():IsGhost() then
			v:SetRenderMode(RENDERMODE_TRANSALPHA)
			v:SetColor(Color(255, 255, 255, 100))
		else
			v:SetColor(Color(255, 255, 255, 255))
		end
	end
end)

if not SpecDM.IsScoreboardCustom then

	GROUP_DEATHMATCH = 5
	local old_vguiRegister = vgui.Register
	vgui.Register = function(className, tbl, base)
		if className == "TTTScoreboard" then
			local old_Init = tbl.Init
			tbl.Init = function(self)
				old_Init(self)
				local t = vgui.Create("TTTScoreGroup", self.ply_frame:GetCanvas())
				t:SetGroupInfo("Spectator Deathmatch", Color(255, 127, 39, 100), GROUP_DEATHMATCH)
				self.ply_groups[GROUP_DEATHMATCH] = t
			end
			local old_UpdateScoreboard = tbl.UpdateScoreboard
			tbl.UpdateScoreboard = function(self, force)
				if not force and not self:IsVisible() then return end
				for k,v in pairs(player.GetAll()) do
					if v:IsGhost() and (LocalPlayer():IsSpec() or LocalPlayer():IsActiveTraitor()) then
						if self.ply_groups[GROUP_DEATHMATCH] and not self.ply_groups[GROUP_DEATHMATCH]:HasPlayerRow(v) then
							self.ply_groups[GROUP_DEATHMATCH]:AddPlayerRow(v)
						end
					end
				end
				old_UpdateScoreboard(self, force)
			end
		elseif className == "TTTScoreGroup" then
			tbl.AddPlayerRow = function(self, ply)
				if (self.group == GROUP_DEATHMATCH or ScoreGroup(ply) == self.group) and not self.rows[ply] then
					local row = vgui.Create("TTTScorePlayerRow", self)
					row:SetPlayer(ply)
					self.rows[ply] = row
					self.rowcount = table.Count(self.rows)
					-- I sincerely hate you for putting this here, spykr
					self.rows[ply].OnMousePressed = function(s, mc) 
						if RightClickRow and mc == MOUSE_RIGHT then 
							RightClickRow(ply) 
						elseif mc == MOUSE_LEFT then 
							s:DoClick() 
						elseif mc == MOUSE_RIGHT then
							s:DoRightClick()
						end
					end
					self:PerformLayout()
				end
			end
			tbl.UpdatePlayerData = function(self)
				local to_remove = {}
				for k,v in pairs(self.rows) do
					if ValidPanel(v) and IsValid(v:GetPlayer()) and ((self.group == GROUP_DEATHMATCH and v:GetPlayer():IsGhost() and (LocalPlayer():IsSpec() or LocalPlayer():IsActiveTraitor())) or ScoreGroup(v:GetPlayer()) == self.group) then
						v:UpdatePlayerData()
					else
						table.insert(to_remove, k)
					end
				end
				if #to_remove == 0 then return end
				for k,ply in pairs(to_remove) do
					local pnl = self.rows[ply]
					if ValidPanel(pnl) then
						pnl:Remove()
					end
					self.rows[ply] = nil
				end
				self.rowcount = table.Count(self.rows)
				self:UpdateSortCache()
				self:InvalidateLayout()
			end
		end
		return old_vguiRegister(className, tbl, base)
	end
	
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
			if WSWITCH.Show then
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
		elseif bind == "messagemode" and pressed and ply:IsSpec() then
			if GAMEMODE.round_state == ROUND_ACTIVE and DetectiveMode() then
				LANG.Msg("spec_teamchat_hint")
				return true
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
		local client = LocalPlayer()
		if p:IsGhost()  then
			if not p:GetNWBool("PlayedSRound") then return GROUP_SPEC end
			if p:GetNWBool("body_found", false) then
				return GROUP_FOUND
			else
				local client = LocalPlayer()
				if client:IsSpec() or client:IsActiveTraitor() or ((GAMEMODE.round_state != ROUND_ACTIVE) and client:IsTerror()) then
					return GROUP_NOTFOUND
				else
					return GROUP_TERROR
				end
			end	   
		end
		if DetectiveMode() then
			if p:IsSpec() and p:GetNWBool("PlayedSRound") and not p:Alive() then
				if p:GetNWBool("body_found", false) then
					return GROUP_FOUND
				else
					local client = LocalPlayer()
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
	
	if not SpecDM.IsScoreboardCustom then
		GROUP_COUNT = 5
	end
	
	for k,v in pairs(weapons.GetList()) do
		if v.Base == "weapon_tttbase" then
			local old_DrawWorldModel = v.DrawWorldModel
			v.DrawWorldModel = function(self)
				if LocalPlayer():IsGhost() then
					if showalive:GetBool() then
						if old_DrawWorldModel then
							old_DrawWorldModel(self)
						else
							self:DrawModel()
						end
					else
						return false
					end
				else
					if old_DrawWorldModel then
						old_DrawWorldModel(self)
					else
						self:DrawModel()
					end
				end
			end
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
		chat.AddText("You've died! Type ", Color(98,176,255), SpecDM.Commands[1], Color(255, 255, 255), " to enter deathmatch mode and ", Color(255,62,62), "keep killing", Color(255, 255, 255), "!")
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
		timer.Destroy("SpecDM_Hitmarker")
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