print("[Advanced Door System] Loading...")
AdvDoors = AdvDoors or {}
AdvDoors.ManualLoad = {
	"util/cl_mgui.lua",
	"core/sv_configuration.lua",
	"util/sh_meta.lua",
	"core/sv_doorinfo.lua",
	"menu/sv_menu.lua",
	"hud/cl_overrides.lua",
	"core/cl_fonts.lua",
	"core/cl_configuration.lua",
	"util/sh_util.lua",
	"hud/cl_hud.lua",
	"menu/tabs/cl_information.lua",
	"menu/tabs/cl_purchase.lua",
	"menu/tabs/cl_management.lua",
	"menu/tabs/cl_modifications.lua",
	"menu/tabs/cl_admin.lua",
	"menu/cl_menu.lua"
}

local function LoadFileByName(name, path)
	path = path or name

	if name:match(".*sh_.+%.lua$") then
		if SERVER then AddCSLuaFile(path) end
		include(path)
	elseif name:match(".*sv_.+%.lua$") then
		if SERVER then include(path) end
	elseif name:match(".*cl_.+%.lua$") then
		if SERVER then AddCSLuaFile(path)
		else include(path) end
	else
		MsgC(Color(255, 0, 0), "[Advanced Door System] Unknown file prefix: " .. path .. "\n")
	end
	MsgN("[Advanced Door System] Loaded: " .. path)
end

file.CreateDir("advdoors")
if CLIENT then
	file.CreateDir("advdoors/materials")
else
	file.CreateDir("advdoors/configuration")
end

for k,v in pairs(AdvDoors.ManualLoad) do
	LoadFileByName(v, "advdoors/" .. v)
end