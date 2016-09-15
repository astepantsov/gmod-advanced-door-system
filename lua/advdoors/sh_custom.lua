-- AdvDoors.SetModificationsDisabled()

local doorbell, reinforce, alarm

if CLIENT then

	AdvDoors.DownloadMaterial("http://i.imgur.com/4ZlW2gE.png", function(self) doorbell = self end) -- Icon made by http://www.flaticon.com/authors/madebyoliver from www.flaticon.com

	AdvDoors.DownloadMaterial("http://i.imgur.com/iGgYdyV.png", function(self) reinforce = self end) -- Icon made by http://www.flaticon.com/authors/freepik from www.flaticon.com

	AdvDoors.DownloadMaterial("http://i.imgur.com/8SThKBP.png", function(self) alarm = self end) -- Icon made by http://www.flaticon.com/authors/trinh-ho from www.flaticon.com

	AdvDoors.useBell = function(door)

		net.Start("advdoors_doorbell")

		net.WriteEntity(door)

		net.SendToServer()

	end

end

AdvDoors.AddModification(
	ADVDOORS_MODIFICATION_DOORBELL,
	{
		Name = "Door bell",
		Description = "Allows other players to use a door bell on your door (will only work if door display is enabled for this door)",
		isEnabled = true,
		Cost = 500,
		Icon = doorbell
	}
)

AdvDoors.AddModification(
	ADVDOORS_MODIFICATION_REINFORCE,
	{
		Name = "Reinforce a door",
		Description = "Lockpicking will take more time",
		isEnabled = true,
		Cost = 2000,
		Icon = reinforce
	}
)

AdvDoors.AddModification(
	ADVDOORS_MODIFICATION_ALARM,
	{
		Name = "Add alarm",
		Description = "Adds an alarm to your door which will activate when somebody has lockpicked it",
		isEnabled = true,
		Cost = 5000,
		Icon = alarm
	}
)