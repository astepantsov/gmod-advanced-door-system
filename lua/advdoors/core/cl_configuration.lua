NO_ACCESS = 0
OWNER = 1
COOWNER = 2
ADMIN = 3

AdvDoors.Configuration = AdvDoors.Configuration or {}

local function loadConfig(len)
	AdvDoors.Configuration.Loaded = net.ReadTable()
end

net.Receive("advdoors_sendconfig", loadConfig)

AdvDoors.Configuration.getGeneralConfig = function()
	return AdvDoors.Configuration.Loaded.General
end

AdvDoors.Configuration.getMapConfig = function()
	return AdvDoors.Configuration.Loaded[game.GetMap()]
end

AdvDoors.Configuration.GetField = function(type, name)
	return AdvDoors.Configuration.Loaded[type == "map" and game.GetMap() or "General"][name]
end

AdvDoors.Configuration.SetValue = function(type, name, value)
	if LocalPlayer():IsSuperAdmin() then
		net.Start("advdoors_sendconfig")
		net.WriteTable({type = type, name = name, value = value})
		net.SendToServer()
	end
end
