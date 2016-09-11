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
	
	local labelTenant = vgui.Create("DLabel", pnl_information)
	labelTenant:SetPos(pnl_information:GetWide() - 180, 16)
	labelTenant:SetText("Tenant: ")
	labelTenant:SetFont(fontMenu)
	labelTenant:SizeToContents()
	local tenantItem = vgui.Create("mgItem", pnl_information)
	tenantItem:SetPos(pnl_information:GetWide() - 120, 10)
	tenantItem:SetSize(110, 32)
	tenantItem:SetName(door:GetNWEntity("tenant", false) and door:GetNWEntity("tenant", false):Name() or "No tenant") 
	tenantItem:SetSteamID(door:GetNWEntity("tenant", false) and door:GetNWEntity("tenant", false):SteamID64() or "")
	tenantItem:SetType("Player")
	if door:GetNWEntity("tenant", false) then
		tenantItem.DoClick = function()
			gui.OpenURL("http://steamcommunity.com/profiles/" .. door:GetNWEntity("tenant", false):SteamID64() .. "/")
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
	local elements = 0;
	local coOwners = door:getKeysCoOwners()
	if coOwners and AdvDoors.hasValidCoowner(coOwners) then
		for k,v in pairs(coOwners) do
			elements = elements + 1;
			local ply = AdvDoors.getByUserID(k)
			if IsValid(ply) and ply:IsPlayer() then
				local coownerItem = coownerLayout:Add("mgItem")
				coownerItem:SetSize(110, 32)
				coownerItem:SetName(ply:Name()) 
				coownerItem:SetSteamID(ply:SteamID64())
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
	labelGroups:SetPos(5, select(2, coownerLayout:GetPos()) + coownerLayout:GetTall() + 8)
	labelGroups:SetText("Door group: ")
	labelGroups:SetFont(fontMenu)
	labelGroups:SizeToContents()
	
	local labelGroupOwner = vgui.Create("mgStatusLabel", pnl_information)
	labelGroupOwner:SetType("primary")
	labelGroupOwner:SetText(door:getKeysDoorGroup() or "No group")
	labelGroupOwner:SetPos(10 + labelGroups:GetWide(), select(2, coownerLayout:GetPos()) + coownerLayout:GetTall() + 8);
	labelGroupOwner:SizeToContents(true)
	
	local x, y = labelGroupOwner:GetPos();
	local labelTeams = vgui.Create("DLabel", pnl_information)
	labelTeams:SetPos(5, y + labelGroupOwner:GetTall() + 8)
	labelTeams:SetText("Door teams: ")
	labelTeams:SetFont(fontMenu)
	labelTeams:SizeToContents()
	
	local teamsLayout = vgui.Create("DIconLayout", pnl_information)
	teamsLayout:SetSize(frame:GetWide() - labelTeams:GetWide() - 10, 69)
	teamsLayout:SetPos(10 + labelTeams:GetWide(), y + labelGroupOwner:GetTall() + 8)
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
		mgui.ShowDialog("confirm", "Are you sure that you want to purchase this door?", function()
			RunConsoleCommand("darkrp", "toggleown")
			net.Receive("advdoors_purchased", function()
				if frame and IsValid(frame) then
					frame:Remove()
					AdvDoors.openMenu(door)
					mgui.Notify("You have bought this door for " .. DarkRP.formatMoney(door:getDoorPrice() or GAMEMODE.Config.doorcost))
				end
			end)
		end, "Yes", "No")
	end
		
	if isOwned and not door:isKeysAllowedToOwn(LocalPlayer()) then
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
	labelRentInfo:SetType(isOwned == LocalPlayer() and "success" or (door:GetNWBool("canRent", false) and not door:GetNWBool("tenant", false)) and "primary" or door:GetNWBool("tenant", false) == LocalPlayer() and "warning" or isOwned and "danger" or "warning")
	labelRentInfo:SetText(isOwned == LocalPlayer() and "You are the owner of this door and cannot rent it" or (door:GetNWBool("canRent", false) and not door:GetNWBool("tenant", false)) and DarkRP.formatMoney(door:GetNWFloat("rentPrice")) .. " / " .. door:GetNWFloat("rentLength") .. " minute(s)" or door:GetNWBool("tenant", false) == LocalPlayer() and "Your rent expires at " .. os.date("%H:%M:%S - %d/%m/%Y", os.time() + (door:GetNWFloat("tenantExpire") - CurTime())) or isOwned and "Owner of this door doesn't want to rent it out" or "You cannot rent this door as it is not owned by anyone yet")
	labelRentInfo:SizeToContents(true)
	
	local labelRentPeriods = vgui.Create("DLabel", pnl_information)
	labelRentPeriods:SetPos(5, select(2, labelRent:GetPos()) + labelRent:GetTall() + 8)
	labelRentPeriods:SetText("Amount of periods: ")
	labelRentPeriods:SetFont(fontMenu)
	labelRentPeriods:SizeToContents()
	labelRentPeriods:InvalidateLayout(true)
	
	local sliderRentPeriods = door:GetNWFloat("rentMaxPeriods", 1) == 1 and vgui.Create("mgStatusLabel", pnl_information) or vgui.Create("mgSlider", pnl_information)
	sliderRentPeriods:SetPos(10 + labelRentPeriods:GetWide(), select(2, labelRentPeriods:GetPos()))
	if door:GetNWFloat("rentMaxPeriods", 1) != 1 then
		sliderRentPeriods:ShowAmount(true)
		sliderRentPeriods:SetMinMax(1, door:GetNWFloat("rentMaxPeriods", 1))
		sliderRentPeriods:SetValue(0)
		sliderRentPeriods:SizeToContents()
	else
		sliderRentPeriods:SetType("warning")
		sliderRentPeriods:SetText("You can't change the amount of periods for this door")
		sliderRentPeriods:SizeToContents(true)
	end
	sliderRentPeriods:InvalidateLayout(true)
	
	local labelResult = vgui.Create("DLabel", pnl_information)
	labelResult:SetPos(5, select(2, sliderRentPeriods:GetPos()) + sliderRentPeriods:GetTall() + 8)
	labelResult:SetText("You will pay ")
	labelResult:SetFont(fontMenu)
	labelResult:SizeToContents()
	labelResult:InvalidateLayout(true)
	
	local labelResultMoney = vgui.Create("mgStatusLabel", pnl_information)
	labelResultMoney:SetPos(10 + labelResult:GetWide(), select(2, sliderRentPeriods:GetPos()) + sliderRentPeriods:GetTall() + 8)
	labelResultMoney:SetType("warning")
	labelResultMoney:SetText((door:GetNWFloat("rentMaxPeriods", 1) == 1 and door:GetNWBool("canRent", false)) and DarkRP.formatMoney(door:GetNWFloat("rentPrice")) .. " for " .. door:GetNWFloat("rentLength") .. " minute(s)" or door:GetNWBool("canRent", false) and DarkRP.formatMoney(door:GetNWFloat("rentPrice") * math.Round(sliderRentPeriods:GetValue())) .. " for " .. (door:GetNWFloat("rentLength") * math.Round(sliderRentPeriods:GetValue())) .. " minute(s)" or "unknown")
	labelResultMoney:SizeToContents(true)

	
	sliderRentPeriods.Think = function()
		labelResultMoney:SetText((door:GetNWFloat("rentMaxPeriods", 1) == 1 and door:GetNWBool("canRent", false)) and DarkRP.formatMoney(door:GetNWFloat("rentPrice")) .. " for " .. door:GetNWFloat("rentLength") .. " minute(s)" or door:GetNWBool("canRent", false) and DarkRP.formatMoney(door:GetNWFloat("rentPrice") * math.Round(sliderRentPeriods:GetValue())) .. " for " .. (door:GetNWFloat("rentLength") * math.Round(sliderRentPeriods:GetValue())) .. " minute(s)" or "unknown")
		labelResultMoney:SizeToContents(true)
	end
	
	local rentActive = door:GetNWBool("canRent", false) and isOwned and isOwned != LocalPlayer() and !door:GetNWEntity("tenant", false) and !door:isKeysOwnedBy(LocalPlayer())
	
	local buttonRent = vgui.Create("mgButton", pnl_information)
	buttonRent:SetPos(pnl_information:GetWide() - 106, select(2, labelResultMoney:GetPos()) - 5)
	buttonRent:SetSize(100, 30)
	buttonRent:SetText("Rent this door")
	buttonRent:SetDisabled(!rentActive)
	buttonRent.DoClick = function()
		mgui.ShowDialog("confirm", "Are you sure that you want to rent this door?", function()
			net.Start("advdoors_rent")
			net.WriteTable({
				door = door,
				periods = math.Round(tonumber(door:GetNWFloat("rentMaxPeriods", 1) == 1 and 1 or sliderRentPeriods:GetValue()))
			})
			net.SendToServer()
			net.Receive("advdoors_rent", function(len)
				if frame and IsValid(frame) then
					frame:Remove()
					AdvDoors.openMenu(door)
					mgui.Notify("You have rent this door.")
				end
			end)
		end, "Yes", "No")
	end
	
	pnl_information.PaintOver = function()
		surface.SetDrawColor(mgui.Colors.Blue)
		surface.DrawOutlinedRect(0, 0, pnl_information:GetWide(), pnl_information:GetTall())
		surface.DrawLine(0, select(2, labelTeams:GetPos()) + labelTeams:GetTall() + 5, pnl_information:GetWide(), select(2, labelTeams:GetPos()) + labelTeams:GetTall() + 5)
		if isOwned and not door:isKeysAllowedToOwn(LocalPlayer()) then
			surface.SetDrawColor(37, 37, 37, 150)
			surface.DrawRect(1, select(2, labelTeams:GetPos()) + labelTeams:GetTall() + 6, pnl_information:GetWide() - 2, labelPurchase:GetTall() + 18)
		end
		surface.SetDrawColor(mgui.Colors.Blue)
		surface.DrawLine(0, select(2, labelPurchase:GetPos()) + labelPurchase:GetTall() + 8, pnl_information:GetWide(), select(2, labelPurchase:GetPos()) + labelPurchase:GetTall() + 8)
		surface.DrawLine(0, select(2, buttonRent:GetPos()) + buttonRent:GetTall() + 4, pnl_information:GetWide(), select(2, buttonRent:GetPos()) + buttonRent:GetTall() + 4)
		if !rentActive then
			surface.SetDrawColor(37, 37, 37, 150)
			surface.DrawRect(1, select(2, labelPurchase:GetPos()) + labelPurchase:GetTall() + 9, pnl_information:GetWide() - 2, select(2, buttonRent:GetPos()) + buttonRent:GetTall() + 3 - (select(2, labelPurchase:GetPos()) + labelPurchase:GetTall() + 8))
		end
	end
		
	return pnl_information
end

AdvDoors.AddMenuTab(TAB, 1)