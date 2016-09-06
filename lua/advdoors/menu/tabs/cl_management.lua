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
			rentLength = tonumber(sliderLengthRent:GetValue()) or ""
		})
		net.SendToServer()
		net.Receive("advdoors_updaterent", function(len)
			mgui.Notify(net.ReadString())
		end)
	end
	
	pnl_management.PaintOver = function()
		surface.SetDrawColor(mgui.Colors.Blue)
		surface.DrawOutlinedRect(0, 0, pnl_management:GetWide(), pnl_management:GetTall())
		surface.DrawLine(0, select(2, buttonUpdateRent:GetPos()) + buttonUpdateRent:GetTall() + 5, pnl_management:GetWide(), select(2, buttonUpdateRent:GetPos()) + buttonUpdateRent:GetTall() + 5)
	end
	
	return pnl_management
end

AdvDoors.AddMenuTab(TAB, 2)