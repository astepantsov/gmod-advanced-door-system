util.AddNetworkString("advdoors_sendconfig")

AdvDoors.Configuration = AdvDoors.Configuration or {}
AdvDoors.Configuration.Default = {
	General = {
		doorPropBlacklist = {},
		doorModelBlacklist = {}
	},
	[game.GetMap()] = {
		DoorPrices = {},
		blacklistedDoors = {},
		DoorJobs = {}
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
			DoorPrices = {},
			blacklistedDoors = {},
			DoorJobs = {}
		}
		AdvDoors.Configuration.Save(config)
	end

	if not config.General.doorModelBlacklist then
		config.General.doorModelBlacklist = {}
		AdvDoors.Configuration.Save(config)
	end
	
	AdvDoors.Configuration.Loaded = config

	AdvDoors.Configuration.Broadcast()
	
	MsgC(Color(0, 255, 0), "[Advanced Door System] Configuration has been loaded.\n")
end

AdvDoors.Configuration.getGeneralConfig = function()
	return AdvDoors.Configuration.Loaded.General
end

AdvDoors.Configuration.getMapConfig = function()
	return AdvDoors.Configuration.Loaded[game.GetMap()]
end

AdvDoors.Configuration.SetValue = function(type, name, value)
	AdvDoors.Configuration.Loaded[type == "map" and game.GetMap() or "General"][name] = value
	AdvDoors.Configuration.Save(AdvDoors.Configuration.Loaded)
	AdvDoors.Configuration.Broadcast()
end

AdvDoors.Configuration.GetField = function(type, name)
	return AdvDoors.Configuration.Loaded[type == "map" and game.GetMap() or "General"][name]
end

AdvDoors.Configuration.Broadcast = function()
	net.Start("advdoors_sendconfig")
	net.WriteTable(AdvDoors.Configuration.Loaded)
	net.Broadcast()
end

AdvDoors.Configuration.Load();

local function loadClientConfig(ply)
	net.Start("advdoors_sendconfig")
	net.WriteTable(AdvDoors.Configuration.Loaded)
	net.Send(ply)
end

hook.Add("PlayerInitialSpawn", "zAdvancedDoorSystem_ConfigurationLoad", loadClientConfig)

net.Receive("advdoors_sendconfig", function( len, ply )
	if IsValid(ply) and ply:IsSuperAdmin() then
		local data = net.ReadTable()
		AdvDoors.Configuration.SetValue(data.type, data.name, data.value)
	end
end)