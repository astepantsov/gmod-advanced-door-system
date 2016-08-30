local TAB = {}

TAB.Title = "Modifications"
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
	
	return pnl_modifications
end

AdvDoors.AddMenuTab(TAB, 4)