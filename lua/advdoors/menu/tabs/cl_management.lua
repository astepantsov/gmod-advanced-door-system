local TAB = {}

TAB.Title = "Management"
TAB.Access = {
	OWNER
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
	boolRent.OnValueChanged = function(value)
		
	end
	
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
		RunConsoleCommand("darkrp", "toggleown")
		net.Receive("advdoors_sold", function()
			if frame and IsValid(frame) then
				frame:Remove()
				AdvDoors.openMenu(door)
				mgui.Notify("You have sold this door for " .. DarkRP.formatMoney(door:getDoorSellPrice() or math.Round(GAMEMODE.Config.doorcost * 2 / 3)))
			end
		end)
	end
	
	local labelCoownerAdd = vgui.Create("DLabel", pnl_management)
	labelCoownerAdd:SetPos(5, select(2, buttonSell:GetPos()) + buttonSell:GetTall() + 15)
	labelCoownerAdd:SetText("Add a coowner:")
	labelCoownerAdd:SetFont(fontMenu)
	labelCoownerAdd:SizeToContents()
	labelCoownerAdd:InvalidateLayout(true) 
	
	local playerList = vgui.Create("mgPlayerList", pnl_management)
	playerList:SetPos(10 + labelCoownerAdd:GetWide(), select(2, labelCoownerAdd:GetPos()) - 5)
	playerList:SetSize(100, labelCoownerAdd:GetTall() + 10)
	playerList:RemoveByData(LocalPlayer())
	
	pnl_management.PaintOver = function()
		surface.SetDrawColor(mgui.Colors.Blue)
		surface.DrawOutlinedRect(0, 0, pnl_management:GetWide(), pnl_management:GetTall())
		surface.DrawLine(0, select(2, buttonUpdateRent:GetPos()) + buttonUpdateRent:GetTall() + 5, pnl_management:GetWide(), select(2, buttonUpdateRent:GetPos()) + buttonUpdateRent:GetTall() + 5)
		surface.DrawLine(0, select(2, buttonSell:GetPos()) + buttonSell:GetTall() + 5, pnl_management:GetWide(), select(2, buttonSell:GetPos()) + buttonSell:GetTall() + 5)
	end
	
	return pnl_management
end

AdvDoors.AddMenuTab(TAB, 2)