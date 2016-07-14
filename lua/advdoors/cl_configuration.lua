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
