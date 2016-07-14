util.AddNetworkString("advdoors_sendconfig")

AdvDoors.Configuration = AdvDoors.Configuration or {}
AdvDoors.Configuration.Default = {
	[game.GetMap()] = {
		DoorPrices = {}
	}
}

AdvDoors.Configuration.Save = function(config)
	file.Write("advdoors/configuration/config.txt", util.TableToJSON(config))
end

AdvDoors.Configuration.Load = function()
	if !file.Exists("advdoors/configuration/config.txt", "DATA") then
		file.Write("advdoors/configuration/config.txt", util.TableToJSON(AdvDoors.Configuration.Default))
	end

	local config = util.JSONToTable(file.Read("advdoors/configuration/config.txt", "DATA"))
	if not config[game.GetMap()] then
		config[game.GetMap()] = {
			DoorPrices = {}
		}
		AdvDoors.Configuration.Save(config)
	end

	AdvDoors.Configuration.Loaded = config

	print("[Advanced Door System] Configuration has been loaded.")
end

AdvDoors.Configuration.getGeneralConfig = function()
	return AdvDoors.Configuration.Loaded.General
end

AdvDoors.Configuration.getMapConfig = function()
	return AdvDoors.Configuration.Loaded[game.GetMap()]
end

AdvDoors.Configuration.Load();

local function loadClientConfig(ply)
	net.Start("advdoors_sendconfig")
	net.WriteTable(AdvDoors.Configuration.Loaded);
	net.Send(ply)
end

hook.Add("PlayerInitialSpawn", "AdvancedDoorSystem_ConfigurationLoad", loadClientConfig)