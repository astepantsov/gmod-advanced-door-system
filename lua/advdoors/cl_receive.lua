AdvDoors.Configuration = AdvDoors.Configuration or {}

local function loadConfig(len)
	AdvDoors.Configuration.Loaded = net.ReadTable()
end

net.Receive("advdoors_sendconfig", loadConfig)