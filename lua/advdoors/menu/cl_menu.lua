local cog
AdvDoors.DownloadMaterial("http://i.imgur.com/2CKMuhQ.png", function(m) cog = m end)

AdvDoors.openMenu = function(door)
	local frame = vgui.Create("mgFrame")
	frame:SetSize(600, 500)
	frame:Center()
	frame:MakePopup()
	frame:SetTitle("Door Menu")
	frame:SetBackgroundBlur(true)
	frame.CloseButton.DoClick = function()
		AdvDoors.KeyLocked = false
		frame:Remove()
	end

	local hlist = vgui.Create("mgHorizontalTabs", frame)
	hlist:SetPos(5, 30)
	hlist:SetSize(frame:GetWide() - 10, 40)

	for k, v in pairs(AdvDoors.MenuTabs) do
		if (table.HasValue(v.Access, NO_ACCESS) and not LocalPlayer():canKeysLock(door) and not LocalPlayer():canKeysLock(door) and not AdvDoors.getOwnerName(door)) or (table.HasValue(v.Access, OWNER) and LocalPlayer() == door:getDoorOwner()) or (table.HasValue(v.Access, COOWNER) and door:getKeysCoOwners() and door:getKeysCoOwners()[LocalPlayer():UserID()]) or (table.HasValue(v.Access, ADMIN) and LocalPlayer():IsSuperAdmin()) then
			
			local b = hlist:AddTab(v.Title, cog, v.Function(frame, door) or nil)
			if k == 1 then hlist:SetSelected(b) end
		end
	end
end