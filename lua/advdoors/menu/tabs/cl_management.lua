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
	
	return pnl_management
end

AdvDoors.AddMenuTab(TAB)