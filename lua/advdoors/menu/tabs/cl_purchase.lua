local TAB = {}

TAB.Title = "Purchase"
TAB.Access = {
	NO_ACCESS
}

TAB.Function = function(frame, door)
	local fontMenu = mgui.CreateFont("menu", {size = 18})
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
	return pnl_purchase
end

AdvDoors.AddMenuTab(TAB)