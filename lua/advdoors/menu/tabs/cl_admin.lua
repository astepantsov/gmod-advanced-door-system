local TAB = {}

TAB.Title = AdvDoors.LANG.GetString("adm_title")
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
	labelOwnership:SetText(AdvDoors.LANG.GetString("ownership_isenabled") .. ": ")
	labelOwnership:SetFont(fontMenu)
	labelOwnership:SizeToContents()

	local boolOwnership = vgui.Create("mgBoolean", pnl_admin)
	boolOwnership:SetPos(10 + labelOwnership:GetWide(), 5)
	boolOwnership:SetValue(!door:getKeysNonOwnable())
	boolOwnership.OnValueChanged = function(bool)
		net.Start("advdoors_toggleownership")
		net.WriteTable({door = door, state = bool:GetValue()})
		net.SendToServer()
		net.Receive("advdoors_toggleownership", function()
			AdvDoors.refreshTab(1, false)
		end)
	end
	
	local labelDisplay = vgui.Create("DLabel", pnl_admin)
	labelDisplay:SetPos(5, select(2, boolOwnership:GetPos()) + boolOwnership:GetTall() + 15)
	labelDisplay:SetText(AdvDoors.LANG.GetString("doordisplay_disable") .. ": ")
	labelDisplay:SetFont(fontMenu)
	labelDisplay:SizeToContents()
	
	local menuDisplay = vgui.Create("mgMenu", pnl_admin)
	menuDisplay:SetSize(250, 32)
	menuDisplay:SetPos(10 + labelDisplay:GetWide(), select(2, boolOwnership:GetPos()) + boolOwnership:GetTall() + 10)
	menuDisplay:SetText(AdvDoors.LANG.GetString("select_option"))
	menuDisplay:AddChoice(AdvDoors.LANG.GetString("this_door"), 1)
	menuDisplay:AddChoice(AdvDoors.LANG.FormatString("alldoors_x_type", door:GetClass()), 2)
	menuDisplay:AddChoice(AdvDoors.LANG.FormatString("alldoors_x_model", door:GetModel()), 3)
	
	local buttonDisplay = vgui.Create("mgButton", pnl_admin)
	buttonDisplay:SetPos(15 + labelDisplay:GetWide() + menuDisplay:GetWide(), select(2, boolOwnership:GetPos()) + boolOwnership:GetTall() + 10)
	buttonDisplay:SetSize(100, 32)
	buttonDisplay:SetText(AdvDoors.LANG.GetString("disable_btn"))
	buttonDisplay.DoClick = function()
		if not menuDisplay:GetValue() then return end
		mgui.ShowDialog("confirm", AdvDoors.LANG.GetString("disable_conf"), function()
			net.Start("advdoors_addblacklist")
			net.WriteTable({door = door, option = select(2, menuDisplay:GetValue())})
			net.SendToServer()
			net.Receive("advdoors_addblacklist", function(len)
				AdvDoors.refreshTab(4, true)
			end)
		end, AdvDoors.LANG.GetString("yes"), AdvDoors.LANG.GetString("no"))
	end
	
	local labelStatusDisplay = vgui.Create("mgStatusLabel", pnl_admin)
	labelStatusDisplay:SetPos(5, select(2, buttonDisplay:GetPos()) + buttonDisplay:GetTall() + 5)
	labelStatusDisplay:SetType((door:isDoorBlacklisted() or door:isDoorTypeBlacklisted()) and "danger" or "success")
	labelStatusDisplay:SetText(door:isDoorBlacklisted() and AdvDoors.LANG.GetString("disabled_display") or door:isDoorTypeBlacklisted() and AdvDoors.LANG.FormatString("disabledall_x_type_display", door:GetClass()) or door:isDoorModelBlacklisted() and AdvDoors.LANG.FormatString("disabledall_x_model_display", door:GetModel()) or AdvDoors.LANG.GetString("not_disabled_display"))
	labelStatusDisplay:SizeToContents() 
	
	if door:isDoorBlacklisted() or door:isDoorTypeBlacklisted() then
		local buttonRemove = vgui.Create("mgButton", pnl_admin)
		buttonRemove:SetPos(10 + labelStatusDisplay:GetWide(), select(2, buttonDisplay:GetPos()) + buttonDisplay:GetTall() + 5)
		buttonRemove:SetSize(100, 16)
		buttonRemove:SetText(AdvDoors.LANG.GetString("enable_btn"))
		buttonRemove.DoClick = function()
			mgui.ShowDialog("confirm", AdvDoors.LANG.GetString("enable_conf"), function()
				net.Start("advdoors_removeblacklist")
				net.WriteEntity(door)
				net.SendToServer()
				net.Receive("advdoors_removeblacklist", function(len)
					AdvDoors.refreshTab(4, true)
				end)
			end, AdvDoors.LANG.GetString("yes"), AdvDoors.LANG.GetString("no"))
		end
		buttonDisplay:SetDisabled(true)
		menuDisplay:SetDisabled(true)
	end
	
	local labelCanOwn = vgui.Create("DLabel", pnl_admin)
	labelCanOwn:SetPos(5, select(2, labelStatusDisplay:GetPos()) + labelStatusDisplay:GetTall() + 15)
	labelCanOwn:SetText(AdvDoors.LANG.GetString("can_use") .. ": ")
	labelCanOwn:SetFont(fontMenu)
	labelCanOwn:SizeToContents()
	
	local ownerChoices = {}
	
	local menuCanOwn = vgui.Create("mgMenu", pnl_admin)
	menuCanOwn:SetSize(110, 32)
	menuCanOwn:SetPos(10 + labelCanOwn:GetWide(), select(2, labelStatusDisplay:GetPos()) + labelStatusDisplay:GetTall() + 10)
	menuCanOwn:SetText(AdvDoors.LANG.GetString("select_option"))
	menuCanOwn:AddChoice(AdvDoors.LANG.GetString("any_ply"), 1)
	menuCanOwn:AddChoice(AdvDoors.LANG.GetString("specified_jobs"), 2)
	menuCanOwn:AddChoice(AdvDoors.LANG.GetString("specified_group"), 3)
	
	local panelOwner = vgui.Create("DPanel", pnl_admin);
	panelOwner:SetSize(pnl_admin:GetWide() - 2, 55)
	panelOwner:SetPos(1, select(2, menuCanOwn:GetPos()) + menuCanOwn:GetTall() + 5)
	panelOwner.Paint = function() end
	
	menuCanOwn.OnValueChanged = function(panel, value)
		for k,v in pairs(panelOwner:GetChildren()) do
			v:Remove()
		end
		
		if select(2, panel:GetValue()) == 1 then
			mgui.ShowDialog("confirm", AdvDoors.LANG.GetString("type_conf"), function()
				net.Start("advdoors_anyplayer")
				net.WriteEntity(door)
				net.SendToServer()
				net.Receive("advdoors_anyplayer", function(len)
					AdvDoors.refreshTab(1, false)
					AdvDoors.refreshTab(4, true)
				end)
			end, AdvDoors.LANG.GetString("yes"), AdvDoors.LANG.GetString("no"))
		end
		
		ownerChoices[select(2, panel:GetValue())]()
	end
	
	ownerChoices[1] = function()
		local menuJobs = vgui.Create("mgMenu", panelOwner)
		menuJobs:SetSize(250, 32)
		menuJobs:SetPos(4, 1)
		menuJobs:SetText(AdvDoors.LANG.GetString("job_restr_add"))
		for k,v in pairs(RPExtraTeams) do
			if not AdvDoors.hasJobRestriction(door) or not AdvDoors.Configuration.getMapConfig().DoorJobs[AdvDoors.getEntIndex(door)][k] or AdvDoors.Configuration.getMapConfig().DoorJobs[AdvDoors.getEntIndex(door)][k] == nil then
				menuJobs:AddChoice(v.name, k)
			end
		end
		local buttonJobAdd = vgui.Create("mgButton", panelOwner)
		buttonJobAdd:SetPos(9 + menuJobs:GetWide(), 1)
		buttonJobAdd:SetSize(100, 32)
		buttonJobAdd:SetText(AdvDoors.LANG.GetString("add"))
		buttonJobAdd.DoClick = function()
			if not menuJobs:GetValue() then return end
			mgui.ShowDialog("confirm", AdvDoors.LANG.GetString("job_restr_conf"), function()
				net.Start("advdoors_addjobplayer")
				net.WriteTable({door = door, job = select(2, menuJobs:GetValue())})
				net.SendToServer()
				net.Receive("advdoors_addjobplayer", function(len)
					AdvDoors.refreshTab(1, false)
					AdvDoors.refreshTab(4, true)
				end)
			end, AdvDoors.LANG.GetString("yes"), AdvDoors.LANG.GetString("no"))
		end
		local JobsLayout = vgui.Create("DIconLayout", panelOwner)
		JobsLayout:SetWidth(panelOwner:GetWide() - 2);
		JobsLayout:SetPos(4, 6 + buttonJobAdd:GetTall())
		JobsLayout:SetSpaceX(5)
		JobsLayout:SetSpaceY(5)
		if not AdvDoors.hasJobRestriction(door) then
			local labelNoJobs = JobsLayout:Add("mgStatusLabel")
			labelNoJobs:SetType("warning")
			labelNoJobs:SetText(AdvDoors.LANG.GetString("job_restr_no"))
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
								mgui.ShowDialog("confirm", AdvDoors.LANG.GetString("job_restr_remove_conf"), function()
									net.Start("advdoors_jobremoveplayer")
									net.WriteTable({door = door, job = btn.Data})
									net.SendToServer()
									net.Receive("advdoors_jobremoveplayer", function(len)
										AdvDoors.refreshTab(1, false)
										AdvDoors.refreshTab(4, true)
									end)
								end, AdvDoors.LANG.GetString("yes"), AdvDoors.LANG.GetString("no"))
							end 
						end
						menuMoreJobs:SetText(AdvDoors.LANG.FormatString("and_x_more", AdvDoors.getDoorList(door) - jobCount))
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
						mgui.ShowDialog("confirm", AdvDoors.LANG.GetString("job_restr_remove_conf"), function()
							net.Start("advdoors_jobremoveplayer")
							net.WriteTable({door = door, job = k})
							net.SendToServer()
							net.Receive("advdoors_jobremoveplayer", function(len)
								AdvDoors.refreshTab(1, false)
								AdvDoors.refreshTab(4, true)
							end)
						end, AdvDoors.LANG.GetString("yes"), AdvDoors.LANG.GetString("no"))
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
		menuJobs:SetText(AdvDoors.LANG.GetString("job_to_add"))
		for k,v in pairs(RPExtraTeams) do
			if not doorTeams or not doorTeams[k] then
				menuJobs:AddChoice(v.name, k)
			end
		end
		local buttonJobAdd = vgui.Create("mgButton", panelOwner)
		buttonJobAdd:SetPos(9 + menuJobs:GetWide(), 1)
		buttonJobAdd:SetSize(100, 32)
		buttonJobAdd:SetText(AdvDoors.LANG.GetString("add"))
		buttonJobAdd.DoClick = function()
			if not menuJobs:GetValue() then return end
			mgui.ShowDialog("confirm", AdvDoors.LANG.GetString("job_restr_conf"), function()
				net.Start("advdoors_addjob")
				net.WriteTable({door = door, job = select(2, menuJobs:GetValue())})
				net.SendToServer()
				net.Receive("advdoors_addjob", function(len)
					AdvDoors.refreshTab(1, false)
					AdvDoors.refreshTab(4, true)
				end)
			end, AdvDoors.LANG.GetString("yes"), AdvDoors.LANG.GetString("no"))
		end
		local JobsLayout = vgui.Create("DIconLayout", panelOwner)
		JobsLayout:SetWidth(panelOwner:GetWide() - 2);
		JobsLayout:SetPos(4, 6 + buttonJobAdd:GetTall())
		JobsLayout:SetSpaceX(5)
		JobsLayout:SetSpaceY(5)
		if not doorTeams then
			local labelNoJobs = JobsLayout:Add("mgStatusLabel")
			labelNoJobs:SetType("warning")
			labelNoJobs:SetText(AdvDoors.LANG.GetString("no_jobs"))
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
							mgui.ShowDialog("confirm", AdvDoors.LANG.GetString("job_restr_remove_conf"), function()
								net.Start("advdoors_jobremove")
								net.WriteTable({door = door, job = btn.Data})
								net.SendToServer()
								net.Receive("advdoors_jobremove", function(len)
									AdvDoors.refreshTab(1, false)
									AdvDoors.refreshTab(4, true)
								end)
							end, AdvDoors.LANG.GetString("yes"), AdvDoors.LANG.GetString("no"))
						end 
					end
					menuMoreJobs:SetText(AdvDoors.LANG.FormatString("and_x_more", AdvDoors.jobList(doorTeams) - jobCount))
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
					mgui.ShowDialog("confirm", AdvDoors.LANG.GetString("job_restr_remove_conf"), function()
						net.Start("advdoors_jobremove")
						net.WriteTable({door = door, job = k})
						net.SendToServer()
						net.Receive("advdoors_jobremove", function(len)
							AdvDoors.refreshTab(1, false)
							AdvDoors.refreshTab(4, true)
						end)
					end, AdvDoors.LANG.GetString("yes"), AdvDoors.LANG.GetString("no"))
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
		menuTeam:SetText(door:getKeysDoorGroup() or AdvDoors.LANG.GetString("team_own"))
		for k,v in pairs(RPExtraTeamDoors) do
			menuTeam:AddChoice(k, k)
		end
		menuTeam.OnValueChanged = function(panel, value)
			mgui.ShowDialog("confirm", AdvDoors.LANG.GetString("group_add_conf"), function()
				net.Start("advdoors_setgroup")
				net.WriteTable({door = door, group = select(2, menuTeam:GetValue())})
				net.SendToServer()
				net.Receive("advdoors_setgroup", function(len)
					AdvDoors.refreshTab(1, false)
					AdvDoors.refreshTab(4, true)
				end)
			end, AdvDoors.LANG.GetString("yes"), AdvDoors.LANG.GetString("no"))
		end
	end
	
	if doorTeams then
		ownerChoices[2]()
		menuCanOwn:SetText(AdvDoors.LANG.GetString("specified_jobs"))
	elseif door:getKeysDoorGroup() then
		ownerChoices[3]()
		menuCanOwn:SetText(AdvDoors.LANG.GetString("specified_group"))
	else
		ownerChoices[1]()
		menuCanOwn:SetText(AdvDoors.LANG.GetString("any_ply"))
	end
	
	local labelWarningCanOwn = vgui.Create("mgStatusLabel", pnl_admin)
	labelWarningCanOwn:SetPos(15 + labelCanOwn:GetWide() + menuCanOwn:GetWide(), select(2, labelStatusDisplay:GetPos()) + labelStatusDisplay:GetTall() + 15)
	labelWarningCanOwn:SetType("warning")
	labelWarningCanOwn:SetText(AdvDoors.LANG.GetString("warning_removeowners"))
	labelWarningCanOwn:SizeToContents() 
	
	local labelCanOwn = vgui.Create("DLabel", pnl_admin)
	labelCanOwn:SetPos(5, select(2, panelOwner:GetPos()) + panelOwner:GetTall() + 15)
	labelCanOwn:SetText(AdvDoors.LANG.GetString("change_price") .. ": ")
	labelCanOwn:SetFont(fontMenu)
	labelCanOwn:SizeToContents()
	
	local textAmountBuy = vgui.Create("mgTextEntry", pnl_admin)
	textAmountBuy:SetPos(labelCanOwn:GetWide() + 10, select(2, labelCanOwn:GetPos()) - 5);
	textAmountBuy:SetSize(100, 32)
	textAmountBuy:SetValue(door:getDoorPrice() or GAMEMODE.Config.doorcost)
	
	local buttonAmountBuy = vgui.Create("mgButton", pnl_admin)
	buttonAmountBuy:SetPos(textAmountBuy:GetPos() + textAmountBuy:GetWide() + 5, select(2, labelCanOwn:GetPos()) - 5)
	buttonAmountBuy:SetSize(100, 32)
	buttonAmountBuy:SetText(AdvDoors.LANG.GetString("change"))
	buttonAmountBuy.DoClick = function()
		if not tonumber(textAmountBuy:GetValue()) or math.Round(tonumber(textAmountBuy:GetValue())) < 1 then return end
		mgui.ShowDialog("confirm", AdvDoors.LANG.GetString("change_price_conf"), function()
			net.Start("advdoors_changeprice")
			net.WriteTable({door = door, price = math.Round(tonumber(textAmountBuy:GetValue()) or "")})
			net.SendToServer()
			net.Receive("advdoors_changeprice", function(len)
				AdvDoors.refreshTab(1, false)
				AdvDoors.refreshTab(4, true)
				mgui.Notify(AdvDoors.LANG.GetString("change_price_success"))
			end)
		end, AdvDoors.LANG.GetString("yes"), AdvDoors.LANG.GetString("no"))
	end
	
	local labelWarningOther = vgui.Create("mgStatusLabel", pnl_admin)
	labelWarningOther:SetPos(5, select(2, buttonAmountBuy:GetPos()) + buttonAmountBuy:GetTall() + 10)
	labelWarningOther:SetType("warning")
	labelWarningOther:SetText(AdvDoors.LANG.GetString("info_commands"))
	labelWarningOther:SizeToContents() 
	
	local buttonActions = {
		[1] = {
				Name = AdvDoors.LANG.GetString("remove_owner"), w = 150, h = 32, netID = 1, message = AdvDoors.LANG.GetString("remove_owner_msg")
			},
		[2] = {
				Name = AdvDoors.LANG.GetString("remove_all_coowners"), w = 150, h = 32, netID = 2, message = AdvDoors.LANG.GetString("remove_all_coowners_msg")
			},
		[3] = {
				Name = AdvDoors.LANG.GetString("remove_tenant"), w = 150, h = 32, netID = 3, message = AdvDoors.LANG.GetString("remove_tenant_msg")
			},
		[4] = {
				Name = AdvDoors.LANG.GetString("remove_everyone"), w = 150, h = 32, netID = 4, message = AdvDoors.LANG.GetString("remove_everyone_msg")
			}
	}
	
	local otherLayout = vgui.Create("DIconLayout", pnl_admin)
	otherLayout:SetWidth(panelOwner:GetWide() - 10);
	otherLayout:SetPos(5, select(2, labelWarningOther:GetPos()) + labelWarningOther:GetTall() + 5)
	otherLayout:SetSpaceX(5)
	otherLayout:SetSpaceY(5)
	
	for k,v in pairs(buttonActions) do
		local buttonAmountBuy = otherLayout:Add("mgButton")
		buttonAmountBuy:SetSize(v.w, v.h)
		buttonAmountBuy:SetText(v.Name)
		buttonAmountBuy.DoClick = function()
			mgui.ShowDialog("confirm", AdvDoors.LANG.GetString("perform_action_conf"), function()
				net.Start("advdoors_otheractions")
				net.WriteTable({door = door, actionID = v.netID})
				net.SendToServer()
				net.Receive("advdoors_otheractions", function(len)
					mgui.Notify(v.message)
					AdvDoors.refreshTab(1, false)
					AdvDoors.refreshTab(4, true)
				end)
			end, AdvDoors.LANG.GetString("yes"), AdvDoors.LANG.GetString("no"))
		end
	end
	
	pnl_admin.PaintOver = function()
		surface.SetDrawColor(mgui.Colors.Blue)
		surface.DrawOutlinedRect(0, 0, pnl_admin:GetWide(), pnl_admin:GetTall())
		surface.DrawLine(1, boolOwnership:GetTall() + 10, pnl_admin:GetWide() - 2, boolOwnership:GetTall() + 10)
		surface.DrawLine(1, select(2, labelStatusDisplay:GetPos()) + labelStatusDisplay:GetTall() + 5, pnl_admin:GetWide() - 2, select(2, labelStatusDisplay:GetPos()) + labelStatusDisplay:GetTall() + 5)
		surface.DrawLine(1, select(2, panelOwner:GetPos()) + panelOwner:GetTall() + 5, pnl_admin:GetWide() - 2, select(2, panelOwner:GetPos()) + panelOwner:GetTall() + 5)
		surface.DrawLine(1, select(2, buttonAmountBuy:GetPos()) + buttonAmountBuy:GetTall() + 5, pnl_admin:GetWide() - 2, select(2, buttonAmountBuy:GetPos()) + buttonAmountBuy:GetTall() + 5)
	end
	
	return pnl_admin
end

AdvDoors.AddMenuTab(TAB, 4)