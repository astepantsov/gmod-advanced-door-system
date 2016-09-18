local TAB = {}

TAB.Title = AdvDoors.LANG.GetString("mng_title")
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
	labelCanRent:SetText(AdvDoors.LANG.GetString("can_rent"))
	labelCanRent:SetFont(fontMenu)
	labelCanRent:SizeToContents()
	labelCanRent:InvalidateLayout(true)
	
	local boolRent = vgui.Create("mgBoolean", pnl_management)
	boolRent:SetPos(10 + labelCanRent:GetWide(), 3)
	boolRent:SetValue(door:GetNWBool("canRent", false))
	
	local labelAmountRent = vgui.Create("DLabel", pnl_management)
	labelAmountRent:SetPos(5, 20 + select(2, labelCanRent:GetPos()))
	labelAmountRent:SetText(AdvDoors.LANG.GetString("rent_pay")  .. ":")
	labelAmountRent:SetFont(fontMenu)
	labelAmountRent:SizeToContents()
	labelAmountRent:InvalidateLayout(true)
	
	local textAmountRent = vgui.Create("mgTextEntry", pnl_management)
	textAmountRent:SetPos(10 + labelAmountRent:GetWide(), select(2, labelAmountRent:GetPos()));
	textAmountRent:SetSize(100, 16)
	textAmountRent:SetValue(door:GetNWFloat("rentPrice", 1))
	
	local labelLengthRent = vgui.Create("DLabel", pnl_management)
	labelLengthRent:SetPos(5, 20 + select(2, labelAmountRent:GetPos()))
	labelLengthRent:SetText(AdvDoors.LANG.GetString("mins_in_period") .. ":")
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
	labelPeriodsRent:SetText(AdvDoors.LANG.GetString("max_periods") .. ":")
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
	buttonUpdateRent:SetText(AdvDoors.LANG.GetString("update"))
	buttonUpdateRent.DoClick = function()
		if not tonumber(textAmountRent:GetValue()) or not tonumber(sliderLengthRent:GetValue()) or not tonumber(textPeriodsRent:GetValue()) or not isbool(boolRent:GetValue()) then return end
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
	labelSell:SetText(AdvDoors.LANG.GetString("sell_for"))
	labelSell:SetFont(fontMenu)
	labelSell:SizeToContents()
	labelSell:InvalidateLayout(true) 
	
	local labelSellPrice = vgui.Create("mgStatusLabel", pnl_management)
	labelSellPrice:SetPos(10 + labelSell:GetWide(), select(2, labelSell:GetPos()))
	labelSellPrice:SetType("primary")
	labelSellPrice:SetText(DarkRP.formatMoney(door:getDoorSellPrice() or math.Round(GAMEMODE.Config.doorcost * 2 / 3)))
	labelSellPrice:SizeToContents()
	
	local buttonSell = vgui.Create("mgButton", pnl_management)
	buttonSell:SetPos(labelSell:GetWide() + labelSellPrice:GetWide() + 15, select(2, labelSell:GetPos()) - 5)
	buttonSell:SetSize(100, labelSell:GetTall() + 10)
	buttonSell:SetText(AdvDoors.LANG.GetString("sell_btn"))
	buttonSell.DoClick = function()
		mgui.ShowDialog("confirm", AdvDoors.LANG.GetString("sell_conf"), function()
			RunConsoleCommand("darkrp", "toggleown")
			net.Receive("advdoors_sold", function()
				if frame and IsValid(frame) then
					frame:Remove()
					AdvDoors.openMenu(door)
				end
			end)
		end, AdvDoors.LANG.GetString("yes"), AdvDoors.LANG.GetString("no"))
	end
	
	local labelTitle = vgui.Create("DLabel", pnl_management)
	labelTitle:SetPos(5, select(2, buttonSell:GetPos()) + buttonSell:GetTall() + 15)
	labelTitle:SetText(door:getKeysTitle() and AdvDoors.LANG.FormatString("current_title", door:getKeysTitle()) or AdvDoors.LANG.GetString("no_title"))
	labelTitle:SetFont(fontMenu)
	labelTitle:SizeToContents()
	labelTitle:InvalidateLayout(true)
	
	local buttonChangeTitle = vgui.Create("mgButton", pnl_management)
	buttonChangeTitle:SetPos(labelTitle:GetWide() + 10, select(2, labelTitle:GetPos()) - 5)
	buttonChangeTitle:SetSize(100, labelTitle:GetTall() + 10)
	buttonChangeTitle:SetText(AdvDoors.LANG.GetString("change"))
	buttonChangeTitle.DoClick = function()
		mgui.ShowDialog("string", AdvDoors.LANG.GetString("set_title_conf"), function(val)
			net.Start("advdoors_settitle")
			net.WriteTable({door = door, title = val})
			net.SendToServer()
			net.Receive("advdoors_settitle", function()
				if frame and IsValid(frame) then
					AdvDoors.refreshTab(2, true)
				end
			end)
		end, AdvDoors.LANG.GetString("set_title_descr"), door:getKeysTitle() or "")
	end
	
	local labelCoOwner = vgui.Create("DLabel", pnl_management)
	labelCoOwner:SetPos(5, select(2, buttonChangeTitle:GetPos()) + buttonChangeTitle:GetTall() + 15)
	labelCoOwner:SetText(AdvDoors.LANG.GetString("add_coowner") .. ": ")
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
	buttonAddCoOwner:SetText(AdvDoors.LANG.GetString("add"))
	buttonAddCoOwner.DoClick = function()
		if not playerList:GetPlayer() or not IsValid(playerList:GetPlayer()) or not playerList:GetPlayer():IsPlayer() then return end
		mgui.ShowDialog("confirm", AdvDoors.LANG.GetString("add_conf"), function()
			net.Start("advdoors_coowneradd")
			net.WriteTable({door = door, ply = playerList:GetPlayer()})
			net.SendToServer()
			net.Receive("advdoors_coowneradd", function()
				if frame and IsValid(frame) then
					AdvDoors.refreshTab(1, false)
					AdvDoors.refreshTab(2, true)
				end
			end)
		end, AdvDoors.LANG.GetString("yes"), AdvDoors.LANG.GetString("no"))
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
					buttonRemove:SetText(AdvDoors.LANG.GetString("remove"))
					buttonRemove.DoClick = function()
						if not IsValid(AdvDoors.getByUserID(k)) or not AdvDoors.getByUserID(k):IsPlayer() or not door:isMasterOwner(LocalPlayer()) then return end
						mgui.ShowDialog("confirm", AdvDoors.LANG.GetString("remove_conf"), function()
							net.Start("advdoors_coownerallowedremove")
							net.WriteTable({door = door, ply = AdvDoors.getByUserID(k)})
							net.SendToServer()
							net.Receive("advdoors_coownerallowedremove", function()
								if frame and IsValid(frame) then
									AdvDoors.refreshTab(1, false)
									AdvDoors.refreshTab(2, true)
								end
							end)
						end, AdvDoors.LANG.GetString("yes"), AdvDoors.LANG.GetString("no"))
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
					buttonRemove:SetText(AdvDoors.LANG.GetString("remove"))
					buttonRemove.DoClick = function()
						if not IsValid(AdvDoors.getByUserID(k)) or not AdvDoors.getByUserID(k):IsPlayer() or not door:isMasterOwner(LocalPlayer()) then return end
						mgui.ShowDialog("confirm", AdvDoors.LANG.GetString("remove_conf"), function()
							net.Start("advdoors_coownerremove")
							net.WriteTable({door = door, ply = AdvDoors.getByUserID(k)})
							net.SendToServer()
							net.Receive("advdoors_coownerremove", function()
								if frame and IsValid(frame) then
									AdvDoors.refreshTab(1, false)
									AdvDoors.refreshTab(2, true)
								end
							end)
						end, AdvDoors.LANG.GetString("yes"), AdvDoors.LANG.GetString("no"))
					end
				end
			end
		end
	else
		local noCoowners = CoOwnerLayout:Add("mgStatusLabel")
		noCoowners:SetType("danger")
		noCoowners:SetText(AdvDoors.LANG.GetString("no_coowners"))
		noCoowners:SizeToContents() 
	end
	
	CoOwnerScroll:AddItem(CoOwnerLayout)
	
	local labelTransferOwnership = vgui.Create("DLabel", pnl_management)
	labelTransferOwnership:SetPos(5, select(2, CoOwnerScroll:GetPos()) + CoOwnerScroll:GetTall() + 15)
	labelTransferOwnership:SetText(AdvDoors.LANG.GetString("transfer") .. ": ")
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
	buttonTransferOwnership:SetText(AdvDoors.LANG.GetString("transfer_btn"))
	buttonTransferOwnership.DoClick = function()
		if not playerListTransfer:GetPlayer() or not IsValid(playerListTransfer:GetPlayer()) or not playerListTransfer:GetPlayer():IsPlayer() or not door:isMasterOwner(LocalPlayer()) then return end
		mgui.ShowDialog("confirm", AdvDoors.LANG.GetString("transfer_conf"), function()
			net.Start("advdoors_transferownership")
			net.WriteTable({door = door, ply = playerListTransfer:GetPlayer()})
			net.SendToServer()
			net.Receive("advdoors_transferownership", function()
				if frame and IsValid(frame) then
					frame:Remove()
					AdvDoors.openMenu(door)
					mgui.Notify(AdvDoors.LANG.GetString("transfer_success"))
				end
			end)
		end, AdvDoors.LANG.GetString("yes"), AdvDoors.LANG.GetString("no"))
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
		labelRentNotOwner:SetText(AdvDoors.LANG.GetString("not_master"))
		labelRentNotOwner:SizeToContents()
		local labelTransferNotOwner = vgui.Create("mgStatusLabel", pnl_management)
		labelTransferNotOwner:SetPos(buttonTransferOwnership:GetPos() + buttonTransferOwnership:GetWide() + 5, select(2, buttonTransferOwnership:GetPos()) + 5)
		labelTransferNotOwner:SetType("danger")
		labelTransferNotOwner:SetText(AdvDoors.LANG.GetString("not_master"))
		labelTransferNotOwner:SizeToContents()
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