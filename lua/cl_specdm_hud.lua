
local dr = draw
local function ShadowedText(text, font, x, y, color, xalign, yalign)
	dr.SimpleText(text, font, x+2, y+2, COLOR_BLACK, xalign, yalign)
	dr.SimpleText(text, font, x, y, color, xalign, yalign)
end

local bg_colors = {
	background_main = Color(0, 0, 10, 200),
	noround = Color(100,100,100,200),
	traitor = Color(200, 25, 25, 200),
	innocent = Color(25, 200, 25, 200),
	detective = Color(25, 25, 200, 200)
};

local health_colors = {
	border = COLOR_WHITE,
	background = Color(100, 25, 25, 222),
	fill = Color(200, 50, 50, 250)
};

local ammo_colors = {
	border = COLOR_WHITE,
	background = Color(20, 20, 5, 222),
	fill = Color(205, 155, 0, 255)
};


local function DrawBg(x, y, width, height, client)
	local th = 30
	local tw = 170
	y = y - th
	height = height + th
	draw.RoundedBox(8, x, y, width, height, bg_colors.background_main)
	local col = bg_colors.innocent
	if LocalPlayer():IsGhost() then
	elseif GAMEMODE.round_state != ROUND_ACTIVE then
		col = bg_colors.noround
	elseif LocalPlayer():GetTraitor() then
		col = bg_colors.traitor
	elseif LocalPlayer():GetDetective() then
		col = bg_colors.detective
	end
	draw.RoundedBox(8, x, y, tw, th, col)
end

local Tex_Corner8 = surface.GetTextureID("gui/corner8")
local function RoundedMeter( bs, x, y, w, h, color)
	surface.SetDrawColor(clr(color))
	surface.DrawRect( x+bs, y, w-bs*2, h )
	surface.DrawRect( x, y+bs, bs, h-bs*2 )
	surface.SetTexture( Tex_Corner8 )
	surface.DrawTexturedRectRotated( x + bs/2 , y + bs/2, bs, bs, 0 )
	surface.DrawTexturedRectRotated( x + bs/2 , y + h -bs/2, bs, bs, 90 )
	if w > 14 then
		surface.DrawRect( x+w-bs, y+bs, bs, h-bs*2 )
		surface.DrawTexturedRectRotated( x + w - bs/2 , y + bs/2, bs, bs, 270 )
		surface.DrawTexturedRectRotated( x + w - bs/2 , y + h - bs/2, bs, bs, 180 )
	else
		surface.DrawRect( x + math.max(w-bs, bs), y, bs/2, h )
	end
end

local function GetAmmo(ply)
	local weap = ply:GetActiveWeapon()
	if not weap or not ply:Alive() then return -1 end
	local ammo_inv = weap:Ammo1() or 0
	local ammo_clip = weap:Clip1() or 0
	local ammo_max = weap.Primary.ClipSize or 0
	return ammo_clip, ammo_max, ammo_inv
end

local function PaintBar(x, y, w, h, colors, value)
	draw.RoundedBox(8, x-1, y-1, w+2, h+2, colors.background)
	local width = w * math.Clamp(value, 0, 1)
	if width > 0 then
		RoundedMeter(8, x, y, width, h, colors.fill)
	end
end

hook.Add("Initialize", "Initialize_GhostHUD", function()

	local GetLang = LANG.GetUnsafeLanguageTable

	local ttt_health_label = GetConVar("ttt_health_label")

	local margin = 10
	local old_DrawHUD = GAMEMODE.HUDPaint
	function GAMEMODE:HUDPaint()
		if LocalPlayer():IsGhost() then
			self:HUDDrawTargetID()
			MSTACK:Draw(LocalPlayer())		
			TBHUD:Draw(LocalPlayer())
			WSWITCH:Draw(LocalPlayer())
			self:HUDDrawPickupHistory()
			local L = GetLang()
			local width = 250
			local height = 90
			local x = margin
			local y = ScrH() - margin - height
			DrawBg(x, y, width, height, LocalPlayer())
			local bar_height = 25
			local bar_width = width - (margin*2)
			local health = math.max(0, LocalPlayer():Health())
			local health_y = y + margin
			PaintBar(x + margin, health_y, bar_width, bar_height, health_colors, health/100)
			ShadowedText(tostring(health), "HealthAmmo", bar_width, health_y, COLOR_WHITE, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT)
			if ttt_health_label:GetBool() then
				local health_status = util.HealthToString(health)
				draw.SimpleText(L[health_status], "TabLarge", x + margin*2, health_y + bar_height/2, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
			if LocalPlayer():GetActiveWeapon().Primary then
				local ammo_clip, ammo_max, ammo_inv = GetAmmo(LocalPlayer())
				if ammo_clip != -1 then
					local ammo_y = health_y + bar_height + margin
					PaintBar(x+margin, ammo_y, bar_width, bar_height, ammo_colors, ammo_clip/ammo_max)
					local text = string.format("%i + %02i", ammo_clip, ammo_inv)
					ShadowedText(text, "HealthAmmo", bar_width, ammo_y, COLOR_WHITE, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT)
				end
			end
			local text = "Ghost DM"
			local traitor_y = y - 30
			ShadowedText(text, "TraitorState", x + margin + 73, traitor_y, COLOR_WHITE, TEXT_ALIGN_CENTER)
			local is_haste = HasteMode() and round_state == ROUND_ACTIVE
			local endtime = GetGlobalFloat("ttt_round_end", 0) - CurTime()
			local text
			local font = "TimeLeft"
			local color = COLOR_WHITE
			local rx = x + margin + 170
			local ry = traitor_y + 3
			if is_haste then
				local hastetime = GetGlobalFloat("ttt_haste_end", 0) - CurTime()
				if hastetime < 0 then
					text = L.overtime
					font = "Trebuchet18"
					ry = ry + 5
					rx = rx - 3
				else
					local t = hastetime
					text = util.SimpleTime(math.max(0, t), "%02i:%02i")
				end
			else
				text = util.SimpleTime(math.max(0, endtime), "%02i:%02i")
			end
			ShadowedText(text, font, rx, ry, color)
			if is_haste then
				dr.SimpleText(L.hastemode, "TabLarge", x + margin + 165, traitor_y - 8)
			end
			return
		end
		return old_DrawHUD(self)
	end
		
end)