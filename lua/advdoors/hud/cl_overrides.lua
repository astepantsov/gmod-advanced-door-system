--Ugly workaround for the door menu removal.
hook.Add("onKeysMenuOpened", "AdvancedDoorSystem_F2Override", function(ent, panel)
	if ent:isDoor() then
		panel:Remove()
	end
end)
local fontMenu = mgui.CreateFont("menu", {size = 18})
hook.Add("HUDDrawDoorData", "AdvancedDoorSystem_DrawDoorOverride", function(self)
	if self:isDoor() then
		local ent = LocalPlayer():GetEyeTrace().Entity
		if (ent:isDoor() and LocalPlayer():GetPos():Distance(ent:GetPos()) < 300) and (((ent:isDoorBlacklisted() or ent:isDoorTypeBlacklisted() or ent:isDoorModelBlacklisted()) and not ent:getKeysNonOwnable()) or (ent:getKeysNonOwnable() and LocalPlayer():IsSuperAdmin())) then
			draw.SimpleText(AdvDoors.LANG.GetString("disabled_open"), fontMenu, ScrW()/2, ScrH()/2, mgui.Colors.Blue, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		return true
	end
end)