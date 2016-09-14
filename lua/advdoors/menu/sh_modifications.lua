ADVDOORS_MODIFICATION_DOORBELL = 1
ADVDOORS_MODIFICATION_REINFORCE = 2
ADVDOORS_MODIFICATION_ALARM = 3
AdvDoors.Modifications = AdvDoors.Modifications or {}
AdvDoors.AddModification = function(modification)
	if not table.HasValue(AdvDoors.Modifications, modification) then
		return table.insert(AdvDoors.Modifications, modification)
	end
	return false
end
AdvDoors.hasModification = function(door, id)
	if door:GetNWBool("advdoors_modification_" .. id, false) then
		return true
	end
	return false
end
--You can edit modifications here
local doorbell, reinforce, alarm
if CLIENT then
	AdvDoors.DownloadMaterial("http://i.imgur.com/4ZlW2gE.png", function(self) doorbell = self end)
	AdvDoors.DownloadMaterial("http://i.imgur.com/iGgYdyV.png", function(self) reinforce = self end)
	AdvDoors.DownloadMaterial("http://i.imgur.com/8SThKBP.png", function(self) alarm = self end)
end

AdvDoors.AddModification(
	{
		Name = "Door bell",
		Description = "Allows other players to use a door bell on your door (will only work if door display is enabled for this door)",
		isEnabled = true,
		Cost = 500,
		Icon = doorbell
	}
)

AdvDoors.AddModification(
	{
		Name = "Reinforce a door",
		Description = "Lockpicking will take more time",
		isEnabled = true,
		Cost = 2000,
		Icon = reinforce
	}
)

AdvDoors.AddModification(
	{
		Name = "Add alarm",
		Description = "Adds an alarm to your door which will activate when somebody has lockpicked it",
		isEnabled = true,
		Cost = 5000,
		Icon = alarm
	}
)

AdvDoors.SetModificationPrice = function(id, price)
	if AdvDoors.Modifications[id] then
		AdvDoors.Modifications[id].Cost = price
	end
end

if SERVER then
	util.AddNetworkString("advdoors_doorbell")
	util.AddNetworkString("advdoors_purchasemod")
	util.AddNetworkString("advdoors_deletemod")
	
	AdvDoors.SetModification = function(door, id)
		door:SetNWBool("advdoors_modification_" .. id, true)
	end
	
	AdvDoors.UnsetModification = function(door, id)
		door:SetNWBool("advdoors_modification_" .. id, false)
	end
	
	hook.Add("lockpickTime", "AdvancedDoorSystem_LockpickTime", function(ply, ent)
		if AdvDoors.hasModification(ent, ADVDOORS_MODIFICATION_REINFORCE) then
			return 60
		end
	end)
	
	hook.Add("onLockpickCompleted", "AdvancedDoorSystem_LockpickCompleted", function(ply, success, ent)
		if AdvDoors.hasModification(ent, ADVDOORS_MODIFICATION_ALARM) and success then
			ent:EmitSound("advdoors/alarm.wav")
			timer.Create("AdvDoors_Alarm_" .. AdvDoors.getEntIndex(ent), 5, 5, function()
				ent:StopSound("advdoors/alarm.wav")
				ent:EmitSound("advdoors/alarm.wav")
			end)
		end
	end)
	
	local doorbellCooldown = doorbellCooldown or {}
	
	net.Receive("advdoors_doorbell", function(len, ply)
		local data = net.ReadEntity()
		if IsValid(ply) and ply:IsPlayer() and IsValid(data) and ply:GetPos():Distance(data:GetPos()) < 200 and not doorbellCooldown[AdvDoors.getEntIndex(data)] then
			doorbellCooldown = true
			timer.Simple(5, function()
				doorbellCooldown = false
			end)
			ent:EmitSound("advdoors/doorbell.wav")
		end
	end)
	
	net.Receive("advdoors_purchasemod", function(len, ply)
		local data = net.ReadTable()
		if IsValid(data.door) and data.door:isDoor() and data.door:isKeysOwnedBy(ply) and ply:GetPos():Distance(data.door:GetPos()) < 300 and AdvDoors.Modifications[data.mod] and ply:getDarkRPVar("money") >= AdvDoors.Modifications[data.mod].Cost then
			ply:addMoney(-AdvDoors.Modifications[data.mod].Cost)
			AdvDoors.SetModification(data.door, data.mod)
			timer.Simple(0.25, function()
				net.Start("advdoors_purchasemod")
				net.Send(ply)
			end)
		end
	end)
	
end