-- AdvDoors.SetModificationsDisabled()

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