local cog
AdvDoors.DownloadMaterial("http://i.imgur.com/2CKMuhQ.png", function(m) cog = m end)

AdvDoors.openMenu = function(door)
	AdvDoors.CurrentTabs = {}
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
		if (table.HasValue(v.Access, NO_ACCESS) and not LocalPlayer():canKeysLock(door) and not LocalPlayer():canKeysLock(door)) or (table.HasValue(v.Access, OWNER) and LocalPlayer() == door:getDoorOwner()) or (table.HasValue(v.Access, COOWNER) and door:getKeysCoOwners() and door:getKeysCoOwners()[LocalPlayer():UserID()]) or (table.HasValue(v.Access, ADMIN) and LocalPlayer():IsSuperAdmin()) then			
			local b = hlist:AddTab(v.Title, cog, v.Function(frame, door) or nil)
			AdvDoors.CurrentTabs[k] = b
			if k == 1 then hlist:SetSelected(b) end
		end
	end
	
	AdvDoors.refreshTab = function(tab_id, setselected)
		if AdvDoors.CurrentTabs[tab_id] then
			AdvDoors.CurrentTabs[tab_id].Child:Remove()
			AdvDoors.CurrentTabs[tab_id].Child = AdvDoors.MenuTabs[tab_id].Function(frame, door) or nil
			if setselected then
				hlist:SetSelected(AdvDoors.CurrentTabs[tab_id])
			end
		end
	end
end

local function KeyPress()
    gui.EnableScreenClicker(input.IsKeyDown(KEY_LALT))
end
 
hook.Add("Think","AdvancedDoorSystem_OpenMenuF2", function()
	local ent = LocalPlayer():GetEyeTrace().Entity
	if input.IsKeyDown(KEY_F2) and not AdvDoors.KeyLocked and ent:isDoor() and LocalPlayer():GetPos():Distance(ent:GetPos()) < 200 and ((ent:isKeysOwnable() and not ent:getKeysNonOwnable()) or LocalPlayer():IsSuperAdmin()) then
		AdvDoors.KeyLocked = true
		AdvDoors.openMenu(ent);
	end
end)