surface.CreateFont("DL_ChatCategory", {
	font = "DermaDefault",
	size = 17,
	weight = 700
})

surface.CreateFont("DL_ChatFont", {
	font = "DermaDefault",
	size = 17
})

surface.CreateFont("DL_ChatPlayer", {
	font = "DermaDefault",
	size = 16,
	weight = 600
})

function AAText(text, font, x, y, color, align)
	draw.SimpleText(text, font, x + 1, y + 1, Color(0, 0, 0, math.min(color.a, 120)), align)
	draw.SimpleText(text, font, x + 2, y + 2, Color(0, 0, 0, math.min(color.a, 50)), align)
	draw.SimpleText(text, font, x, y, color, align)
end

local PANEL = {}

function PANEL:Init()
	self.LockedIcon = Material("icon16/lock.png")
end

function PANEL:SetPlayer(ply, playertype)
	self.Player = ply
	self.PlayerName = ply:Nick()
	self.PlayerValid = true
    
	self.Avatar = vgui.Create("AvatarImage", self)
	self.Avatar:SetSize(32, 32)
	self.Avatar:SetPos(5, 0)
	self.Avatar:CenterVertical()
	self.Avatar:SetPlayer(self.Player, 32)
    
	self.PlayerType = playertype
end

function PANEL:SetRID(RID)
	self.RID = RID
end

function PANEL:Think()
	self.PlayerValid = IsValid(self.Player)
end

function PANEL:Paint(w, h)
	surface.SetTextColor(color_black)
	surface.SetFont("DL_ChatPlayer")
	surface.SetTextPos(40, 0)
	surface.DrawText(self.PlayerName)
    
	surface.SetFont("DL_ChatPlayer")
	surface.SetTextPos(40, 16)
    
	if self.PlayerValid then
		local txt
        
		if self.PlayerType == DAMAGELOG_REPORTED then
			surface.SetTextColor(Color(190, 18, 29))
			txt = TTTLogTranslate(GetDMGLogLang, "Reported")
		elseif self.PlayerType == DAMAGELOG_VICTIM then
			surface.SetTextColor(Color(18, 190, 29))
			txt = TTTLogTranslate(GetDMGLogLang, "Victim")
		elseif self.PlayerType == DAMAGELOG_ADMIN then
			surface.SetTextColor(Color(160, 160, 0))
			txt = TTTLogTranslate(GetDMGLogLang, "Admin")
		end
        
		if txt then
			surface.DrawText(txt)
            
			if self.Player:GetNWInt("DL_ForcedStay", -1) == self.RID then
				local textWidth = select(1, surface.GetTextSize(txt))
                
				surface.SetDrawColor(color_white)
				surface.SetMaterial(self.LockedIcon)
				surface.DrawTexturedRect(45 + textWidth, 15, 12, 12)
			end
		end
	else
		surface.SetTextColor(color_black)
		surface.DrawText(TTTLogTranslate(GetDMGLogLang, "ChatDisconnected"))
	end
end

vgui.Register("DL_ChatPlayer", PANEL, "DPanel")

local PANEL = {}

function PANEL:Init()
	self.List = vgui.Create("DPanelList", self)
	self.List:SetSpacing(2)
	self.List:SetPos(0, 25)
	self.List:SetSize(self:GetWide(), self:GetTall() - 20)
    
	self.Players = {}
	self.PlayerTypes = {}
end

function PANEL:SetRID(RID)
	self.RID = RID
end

function PANEL:SetCategoryName(name)
	self.Name = name
end

function PANEL:AddPlayer(ply, playertype)
	if not table.HasValue(self.Players, ply) then
		local panel = vgui.Create("DL_ChatPlayer", self)
		panel:SetHeight(30)
		panel:SetPlayer(ply, playertype)
		panel:SetRID(self.RID)
        
		self.List:AddItem(panel)
        
		table.insert(self.Players, ply)
        
		self.PlayerTypes[ply] = playertype
	end
end

function PANEL:Paint()
	if not self.Name then return end
    
	surface.SetFont("DL_ChatCategory")
	surface.SetTextColor(Color(150, 150, 150))
	surface.SetTextPos(5, 5)
	surface.DrawText(self.Name)
end

vgui.Register("DL_ChatCategory", PANEL, "DPanel")

local PANEL = {}

function PANEL:Init()
	self:EnableVerticalScrollbar(true)
    
	self.Normal = vgui.Create("DL_ChatCategory", self)
	self.Normal:SetCategoryName(TTTLogTranslate(GetDMGLogLang, "ChatPlayers"))
    
	self.Admins = vgui.Create("DL_ChatCategory", self)
	self.Admins:SetCategoryName(TTTLogTranslate(GetDMGLogLang, "ChatAdmins"))
end

function PANEL:SetRID(RID)
	self.Normal:SetRID(RID)
	self.Admins:SetRID(RID)
end

function PANEL:AddPlayer(ply, playertype)
	if playertype == DAMAGELOG_ADMIN then
		self.Admins:AddPlayer(ply, playertype)
	else
		self.Normal:AddPlayer(ply, playertype)
	end
    
	self.Normal:SetSize(self:GetWide(), #(self.Normal.Players or {}) * 32 + 25)
    
	self.Normal.List:SetSize(self:GetWide(), self.Normal:GetTall() - 25)
    
	self.Admins:SetPos(0, self.Normal:GetTall() + 2)
	self.Admins:SetSize(self:GetWide(), #(self.Admins.Players or {}) * 32 + 25)
    
	self.Admins.List:SetSize(self:GetWide(), self.Admins:GetTall() - 25)
end

function PANEL:RemoveAdmin(ply)
	for key, admin in pairs(self.Admins.Players) do
		if admin == ply then
			table.remove(self.Admins.Players, key)
            
			break
		end
	end
end

function PANEL:GetPlayers()
	local tbl = {}
    
	for _, v in pairs(self.Normal.Players or {}) do
		if not table.HasValue(tbl, v) then
			table.insert(tbl, v)
		end
	end
    
	for _, v in pairs(self.Admins.Players or {}) do
		if not table.HasValue(tbl, v) then
			table.insert(tbl, v)
		end
	end
    
	return tbl
end

function PANEL:Paint(w, h)
	local background = Color(235, 240, 243)
    
	surface.SetDrawColor(background)
    
	surface.DrawRect(0, 0, w, h - 10)
	surface.DrawRect(w - 10, h - 10, w, h)
	draw.RoundedBox(4, 0, h - 12, w - 8, 12, background)
end

vgui.Register("DL_ChatList", PANEL, "DPanelList")

Damagelog.CurrentChats = Damagelog.CurrentChats or {}

function Damagelog:StartChat(report, admins, victim, attacker, players, history, adminReport)
	local Chat = vgui.Create("DFrame")
	Chat:SetSize(600, 350)
	Chat:SetTitle(TTTLogTranslate(GetDMGLogLang, "ChatTitle"))
	Chat:Center()
    
	Chat.RID = report
    
	table.insert(self.CurrentChats, Chat)
    
	Chat:SetDeleteOnClose(false)
    
	Chat.VictimName = victim:Nick()
	Chat.AttackerName = attacker:Nick()
	Chat.OnRemove = function()
		for k, v in pairs(self.CurrentChats) do
			if v == Chat then
				table.remove(self.CurrentChats, k)
			end
		end
	end

	local List = vgui.Create("DL_ChatList", Chat)
	List:SetRID(Chat.RID)
	List:SetPos(2, 26)
	List:SetSize(152, Chat:GetTall() - 57)
    
	for _, v in ipairs(admins) do
		List:AddPlayer(v, DAMAGELOG_ADMIN)
	end
    
	if not adminReport then
		List:AddPlayer(victim, DAMAGELOG_VICTIM)
	end
	
    List:AddPlayer(attacker, DAMAGELOG_REPORTED)
	
    for _, v in ipairs(players) do
		List:AddPlayer(v, DAMAGELOG_OTHER)
	end

	local Actions = vgui.Create("DButton", Chat)
	Actions:SetPos(2, Chat:GetTall() - 30)
	Actions:SetSize(152, 28)
	Actions:SetText(TTTLogTranslate(GetDMGLogLang, "Actions"))
    
	if not LocalPlayer():CanUseRDMManager() then
		Actions:SetDisabled(true)
	end
    
	Actions.DoClick = function(self)
		local menu = DermaMenu()

		menu:AddOption(TTTLogTranslate(GetDMGLogLang, "AddPlayer"), function()
			local selection = vgui.Create("DFrame")
			selection:SetTitle(TTTLogTranslate(GetDMGLogLang, "SelectPlayer"))
			selection:SetSize(270, 400)
			selection:SetDraggable(false)
			selection:Center()
			selection:MakePopup()
            
			selection.Think = function(panel)
				panel:MoveToFront()
			end
            
			local button = vgui.Create("DButton", selection)
			button:SetText(TTTLogTranslate(GetDMGLogLang, "AddSelected"))
			button:SetSize(255, 25)
			button:SetPos(0, 28)
			button:CenterHorizontal()
            
			local plist = vgui.Create("DPanelList", selection)
			plist:SetPos(0, 60)
			plist:SetSize(255, 340)
			plist:CenterHorizontal()
			plist:EnableVerticalScrollbar(true)
            
			local cur_selected
            
			plist.AddPlayer = function(pnl, pl)
				local pl = pl
                
				if not IsValid(pl) then return end
                
				if not IsValid(pnl) then return end
                
				local ply = vgui.Create("DPanel")
				ply:SetSize(0, 30)
                
				local alpha = 140
				local col = {r = 40, g = 40, b = 40}
				local col_selected = {r = 204, g = 204, b = 51}
                
				ply.pl = pl
                
				local function checkValidity()
					if not IsValid(pl) then
						ply:Remove()
						pnl:Clear(false)
                        
						return false
					end
                    
					return true
				end
                
				ply.Think = checkValidity
				ply.Paint = function(self, w, h)
					if not checkValidity() then return end
                    
					if cur_selected ~= ply then
						draw.RoundedBox(0, 0, 0, w, h, Color(13, 14, 15, alpha))
						draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(col.r + 40, col.g + 40, col.b + 40, alpha))
						draw.RoundedBox(0, 2, 2, w - 4, h - 4, Color(col.r, col.g, col.b, alpha))
					else
						draw.RoundedBox(0, 0, 0, w, h, Color(13, 14, 15, alpha))
						draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(col_selected.r + 40, col_selected.g + 40, col_selected.b + 40, alpha))
						draw.RoundedBox(0, 2, 2, w - 4, h - 4, Color(col_selected.r, col_selected.g, col_selected.b, alpha))
					end
                    
					AAText(pl:Nick(), "GModNotify", 40, 7, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
				end
				ply.OnMousePressed = function(pnl, mc)
					if mc == MOUSE_LEFT and cur_selected ~= ply then
						cur_selected = ply
					end
				end
                
				local ava = vgui.Create("AvatarImage", ply)
				ava:SetSize(24, 24)
				ava:SetPlayer(pl, 32)
				ava:SetPos(4, 4)
                
				pnl:AddItem(ply)
			end
            
			local list = List:GetPlayers()
            
			for _, v in ipairs(player.GetHumans()) do
				if not table.HasValue(list, v) then
					plist:AddPlayer(v)
				end
			end
            
			button.DoClick = function()
				if IsValid(cur_selected) and IsValid(cur_selected.pl) then
					local ply = cur_selected.pl
                    
					net.Start("DL_AddChatPlayer")
					net.WriteUInt(Chat.RID, 32)
					net.WriteEntity(ply)
					net.SendToServer()
				end
				selection:Close()
			end
		end):SetImage("icon16/user_add.png")

		local forceStayPnl = vgui.Create("DMenuOption", menu)
        
		local forceStayList = DermaMenu(menu)
		forceStayList:SetVisible(false)
		forceStayPnl:SetSubMenu(forceStayList)
		forceStayPnl:SetText(TTTLogTranslate(GetDMGLogLang, "ForceStay"))
		forceStayPnl:SetImage("icon16/lock_add.png")
        
		menu:AddPanel(forceStayPnl)
        
		forceStayList:AddOption(TTTLogTranslate(GetDMGLogLang, "AllPlayers"), function()
			net.Start("DL_ForceStay")
			net.WriteUInt(Chat.RID, 32)
			net.WriteUInt(1, 1)
			net.SendToServer()
		end):SetImage("icon16/group_link.png")

		forceStayList:AddSpacer()

		for _, v in pairs(List.Normal.Players) do
			local playerPanel = forceStayList:AddOption(IsValid(v) and v:Nick() or TTTLogTranslate(GetDMGLogLang, "ChatDisconnected"), function()
				if not IsValid(v) then
					Damagelog:Notify(DAMAGELOG_NOTIFY_ALERT, TTTLogTranslate(GetDMGLogLang, "InvalidPlayerChat"), 2, "buttons/weapon_cant_buy.wav")
                    
					return
				end
                
				net.Start("DL_ForceStay")
				net.WriteUInt(Chat.RID, 32)
				net.WriteUInt(0, 1)
				net.WriteEntity(v)
				net.SendToServer()
			end)
            
			local playerType = List.Normal.PlayerTypes[v]
			if playerType == DAMAGELOG_VICTIM then
				playerPanel:SetImage("icon16/user_green.png")
			elseif playerType == DAMAGELOG_REPORTED then
				playerPanel:SetImage("icon16/user_red.png")
			else
				playerPanel:SetImage("icon16/user.png")
			end
		end

		local releasePnl = vgui.Create("DMenuOption", menu)
        
		local releaseList = DermaMenu(menu)
		releaseList:SetVisible(false)
        
		releasePnl:SetSubMenu(releaseList)
		releasePnl:SetText(TTTLogTranslate(GetDMGLogLang, "ReleaseChat"))
		releasePnl:SetImage("icon16/lock_open.png")
        
		menu:AddPanel(releasePnl)
        
		releaseList:AddOption(TTTLogTranslate(GetDMGLogLang, "AllPlayers"), function()
			net.Start("DL_Release")
			net.WriteUInt(Chat.RID, 32)
			net.WriteUInt(1, 1)
			net.SendToServer()
		end):SetImage("icon16/group_go.png")

		releaseList:AddSpacer()

		for _, v in pairs(List.Normal.Players) do
			local playerPanel = releaseList:AddOption(IsValid(v) and v:Nick() or TTTLogTranslate(GetDMGLogLang, "ChatDisconnected"), function()
				if not IsValid(v) then
					Damagelog:Notify(DAMAGELOG_NOTIFY_ALERT, TTTLogTranslate(GetDMGLogLang, "InvalidPlayerChat"), 2, "buttons/weapon_cant_buy.wav")
                    
					return
				end
                
				net.Start("DL_Release")
				net.WriteUInt(Chat.RID, 32)
				net.WriteUInt(0, 1)
				net.WriteEntity(v)
				net.SendToServer()
			end)
            
			local playerType = List.Normal.PlayerTypes[v]
			if playerType == DAMAGELOG_VICTIM then
				playerPanel:SetImage("icon16/user_green.png")
			elseif playerType == DAMAGELOG_REPORTED then
				playerPanel:SetImage("icon16/user_red.png")
			else
				playerPanel:SetImage("icon16/user.png")
			end
		end

		menu:AddOption("Close chat", function()
			net.Start("DL_CloseChat")
			net.WriteUInt(Chat.RID, 32)
			net.SendToServer()
		end):SetImage("icon16/disconnect.png")

		menu:AddOption("Leave chat", function()
			if #List.Admins.Players <= 1 then
				Damagelog:Notify(DAMAGELOG_NOTIFY_ALERT, TTTLogTranslate(GetDMGLogLang, "CannotLeaveChat"), 4, "buttons/weapon_cant_buy.wav")
			else
				Chat:Close()
                
				net.Start("DL_LeaveChat")
				net.WriteUInt(Chat.RID, 32)
				net.SendToServer()
                
				for k, v in pairs(Damagelog.CurrentChats) do
					if v == Chat then
						table.remove(Damagelog.CurrentChats, k)
                        
						break
					end
				end
                
				Chat:Stop()
			end
		end):SetImage("icon16/door_out.png")
        
		menu:Open()
	end

	Chat.AddPlayer = function(self, ply, category)
		List:AddPlayer(ply, category)
	end

	Chat.RemoveAdmin = function(self, admin)
		List:RemoveAdmin(admin)
	end

	local Sheet = vgui.Create("DPropertySheet", Chat)
	Sheet:SetPos(List:GetWide()+2, 25)
	Sheet:SetSize(Chat:GetWide() - List:GetWide() - 4, Chat:GetTall() - 26)
    
	Sheet.PaintOver = function(self, w, h)
		surface.SetDrawColor(color_black)
		surface.DrawLine(0, 5, 0, 30)
	end

	local ChatBox = vgui.Create("DPanel")
	ChatBox.Paint = function(self, w, h)
		surface.SetDrawColor(Color(101, 100, 105, 255))
		surface.DrawRect(0, 0, w, h)
        
		surface.SetDrawColor(Color(220, 220, 220, 255))
		surface.DrawRect(0, h - 35, w, 35)
	end

	local RichText = vgui.Create("RichText", ChatBox)
	RichText:SetPos(5, 10)
	RichText:SetSize(Sheet:GetWide() - 25, Sheet:GetTall() - 78)
    
	RichText.AddText = function(self, nick, color, text)
		self.m_FontName = "DL_ChatFont"
        
		self:SetFontInternal("DL_ChatFont")
		self:InsertColorChange(color.r, color.g, color.b, color.a or 255)
		self:AppendText(nick.. ": ")
		self:InsertColorChange(255, 255, 255, 255)
		self:AppendText(text.."\n")
	end
    
	Chat.RichText = RichText

	Sheet:AddSheet("Chatbox", ChatBox, "icon16/application_view_list.png")

	local TextEntry = vgui.Create("DTextEntry", ChatBox)
	local Send = vgui.Create("DButton", ChatBox)

	Chat.Stop = function(self)
		TextEntry:SetDisabled(true)
		Actions:SetDisabled(true)
		self:SetDeleteOnClose(true)
	end

	Chat.AddMessage = function(self, msg)
		RichText.m_FontName = "DL_ChatFont"
        
		RichText:SetFontInternal("DL_ChatFont")
		RichText:InsertColorChange(230, 62, 99, 255)
		RichText:AppendText(msg.."\n")
	end

	local function SendMessage(msg)
		if #msg == 0 or #msg > 200 then return end
        
		net.Start("DL_SendChatMessage")
		net.WriteUInt(report, 32)
		net.WriteString(msg)
		net.SendToServer()
        
		TextEntry:SetText("")
		TextEntry:RequestFocus()
	end

	TextEntry:SetPos(3, Sheet:GetTall() - 65)
	TextEntry:SetSize(Sheet:GetWide() - 80, 25)
    
	TextEntry.OnEnter = function(self)
		SendMessage(self:GetValue())
	end

	Send:SetPos(Sheet:GetWide() - 75, Sheet:GetTall() - 65)
	Send:SetSize(55, 25)
	Send:SetText(TTTLogTranslate(GetDMGLogLang, "Send"))
    
	Send.DoClick = function()
		SendMessage(TextEntry:GetValue())
	end

	Chat:MakePopup()

	timer.Simple(0.1, function()
		for _, v in ipairs(history) do
			RichText:AddText(v.nick, v.color, v.msg)
		end
        
		TextEntry:RequestFocus()
	end)

end

net.Receive("DL_BroadcastMessage", function()
	local id = net.ReadUInt(32)
	local ply = net.ReadEntity()
	local color = net.ReadColor()
	local message = net.ReadString()

	if not id or not IsValid(ply) or not color or not message then return end

	for _, v in pairs(Damagelog.CurrentChats) do
		if v.RID == id then
			if not v:IsVisible() then
				if not v.MissingMessages then
					v.MissingMessages = 1
				else
					v.MissingMessages = v.MissingMessages + 1
				end
			end
            
			v.RichText:AddText(ply:Nick(), color, message)
            
			break
		end
	end
end)

net.Receive("DL_OpenChat", function()
	local report = net.ReadUInt(32)
	local adminReport = net.ReadUInt(1) == 1
	local admin = net.ReadEntity()
	local victim = net.ReadEntity()
	local attacker = net.ReadEntity()
	local players = net.ReadTable()

	local loadhistory = net.ReadUInt(1) == 1

	local history = {}

	if loadhistory then
		local length = net.ReadUInt(32)
		local compressed = net.ReadData(length)
		local json = util.Decompress(compressed)
        
		history = util.JSONToTable(json)
	end

	if not report or not IsValid(admin) or not IsValid(victim) or not IsValid(attacker) then return end

	Damagelog:StartChat(report, {admin}, victim, attacker, players, history, adminReport)
end)

net.Receive("DL_JoinChatCL", function()
	local is_joining = net.ReadUInt(1) == 1

	if is_joining then
		local id = net.ReadUInt(32)
		local size = net.ReadUInt(32)
		local compressed = net.ReadData(size)
        
		local not_compressed = util.Decompress(compressed)
		local history = util.JSONToTable(not_compressed)
        
		local tbl = net.ReadTable()

		for _, v in pairs(Damagelog.CurrentChats) do
			if v.RID == id then
				if not v:IsVisible() then
					v:SetVisible(true)
				end
                
				v:Center()
				v:MakePopup()
                
				return
			end
		end

		Damagelog:StartChat(id, tbl.admins, tbl.victim, tbl.attacker, tbl.players, history)
	else
		local id = net.ReadUInt(32)
		local ply = net.ReadEntity()
		local category = net.ReadUInt(32)

		local chat = Damagelog.CurrentChats[id]
		if not chat then return end

		chat:AddPlayer(ply, category)
	end
end)

local drawing = false

hook.Add("TTTBeginRound", "Damagelog_Chat", function()
	drawing = false
end)

local exclamation = Material("icon16/exclamation.png")

local show_chats = false

local buttons = {}

local function IsButtonHovered(tbl)
	local mx, my = gui.MousePos()
    
	return (mx >= tbl.x and mx <= (tbl.x + tbl.w)) and (my >= tbl.y and my <= (tbl.y + tbl.h))
end

local pressed_key = false

hook.Add("Think", "Damagelog_Chat", function()
	for _, v in pairs(buttons) do
		if IsButtonHovered(v) and not v.cursor_set then
			vgui.GetWorldPanel():SetCursor("hand")
            
			v.cursor_set = true
		elseif v.cursor_set and not IsButtonHovered(v) then
			vgui.GetWorldPanel():SetCursor("arrow")
            
			v.cursor_set = false
		end
	end

	if input.IsMouseDown(MOUSE_LEFT) and not pressed_key then
		pressed_key = true
        
		for _, v in pairs(buttons) do
			if IsButtonHovered(v) then
				v:callback()
                
				show_chats = false
                
				break
			end
		end
	elseif pressed_key and not input.IsMouseDown(MOUSE_LEFT) then
		pressed_key = false
        
		vgui.GetWorldPanel():SetCursor("arrow")
	end
end)

net.Receive("DL_StopChat", function()
	local id = net.ReadUInt(32)
	local forced = net.ReadUInt(1) == 1

	local msg

	if not forced then
		msg = TTTLogTranslate(GetDMGLogLang, "AdminsDisconnectedChat")
	else
		local admin = net.ReadEntity()
        
		msg = string.format(TTTLogTranslate(GetDMGLogLang, "ChatClosedBy"), admin:Nick())
	end

	for k, v in pairs(Damagelog.CurrentChats) do
		if v.RID == id then
			v:AddMessage(msg)
			v:Stop()
			v:ShowCloseButton(true)
			v:SetDeleteOnClose(true)
            
			table.remove(Damagelog.CurrentChats, k)
            
			break
		end
	end
end)

net.Receive("DL_LeaveChatCL", function()
	local id = net.ReadUInt(32)
	local leaver = net.ReadEntity()

	for _, v in pairs(Damagelog.CurrentChats) do
		if v.RID == id then
			v:RemoveAdmin(leaver)
			v:AddMessage(string.format(TTTLogTranslate(GetDMGLogLang, "AdminLeaveChat"), leaver:Nick()))
		end
	end
end)

net.Receive("DL_ForcePlayerStay", function()
	local id = net.ReadUInt(32)

	for _, v in pairs(Damagelog.CurrentChats) do
		if v.RID == id then
			if not v:IsVisible() then
				v:SetVisible(true)
			end
            
			v:Center()
			v:MakePopup()
			v:ShowCloseButton(false)
		else
			v:ShowCloseButton(true)
			v:SetVisible(false)
		end
	end
end)

net.Receive("DL_ReleaseCL", function()
	local id = net.ReadUInt(32)
    
	for _, v in pairs(Damagelog.CurrentChats) do
		v:ShowCloseButton(true)
	end
end)

net.Receive("DL_ForceStayNotification", function()
	local id = net.ReadUInt(32)
	local allPlayers = net.ReadUInt(1) == 1
    
	local ply
    
	if not allPlayers then
		ply = net.ReadEntity()
	end
    
	local forced = net.ReadUInt(1) == 1
	local admin = net.ReadEntity()

	for _, v in pairs(Damagelog.CurrentChats) do
		if v.RID == id then
			local players = allPlayers and TTTLogTranslate(GetDMGLogLang, "AllPlayersShort") or ply:Nick()
            
			if forced then
				v:AddMessage(string.format(TTTLogTranslate(GetDMGLogLang, "ForcedNotification"), admin:Nick(), players))
			else
				v:AddMessage(string.format(TTTLogTranslate(GetDMGLogLang, "ReleasedNotification"), admin:Nick(), players))
			end
            
			break
		end
	end
end)

net.Receive("DL_ViewChatCL", function()
	local id = net.ReadUInt(32)
	local length = net.ReadUInt(32)
	local compressed = net.ReadData(length)
    
	local json = util.Decompress(compressed)
	local history = util.JSONToTable(json)

	local Frame = vgui.Create("DFrame")
	Frame:SetSize(400, 300)
	Frame:SetTitle(string.format(TTTLogTranslate(GetDMGLogLang, "ReportHistory"), id))
	Frame:Center()
	Frame:MakePopup()

	local RichText = vgui.Create("RichText", Frame)
	RichText:SetPos(5, 25)
	RichText:SetSize(Frame:GetWide() - 10, Frame:GetTall() - 60)
    
	RichText.AddText = function(self, nick, color, text)
		self.m_FontName = "DL_ChatFont"
        
		self:SetFontInternal("DL_ChatFont")
		self:InsertColorChange(color.r, color.g, color.b, color.a or 255)
		self:AppendText(nick.. ": ")
        
		self:InsertColorChange(255, 255, 255, 255)
		self:AppendText(text.."\n")
	end
	RichText.Paint = function(RichText, w, h)
		surface.SetDrawColor(Color(52, 73, 94))
		surface.DrawRect(0, 0, w, h)
	end

	timer.Simple(0.1, function()
		for _, v in ipairs(history) do
			RichText:AddText(v.nick, v.color, v.msg)
		end
	end)

	local Reopen = vgui.Create("DButton", Frame)
	Reopen:SetSize(Frame:GetWide() - 10, 30)
	Reopen:SetPos(5, Frame:GetTall() - 35)
	Reopen:SetText(TTTLogTranslate(GetDMGLogLang, "ReopenChat"))
    
	Reopen.DoClick = function()
		net.Start("DL_StartChat")
		net.WriteUInt(id, 32)
		net.SendToServer()
		Frame:Close()
	end
end)

hook.Add("HUDPaint", "Damagelog_Chat", function()
    local client = LocalPlayer()

	if IsValid(client) then
		local wr, hr = 150, 40
		local w, h = ScrW() / 2, ScrH() - 50

		if not drawing and #Damagelog.CurrentChats > 0 then
			TIPS.Hide()
            
			drawing = true
            
			if Damagelog.ChatButton then
				Damagelog.ChatButton:Remove()
			end
            
			Damagelog.ChatButton = vgui.Create("DButton")
			Damagelog.ChatButton:SetSize(16, 16)
			Damagelog.ChatButton:SetPos(w + wr / 2 - Damagelog.ChatButton:GetWide() - 10, h - Damagelog.ChatButton:GetTall() / 2)
			Damagelog.ChatButton:SetText("")
            
			Damagelog.ChatButton.PaintOver = function(self, w, h)
				surface.SetFont("DermaDefault")
                
				local text = show_chats and "▼" or "▲"
				local wt, ht = surface.GetTextSize(text)
                
				surface.SetTextPos(w / 2 - wt / 2 + 2, h / 2 - ht / 2)
				surface.DrawText(text)
			end
			Damagelog.ChatButton.DoClick = function(self)
				show_chats = not show_chats
			end
		elseif drawing and #Damagelog.CurrentChats == 0 then
			if client:IsSpec() then
				TIPS.Show()
			end
            
			drawing = false
            
			Damagelog.ChatButton:Remove()
		end

		if #Damagelog.CurrentChats > 0 then
			surface.SetDrawColor(Color(171, 181, 198, 200))
			surface.DrawRect(w - wr / 2, h - hr / 2, wr, hr)
            
			surface.SetDrawColor(color_black)
			surface.DrawLine(w - wr / 2, h - hr / 2, w + wr / 2, h - hr / 2)
			surface.DrawLine(w + wr / 2, h - hr / 2, w + wr / 2, h + hr / 2)
			surface.DrawLine(w + wr / 2, h + hr / 2, w - wr / 2, h + hr / 2)
			surface.DrawLine(w - wr / 2, h + hr / 2, w - wr / 2, h - hr / 2)

			surface.SetTextColor(color_black)
			surface.SetFont("DL_ChatCategory")
            
			local text = string.format(TTTLogTranslate(GetDMGLogLang, "ActiveChats"), #Damagelog.CurrentChats)
			local wt, ht = surface.GetTextSize(text)
            
			surface.SetTextPos(w - wr / 2 + 10, h - ht / 2)
			surface.DrawText(text)

			local missing_messages = 0
            
			for _, v in pairs(Damagelog.CurrentChats) do
				if v.MissingMessages then
					missing_messages = missing_messages + v.MissingMessages
				end
			end

			if missing_messages > 0 and not show_chats then
				surface.SetDrawColor(Color(92, 127, 183))
				Damagelog.DrawCircle(w + wr / 2, h - hr / 2, 13, 50)

				surface.SetFont("DL_ChatCategory")
				surface.SetTextPos(w + wr / 2 - 4, h - hr / 2 - 8)
				surface.SetTextColor(color_white)
				surface.DrawText(tostring(missing_messages))
			end

			table.Empty(buttons)

			if show_chats then
				local andStr = TTTLogTranslate(GetDMGLogLang, "And")

				local i = h - hr

				surface.SetFont("DL_ChatPlayer")

				local max_w = 0
                
				for _, v in pairs(Damagelog.CurrentChats) do
					local w = surface.GetTextSize(v.VictimName .. " " .. andStr .. " " .. v.AttackerName)
					if w > max_w then
						max_w = w
					end
				end

				max_w = max_w + 30

				for k, v in ipairs(Damagelog.CurrentChats) do
					if k == 1 then
						i = i - 17
					else
						i = i - 27
					end

					surface.SetDrawColor(color_black)
                    
					local _x, _y, _w, _h = w - max_w / 2, i, max_w, 30
					local tbl = {
						x = _x,
						y = _y,
						w = _w,
						h = _h,
						menu = v,
						callback = function(self)
							if not self.menu:IsVisible() then
								self.menu:SetVisible(true)
							end
                            
							self.menu:Center()
							self.menu:MakePopup()
						end
					}
                    
					table.insert(buttons, tbl)
                    
					surface.DrawRect(_x, _y, _w, _h)
                    
					if IsButtonHovered(tbl) then
						surface.SetDrawColor(Color(255, 255, 255))
					else
						surface.SetDrawColor(Color(215, 216, 222))
					end
                    
					surface.DrawRect(_x + 1, _y + 1, _w - 2, _h - 2)

					surface.SetTextColor(Color(62, 141, 99))
                    
					local victim = v.VictimName
					local w_victim, h_victim = surface.GetTextSize(victim)
					local ytext =  _y + _h / 2 - h_victim / 2
                    
					surface.SetTextPos(_x + 5, ytext)
					surface.DrawText(victim)

					w_victim = w_victim + _x + 5

					local w_and, y_and = surface.GetTextSize(andStr)
                    
					surface.SetTextColor(color_black)
					surface.SetTextPos(w_victim + 3, ytext)
					surface.DrawText(andStr)

					w_victim = w_victim + w_and + 2

					local attacker = v.AttackerName
					local w_attacker, h_attacker = surface.GetTextSize(attacker)
                    
					surface.SetTextPos(w_victim + 3, ytext)
					surface.SetTextColor(Color(181, 62, 99))
					surface.DrawText(attacker)

					surface.SetDrawColor(Color(92, 127, 183))
					Damagelog.DrawCircle(_x + max_w - 15, _y + 15, 10, 20)

					surface.SetTextColor(color_white)
					surface.SetFont("DL_ChatPlayer")
                    
					local count = v.MissingMessages or 0
					local count_x = count >= 10 and 22 or 18
                    
					surface.SetTextPos(_x + max_w - count_x, _y + 7)
					surface.DrawText(tostring(count))
				end
			end
		end
	end
end)
