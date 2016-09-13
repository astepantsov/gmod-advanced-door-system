local TAB = {}

TAB.Title = "Management"
TAB.Access = {
	OWNER,
	COOWNER
}

TAB.Function = function(frame, door)
	local fontMenu = mgui.CreateFont("menu", {size = 18})
	local pnl_management = vgui.Create("mgPanel", frame)
	pnl_management:SetPos(5, 75)
	pnl_management:SetSize(frame:GetWide() - 10, frame:GetTall() - 80)
	pnl_management:SetVisible(false)
	
	local labelCanRent = vgui.Create("DLabel", pnl_management)
	labelCanRent:SetPos(5, 5)
	labelCanRent:SetText("Can other players rent this door?")
	labelCanRent:SetFont(fontMenu)
	labelCanRent:SizeToContents()
	labelCanRent:InvalidateLayout(true)
	
	local boolRent = vgui.Create("mgBoolean", pnl_management)
	boolRent:SetPos(10 + labelCanRent:GetWide(), 3)
	boolRent:SetValue(door:GetNWBool("canRent", false))
	
	local labelAmountRent = vgui.Create("DLabel", pnl_management)
	labelAmountRent:SetPos(5, 20 + select(2, labelCanRent:GetPos()))
	labelAmountRent:SetText("Amount of money that tenant will pay for each period:")
	labelAmountRent:SetFont(fontMenu)
	labelAmountRent:SizeToContents()
	labelAmountRent:InvalidateLayout(true)
	
	local textAmountRent = vgui.Create("mgTextEntry", pnl_management)
	textAmountRent:SetPos(10 + labelAmountRent:GetWide(), select(2, labelAmountRent:GetPos()));
	textAmountRent:SetSize(100, 16)
	textAmountRent:SetValue(door:GetNWFloat("rentPrice", 1))
	
	local labelLengthRent = vgui.Create("DLabel", pnl_management)
	labelLengthRent:SetPos(5, 20 + select(2, labelAmountRent:GetPos()))
	labelLengthRent:SetText("Amount of minutes in each period:")
	labelLengthRent:SetFont(fontMenu)
	labelLengthRent:SizeToContents()
	labelLengthRent:InvalidateLayout(true)
	
	local sliderLengthRent = vgui.Create("mgSlider", pnl_management)
	sliderLengthRent:SetPos(10 + labelLengthRent:GetWide(), select(2, labelLengthRent:GetPos()) + 3)
	sliderLengthRent:ShowAmount(true)
	sliderLengthRent:SetMinMax(1, 60)
	sliderLengthRent:SetValue(door:GetNWFloat("rentLength", 1) - 1)
	sliderLengthRent:SizeToContents()
	
	local labelPeriodsRent = vgui.Create("DLabel", pnl_management)
	labelPeriodsRent:SetPos(5, 40 + select(2, labelLengthRent:GetPos()))
	labelPeriodsRent:SetText("Maximum amount of periods:")
	labelPeriodsRent:SetFont(fontMenu)
	labelPeriodsRent:SizeToContents()
	labelPeriodsRent:InvalidateLayout(true) 
	
	local textPeriodsRent = vgui.Create("mgTextEntry", pnl_management)
	textPeriodsRent:SetPos(10 + labelPeriodsRent:GetWide(), select(2, labelPeriodsRent:GetPos()));
	textPeriodsRent:SetSize(100, 16)
	textPeriodsRent:SetValue(door:GetNWFloat("rentMaxPeriods", 1))
	
	local buttonUpdateRent = vgui.Create("mgButton", pnl_management)
	buttonUpdateRent:SetPos(pnl_management:GetWide() - 106, select(2, sliderLengthRent:GetPos()) + sliderLengthRent:GetTall() + 5)
	buttonUpdateRent:SetSize(100, 16)
	buttonUpdateRent:SetText("Update")
	buttonUpdateRent.DoClick = function()
		net.Start("advdoors_updaterent")
		net.WriteTable({
			door = door,
			canRent = boolRent:GetValue(),
			rentPrice = tonumber(textAmountRent:GetValue()) or "",
			rentLength = math.Round(tonumber(sliderLengthRent:GetValue())) or "",
			rentMaxPeriods = tonumber(textPeriodsRent:GetValue()) or ""
		})
		net.SendToServer()
		net.Receive("advdoors_updaterent", function(len)
			mgui.Notify(net.ReadString())
			AdvDoors.refreshTab(1, false)
		end)
	end
	
	local labelSell = vgui.Create("DLabel", pnl_management)
	labelSell:SetPos(5, select(2, buttonUpdateRent:GetPos()) + buttonUpdateRent:GetTall() + 15)
	labelSell:SetText("Sell this door for ")
	labelSell:SetFont(fontMenu)
	labelSell:SizeToContents()
	labelSell:InvalidateLayout(true) 
	
	local labelSellPrice = vgui.Create("mgStatusLabel", pnl_management)
	labelSellPrice:SetPos(10 + labelSell:GetWide(), select(2, labelSell:GetPos()))
	labelSellPrice:SetType("primary")
	labelSellPrice:SetText(DarkRP.formatMoney(door:getDoorSellPrice() or math.Round(GAMEMODE.Config.doorcost * 2 / 3)))
	labelSellPrice:SizeToContents(true)
	
	local buttonSell = vgui.Create("mgButton", pnl_management)
	buttonSell:SetPos(labelSell:GetWide() + labelSellPrice:GetWide(), select(2, labelSell:GetPos()) - 5)
	buttonSell:SetSize(100, labelSell:GetTall() + 10)
	buttonSell:SetText("Sell")
	buttonSell.DoClick = function()
		mgui.ShowDialog("confirm", "Are you sure that you want to sell this door?", function()
			RunConsoleCommand("darkrp", "toggleown")
			net.Receive("advdoors_sold", function()
				if frame and IsValid(frame) then
					frame:Remove()
					AdvDoors.openMenu(door)
					mgui.Notify("You have sold this door for " .. DarkRP.formatMoney(door:getDoorSellPrice() or math.Round(GAMEMODE.Config.doorcost * 2 / 3)))
				end
			end)
		end, "Yes", "No")
	end
	
	local labelTitle = vgui.Create("DLabel", pnl_management)
	labelTitle:SetPos(5, select(2, buttonSell:GetPos()) + buttonSell:GetTall() + 15)
	labelTitle:SetText(door:getKeysTitle() and "Current door title is " .. door:getKeysTitle() or "This door has no title")
	labelTitle:SetFont(fontMenu)
	labelTitle:SizeToContents()
	labelTitle:InvalidateLayout(true)
	
	local buttonChangeTitle = vgui.Create("mgButton", pnl_management)
	buttonChangeTitle:SetPos(labelTitle:GetWide() + 10, select(2, labelTitle:GetPos()) - 5)
	buttonChangeTitle:SetSize(100, labelTitle:GetTall() + 10)
	buttonChangeTitle:SetText("Change")
	buttonChangeTitle.DoClick = function()
		mgui.ShowDialog("string", "Set door title", function(val)
			net.Start("advdoors_settitle")
			net.WriteTable({door = door, title = val})
			net.SendToServer()
			net.Receive("advdoors_settitle", function()
				if frame and IsValid(frame) then
					AdvDoors.refreshTab(2, true)
				end
			end)
		end, "Set the door title (less than 30 characters)", door:getKeysTitle() or "")
	end
	
	local labelCoOwner = vgui.Create("DLabel", pnl_management)
	labelCoOwner:SetPos(5, select(2, buttonChangeTitle:GetPos()) + buttonChangeTitle:GetTall() + 15)
	labelCoOwner:SetText("Add door owner: ")
	labelCoOwner:SetFont(fontMenu)
	labelCoOwner:SizeToContents()
	labelCoOwner:InvalidateLayout(true)
	
	local playerList = vgui.Create("mgPlayerList", pnl_management)
	playerList:SetPos(labelCoOwner:GetWide() + 10, select(2, labelCoOwner:GetPos()) - 5)
	playerList:SetSize(100, labelCoOwner:GetTall() + 10)
	if door:getKeysAllowedToOwn() then
		for k,v in pairs(door:getKeysAllowedToOwn()) do
			playerList:RemoveByData(AdvDoors.getByUserID(k))
		end
	end
	if door:getKeysCoOwners() then
		for k,v in pairs(door:getKeysCoOwners()) do
			playerList:RemoveByData(AdvDoors.getByUserID(k))
		end
	end
	playerList:RemoveByData(AdvDoors.getOwner(door))
	
	local buttonAddCoOwner = vgui.Create("mgButton", pnl_management)
	buttonAddCoOwner:SetPos(labelCoOwner:GetWide() + playerList:GetWide() + 15, select(2, labelCoOwner:GetPos()) - 5)
	buttonAddCoOwner:SetSize(100, labelCoOwner:GetTall() + 10)
	buttonAddCoOwner:SetText("Add")
	buttonAddCoOwner.DoClick = function()
		if not playerList:GetPlayer() or not IsValid(playerList:GetPlayer()) or not playerList:GetPlayer():IsPlayer() then return end
		mgui.ShowDialog("confirm", "Are you sure that you want to add a coowner?", function()
			net.Start("advdoors_coowneradd")
			net.WriteTable({door = door, ply = playerList:GetPlayer()})
			net.SendToServer()
			net.Receive("advdoors_coowneradd", function()
				if frame and IsValid(frame) then
					AdvDoors.refreshTab(1, false)
					AdvDoors.refreshTab(2, true)
				end
			end)
		end, "Yes", "No")
	end
	
	local CoOwnerScroll = vgui.Create("mgScrollPanel", pnl_management)
	CoOwnerScroll:SetSize(275, 106)
	CoOwnerScroll:SetPos(5, select(2, buttonAddCoOwner:GetPos()) + buttonAddCoOwner:GetTall() + 5)
	
	local CoOwnerLayout = vgui.Create("DIconLayout", pnl_management)
	CoOwnerLayout:SetSize(255, 0)
	CoOwnerLayout:SetPos(0, 0)
	CoOwnerLayout:SetSpaceX(5)
	CoOwnerLayout:SetSpaceY(5)
	
	if door:getKeysAllowedToOwn() or door:getKeysCoOwners() then
		if door:getKeysAllowedToOwn() then
			for k,v in pairs(door:getKeysAllowedToOwn()) do
				if AdvDoors.getByUserID(k) then
					local coownerItem = CoOwnerLayout:Add("mgItem")
					coownerItem:SetSize(125, 32)
					coownerItem:SetPlayer(AdvDoors.getByUserID(k))
					coownerItem:SetType("Player")
					local buttonRemove = CoOwnerLayout:Add("mgButton")
					buttonRemove:SetSize(125, 32)
					buttonRemove:SetText("Remove")
					buttonRemove.DoClick = function()
						if not IsValid(AdvDoors.getByUserID(k)) or not AdvDoors.getByUserID(k):IsPlayer() or not door:isMasterOwner(LocalPlayer()) then return end
						mgui.ShowDialog("confirm", "Are you sure that you want to remove this coowner?", function()
							net.Start("advdoors_coownerallowedremove")
							net.WriteTable({door = door, ply = AdvDoors.getByUserID(k)})
							net.SendToServer()
							net.Receive("advdoors_coownerallowedremove", function()
								if frame and IsValid(frame) then
									AdvDoors.refreshTab(1, false)
									AdvDoors.refreshTab(2, true)
								end
							end)
						end, "Yes", "No")
					end
				end
			end
		end
		if door:getKeysCoOwners() then
			for k,v in pairs(door:getKeysCoOwners()) do
				if AdvDoors.getByUserID(k) then
					local coownerItem = CoOwnerLayout:Add("mgItem")
					coownerItem:SetSize(125, 32)
					coownerItem:SetPlayer(AdvDoors.getByUserID(k))
					coownerItem:SetType("Player")
					local buttonRemove = CoOwnerLayout:Add("mgButton")
					buttonRemove:SetSize(125, 32)
					buttonRemove:SetText("Remove")
					buttonRemove.DoClick = function()
						if not IsValid(AdvDoors.getByUserID(k)) or not AdvDoors.getByUserID(k):IsPlayer() or not door:isMasterOwner(LocalPlayer()) then return end
						mgui.ShowDialog("confirm", "Are you sure that you want to remove this coowner?", function()
							net.Start("advdoors_coownerremove")
							net.WriteTable({door = door, ply = AdvDoors.getByUserID(k)})
							net.SendToServer()
							net.Receive("advdoors_coownerremove", function()
								if frame and IsValid(frame) then
									AdvDoors.refreshTab(1, false)
									AdvDoors.refreshTab(2, true)
								end
							end)
						end, "Yes", "No")
					end
				end
			end
		end
	else
		local noCoowners = CoOwnerLayout:Add("mgStatusLabel")
		noCoowners:SetType("danger")
		noCoowners:SetText("This door has no coowners yet")
		noCoowners:SizeToContents(true) 
	end
	
	CoOwnerScroll:AddItem(CoOwnerLayout)
	
	local labelTransferOwnership = vgui.Create("DLabel", pnl_management)
	labelTransferOwnership:SetPos(5, select(2, CoOwnerScroll:GetPos()) + CoOwnerScroll:GetTall() + 15)
	labelTransferOwnership:SetText("Transfer ownership: ")
	labelTransferOwnership:SetFont(fontMenu)
	labelTransferOwnership:SizeToContents()
	labelTransferOwnership:InvalidateLayout(true)
	
	local playerListTransfer = vgui.Create("mgPlayerList", pnl_management)
	playerListTransfer:SetPos(labelTransferOwnership:GetWide() + 10, select(2, labelTransferOwnership:GetPos()) - 5)
	playerListTransfer:SetSize(100, labelTransferOwnership:GetTall() + 10)
	playerListTransfer:RemoveByData(LocalPlayer())
	
	local buttonTransferOwnership = vgui.Create("mgButton", pnl_management)
	buttonTransferOwnership:SetPos(labelTransferOwnership:GetWide() + playerListTransfer:GetWide() + 15, select(2, labelTransferOwnership:GetPos()) - 5)
	buttonTransferOwnership:SetSize(100, labelTransferOwnership:GetTall() + 10)
	buttonTransferOwnership:SetText("Transfer")
	buttonTransferOwnership.DoClick = function()
		if not playerListTransfer:GetPlayer() or not IsValid(playerListTransfer:GetPlayer()) or not playerListTransfer:GetPlayer():IsPlayer() or not door:isMasterOwner(LocalPlayer()) then return end
		mgui.ShowDialog("confirm", "Are you sure that you want to transfer owner rights?", function()
			net.Start("advdoors_transferownership")
			net.WriteTable({door = door, ply = playerListTransfer:GetPlayer()})
			net.SendToServer()
			net.Receive("advdoors_transferownership", function()
				if frame and IsValid(frame) then
					frame:Remove()
					AdvDoors.openMenu(door)
					mgui.Notify("You have successfully transfered ownership.")
				end
			end)
		end, "Yes", "No")
	end
	
	if not door:isMasterOwner(LocalPlayer()) then
		boolRent:SetDisabled(true)
		textAmountRent:SetDisabled(true)
		textPeriodsRent:SetDisabled(true)
		buttonUpdateRent:SetDisabled(true)
		playerListTransfer:SetDisabled(true)
		buttonTransferOwnership:SetDisabled(true)
		local labelRentNotOwner = vgui.Create("mgStatusLabel", pnl_management)
		labelRentNotOwner:SetPos(boolRent:GetPos() + boolRent:GetWide() + 5, select(2, boolRent:GetPos()) + 1)
		labelRentNotOwner:SetType("danger")
		labelRentNotOwner:SetText("You are not a master owner")
		labelRentNotOwner:SizeToContents(true)
		local labelTransferNotOwner = vgui.Create("mgStatusLabel", pnl_management)
		labelTransferNotOwner:SetPos(buttonTransferOwnership:GetPos() + buttonTransferOwnership:GetWide() + 5, select(2, buttonTransferOwnership:GetPos()) + 5)
		labelTransferNotOwner:SetType("danger")
		labelTransferNotOwner:SetText("You are not a master owner")
		labelTransferNotOwner:SizeToContents(true)
	end
	
	pnl_management.PaintOver = function()
		surface.SetDrawColor(mgui.Colors.Blue)
		surface.DrawOutlinedRect(0, 0, pnl_management:GetWide(), pnl_management:GetTall())
		surface.DrawLine(0, select(2, buttonUpdateRent:GetPos()) + buttonUpdateRent:GetTall() + 5, pnl_management:GetWide(), select(2, buttonUpdateRent:GetPos()) + buttonUpdateRent:GetTall() + 5)
		surface.DrawLine(0, select(2, buttonSell:GetPos()) + buttonSell:GetTall() + 5, pnl_management:GetWide(), select(2, buttonSell:GetPos()) + buttonSell:GetTall() + 5)
		surface.DrawLine(0, select(2, buttonChangeTitle:GetPos()) + buttonChangeTitle:GetTall() + 5, pnl_management:GetWide(), select(2, buttonChangeTitle:GetPos()) + buttonChangeTitle:GetTall() + 5)
		surface.DrawLine(0, select(2, CoOwnerScroll:GetPos()) + CoOwnerScroll:GetTall() + 5, pnl_management:GetWide(), select(2, CoOwnerScroll:GetPos()) + CoOwnerScroll:GetTall() + 5)
		surface.SetDrawColor(37, 37, 37, 150)
		if not door:isMasterOwner(LocalPlayer()) then
			surface.DrawRect(1, 1, pnl_management:GetWide() - 2, 19 + labelCanRent:GetTall() + labelAmountRent:GetTall() + sliderLengthRent:GetTall() + labelPeriodsRent:GetTall())
			surface.DrawRect(1, select(2, CoOwnerScroll:GetPos()) + CoOwnerScroll:GetTall() + 6, pnl_management:GetWide() - 2, pnl_management:GetTall() - 1 - (select(2, CoOwnerScroll:GetPos()) + CoOwnerScroll:GetTall() + 6))
		end
	end
	
	return pnl_management
end

AdvDoors.AddMenuTab(TAB, 2)