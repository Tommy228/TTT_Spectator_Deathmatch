
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

function GAMEMODE:HUDDrawTargetID()
    local client = LocalPlayer()
    local L = GetLang()

    DrawPropSpecLabels(client)

    local trace = client:GetEyeTrace(MASK_SHOT)
    local ent = trace.Entity
    if (not IsValid(ent)) or ent.NoTarget then return end

    -- some bools for caching what kind of ent we are looking at
    local target_traitor = false
    local target_detective = false
    local target_corpse = false

    local text = nil
    local color = COLOR_WHITE

    -- if a vehicle, we identify the driver instead
    if IsValid(ent:GetNWEntity("ttt_driver", nil)) then
        ent = ent:GetNWEntity("ttt_driver", nil)
        if ent == client then return end
    end

    local cls = ent:GetClass()
    local minimal = minimalist:GetBool()
    local hint = (not minimal) and (ent.TargetIDHint or ClassHint[cls])

    if ent:IsPlayer() then
	if (ent.IsGhost and ent:IsGhost()) then return end
        if ent:GetNWBool("disguised", false) then
            client.last_id = nil

            if client:IsTraitor() or client:IsSpec() then
                text = ent:Nick() .. L.target_disg
            else
                -- Do not show anything
                return
            end

            color = COLOR_RED
          
        else
           
            text = ent:Nick()
            client.last_id = ent
        end

        local _ -- Stop global clutter

        -- in minimalist targetID, colour nick with health level
        if minimal then
            _, color = util.HealthToString(ent:Health())
        end

        if client:IsTraitor() and GAMEMODE.round_state == ROUND_ACTIVE then
            target_traitor = ent:IsTraitor()
        end

        target_detective = ent:IsDetective()

    elseif cls == "prop_ragdoll" then
        -- only show this if the ragdoll has a nick, else it could be a mattress
        if CORPSE.GetPlayerNick(ent, false) == false then return end

        target_corpse = true

        if CORPSE.GetFound(ent, false) or not DetectiveMode() then
            text = CORPSE.GetPlayerNick(ent, "A Terrorist")
        else
            text  = L.target_unid
            color = COLOR_YELLOW
        end
    elseif not hint then
        -- Not something to ID and not something to hint about
        return
    end

    local x_orig = ScrW() / 2.0
    local x = x_orig
    local y = ScrH() / 2.0

    local w, h = 0,0 -- text width/height, reused several times

    if target_traitor or target_detective then
        surface.SetTexture(ring_tex)
    
    if target_traitor then
        surface.SetDrawColor(255, 0, 0, 200)
    else
        surface.SetDrawColor(0, 0, 255, 220)
    end
        surface.DrawTexturedRect(x-32, y-32, 64, 64)
    end

    y = y + 30
    local font = "TargetID"
    surface.SetFont( font )

    -- Draw main title, ie. nickname
    if text then
        w, h = surface.GetTextSize( text )

        x = x - w / 2

        draw.SimpleText( text, font, x+1, y+1, COLOR_BLACK )
        draw.SimpleText( text, font, x, y, color )

        -- for ragdolls searched by detectives, add icon
        if ent.search_result and client:IsDetective() then
            -- if I am detective and I know a search result for this corpse, then I
            -- have searched it or another detective has
            surface.SetMaterial(magnifier_mat)
            surface.SetDrawColor(200, 200, 255, 255)
            surface.DrawTexturedRect(x + w + 5, y, 16, 16)
        end

        y = y + h + 4
    end

    -- Minimalist target ID only draws a health-coloured nickname, no hints, no
    -- karma, no tag
    if minimal then return end

    -- Draw subtitle: health or type
    local clr = rag_color
    if ent:IsPlayer() then
        text, clr = util.HealthToString(ent:Health())

        -- HealthToString returns a string id, need to look it up
        text = L[text]
    elseif hint then
        text = LANG.GetRawTranslation(hint.name) or hint.name
    else
        return
    end
    font = "TargetIDSmall2"

    surface.SetFont( font )
    w, h = surface.GetTextSize( text )
    x = x_orig - w / 2

    draw.SimpleText( text, font, x+1, y+1, COLOR_BLACK )
    draw.SimpleText( text, font, x, y, clr )

    font = "TargetIDSmall"
    surface.SetFont( font )

    -- Draw second subtitle: karma
    if ent:IsPlayer() and KARMA.IsEnabled() then
        text, clr = util.KarmaToString(ent:GetBaseKarma())

        text = L[text]

        w, h = surface.GetTextSize( text )
        y = y + h + 5
        x = x_orig - w / 2

        draw.SimpleText( text, font, x+1, y+1, COLOR_BLACK )
        draw.SimpleText( text, font, x, y, clr )
    end

    -- Draw key hint
    if hint and hint.hint then
        if not hint.fmt then
            text = LANG.GetRawTranslation(hint.hint) or hint.hint
        else
            text = hint.fmt(ent, hint.hint)
        end

        w, h = surface.GetTextSize(text)
        x = x_orig - w / 2
        y = y + h + 5
        draw.SimpleText( text, font, x+1, y+1, COLOR_BLACK )
        draw.SimpleText( text, font, x, y, COLOR_LGRAY )
    end

    text = nil

    if target_traitor then
        text = L.target_traitor
        clr = COLOR_RED
    elseif target_detective then
        text = L.target_detective
        clr = COLOR_BLUE
    elseif ent.sb_tag and ent.sb_tag.txt != nil then
        text = L[ ent.sb_tag.txt ]
        clr = ent.sb_tag.color
    elseif target_corpse and client:IsActiveTraitor() and CORPSE.GetCredits(ent, 0) > 0 then
        text = L.target_credits
        clr = COLOR_YELLOW
    end

    if text then
        w, h = surface.GetTextSize( text )
        x = x_orig - w / 2
        y = y + h + 5

        draw.SimpleText( text, font, x+1, y+1, COLOR_BLACK )
        draw.SimpleText( text, font, x, y, clr )
    end
end

timer.Simple( 5, function()
function RADIO:GetTargetType()
    if not IsValid(LocalPlayer()) then return end
    local trace = LocalPlayer():GetEyeTrace(MASK_SHOT)

    if not trace or (not trace.Hit) or (not IsValid(trace.Entity)) then return end

    local ent = trace.Entity
    
    if (ent.IsGhost and ent:IsGhost()) then return end
    if ent:IsPlayer() then
        if ent:GetNWBool("disguised", false) then
            return "quick_disg", true
        else
            return ent, false
        end
    elseif ent:GetClass() == "prop_ragdoll" and CORPSE.GetPlayerNick(ent, "") != "" then
        if DetectiveMode() and not CORPSE.GetFound(ent, false) then
            return "quick_corpse", true
        else
            return ent, false
        end
    end
end
end )
