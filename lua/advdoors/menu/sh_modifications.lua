ADVDOORS_MODIFICATION_DOORBELL = 1
ADVDOORS_MODIFICATION_REINFORCE = 2
ADVDOORS_MODIFICATION_ALARM = 3
AdvDoors.Modifications = AdvDoors.Modifications or {}
AdvDoors.ModificationsEnabled = true
AdvDoors.AddModification = function(id, modification)
	AdvDoors.Modifications[id] = modification
end
AdvDoors.hasModification = function(door, id)
	if door:GetNWBool("advdoors_modification_" .. id, false) then
		return true
	end
	return false
end
AdvDoors.SetModificationsDisabled = function()
	AdvDoors.ModificationsEnabled = false
	if CLIENT then
		AdvDoors.removeMenuTab(3)
	end
end

AdvDoors.SetModificationPrice = function(id, price)
	if AdvDoors.Modifications[id] then
		AdvDoors.Modifications[id].Cost = price
	end
end

AdvDoors.SetModificationEnabled = function(id, bool)
	if AdvDoors.Modifications[id] then
		AdvDoors.Modifications[id].isEnabled = bool
	end
end

if SERVER then
	util.AddNetworkString("advdoors_doorbell")
	util.AddNetworkString("advdoors_purchasemod")
	
	AdvDoors.SetModification = function(door, id)
		door:SetNWBool("advdoors_modification_" .. id, true)
	end
	
	AdvDoors.UnsetModification = function(door, id)
		door:SetNWBool("advdoors_modification_" .. id, false)
	end
	
	AdvDoors.RemoveAllModifications = function(door) 
		for k,v in pairs(AdvDoors.Modifications) do
			door:SetNWBool("advdoors_modification_" .. k, false)
		end
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
			doorbellCooldown[AdvDoors.getEntIndex(data)] = true
			timer.Simple(5, function()
				doorbellCooldown[AdvDoors.getEntIndex(data)] = false
			end)
			data:EmitSound("advdoors/doorbell.wav")
		end
	end)
	
	net.Receive("advdoors_purchasemod", function(len, ply)
		local data = net.ReadTable()
		if IsValid(data.door) and data.door:isDoor() and data.door:isKeysOwnedBy(ply) and ply:GetPos():Distance(data.door:GetPos()) < 300 and AdvDoors.Modifications[data.mod] and ply:getDarkRPVar("money") >= AdvDoors.Modifications[data.mod].Cost and AdvDoors.ModificationsEnabled then
			ply:addMoney(-AdvDoors.Modifications[data.mod].Cost)
			AdvDoors.SetModification(data.door, data.mod)
			timer.Simple(0.25, function()
				net.Start("advdoors_purchasemod")
				net.Send(ply)
			end)
		end
	end)
end