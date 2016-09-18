AdvDoors.LANG = AdvDoors.LANG or {_List = {}}
AdvDoors.Language = "English"

AdvDoors.LANG.RegisterLanguage = function(name)
	AdvDoors.LANG._List[name] = {}

	return AdvDoors.LANG._List[name]
end

AdvDoors.LANG.GetActiveLanguage = function()
	if SERVER then
		return AdvDoors.Language
	else
		return AdvDoors.Language or "English"
	end
end

AdvDoors.LANG.GetString = function(id)
	local lang = AdvDoors.LANG.GetActiveLanguage()

	return (AdvDoors.LANG._List[lang] and AdvDoors.LANG._List[lang][id]) or "..."
end

AdvDoors.LANG.FormatString = function(id, ...)
	local lang = AdvDoors.LANG.GetActiveLanguage()
	local str = (AdvDoors.LANG._List[lang] and AdvDoors.LANG._List[lang][id]) or "..."

	for k, v in ipairs({...}) do
		str = str:Replace("{" .. k .. "}", tostring(v))
	end

	return str
end

local files, _ = file.Find("advdoors/lang/*", "LUA")

for k, v in ipairs(files) do
	local path = "advdoors/lang/" .. v 
	if SERVER then AddCSLuaFile(path) end
	include(path)
end  