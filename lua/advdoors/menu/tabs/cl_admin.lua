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

	local Label_Purchase = vgui.Create("DLabel", pnl_admin)
	Label_Purchase:SetPos(5, 5)
	Label_Purchase:SetText("Is ownership enabled: ")
	Label_Purchase:SetFont(fontMenu)
	Label_Purchase:SizeToContents()

	local BoolOwnership = vgui.Create("mgBoolean", pnl_admin)
	BoolOwnership:SetPos(10 + Label_Purchase:GetWide(), 5)
	BoolOwnership:SetValue(!door:getKeysNonOwnable())
	BoolOwnership.OnValueChanged = function(bool)
		net.Start("advdoors_toggleownership")
		net.WriteTable({door = door, state = bool:GetValue()})
		net.SendToServer()
	end
	
	pnl_admin.PaintOver = function()
		surface.SetDrawColor(mgui.Colors.Blue)
		surface.DrawOutlinedRect(0, 0, pnl_admin:GetWide(), pnl_admin:GetTall())
		surface.DrawLine(1, BoolOwnership:GetTall() + 10, pnl_admin:GetWide() - 2, BoolOwnership:GetTall() + 10)
	end
	
	return pnl_admin
end

AdvDoors.AddMenuTab(TAB, 4)