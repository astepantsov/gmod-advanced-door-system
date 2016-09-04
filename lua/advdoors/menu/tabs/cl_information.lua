local TAB = {}

TAB.Title = "Information"
TAB.Access = {
	NO_ACCESS, 
	OWNER, 
	COOWNER, 
	ADMIN
}

TAB.Function = function(frame, door)
	local fontMenu = mgui.CreateFont("menu", {size = 18})
	local pnl_information = vgui.Create("mgPanel", frame)
	pnl_information:SetPos(5, 75)
	pnl_information:SetSize(frame:GetWide() - 10, frame:GetTall() - 80)
	pnl_information:SetVisible(false)
	
	local isOwned = AdvDoors.getOwner(door)
	local ownerName = AdvDoors.getOwnerName(door)
	
	local labelOwner = vgui.Create("DLabel", pnl_information)
	labelOwner:SetPos(5, 16)
	labelOwner:SetText("Owner: ")
	labelOwner:SetFont(fontMenu)
	labelOwner:SizeToContents()
	local ownerItem = vgui.Create("mgItem", pnl_information)
	ownerItem:SetPos(10 + labelOwner:GetWide(), 10)
	ownerItem:SetSize(110, 32)
	ownerItem:SetName(ownerName or "No owner") 
	ownerItem:SetSteamID(AdvDoors.getOwnerSteamID64(door) or "")
	ownerItem:SetType("Player")
	if ownerName then
		ownerItem.DoClick = function()
			gui.OpenURL("http://steamcommunity.com/profiles/" .. AdvDoors.getOwnerSteamID64(door) .. "/")
		end
	end
	
	local labelCoowner = vgui.Create("DLabel", pnl_information)
	labelCoowner:SetPos(5, 54)
	labelCoowner:SetText("Coowners: ")
	labelCoowner:SetFont(fontMenu)
	labelCoowner:SizeToContents()
	local coownerLayout = vgui.Create("DIconLayout", pnl_information)
	coownerLayout:SetWidth(frame:GetWide() - labelCoowner:GetWide() - 10);
	coownerLayout:SetPos(10 + labelCoowner:GetWide(), 47)
	coownerLayout:SetSpaceX(5)
	coownerLayout:SetSpaceY(5)
	local hNew = 0;
	local testtable = {
	{"TestNameasdasdasdasdsdadas", "76561198079040229"},
	{"TestName", "76561197997600622"},
	{"TestName", "TestSteamID"},
	{"TestName", "TestSteamID"},
	{"TestName", "TestSteamID"},
	{"TestName132321321321123213312", "TestSteamID"},
	{"TestName", "TestSteamID"},
	{"TestName", "TestSteamID"},
	{"TestName", "TestSteamID"},
	{"TestName", "TestSteamID"},
	{"TestName", "TestSteamID"},
	{"TestName", "TestSteamID"},
	{"TestName", "TestSteamID"},
	{"TestName", "TestSteamID"},
	{"TestName", "TestSteamID"},
	{"TestName", "TestSteamID"}
	}
	local elements = 0;
	local coOwners = door:getKeysCoOwners()
	if coOwners then
		for k,v in pairs(coOwners) do
			elements = elements + 1;
			local coownerItem = coownerLayout:Add("mgItem")
			coownerItem:SetSize(110, 32)
			coownerItem:SetName(v:Name()) 
			coownerItem:SetSteamID(v:SteamID64())
			coownerItem:SetType("Player")
			if elements == 3 then
				local CoownersMore = coownerLayout:Add("mgMenu")
				CoownersMore:SetText("and " .. (#coOwners - elements) .. " more")
				CoownersMore:SetSize(110, 32)
				CoownersMore.ChoicePanelCreated = function(self, btn) btn:SetDisabled(true) end
				for l = 4, #coOwners, 1 do
					CoownersMore:AddChoice(coOwners[l]:Name(), coOwners[l]:SteamID64())
				end
				break
			end
		end
	else
		local pos_x, pos_y = coownerLayout:GetPos();
		coownerLayout:SetPos(pos_x, pos_y + 8);
		local noCoowners = coownerLayout:Add("mgStatusLabel")
		noCoowners:SetType("primary")
		noCoowners:SetText("This door has no coowners")
		noCoowners:SizeToContents(true) 
	end

	coownerLayout:InvalidateLayout(true)
	local labelGroups = vgui.Create("DLabel", pnl_information)
	labelGroups:SetPos(5, 67 + coownerLayout:GetTall())
	labelGroups:SetText("Door group: ")
	labelGroups:SetFont(fontMenu)
	labelGroups:SizeToContents()
	
	local labelGroupOwner = vgui.Create("mgStatusLabel", pnl_information)
	labelGroupOwner:SetType("primary")
	labelGroupOwner:SetText(door:getKeysDoorGroup() or "No group")
	labelGroupOwner:SetPos(10 + labelGroups:GetWide(), 70 + coownerLayout:GetTall());
	labelGroupOwner:SizeToContents(true)
	
	local x, y = labelGroupOwner:GetPos();
	local labelTeams = vgui.Create("DLabel", pnl_information)
	labelTeams:SetPos(5, y + labelGroupOwner:GetTall() + 15)
	labelTeams:SetText("Door teams: ")
	labelTeams:SetFont(fontMenu)
	labelTeams:SizeToContents()
	
	local teamsLayout = vgui.Create("DIconLayout", pnl_information)
	teamsLayout:SetSize(frame:GetWide() - labelTeams:GetWide() - 10, 69)
	teamsLayout:SetPos(10 + labelTeams:GetWide(), y + labelGroupOwner:GetTall() + 16)
	teamsLayout:SetSpaceX(5)
	teamsLayout:SetSpaceY(5)
	local teamWidth = 0
	local teamCount = 0
	local doorTeams = door:getKeysDoorTeams()
	
	if doorTeams then
		for k,v in pairs(doorTeams) do
			if (teamWidth + 100 > teamsLayout:GetWide() - labelTeams:GetWide()) then
				local teamsMore = teamsLayout:Add("mgMenu")
				teamsMore:SetText("and " .. (#doorTeams - teamCount) .. " more")
				teamsMore:SetSize(100, 18)
				teamsMore.ChoicePanelCreated = function(self, btn) btn:SetDisabled(true) end
				for l,p in pairs(doorTeams) do
					if l >= k then
						teamsMore:AddChoice(team.GetName(l), "")
					end
				end
				break
			end			
			local teamItem = teamsLayout:Add("mgStatusLabel")
			teamItem:SetType(k == LocalPlayer():Team() and "success" or "primary")
			teamItem:SetText(team.GetName(k))
			teamItem:SizeToContents(true)
			teamItem:InvalidateLayout(true)
			
			teamWidth = teamWidth + teamItem:GetWide()
			teamCount = teamCount + 1
		end
	else
		local noTeams = teamsLayout:Add("mgStatusLabel")
		noTeams:SetType("primary")
		noTeams:SetText("This door has no teams assigned")
		noTeams:SizeToContents(true)
	end
	
	x, y = labelTeams:GetPos()
	
	local labelPurchase = vgui.Create("DLabel", pnl_information)
	labelPurchase:SetPos(5, y + labelTeams:GetTall() + 15)
	labelPurchase:SetText("Buy a door for")
	labelPurchase:SetFont(fontMenu)
	labelPurchase:SizeToContents()
	labelPurchase:InvalidateLayout(true)

	local labelPrice = vgui.Create("mgStatusLabel", pnl_information)
	labelPrice:SetPos(10 + labelPurchase:GetWide(), y + labelTeams:GetTall() + 15)
	labelPrice:SetType("primary")
	labelPrice:SetText(DarkRP.formatMoney(door:getDoorPrice() or GAMEMODE.Config.doorcost))
	labelPrice:SizeToContents(true)
	
	local buttonPurchase = vgui.Create("mgButton", pnl_information)
	buttonPurchase:SetPos(labelPurchase:GetWide() + labelPrice:GetWide(), y + labelTeams:GetTall() + 10)
	buttonPurchase:SetSize(100, labelPrice:GetTall() + 10)
	buttonPurchase:SetText("Purchase")
	buttonPurchase.DoClick = function()
		RunConsoleCommand("darkrp", "toggleown")
		net.Receive("advdoors_purchased", function()
			if frame and IsValid(frame) then
				frame:Remove()
				AdvDoors.openMenu(door)
				mgui.Notify("You have bought this door for " .. DarkRP.formatMoney(door:getDoorPrice() or GAMEMODE.Config.doorcost))
			end
		end)
	end
		
	if isOwned then
		buttonPurchase:SetDisabled(true)
		local labelOwned = vgui.Create("mgStatusLabel", pnl_information)
		labelOwned:SetPos(labelPrice:GetWide() + labelPurchase:GetWide() + buttonPurchase:GetWide() + 5, y + labelTeams:GetTall() + 15)
		labelOwned:SetType(isOwned == LocalPlayer() and "success" or "danger")
		labelOwned:SetText(isOwned == LocalPlayer() and "You are the owner of this door and cannot purchase it" or "This door is owned already and cannot be purchased")
		labelOwned:SizeToContents(true)
	end
	
	local labelRent = vgui.Create("DLabel", pnl_information)
	labelRent:SetPos(5, select(2, labelPurchase:GetPos()) + labelPurchase:GetTall() + 15)
	labelRent:SetText("Rent this door for ")
	labelRent:SetFont(fontMenu)
	labelRent:SizeToContents()
	labelRent:InvalidateLayout(true)
	
	local labelRentInfo = vgui.Create("mgStatusLabel", pnl_information)
	labelRentInfo:SetPos(10 + labelRent:GetWide(), select(2, labelRent:GetPos()))
	labelRentInfo:SetType(isOwned == LocalPlayer() and "success" or door:GetNWBool("canRent", false) == true and "primary" or isOwned and "danger" or "warning")
	labelRentInfo:SetText(isOwned == LocalPlayer() and "You are the owner of this door and cannot rent it" or door:GetNWBool("canRent", false) == true and door:GetNWFloat("rentPrice") .. "$ / " .. door:GetNWFloat("rentLength") .. " minute(s)" or isOwned and "Owner of this door doesn't want to rent it out" or "You cannot rent this door as it is not owned by anyone yet")
	labelRentInfo:SizeToContents(true)
	
	pnl_information.PaintOver = function()
		surface.SetDrawColor(mgui.Colors.Blue)
		surface.DrawOutlinedRect(0, 0, pnl_information:GetWide(), pnl_information:GetTall())
		surface.DrawLine(0, select(2, labelTeams:GetPos()) + labelTeams:GetTall() + 5, pnl_information:GetWide(), select(2, labelTeams:GetPos()) + labelTeams:GetTall() + 5)
		if isOwned then
			surface.SetDrawColor(37, 37, 37, 150)
			surface.DrawRect(1, select(2, labelTeams:GetPos()) + labelTeams:GetTall() + 6, pnl_information:GetWide() - 2, labelPurchase:GetTall() + 18)
		end
		surface.SetDrawColor(mgui.Colors.Blue)
		surface.DrawLine(0, select(2, labelPurchase:GetPos()) + labelPurchase:GetTall() + 8, pnl_information:GetWide(), select(2, labelPurchase:GetPos()) + labelPurchase:GetTall() + 8)
	end
	
	return pnl_information
end

AdvDoors.AddMenuTab(TAB, 1)