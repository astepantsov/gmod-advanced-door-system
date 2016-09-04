util.AddNetworkString("advdoors_purchased")
util.AddNetworkString("advdoors_updaterent")

local function doorCost(ply, door)
	return door:getDoorPrice() or GAMEMODE.Config.doorcost
end

hook.Add("getDoorCost", "AdvancedDoorSystem_DoorCostOverride", doorCost)

local function boughtDoor(ply, door, cost)
	net.Start("advdoors_purchased")
	net.Send(ply)
	return false
end

hook.Add("playerBoughtDoor", "AdvancedDoorSystem_DoorBoughtRefresh", boughtDoor)

net.Receive("advdoors_updaterent", function(len, ply)
	local data = net.ReadTable()
	if (AdvDoors.getOwner(data.door) == ply) then
		if isbool(data.canRent) and isnumber(data.rentPrice) and data.rentPrice >= 1 and isnumber(data.rentLength) and data.rentLength >= 1 and data.rentLength <= 60 then
			data.door:SetNWBool("canRent", data.canRent)
			data.door:SetNWFloat("rentPrice", data.rentPrice)
			data.door:SetNWFloat("rentLength", data.rentLength)
			net.Start("advdoors_updaterent")
			net.WriteString("Rent information has been updated")
			net.Send(ply)
		end
	end
end)