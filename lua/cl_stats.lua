
surface.CreateFont("SpecDM_Page", {
	font = "DermaDefault",
	size = 18
})

local weapon_tbl = {}
local Stats = nil

local function OpenStats()

	local general_pages = net.ReadUInt(19)
	local weapons = net.ReadTable()
	local General_CurPage = 1

	Stats = vgui.Create("DFrame")
	Stats:SetPos(50,50)
	Stats:SetSize(620, 400)
    Stats:SetTitle("TTT Spectator Deathmatch Statistics")
    Stats:MakePopup()
	Stats:Center()

	local PropertySheet = vgui.Create("DPropertySheet", Stats)
	PropertySheet:SetPos(5, 35)
	PropertySheet:SetSize(610, 360)

	local General = vgui.Create("DPanelList")
	General:SetSpacing(2)
	local General_Search = vgui.Create("DTextEntry")
	General_Search:SetText("Search player...")
	General_Search.OnGetFocus = function(self)
		if self:GetValue() == "Search player..." and not self.Focused then
			self.Focused = true
			self:SetText("")
		end
	end
	General_Search.OnEnter = function()
		SpecDM_UpdateStats(true, true)
	end
	General_Search.GetRealValue = function(self)
		local value = self:GetValue()
		if not value or value == "" or (value == "Search player..." and not self.Focused) then
			return false
		end
		return value
	end
	General:AddItem(General_Search)
	local General_SearchButton = vgui.Create("DButton", General)
	General_SearchButton:SetSize(60, 20)
	General_SearchButton:SetText("Search")
	General_SearchButton:SetPos(534, 0)
	General_SearchButton.DoClick = function()
		SpecDM_UpdateStats(true, true)
	end
	local General_ListView = vgui.Create("DListView")
	General_ListView:SetHeight(273)
	General_ListView.CurDesc = false
	General_ListView.SortByColumn = function(self, column, desc)
		General_ListView.CurColumn = column
		General_ListView.CurDesc = not General_ListView.CurDesc
		SpecDM_UpdateStats(true, true)
	end
	local General_First
	General_ListView:AddColumn("Player")
	General_ListView:AddColumn("Kills")
	General_ListView:AddColumn("Top kills in a row")
	General_ListView:AddColumn("Deaths")
	General_ListView:AddColumn("Time in DM (h)")
	General_ListView:AddColumn("Time alive (h)")
	General:AddItem(General_ListView)
	local General_Previous = vgui.Create("DButton", General)
	General_Previous:SetText("Previous")
	General_Previous:SetSize(70, 25)
	General_Previous:SetPos(35, 298)
	General_Previous:SetEnabled(false)
	General_Previous.DoClick = function(self)
		General_CurPage = General_CurPage - 1
		if General_CurPage == 1 then
			self:SetEnabled(false)
			General_First:SetEnabled(false)
		end
		SpecDM_UpdateStats(true, true)
	end
	General_First = vgui.Create("DButton", General)
	General_First:SetText("<<")
	General_First:SetSize(30, 25)
	General_First:SetPos(0, 298)
	General_First:SetEnabled(false)
	General_First.DoClick = function(self)
		General_CurPage = 1
		self:SetEnabled(false)
		General_Previous:SetEnabled(false)
		SpecDM_UpdateStats(true, true)
	end
	local General_Last
	local General_Next = vgui.Create("DButton", General)
	General_Next:SetText("Next")
	General_Next:SetSize(70, 25)
	General_Next:SetPos(489, 298)
	if general_pages <= 15 then
		General_Next:SetEnabled(false)
		if General_Last then General_Last:SetEnabled(false) end
	end
	General_Next.DoClick = function(self)
		General_CurPage = General_CurPage + 1
		if General_CurPage == math.ceil(general_pages/15) then
			self:SetEnabled(false)
		end
		General_Previous:SetEnabled(true)
		SpecDM_UpdateStats(true, true)
	end
	General_Last = vgui.Create("DButton", General)
	General_Last:SetText(">>")
	General_Last:SetSize(30, 25)
	General_Last:SetPos(564, 298)
	General_Last.DoClick = function(self)
		General_CurPage = math.ceil(general_pages/15)
		self:SetEnabled(false)
		General_Next:SetEnabled(false)
		SpecDM_UpdateStats(true, true)
	end

	local General_Page = vgui.Create("DLabel", General)
	General_Page.UpdateText = function(self, text)
		self:SetText(text)
		self:SetFont("SpecDM_Page")
		self:SizeToContents()
		self:CenterHorizontal()
		surface.SetFont("SpecDM_Page")
		local x,y = surface.GetTextSize(text)
		self:SetPos((484+70)/2 - x/2, 302)
	end
	General_Page:UpdateText("1/"..math.ceil(general_pages/15))
	General_Page:SetTextColor(color_black)

	local General_PrevFilter = false
	function SpecDM_UpdateStats(general, filter)
		if general then
			net.Start("SpecDM_AskStats")
			net.WriteUInt(1, 1)
			if General_PrevFilter != (filter and General_Search:GetRealValue()) then
				General_CurPage = 1
				General_PrevFilter = (filter and General_Search:GetRealValue())
			end
			net.WriteUInt(General_CurPage, 19)
			net.WriteUInt(General_ListView.CurColumn or 2, 19)
			local order = nil
			if General_ListView.CurDesc != nil then
				order = General_ListView.CurDesc
			else
				order = true
			end
			net.WriteUInt(order and 1 or 0, 1)
			if not filter or not General_Search:GetRealValue() then
				net.WriteUInt(0, 1)
			else
				net.WriteUInt(1, 1)
				net.WriteString(General_Search:GetRealValue())
			end
			net.SendToServer()
		end
	end

	PropertySheet:AddSheet("General Statistics", General, "icon16/group.png")

	net.Receive("SpecDM_SendStats", function()
		local to_update = net.ReadUInt(1) == 1
		general_pages = net.ReadUInt(19)
		local size = net.ReadUInt(19)
		local compressed = net.ReadData(size)
		if not compressed then return end
		local uncompressed = util.Decompress(compressed)
		if not uncompressed then return end
		local decoded = von.deserialize(uncompressed)
		if not decoded then return end
		if to_update then
			General_Page:UpdateText(General_CurPage.."/"..math.ceil(general_pages/15))
			General_ListView:Clear()
			if general_pages <= 15 then
				General_Next:SetEnabled(false)
				General_Last:SetEnabled(false)
			else
				General_Next:SetEnabled(true)
				General_Last:SetEnabled(true)
			end
			if General_CurPage == 1 then
				General_Previous:SetEnabled(false)
				General_First:SetEnabled(false)
			else
				General_Previous:SetEnabled(true)
				General_First:SetEnabled(true)
			end
			General_Page:UpdateText(General_CurPage.."/"..math.ceil(general_pages/15))
			for k,v in ipairs(decoded) do
				if not v.name or not tonumber(v.kills) or not tonumber(v.kill_row) or not tonumber(v.deaths) or not tonumber(v.time_dm) or not tonumber(v.time_playing) then continue end
				local time_dm = math.Round(tonumber(v.time_dm) / 3600, 2)
				local time_playing = math.Round(tonumber(v.time_playing) / 3600, 2)
				General_ListView:AddLine(v.name, tonumber(v.kills), tonumber(v.kill_row), tonumber(v.deaths), time_dm, time_playing)
			end
		end
	end)

	local Weapon_stats = vgui.Create("DListView")
	Weapon_stats:AddColumn("Weapon name")
	Weapon_stats:AddColumn("Number of kills")
	for k,v in pairs(weapons) do
		local name = weapon_tbl[k] and weapon_tbl[k] or k
		Weapon_stats:AddLine(name, v)
	end
	PropertySheet:AddSheet("Your weapon statistics", Weapon_stats, "icon16/gun.png")

	SpecDM_UpdateStats(true, false)
	SpecDM_UpdateStats(false, false)

end
net.Receive("SpecDM_OpenStats", OpenStats)

hook.Add("Initialize", "Initialize_SpecDMStats", function()
	for k,v in pairs(weapons.GetList()) do
		if v.PrintName then
			weapon_tbl[v.ClassName] = v.PrintName
		end
	end
end)

concommand.Add("specdm_stats", function()
	net.Start("SpecDM_AskOpenStats")
	net.SendToServer()
end)

local bind = false
hook.Add("Think", "Think_SpecDMStats", function()
	if input.IsKeyDown(SpecDM.StatsFKey) then
		if not bind then
			bind = true
			if IsValid(Stats) and Stats:IsVisible() then
				Stats:Close()
				return false
			else
				RunConsoleCommand("specdm_stats")
			end
		end
	else
		bind = false
	end
end)