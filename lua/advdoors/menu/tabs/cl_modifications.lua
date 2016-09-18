local TAB = {}

TAB.Title = AdvDoors.LANG.GetString("mod_title")
TAB.Access = {
	OWNER,
	COOWNER
}

TAB.Function = function(frame, door)
	local fontMenu = mgui.CreateFont("menu", {size = 18})
	local pnl_modifications = vgui.Create("mgPanel", frame)
	pnl_modifications:SetPos(5, 75)
	pnl_modifications:SetSize(frame:GetWide() - 10, frame:GetTall() - 80)
	pnl_modifications:SetVisible(false)
	
	local layoutModifications = vgui.Create("DIconLayout", pnl_modifications)
	layoutModifications:SetWidth(pnl_modifications:GetWide() - 10);
	layoutModifications:SetPos(5, 5)
	layoutModifications:SetSpaceX(5)
	layoutModifications:SetSpaceY(5)
	
	for k,v in ipairs(AdvDoors.Modifications) do
		if !v.isEnabled then continue end
		local panel = layoutModifications:Add("mgPanel")
		panel:SetSize(layoutModifications:GetWide(), 52)
		local icon = vgui.Create("DImage", panel)
		icon:SetPos(5, 10)
		icon:SetSize(32, 32)
		icon:SetMaterial(v.Icon)
		local labelModName = vgui.Create("DLabel", panel)
		labelModName:SetPos(47, 5)
		labelModName:SetText(v.Name)
		labelModName:SetFont(fontMenu)
		labelModName:SizeToContents()
		local labelModPrice = vgui.Create("mgStatusLabel", panel)
		labelModPrice:SetPos(labelModName:GetPos() + labelModName:GetWide() + 5, 5)
		labelModPrice:SetType("primary")
		labelModPrice:SetText(DarkRP.formatMoney(v.Cost))
		labelModPrice:SizeToContents() 
		local labelModDescription = vgui.Create("mgStatusLabel", panel)
		labelModDescription:SetPos(47, select(2, labelModName:GetPos()) + labelModName:GetTall() + 5)
		labelModDescription:SetType("primary")
		labelModDescription:SetText(v.Description)
		labelModDescription:SizeToContents() 
		local buttonBuyMod = vgui.Create("mgStatusLabel", panel)
		buttonBuyMod:SetPos(labelModPrice:GetPos() + labelModPrice:GetWide() + 5, 5)
		buttonBuyMod:SetType((AdvDoors.hasModification(door, k) or LocalPlayer():getDarkRPVar("money") < v.Cost) and "danger" or "success")
		buttonBuyMod:SetText(AdvDoors.hasModification(door, k) and AdvDoors.LANG.GetString("mod_owned") or LocalPlayer():getDarkRPVar("money") < v.Cost and AdvDoors.LANG.GetString("mod_no_money") or AdvDoors.LANG.GetString("mod_purchase"))
		if not AdvDoors.hasModification(door, k) and LocalPlayer():getDarkRPVar("money") >= v.Cost then
			buttonBuyMod:SetFunction(function()
				net.Start("advdoors_purchasemod")
				net.WriteTable({door = door, mod = k})
				net.SendToServer()
				net.Receive("advdoors_purchasemod", function()
					AdvDoors.refreshTab(3, true)
				end)
			end)
		end
		buttonBuyMod:SizeToContents()
		panel.PaintOver = function()
			if AdvDoors.hasModification(door, k) then
				surface.SetDrawColor(37, 37, 37, 150)
				surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
			end
		end
	end
	
	pnl_modifications.PaintOver = function()
		surface.SetDrawColor(mgui.Colors.Blue)
		surface.DrawOutlinedRect(0, 0, pnl_modifications:GetWide(), pnl_modifications:GetTall())
	end
	
	return pnl_modifications
end

if AdvDoors.ModificationsEnabled then
	AdvDoors.AddMenuTab(TAB, 3)
end