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
				local CoownersMore = coownerLayout:Add("mgButton")
				CoownersMore:SetText("and " .. (#coOwners - elements) .. " more")
				CoownersMore:SetSize(110, 32) 
				break
			end
		end
	else
		local noCoowners = coownerLayout:Add("mgStatusLabel")
		noCoowners:SetType("primary")
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
	labelGroupOwner:SetType("primary")
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
			teamItem:SetType("primary")
			teamItem:SetText(team.GetName(k))
			teamItem:SizeToContents(true)
			teamItem:SetHeight(32)
		end
	else
		local noTeams = teamsLayout:Add("mgStatusLabel")
		noTeams:SetType("primary")
		noTeams:SetText("this door has no teams assigned")
		noTeams:SizeToContents(true)
		noTeams:SetHeight(32)
	end
	return pnl_information
end

AdvDoors.AddMenuTab(TAB, 1)