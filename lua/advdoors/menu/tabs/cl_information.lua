local TAB = {}

TAB.Title = AdvDoors.LANG.GetString("inf_title")
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
	labelOwner:SetText(AdvDoors.LANG.GetString("owner") .. ": ")
	labelOwner:SetFont(fontMenu)
	labelOwner:SizeToContents()
	local ownerItem = vgui.Create("mgItem", pnl_information)
	ownerItem:SetPos(10 + labelOwner:GetWide(), 10)
	ownerItem:SetSize(110, 32)
	ownerItem:SetName(ownerName or AdvDoors.LANG.GetString("no_owner")) 
	ownerItem:SetSteamID(AdvDoors.getOwnerSteamID64(door) or "")
	ownerItem:SetType("Player")
	if ownerName then
		ownerItem.DoClick = function()
			gui.OpenURL("http://steamcommunity.com/profiles/" .. AdvDoors.getOwnerSteamID64(door) .. "/")
		end
	end
	
	if AdvDoors.hasJobRestriction(door) then
		local menuAllowedJobs = vgui.Create("mgMenu", pnl_information)
		menuAllowedJobs:SetText(AdvDoors.LANG.GetString("allowed_jobs"))
		menuAllowedJobs:SetSize(150, 32)
		menuAllowedJobs:SetPos(ownerItem:GetPos() + ownerItem:GetWide() + 5, select(2, ownerItem:GetPos()))
		menuAllowedJobs.ChoicePanelCreated = function(self, btn) btn:SetDisabled(true) end
		for k,v in pairs(AdvDoors.Configuration.getMapConfig().DoorJobs[AdvDoors.getEntIndex(door)]) do
			if v then
				menuAllowedJobs:AddChoice(team.GetName(k), "")
			end
		end
	end
	
	local labelTenant = vgui.Create("DLabel", pnl_information)
	labelTenant:SetPos(pnl_information:GetWide() - 180, 16)
	labelTenant:SetText(AdvDoors.LANG.GetString("tenant") .. ": ")
	labelTenant:SetFont(fontMenu)
	labelTenant:SizeToContents()
	local tenantItem = vgui.Create("mgItem", pnl_information)
	tenantItem:SetPos(pnl_information:GetWide() - 120, 10)
	tenantItem:SetSize(110, 32)
	tenantItem:SetName(door:GetNWEntity("tenant", false) and door:GetNWEntity("tenant", false):Name() or AdvDoors.LANG.GetString("no_tenant")) 
	tenantItem:SetSteamID(door:GetNWEntity("tenant", false) and door:GetNWEntity("tenant", false):SteamID64() or "")
	tenantItem:SetType("Player")
	if door:GetNWEntity("tenant", false) then
		tenantItem.DoClick = function()
			gui.OpenURL("http://steamcommunity.com/profiles/" .. door:GetNWEntity("tenant", false):SteamID64() .. "/")
		end
	end
	
	local labelCoowner = vgui.Create("DLabel", pnl_information)
	labelCoowner:SetPos(5, 54)
	labelCoowner:SetText(AdvDoors.LANG.GetString("coowners") .. ": ")
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
					CoownersMore:SetText(AdvDoors.LANG.FormatString("and_x_more", #coOwners - elements))
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
		noCoowners:SetText(AdvDoors.LANG.GetString("has_no_coowners"))
		noCoowners:SizeToContents() 
	end

	coownerLayout:InvalidateLayout(true)
	local labelGroups = vgui.Create("DLabel", pnl_information)
	labelGroups:SetPos(5, select(2, coownerLayout:GetPos()) + coownerLayout:GetTall() + 8)
	labelGroups:SetText(AdvDoors.LANG.GetString("door_group") .. ": ")
	labelGroups:SetFont(fontMenu)
	labelGroups:SizeToContents()
	
	local labelGroupOwner = vgui.Create("mgStatusLabel", pnl_information)
	labelGroupOwner:SetType("primary")
	labelGroupOwner:SetText(door:getKeysDoorGroup() or AdvDoors.LANG.GetString("no_group"))
	labelGroupOwner:SetPos(10 + labelGroups:GetWide(), select(2, coownerLayout:GetPos()) + coownerLayout:GetTall() + 8);
	labelGroupOwner:SizeToContents()
	
	local x, y = labelGroupOwner:GetPos();
	local labelTeams = vgui.Create("DLabel", pnl_information)
	labelTeams:SetPos(5, y + labelGroupOwner:GetTall() + 8)
	labelTeams:SetText(AdvDoors.LANG.GetString("door_teams") .. ": ")
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
	
	surface.SetFont(fontMenu)
	
	if doorTeams then
		for k,v in pairs(doorTeams) do
			if (((teamsLayout:GetWide() - teamWidth - surface.GetTextSize(team.GetName(k)) - 10) <= 100) or (teamWidth + surface.GetTextSize(team.GetName(k)) > teamsLayout:GetWide() - labelTeams:GetWide())) and #doorTeams > teamCount then
				local teamsMore = teamsLayout:Add("mgMenu")
				teamsMore:SetText(AdvDoors.LANG.FormatString("and_x_more", #doorTeams - teamCount))
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
			teamItem:SizeToContents()
			teamItem:InvalidateLayout(true)
			
			teamWidth = teamWidth + teamItem:GetWide() + 5
			teamCount = teamCount + 1
		end
	else
		local noTeams = teamsLayout:Add("mgStatusLabel")
		noTeams:SetType("primary")
		noTeams:SetText(AdvDoors.LANG.GetString("no_teams"))
		noTeams:SizeToContents()
	end
	
	local labelPurchase = vgui.Create("DLabel", pnl_information)
	labelPurchase:SetPos(5, select(2, labelTeams:GetPos()) + labelTeams:GetTall() + 15)
	labelPurchase:SetText(AdvDoors.LANG.GetString("buy_for"))
	labelPurchase:SetFont(fontMenu)
	labelPurchase:SizeToContents()
	labelPurchase:InvalidateLayout(true)

	local labelPrice = vgui.Create("mgStatusLabel", pnl_information)
	labelPrice:SetPos(10 + labelPurchase:GetWide(), select(2, labelTeams:GetPos()) + labelTeams:GetTall() + 15)
	labelPrice:SetType("primary")
	labelPrice:SetText(DarkRP.formatMoney(door:getDoorPrice() or GAMEMODE.Config.doorcost))
	labelPrice:SizeToContents()
	
	local buttonPurchase = vgui.Create("mgButton", pnl_information)
	buttonPurchase:SetPos(labelPurchase:GetWide() + labelPrice:GetWide() + 15, select(2, labelTeams:GetPos()) + labelTeams:GetTall() + 10)
	buttonPurchase:SetSize(100, labelPrice:GetTall() + 10)
	buttonPurchase:SetText(AdvDoors.LANG.GetString("purchase"))
	buttonPurchase.DoClick = function()
		mgui.ShowDialog("confirm", AdvDoors.LANG.GetString("purchase_conf"), function()
			RunConsoleCommand("darkrp", "toggleown")
			net.Receive("advdoors_purchased", function()
				if frame and IsValid(frame) then
					frame:Remove()
					AdvDoors.openMenu(door)
				end
			end)
		end, AdvDoors.LANG.GetString("yes"), AdvDoors.LANG.GetString("no"))
	end
		
	if isOwned and not door:isKeysAllowedToOwn(LocalPlayer()) or not AdvDoors.isTeamAllowedToBuyDoor(door, LocalPlayer():Team()) or door:getKeysDoorTeams() or door:getKeysDoorGroup() or door:getKeysNonOwnable() then
		buttonPurchase:SetDisabled(true)
		local labelOwned = vgui.Create("mgStatusLabel", pnl_information)
		labelOwned:SetPos(labelPrice:GetWide() + labelPurchase:GetWide() + buttonPurchase:GetWide() + 20, select(2, labelTeams:GetPos()) + labelTeams:GetTall() + 15)
		labelOwned:SetType(isOwned == LocalPlayer() and "success" or "danger")
		labelOwned:SetText(isOwned == LocalPlayer() and AdvDoors.LANG.GetString("owner_restr") or isOwned and AdvDoors.LANG.GetString("already_owned") or not AdvDoors.isTeamAllowedToBuyDoor(door, LocalPlayer():Team()) and AdvDoors.LANG.GetString("job_restr") or (door:getKeysDoorTeams() or door:getKeysDoorGroup() or door:getKeysNonOwnable()) and AdvDoors.LANG.GetString("nonownable"))
		labelOwned:SizeToContents()
	end
		
	local labelRent = vgui.Create("DLabel", pnl_information)
	labelRent:SetPos(5, select(2, labelPurchase:GetPos()) + labelPurchase:GetTall() + 15)
	labelRent:SetText(AdvDoors.LANG.GetString("rent_for"))
	labelRent:SetFont(fontMenu)
	labelRent:SizeToContents()
	labelRent:InvalidateLayout(true)
	
	local labelRentInfo = vgui.Create("mgStatusLabel", pnl_information)
	labelRentInfo:SetPos(10 + labelRent:GetWide(), select(2, labelRent:GetPos()))
	labelRentInfo:SetType(isOwned == LocalPlayer() and "success" or (door:GetNWBool("canRent", false) and not door:GetNWBool("tenant", false)) and "primary" or door:GetNWBool("tenant", false) == LocalPlayer() and "warning" or isOwned and "danger" or "warning")
	labelRentInfo:SetText(isOwned == LocalPlayer() and AdvDoors.LANG.GetString("owner_rent_restr") or (door:GetNWBool("canRent", false) and not door:GetNWBool("tenant", false)) and AdvDoors.LANG.FormatString("x_mins", DarkRP.formatMoney(door:GetNWFloat("rentPrice")) .. " / " .. door:GetNWFloat("rentLength")) or door:GetNWBool("tenant", false) == LocalPlayer() and AdvDoors.LANG.FormatString(os.date("%H:%M:%S - %d/%m/%Y", os.time() + (door:GetNWFloat("tenantExpire") - CurTime()))) or isOwned and AdvDoors.LANG.GetString("no_rent") or AdvDoors.LANG.GetString("rent_not_owned"))
	labelRentInfo:SizeToContents()
	
	local labelRentPeriods = vgui.Create("DLabel", pnl_information)
	labelRentPeriods:SetPos(5, select(2, labelRent:GetPos()) + labelRent:GetTall() + 8)
	labelRentPeriods:SetText(AdvDoors.LANG.GetString("amnt_periods") .. ": ")
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
		sliderRentPeriods:SetText(AdvDoors.LANG.GetString("amnt_periods_no_change"))
		sliderRentPeriods:SizeToContents()
	end
	sliderRentPeriods:InvalidateLayout(true)
	
	local labelResult = vgui.Create("DLabel", pnl_information)
	labelResult:SetPos(5, select(2, sliderRentPeriods:GetPos()) + sliderRentPeriods:GetTall() + 8)
	labelResult:SetText(AdvDoors.LANG.GetString("will_pay"))
	labelResult:SetFont(fontMenu)
	labelResult:SizeToContents()
	labelResult:InvalidateLayout(true)
	
	local labelResultMoney = vgui.Create("mgStatusLabel", pnl_information)
	labelResultMoney:SetPos(10 + labelResult:GetWide(), select(2, sliderRentPeriods:GetPos()) + sliderRentPeriods:GetTall() + 8)
	labelResultMoney:SetType("warning")
	labelResultMoney:SetText((door:GetNWFloat("rentMaxPeriods", 1) == 1 and door:GetNWBool("canRent", false)) and AdvDoors.LANG.FormatString("x_for_y_mins", DarkRP.formatMoney(door:GetNWFloat("rentPrice")), door:GetNWFloat("rentLength")) or door:GetNWBool("canRent", false) and AdvDoors.LANG.FormatString("x_for_y_mins", DarkRP.formatMoney(door:GetNWFloat("rentPrice") * math.Round(sliderRentPeriods:GetValue())), (door:GetNWFloat("rentLength") * math.Round(sliderRentPeriods:GetValue()))) or AdvDoors.LANG.GetString("unknown"))
	labelResultMoney:SizeToContents()

	
	sliderRentPeriods.Think = function()
		labelResultMoney:SetText((door:GetNWFloat("rentMaxPeriods", 1) == 1 and door:GetNWBool("canRent", false)) and AdvDoors.LANG.FormatString("x_for_y_mins", DarkRP.formatMoney(door:GetNWFloat("rentPrice")), door:GetNWFloat("rentLength")) or door:GetNWBool("canRent", false) and AdvDoors.LANG.FormatString("x_for_y_mins", DarkRP.formatMoney(door:GetNWFloat("rentPrice") * math.Round(sliderRentPeriods:GetValue())), (door:GetNWFloat("rentLength") * math.Round(sliderRentPeriods:GetValue()))) or AdvDoors.LANG.GetString("unknown"))
		labelResultMoney:SizeToContents(true)
	end
	
	local rentActive = door:GetNWBool("canRent", false) and isOwned and isOwned != LocalPlayer() and !door:GetNWEntity("tenant", false) and !door:isKeysOwnedBy(LocalPlayer())
	
	local buttonRent = vgui.Create("mgButton", pnl_information)
	buttonRent:SetPos(pnl_information:GetWide() - 106, select(2, labelResultMoney:GetPos()) - 5)
	buttonRent:SetSize(100, 30)
	buttonRent:SetText(AdvDoors.LANG.GetString("btn_rent"))
	buttonRent:SetDisabled(!rentActive)
	buttonRent.DoClick = function()
		mgui.ShowDialog("confirm", AdvDoors.LANG.GetString("rent_conf"), function()
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
					mgui.Notify(AdvDoors.LANG.GetString("have_rent_notify"))
				end
			end)
		end, AdvDoors.LANG.GetString("yes"), AdvDoors.LANG.GetString("no"))
	end
	
	pnl_information.PaintOver = function()
		surface.SetDrawColor(mgui.Colors.Blue)
		surface.DrawOutlinedRect(0, 0, pnl_information:GetWide(), pnl_information:GetTall())
		surface.DrawLine(0, select(2, labelTeams:GetPos()) + labelTeams:GetTall() + 5, pnl_information:GetWide(), select(2, labelTeams:GetPos()) + labelTeams:GetTall() + 5)
		if isOwned and not door:isKeysAllowedToOwn(LocalPlayer()) or not AdvDoors.isTeamAllowedToBuyDoor(door, LocalPlayer():Team()) or door:getKeysDoorTeams() or door:getKeysDoorGroup() or door:getKeysNonOwnable() then
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