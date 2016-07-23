NO_ACCESS = 0
OWNER = 1
COOWNER = 2
ADMIN = 3

local cog
AdvDoors.DownloadMaterial("http://i.imgur.com/2CKMuhQ.png", function(m) cog = m end)

AdvDoors.openMenu = function(door)
	local frame = vgui.Create("mgFrame")
	frame:SetSize(600, 500)
	frame:Center()
	frame:MakePopup()
	frame:SetTitle("Door Menu")
	frame:SetBackgroundBlur(true)
	frame.CloseButton.DoClick = function()
		AdvDoors.KeyLocked = false
		frame:Remove()
	end

	local hlist = vgui.Create("mgHorizontalTabs", frame)
	hlist:SetPos(5, 30)
	hlist:SetSize(frame:GetWide() - 10, 40)

	local fontMenu = mgui.CreateFont("menu", {size = 18})

	//Information tab

	local pnl_information = vgui.Create("mgPanel", frame)
	pnl_information:SetPos(5, 75)
	pnl_information:SetSize(frame:GetWide() - 10, frame:GetTall() - 80)
	pnl_information:SetVisible(false)
	
	local labelOwner = vgui.Create("DLabel", pnl_information)
	labelOwner:SetPos(5, 16)
	labelOwner:SetText("Owner: ")
	labelOwner:SetFont(fontMenu)
	labelOwner:SizeToContents()
	local ownerItem = vgui.Create("mgItem", pnl_information)
	ownerItem:SetPos(10 + labelOwner:GetWide(), 10)
	ownerItem:SetSize(110, 32)
	ownerItem:SetName(AdvDoors.getOwnerName(door) or "No owner") 
	ownerItem:SetSteamID(AdvDoors.getOwnerSteamID64(door) or "")
	ownerItem:SetType("Player")
	
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
	{"TestName", "TestSteamID"},
	{"TestName", "TestSteamID"},
	{"TestName", "TestSteamID"},
	{"TestName", "TestSteamID"},
	{"TestName", "TestSteamID"},
	{"TestName", "TestSteamID"},
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
	if door:getKeysCoOwners() then
		for k,v in pairs(door:getKeysCoOwners()) do
			local coownerItem = coownerLayout:Add("mgItem")
			coownerItem:SetSize(110, 32)
			coownerItem:SetName(v:Name()) 
			coownerItem:SetSteamID(v:SteamID64())
			coownerItem:SetType("Player")
		end
	else
		local noCoowners = coownerLayout:Add("mgStatusLabel")
		noCoowners:SetType("info")
		noCoowners:SetText("this door has no coowners")
		noCoowners:SizeToContents(true)
		noCoowners:SetHeight(32);
	end

	coownerLayout:InvalidateLayout(true)
	local labelGroups = vgui.Create("DLabel", pnl_information)
	labelGroups:SetPos(5, 59 + coownerLayout:GetTall())
	labelGroups:SetText("Door group: ")
	labelGroups:SetFont(fontMenu)
	labelGroups:SizeToContents()
	
	local labelGroupOwner = vgui.Create("mgStatusLabel", pnl_information)
	labelGroupOwner:SetType("info")
	labelGroupOwner:SetText(door:getKeysDoorGroup() or "No group")
	labelGroupOwner:SetPos(10 + labelGroups:GetWide(), 54 + coownerLayout:GetTall());
	labelGroupOwner:SizeToContents(true)
	labelGroupOwner:SetHeight(32);
	
	local x, y = labelGroupOwner:GetPos();
	local labelTeams = vgui.Create("DLabel", pnl_information)
	labelTeams:SetPos(5, y + labelGroupOwner:GetTall() + 15)
	labelTeams:SetText("Door teams: ")
	labelTeams:SetFont(fontMenu)
	labelTeams:SizeToContents()
	
	local teamsLayout = vgui.Create("DIconLayout", pnl_information)
	teamsLayout:SetSize(frame:GetWide() - labelTeams:GetWide() - 10, 69)
	teamsLayout:SetPos(10 + labelTeams:GetWide(), y + labelGroupOwner:GetTall() + 8)
	teamsLayout:SetSpaceX(5)
	teamsLayout:SetSpaceY(5)
	
	if door:getKeysDoorTeams() then
		for k,v in pairs(door:getKeysDoorTeams()) do
			local teamItem = teamsLayout:Add("mgStatusLabel")
			teamItem:SetType("info")
			teamItem:SetText(team.GetName(k))
			teamItem:SizeToContents(true)
			teamItem:SetHeight(32)
		end
	else
		local noTeams = teamsLayout:Add("mgStatusLabel")
		noTeams:SetType("info")
		noTeams:SetText("this door has no teams assigned")
		noTeams:SizeToContents(true)
		noTeams:SetHeight(32)
	end
	
	//Purchase tab

	local pnl_purchase = vgui.Create("mgPanel", frame)
	pnl_purchase:SetPos(5, 75)
	pnl_purchase:SetSize(frame:GetWide() - 10, frame:GetTall() - 80)
	pnl_purchase:SetVisible(false)

	local Label_Purchase = vgui.Create("DLabel", pnl_purchase)
	Label_Purchase:SetPos(5, 7)
	Label_Purchase:SetText("Buy a door: ")
	Label_Purchase:SetFont(fontMenu)
	Label_Purchase:SizeToContents()

	
	local Label_Price = vgui.Create("mgStatusLabel", pnl_purchase)
	Label_Price:SetPos(10 + Label_Purchase:GetWide(), 10)
	Label_Price:SetType("primary")
	Label_Price:SetText(DarkRP.formatMoney(door:getDoorPrice() or GAMEMODE.Config.doorcost))
	Label_Price:SizeToContents(true)

	local Button_Purchase = vgui.Create("mgButton", pnl_purchase)
	Button_Purchase:SetPos(15 + Label_Price:GetWide() + Label_Purchase:GetWide(), 5)
	Button_Purchase:SetSize(100, Label_Price:GetTall() + 10)
	Button_Purchase:SetText("Purchase")
	Button_Purchase.DoClick = function()
		RunConsoleCommand("darkrp", "toggleown")
		net.Receive("advdoors_purchased", function()
			if frame and IsValid(frame) then
				frame:Remove()
				AdvDoors.openMenu(door)
				mgui.Notify("You have bought this door for " .. DarkRP.formatMoney(door:getDoorPrice() or GAMEMODE.Config.doorcost))
			end
		end)
	end
	//Management tab

	local pnl_management = vgui.Create("mgPanel", frame)
	pnl_management:SetPos(5, 75)
	pnl_management:SetSize(frame:GetWide() - 10, frame:GetTall() - 80)
	pnl_management:SetVisible(false)

	//Modifications tab

	local pnl_modifications = vgui.Create("mgPanel", frame)
	pnl_modifications:SetPos(5, 75)
	pnl_modifications:SetSize(frame:GetWide() - 10, frame:GetTall() - 80)
	pnl_modifications:SetVisible(false)

	//Admin tab

	local pnl_admin = vgui.Create("mgPanel", frame)
	pnl_admin:SetPos(5, 75)
	pnl_admin:SetSize(frame:GetWide() - 10, frame:GetTall() - 80)
	pnl_admin:SetVisible(false)

	local Label_Purchase = vgui.Create("DLabel", pnl_admin)
	Label_Purchase:SetPos(5, 5)
	Label_Purchase:SetText("Is ownership enabled: ")
	Label_Purchase:SetFont(fontMenu)
	Label_Purchase:SizeToContents()

	local BoolOwnership = vgui.Create("mgBoolean", pnl_admin)
	BoolOwnership:SetPos(10 + Label_Purchase:GetWide(), 5)
	BoolOwnership:SetValue(!door:getKeysNonOwnable())
	BoolOwnership.OnValueChanged = function(value)
		RunConsoleCommand("darkrp", "toggleownable")
		BoolOwnership:SetDisabled(true)
		timer.Simple(1, function()
			if frame and IsValid(frame) and BoolOwnership and IsValid(BoolOwnership) then
				BoolOwnership:SetDisabled(false)
			end
		end)
	end

	local menuTabs = {
		{Title = "Information", Access = {NO_ACCESS, OWNER, COOWNER, ADMIN}, Child = pnl_information},
		{Title = "Purchase", Access = {NO_ACCESS}, Child = pnl_purchase},
		{Title = "Management", Access = {OWNER}, Child = pnl_management},
		{Title = "Modifications", Access = {OWNER, COOWNER}, Child = pnl_modifications},
		{Title = "Admin", Access = {ADMIN}, Child = pnl_admin}
	}
	for k, v in pairs(menuTabs) do
		if (table.HasValue(v.Access, NO_ACCESS) and not LocalPlayer():canKeysLock(door) and not LocalPlayer():canKeysLock(door) and not AdvDoors.getOwnerName(door)) or (table.HasValue(v.Access, OWNER) and LocalPlayer() == door:getDoorOwner()) or (table.HasValue(v.Access, COOWNER) and door:getKeysCoOwners() and door:getKeysCoOwners()[LocalPlayer():UserID()]) or (table.HasValue(v.Access, ADMIN) and LocalPlayer():IsSuperAdmin()) then
			local b = hlist:AddTab(v.Title, cog, v.Child or nil)
			if k == 1 then hlist:SetSelected(b) end
		end
	end
end