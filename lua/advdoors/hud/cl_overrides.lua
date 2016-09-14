--Ugly workaround for the door menu removal.
hook.Add("onKeysMenuOpened", "AdvancedDoorSystem_F2Override", function(ent, panel)
	if ent:isDoor() then
		panel:Remove()
	end
end)
hook.Add("HUDDrawDoorData", "AdvancedDoorSystem_DrawDoorOverride", function(self)
	return true
end)