surface.CreateFont("SpecDM_Quake", {
	font = "Arial",
	size = 24,
	width = 1000
})

local quakesounds = CreateClientConVar("ttt_specdm_quakesounds", 1, FCVAR_ARCHIVE)
local playing_quake = false
local path = "specdm/"

local kill_tbl = {
	[3] = { "killingspree.mp3", "is on a ", "Killing spree " },
	[4] = { "dominating.mp3", "is ", "Dominating " },
	[5] = { "megakill.mp3", "is on a ", "Megakill " },
	[6] = { "wickedsick.mp3", "is ", "Wicked sick " },
	[7] = { "monsterkill.mp3", "is on a ", "Monsterkill " },
	[8] = { "unstoppable.mp3", "is ", "Unstoppable " },
	[9] = { "godlike.mp3", "is ", "Godlike " }
}

local tbl_combos = {
	[2] = { "doublekill.mp3", "with a ", "Double kill" },
	[3] = { "triplekill.mp3", "with a ", "Triple kill" },
	[4] = { "ultrakill.mp3", "with an ", "Ultrakill" },
	[5] = { "rampage.mp3", "and is on a ", "Rampage" }
}

local tbl_combos_2 = {
	[2] = { "doublekill.mp3", "just got a ", "Double kill" },
	[3] = { "triplekill.mp3", "just a ", "Triple kill" },
	[4] = { "ultrakill.mp3", "just got an ", "Ultrakill" },
	[5] = { "rampage.mp3", "is on a ", "Rampage" }
}

local label_1, label_2, label_3, label_4, label_5, label_6, label_7

net.Receive("SpecDM_QuakeSound", function()
	if not quakesounds:GetBool() then return end
	local ply = net.ReadEntity()
	local kills = net.ReadUInt(19)
	local combos = net.ReadUInt(19)
	if playing_quake and playing_quake != ply then return end
	-- too lazy to use tables
	if label_1 then label_1:Remove() end
	if label_2 then label_2:Remove() end
	if label_3 then label_3:Remove() end
	if label_4 then label_4:Remove() end
	if label_5 then label_5:Remove() end
	if label_6 then label_6:Remove() end
	if label_7 then label_7:Remove() end
	if timer.Exists("SpecDM_1") then timer.Remove("SpecDM_1") end
	if timer.Exists("SpecDM_2") then timer.Remove("SpecDM_2") end
	if timer.Exists("SpecDM_3") then timer.Remove("SpecDM_3") end
	if not IsValid(ply) or not tonumber(kills) or not tonumber(combos) then return end
	playing_quake = (kills >= 3 or combos >= 2) and ply or false
	if playing_quake then
		surface.SetFont("SpecDM_Quake")
	end
	if kills >= 3 then
		local text_1 = ply:Nick().. " "
		label_1 = vgui.Create("DLabel")
		label_1:SetFont("SpecDM_Quake")
		label_1:SetText(text_1)
		label_1:SizeToContents()
		label_1:SetTextColor(Color(78, 126, 200, 255))
		local x1, y1 = surface.GetTextSize(text_1)
		local tbl = kills <= 9 and kill_tbl[kills] or { "holyshit.mp3", "is beyond ", "Godlike" }
		surface.PlaySound(path..tbl[1])
		label_2 = vgui.Create("DLabel")
		label_2:SetFont("SpecDM_Quake")
		label_2:SetText(tbl[2])
		label_2:SizeToContents()
		label_2:SetTextColor(color_white)
		local x2, y2 = surface.GetTextSize(tbl[2])
		label_3 = vgui.Create("DLabel")
		label_3:SetText(tbl[3])
		label_3:SetFont("SpecDM_Quake")
		label_3:SizeToContents()
		label_3:SetTextColor(Color(200, 42, 42, 255))
		local x3, y3 = surface.GetTextSize(tbl[3])
		local text_4 = kills <= 9 and "!" or ", someone kill them!!"
		label_4 = vgui.Create("DLabel")
		label_4:SetText(text_4)
		label_4:SetFont("SpecDM_Quake")
		label_4:SizeToContents()
		label_4:SetTextColor(color_white)
		local x4, y4 = surface.GetTextSize(text_4)
		local total_x = x1 + x2 + x3 + x4
		local label_1_x = ScrW()/2 - total_x/2
		local label_2_x = label_1_x + x1
		local label_3_x = label_2_x + x2
		label_1:SetPos(label_1_x, 40)
		label_2:SetPos(label_2_x, 40)
		label_3:SetPos(label_3_x, 40)
		label_4:SetPos(label_3_x + x3, 40)
		timer.Create("SpecDM_1", 5, 1, function()
			playing_quake = false
			label_1:Remove()
			label_2:Remove()
			label_3:Remove()
			label_4:Remove()
		end)
		if combos >= 2 then
			if combos <= 5 then
				local text_1 = tbl_combos[combos][2]
				label_5 = vgui.Create("DLabel")
				label_5:SetFont("SpecDM_Quake")
				label_5:SetText(text_1)
				label_5:SizeToContents()
				label_5:SetTextColor(color_white)
				local x1, y1 = surface.GetTextSize(text_1)
				local text_2 = tbl_combos[combos][3]
				local sound = tbl_combos[combos][1]
				timer.Simple(SoundDuration(path..tbl[1]), function()
					surface.PlaySound(path..sound)
				end)
				label_6 = vgui.Create("DLabel")
				label_6:SetFont("SpecDM_Quake")
				label_6:SetText(text_2)
				label_6:SizeToContents()
				label_6:SetTextColor(Color(200, 42, 42, 255))
				local x2, y2 = surface.GetTextSize(text_2)
				label_7 = vgui.Create("DLabel")
				label_7:SetText("!")
				label_7:SetFont("SpecDM_Quake")
				label_7:SizeToContents()
				label_7:SetTextColor(color_white)
				local x3, y3 = surface.GetTextSize("!")
				local total_x = x1 + x2 + x3
				local label_5_x = ScrW()/2 - total_x/2
				local label_6_x = label_5_x + x1
				label_5:SetPos(label_5_x, 70)
				label_6:SetPos(label_6_x, 70)
				label_7:SetPos(label_6_x + x2, 70)
				timer.Create("SpecDM_2", 5, 1, function()
					label_5:Remove()
					label_6:Remove()
					label_7:Remove()
				end)
			end
		end
	elseif combos >= 2 and combos <= 5 then
		local text_1 = ply:Nick().. " "
		label_1 = vgui.Create("DLabel")
		label_1:SetFont("SpecDM_Quake")
		label_1:SetText(text_1)
		label_1:SizeToContents()
		label_1:SetTextColor(Color(78, 126, 200, 255))
		local x1, y1 = surface.GetTextSize(text_1)
		local tbl = tbl_combos_2[combos]
		surface.PlaySound(path..tbl[1])
		label_2 = vgui.Create("DLabel")
		label_2:SetFont("SpecDM_Quake")
		label_2:SetText(tbl[2])
		label_2:SizeToContents()
		label_2:SetTextColor(color_white)
		local x2, y2 = surface.GetTextSize(tbl[2])
		label_3 = vgui.Create("DLabel")
		label_3:SetText(tbl[3])
		label_3:SetFont("SpecDM_Quake")
		label_3:SizeToContents()
		label_3:SetTextColor(Color(200, 42, 42, 255))
		local x3, y3 = surface.GetTextSize(tbl[3])
		label_4 = vgui.Create("DLabel")
		label_4:SetText("!")
		label_4:SetFont("SpecDM_Quake")
		label_4:SizeToContents()
		label_4:SetTextColor(color_white)
		local x4, y4 = surface.GetTextSize("!")
		local total_x = x1 + x2 + x3 + x4
		local label_1_x = ScrW()/2 - total_x/2
		local label_2_x = label_1_x + x1
		local label_3_x = label_2_x + x2
		label_1:SetPos(label_1_x, 40)
		label_2:SetPos(label_2_x, 40)
		label_3:SetPos(label_3_x, 40)
		label_4:SetPos(label_3_x + x3, 40)
		timer.Create("SpecDM_3", 5, 1, function()
			playing_quake = false
			label_1:Remove()
			label_2:Remove()
			label_3:Remove()
			label_4:Remove()
		end)
	end
end)