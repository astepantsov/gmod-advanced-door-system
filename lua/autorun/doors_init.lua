print("[Advanced Door System] Loading...")
AdvDoors = AdvDoors or {}
AdvDoors.ManualLoad = {
	"sv_configuration.lua",
	"sh_meta.lua",
	"sv_doorinfo.lua",
	"sv_menu.lua",
	"cl_overrides.lua",
	"cl_fonts.lua",
	"cl_configuration.lua",
	"sh_util.lua",
	"cl_hud.lua",
	"cl_menu.lua"
}

local function LoadFileByName(name, path)
	path = path or name

	if name:match("sh_.+%.lua$") then
		if SERVER then AddCSLuaFile(path) end
		include(path)
	elseif name:match("sv_.+%.lua$") then
		if SERVER then include(path) end
	elseif name:match("cl_.+%.lua$") then
		if SERVER then AddCSLuaFile(path)
		else include(path) end
	else
		MsgC(Color(255, 0, 0), "[Advanced Door System] Unknown file prefix: " .. path .. "\n")
	end
end

file.CreateDir("advdoors")
if CLIENT then
	file.CreateDir("advdoors/materials")
else
	file.CreateDir("advdoors/configuration")
end

for k,v in pairs(AdvDoors.ManualLoad) do
	LoadFileByName(v, "advdoors/" .. v)
	print("[Advanced Door System] Loaded: advdoors/" .. v)
end