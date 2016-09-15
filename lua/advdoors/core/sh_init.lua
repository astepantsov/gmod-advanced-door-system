AdvDoors = AdvDoors or {}

file.CreateDir("advdoors")
if CLIENT then
	file.CreateDir("advdoors/materials")
else
	file.CreateDir("advdoors/configuration")
	resource.AddWorkshop("763869294")
end

util.PrecacheSound("advdoors/doorbell.wav")
util.PrecacheSound("advdoors/alarm.wav")