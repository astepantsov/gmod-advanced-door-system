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
	return pnl_information
end

AdvDoors.AddMenuTab(TAB, 1)