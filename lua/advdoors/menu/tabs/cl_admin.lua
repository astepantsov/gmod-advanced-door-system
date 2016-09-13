local TAB = {}

TAB.Title = "Admin"
TAB.Access = {
	ADMIN
}

TAB.Function = function(frame, door)
	local fontMenu = mgui.CreateFont("menu", {size = 18})
	local pnl_admin = vgui.Create("mgPanel", frame)
	pnl_admin:SetPos(5, 75)
	pnl_admin:SetSize(frame:GetWide() - 10, frame:GetTall() - 80)
	pnl_admin:SetVisible(false)

	local labelOwnership = vgui.Create("DLabel", pnl_admin)
	labelOwnership:SetPos(5, 5)
	labelOwnership:SetText("Is ownership enabled: ")
	labelOwnership:SetFont(fontMenu)
	labelOwnership:SizeToContents()

	local boolOwnership = vgui.Create("mgBoolean", pnl_admin)
	boolOwnership:SetPos(10 + labelOwnership:GetWide(), 5)
	boolOwnership:SetValue(!door:getKeysNonOwnable())
	boolOwnership.OnValueChanged = function(bool)
		net.Start("advdoors_toggleownership")
		net.WriteTable({door = door, state = bool:GetValue()})
		net.SendToServer()
	end
	
	local labelDisplay = vgui.Create("DLabel", pnl_admin)
	labelDisplay:SetPos(5, select(2, boolOwnership:GetPos()) + boolOwnership:GetTall() + 15)
	labelDisplay:SetText("Disable door display: ")
	labelDisplay:SetFont(fontMenu)
	labelDisplay:SizeToContents()
	
	local menuDisplay = vgui.Create("mgMenu", pnl_admin)
	menuDisplay:SetSize(250, 32)
	menuDisplay:SetPos(10 + labelDisplay:GetWide(), select(2, boolOwnership:GetPos()) + boolOwnership:GetTall() + 10)
	menuDisplay:SetText("Select an option")
	menuDisplay:AddChoice("Only for this door", 1)
	menuDisplay:AddChoice("For all doors of this type (" .. door:GetClass() .. ")", 2)
	
	local buttonDisplay = vgui.Create("mgButton", pnl_admin)
	buttonDisplay:SetPos(15 + labelDisplay:GetWide() + menuDisplay:GetWide(), select(2, boolOwnership:GetPos()) + boolOwnership:GetTall() + 10)
	buttonDisplay:SetSize(100, 32)
	buttonDisplay:SetText("Disable")
	buttonDisplay.DoClick = function()
		if not menuDisplay:GetValue() then return end
		mgui.ShowDialog("confirm", "Are you sure that you want to disable door display?", function()
			net.Start("advdoors_addblacklist")
			net.WriteTable({door = door, option = select(2, menuDisplay:GetValue())})
			net.SendToServer()
			net.Receive("advdoors_addblacklist", function(len)
				AdvDoors.refreshTab(4, true)
			end)
		end, "Yes", "No")
	end
	
	local labelStatusDisplay = vgui.Create("mgStatusLabel", pnl_admin)
	labelStatusDisplay:SetPos(5, select(2, buttonDisplay:GetPos()) + buttonDisplay:GetTall() + 5)
	labelStatusDisplay:SetType((door:isDoorBlacklisted() or door:isDoorTypeBlacklisted()) and "danger" or "success")
	labelStatusDisplay:SetText(door:isDoorBlacklisted() and "Door display is disabled for this door" or door:isDoorTypeBlacklisted() and "Door display is disabled for all doors of this type ("  .. door:GetClass() .. ")" or "Door display for this door is not disabled")
	labelStatusDisplay:SizeToContents() 
	
	if door:isDoorBlacklisted() or door:isDoorTypeBlacklisted() then
		local buttonRemove = vgui.Create("mgButton", pnl_admin)
		buttonRemove:SetPos(10 + labelStatusDisplay:GetWide(), select(2, buttonDisplay:GetPos()) + buttonDisplay:GetTall() + 5)
		buttonRemove:SetSize(100, 16)
		buttonRemove:SetText("Enable")
		buttonRemove.DoClick = function()
			mgui.ShowDialog("confirm", "Are you sure that you want to enable door display?", function()
				net.Start("advdoors_removeblacklist")
				net.WriteEntity(door)
				net.SendToServer()
				net.Receive("advdoors_removeblacklist", function(len)
					AdvDoors.refreshTab(4, true)
				end)
			end, "Yes", "No")
		end
		buttonDisplay:SetDisabled(true)
		menuDisplay:SetDisabled(true)
	end
	
	pnl_admin.PaintOver = function()
		surface.SetDrawColor(mgui.Colors.Blue)
		surface.DrawOutlinedRect(0, 0, pnl_admin:GetWide(), pnl_admin:GetTall())
		surface.DrawLine(1, boolOwnership:GetTall() + 10, pnl_admin:GetWide() - 2, boolOwnership:GetTall() + 10)
		surface.DrawLine(1, select(2, labelStatusDisplay:GetPos()) + labelStatusDisplay:GetTall() + 5, pnl_admin:GetWide() - 2, select(2, labelStatusDisplay:GetPos()) + labelStatusDisplay:GetTall() + 5)
	end
	
	local labelCanOwn = vgui.Create("DLabel", pnl_admin)
	labelCanOwn:SetPos(5, select(2, labelStatusDisplay:GetPos()) + labelStatusDisplay:GetTall() + 15)
	labelCanOwn:SetText("Who can own this door: ")
	labelCanOwn:SetFont(fontMenu)
	labelCanOwn:SizeToContents()
	
	local ownerChoices = {}
	
	local menuCanOwn = vgui.Create("mgMenu", pnl_admin)
	menuCanOwn:SetSize(110, 32)
	menuCanOwn:SetPos(10 + labelCanOwn:GetWide(), select(2, labelStatusDisplay:GetPos()) + labelStatusDisplay:GetTall() + 10)
	menuCanOwn:SetText("Select an option")
	menuCanOwn:AddChoice("Any player", 1)
	menuCanOwn:AddChoice("Specified jobs", 2)
	menuCanOwn:AddChoice("Specified group", 3)
	
	local panelOwner = vgui.Create("DPanel", pnl_admin);
	panelOwner:SetSize(pnl_admin:GetWide() - 2, 60)
	panelOwner:SetPos(1, select(2, menuCanOwn:GetPos()) + menuCanOwn:GetTall() + 5)
	panelOwner.Paint = function() end
	
	menuCanOwn.OnValueChanged = function(panel, value)
		for k,v in pairs(panelOwner:GetChildren()) do
			v:Remove()
		end
		
		if select(2, panel:GetValue()) == 1 then
			mgui.ShowDialog("confirm", "Are you sure that you want to add this job?", function()
				net.Start("advdoors_anyplayer")
				net.WriteEntity(door)
				net.SendToServer()
				net.Receive("advdoors_anyplayer", function(len)
					AdvDoors.refreshTab(1, false)
					AdvDoors.refreshTab(4, true)
				end)
			end, "Yes", "No")
		end
		
		ownerChoices[select(2, panel:GetValue())]()
	end
	
	ownerChoices[1] = function()
		local menuJobs = vgui.Create("mgMenu", panelOwner)
		menuJobs:SetSize(250, 32)
		menuJobs:SetPos(4, 1)
		menuJobs:SetText("Add job restriction")
		for k,v in pairs(RPExtraTeams) do
			if not AdvDoors.hasJobRestriction(door) or not AdvDoors.Configuration.getMapConfig().DoorJobs[AdvDoors.getEntIndex(door)][k] or AdvDoors.Configuration.getMapConfig().DoorJobs[AdvDoors.getEntIndex(door)][k] == nil then
				menuJobs:AddChoice(v.name, k)
			end
		end
		local buttonJobAdd = vgui.Create("mgButton", panelOwner)
		buttonJobAdd:SetPos(9 + menuJobs:GetWide(), 1)
		buttonJobAdd:SetSize(100, 32)
		buttonJobAdd:SetText("Add")
		buttonJobAdd.DoClick = function()
			if not menuJobs:GetValue() then return end
			mgui.ShowDialog("confirm", "Are you sure that you want to add this job?", function()
				net.Start("advdoors_addjobplayer")
				net.WriteTable({door = door, job = select(2, menuJobs:GetValue())})
				net.SendToServer()
				net.Receive("advdoors_addjobplayer", function(len)
					AdvDoors.refreshTab(1, false)
					AdvDoors.refreshTab(4, true)
				end)
			end, "Yes", "No")
		end
		local JobsLayout = vgui.Create("DIconLayout", panelOwner)
		JobsLayout:SetWidth(panelOwner:GetWide() - 2);
		JobsLayout:SetPos(4, 6 + buttonJobAdd:GetTall())
		JobsLayout:SetSpaceX(5)
		JobsLayout:SetSpaceY(5)
		if not AdvDoors.hasJobRestriction(door) then
			local labelNoJobs = JobsLayout:Add("mgStatusLabel")
			labelNoJobs:SetType("warning")
			labelNoJobs:SetText("No job restriction")
			labelNoJobs:SizeToContents() 
		else
			local width = 0;
			local jobCount = 0;
			surface.SetFont(fontMenu)
			for k,v in pairs(AdvDoors.Configuration.getMapConfig().DoorJobs[AdvDoors.getEntIndex(door)]) do
				if v then
					if (((JobsLayout:GetWide() - width - surface.GetTextSize(team.GetName(k)) - 10) <= 100) or (width + surface.GetTextSize(team.GetName(k)) + 10 + 100 > JobsLayout:GetWide())) and #AdvDoors.Configuration.getMapConfig().DoorJobs[AdvDoors.getEntIndex(door)] > jobCount then
						local menuMoreJobs = JobsLayout:Add("mgMenu")
						menuMoreJobs:SetSize(100, 18)
						menuMoreJobs.ChoicePanelCreated = function(self, btn) 
							btn.DoClick = function() 
								mgui.ShowDialog("confirm", "Are you sure that you want to remove this job?", function()
									net.Start("advdoors_jobremoveplayer")
									net.WriteTable({door = door, job = btn.Data})
									net.SendToServer()
									net.Receive("advdoors_jobremoveplayer", function(len)
										AdvDoors.refreshTab(1, false)
										AdvDoors.refreshTab(4, true)
									end)
								end, "Yes", "No")
							end 
						end
						menuMoreJobs:SetText("and " .. AdvDoors.getDoorList(door) - jobCount .. " more")
						for l,p in pairs(AdvDoors.Configuration.getMapConfig().DoorJobs[AdvDoors.getEntIndex(door)]) do
							if l >= k then
								menuMoreJobs:AddChoice(team.GetName(l), l)
							end
						end
						break;
					end
					local labelJob = JobsLayout:Add("mgStatusLabel")
					labelJob:SetType("primary")
					labelJob:SetText(team.GetName(k))
					labelJob:SizeToContents()
					labelJob:SetFunction(function()
						mgui.ShowDialog("confirm", "Are you sure that you want to remove this job?", function()
							net.Start("advdoors_jobremoveplayer")
							net.WriteTable({door = door, job = k})
							net.SendToServer()
							net.Receive("advdoors_jobremoveplayer", function(len)
								AdvDoors.refreshTab(1, false)
								AdvDoors.refreshTab(4, true)
							end)
						end, "Yes", "No")
					end)
					jobCount = jobCount + 1;
					width = width + 5 + labelJob:GetWide()
				end
			end
		end
	end
	
	local doorTeams = door:getKeysDoorTeams()
	
	ownerChoices[2] = function()
		local menuJobs = vgui.Create("mgMenu", panelOwner)
		menuJobs:SetSize(250, 32)
		menuJobs:SetPos(4, 1)
		menuJobs:SetText("Select a job to add")
		for k,v in pairs(RPExtraTeams) do
			if not doorTeams or not doorTeams[k] then
				menuJobs:AddChoice(v.name, k)
			end
		end
		local buttonJobAdd = vgui.Create("mgButton", panelOwner)
		buttonJobAdd:SetPos(9 + menuJobs:GetWide(), 1)
		buttonJobAdd:SetSize(100, 32)
		buttonJobAdd:SetText("Add")
		buttonJobAdd.DoClick = function()
			if not menuJobs:GetValue() then return end
			mgui.ShowDialog("confirm", "Are you sure that you want to add this job?", function()
				net.Start("advdoors_addjob")
				net.WriteTable({door = door, job = select(2, menuJobs:GetValue())})
				net.SendToServer()
				net.Receive("advdoors_addjob", function(len)
					AdvDoors.refreshTab(1, false)
					AdvDoors.refreshTab(4, true)
				end)
			end, "Yes", "No")
		end
		local JobsLayout = vgui.Create("DIconLayout", panelOwner)
		JobsLayout:SetWidth(panelOwner:GetWide() - 2);
		JobsLayout:SetPos(4, 6 + buttonJobAdd:GetTall())
		JobsLayout:SetSpaceX(5)
		JobsLayout:SetSpaceY(5)
		if not doorTeams then
			local labelNoJobs = JobsLayout:Add("mgStatusLabel")
			labelNoJobs:SetType("warning")
			labelNoJobs:SetText("There are no jobs added yet")
			labelNoJobs:SizeToContents() 
		else
			local width = 0;
			local jobCount = 0;
			surface.SetFont(fontMenu)
			for k,v in pairs(doorTeams) do
				if (((JobsLayout:GetWide() - width - surface.GetTextSize(team.GetName(k)) - 10) <= 100) or (width + surface.GetTextSize(team.GetName(k)) + 10 + 100 > JobsLayout:GetWide())) and #doorTeams > jobCount then
					local menuMoreJobs = JobsLayout:Add("mgMenu")
					menuMoreJobs:SetSize(100, 18)
					menuMoreJobs.ChoicePanelCreated = function(self, btn) 
						btn.DoClick = function() 
							mgui.ShowDialog("confirm", "Are you sure that you want to remove this job?", function()
								net.Start("advdoors_jobremove")
								net.WriteTable({door = door, job = btn.Data})
								net.SendToServer()
								net.Receive("advdoors_jobremove", function(len)
									AdvDoors.refreshTab(1, false)
									AdvDoors.refreshTab(4, true)
								end)
							end, "Yes", "No")
						end 
					end
					menuMoreJobs:SetText("and " .. AdvDoors.jobList(doorTeams) - jobCount .. " more")
					for l,p in pairs(doorTeams) do
						if l >= k then
							menuMoreJobs:AddChoice(team.GetName(l), l)
						end
					end
					break;
				end
				local labelJob = JobsLayout:Add("mgStatusLabel")
				labelJob:SetType("primary")
				labelJob:SetText(team.GetName(k))
				labelJob:SizeToContents()
				labelJob:SetFunction(function()
					mgui.ShowDialog("confirm", "Are you sure that you want to remove this job?", function()
						net.Start("advdoors_jobremove")
						net.WriteTable({door = door, job = k})
						net.SendToServer()
						net.Receive("advdoors_jobremove", function(len)
							AdvDoors.refreshTab(1, false)
							AdvDoors.refreshTab(4, true)
						end)
					end, "Yes", "No")
				end)
				jobCount = jobCount + 1;
				width = width + 5 + labelJob:GetWide()
			end
		end
	end
	ownerChoices[3] = function()
		local menuTeam = vgui.Create("mgMenu", panelOwner)
		menuTeam:SetSize(250, 32)
		menuTeam:SetPos(4, 1)
		menuTeam:SetText(door:getKeysDoorGroup() or "Select a team that can own this door")
		for k,v in pairs(RPExtraTeamDoors) do
			menuTeam:AddChoice(k, k)
		end
		menuTeam.OnValueChanged = function(panel, value)
			mgui.ShowDialog("confirm", "Are you sure that you want to add this group?", function()
				net.Start("advdoors_setgroup")
				net.WriteTable({door = door, group = select(2, menuTeam:GetValue())})
				net.SendToServer()
				net.Receive("advdoors_setgroup", function(len)
					AdvDoors.refreshTab(1, false)
					AdvDoors.refreshTab(4, true)
				end)
			end, "Yes", "No")
		end
	end
	
	if doorTeams then
		ownerChoices[2]()
		menuCanOwn:SetText("Specified jobs")
	elseif door:getKeysDoorGroup() then
		ownerChoices[3]()
		menuCanOwn:SetText("Specified group")
	else
		ownerChoices[1]()
		menuCanOwn:SetText("Any player")
	end
	
	local labelWarningCanOwn = vgui.Create("mgStatusLabel", pnl_admin)
	labelWarningCanOwn:SetPos(15 + labelCanOwn:GetWide() + menuCanOwn:GetWide(), select(2, labelStatusDisplay:GetPos()) + labelStatusDisplay:GetTall() + 15)
	labelWarningCanOwn:SetType("warning")
	labelWarningCanOwn:SetText("Warning: changing category may remove all owners")
	labelWarningCanOwn:SizeToContents() 
	
	return pnl_admin
end

AdvDoors.AddMenuTab(TAB, 4)