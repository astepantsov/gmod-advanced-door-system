--Ugly workaround for the door menu removal.
hook.Add("onKeysMenuOpened", "AdvancedDoorSystem_F2Override", function(ent, panel)
	panel:Remove()
end)
hook.Add("HUDDrawDoorData", "AdvancedDoorSystem_DrawDoorOverride", function(self)
	return true
end)