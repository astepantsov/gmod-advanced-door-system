util.AddNetworkString("advdoors_purchased")
util.AddNetworkString("advdoors_updaterent")
util.AddNetworkString("advdoors_rent")
util.AddNetworkString("advdoors_sold")
util.AddNetworkString("advdoors_settitle")
util.AddNetworkString("advdoors_coowneradd")
util.AddNetworkString("advdoors_coownerallowedremove")
util.AddNetworkString("advdoors_coownerremove")
util.AddNetworkString("advdoors_transferownership")
util.AddNetworkString("advdoors_toggleownership")

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

local function soldDoor(ply, door)
	if door:isDoor() then
		door:SetNWBool("canRent", false)
		door:SetNWFloat("rentPrice", 1)
		door:SetNWFloat("rentLength", 1)
		door:SetNWFloat("rentMaxPeriods", 1)
		net.Start("advdoors_sold")
		net.Send(ply)
	end
end

hook.Add("playerKeysSold", "AdvancedDoorSystem_DoorSold", soldDoor)

net.Receive("advdoors_updaterent", function(len, ply)
	local data = net.ReadTable()
	if (AdvDoors.getOwner(data.door) == ply and ply:GetPos():Distance(data.door:GetPos()) < 300) then
		if isbool(data.canRent) and isnumber(data.rentPrice) and data.rentPrice >= 1 and isnumber(data.rentLength) and data.rentLength >= 1 and data.rentLength <= 60 and isnumber(data.rentMaxPeriods) and data.rentMaxPeriods >= 1 and math.Round(data.rentMaxPeriods) == data.rentMaxPeriods and math.Round(data.rentLength) == data.rentLength and math.Round(data.rentPrice) == data.rentPrice then
			data.door:SetNWBool("canRent", data.canRent)
			data.door:SetNWFloat("rentPrice", math.floor(data.rentPrice))
			data.door:SetNWFloat("rentLength", math.floor(data.rentLength))
			data.door:SetNWFloat("rentMaxPeriods", math.floor(data.rentMaxPeriods))
			timer.Simple(0.25, function()
				net.Start("advdoors_updaterent")
				net.WriteString("Rent information has been updated")
				net.Send(ply)
			end)
		else
			net.Start("advdoors_updaterent")
			net.WriteString("Couldn't update the rent information, verify your input")
			net.Send(ply)
		end
	end
end)

net.Receive("advdoors_rent", function(len, ply)
	local data = net.ReadTable()
	if (data.door:GetNWBool("canRent", false) and AdvDoors.getOwner(data.door) and AdvDoors.getOwner(data.door) != ply and data.door:GetNWFloat("rentPrice", false) and data.door:GetNWFloat("rentLength", false) and data.door:GetNWFloat("rentMaxPeriods", false) and data.periods >= 1 and data.periods <= data.door:GetNWFloat("rentMaxPeriods", false) and ply:getDarkRPVar("money") >= (data.door:GetNWFloat("rentPrice", false) * data.periods) and math.Round(data.periods) == data.periods and ply:GetPos():Distance(data.door:GetPos()) < 300) then
		local periods = math.Round(data.periods)
		ply:addMoney(-(data.door:GetNWFloat("rentPrice", false) * periods))
		AdvDoors.getOwner(data.door):addMoney((data.door:GetNWFloat("rentPrice", false) * periods))
		data.door:SetNWEntity("tenant", ply)
		data.door:SetNWFloat("tenantExpire", CurTime() + 60 * periods * data.door:GetNWFloat("rentLength", false))
		timer.Simple(60 * periods * data.door:GetNWFloat("rentLength", false), function()
			data.door:SetNWEntity("tenant", false)
		end)
		timer.Simple(0.25, function()
			net.Start("advdoors_rent")
			net.Send(ply)
		end)
	end
end)

net.Receive("advdoors_settitle", function(len, ply)
	local data = net.ReadTable()
	if IsValid(data.door) and data.door:isDoor() and data.door:isKeysOwnedBy(ply) and #data.title < 30 and ply:GetPos():Distance(data.door:GetPos()) < 300 then
		data.door:setKeysTitle(data.title)
		net.Start("advdoors_settitle")
		net.Send(ply)
	end
end)

net.Receive("advdoors_coowneradd", function(len, ply)
	local data = net.ReadTable()
	if IsValid(data.door) and data.door:isDoor() and IsValid(ply) and ply:IsPlayer() and data.door:isKeysOwnedBy(ply) and ply:GetPos():Distance(data.door:GetPos()) < 300 and IsValid(data.ply) and data.ply:IsPlayer() then
		data.door:addKeysAllowedToOwn(data.ply)
		net.Start("advdoors_coowneradd")
		net.Send(ply)
	end
end)

net.Receive("advdoors_coownerallowedremove", function(len, ply)
	local data = net.ReadTable()
	if IsValid(data.door) and data.door:isDoor() and IsValid(ply) and ply:IsPlayer() and data.door:isMasterOwner(ply) and ply:GetPos():Distance(data.door:GetPos()) < 300 and IsValid(data.ply) and data.ply:IsPlayer() then
		data.door:removeKeysAllowedToOwn(data.ply)
		net.Start("advdoors_coownerallowedremove")
		net.Send(ply)
	end
end)

net.Receive("advdoors_coownerremove", function(len, ply)
	local data = net.ReadTable()
	if IsValid(data.door) and data.door:isDoor() and IsValid(ply) and ply:IsPlayer() and data.door:isMasterOwner(ply) and ply:GetPos():Distance(data.door:GetPos()) < 300 and IsValid(data.ply) and data.ply:IsPlayer() then
		data.door:removeKeysDoorOwner(data.ply)
		net.Start("advdoors_coownerremove")
		net.Send(ply)
	end
end)

net.Receive("advdoors_transferownership", function(len, ply)
	local data = net.ReadTable()
	if IsValid(data.door) and data.door:isDoor() and IsValid(ply) and ply:IsPlayer() and data.door:isMasterOwner(ply) and ply:GetPos():Distance(data.door:GetPos()) < 300 and IsValid(data.ply) and data.ply:IsPlayer() then
		data.door:keysUnOwn(ply)
		if data.door:GetNWEntity("tenant", false) == data.ply then
			data.door:SetNWEntity("tenant", false)
		end
		if data.door:isKeysOwnedBy(data.ply) then
			data.door:removeKeysDoorOwner(data.ply)
		end
		if data.door:isKeysAllowedToOwn(data.ply) then
			data.door:removeKeysAllowedToOwn(data.ply)
		end
		data.door:keysOwn(data.ply)
		
		timer.Simple(0.25, function()
			net.Start("advdoors_transferownership")
			net.Send(ply)
		end)
	end	
end)

net.Receive("advdoors_toggleownership", function(len, ply)
	local data = net.ReadTable()
	if IsValid(data.door) and data.door:isDoor() and IsValid(ply) and ply:IsPlayer() and ply:IsSuperAdmin() and isbool(data.state) then
		if not data.state then
			data.door:removeAllKeysAllowedToOwn()
			data.door:removeAllKeysDoorTeams()
			data.door:removeAllKeysExtraOwners()
			if AdvDoors.getOwner(data.door) then
				data.door:keysUnOwn(AdvDoors.getOwner(data.door))
			end
			data.door:SetNWBool("canRent", false)
			data.door:SetNWEntity("tenant", false)
			data.door:SetNWFloat("rentPrice", 1)
			data.door:SetNWFloat("rentLength", 1)
			data.door:SetNWFloat("rentMaxPeriods", 1)
		end
		data.door:setKeysNonOwnable(!data.state)
	end
end)

hook.Add("PlayerDisconnected", "AdvancedDoorSystem_Disconnect", function(ply)
	for _, door in pairs(ents.GetAll()) do
		if door:isDoor() and door:GetNWEntity("tenant", false) == ply then
			door:SetNWEntity("tenant", false)
		elseif door:isDoor() and door:isMasterOwner(ply) then
			door:SetNWBool("canRent", false)
			door:SetNWFloat("rentPrice", 1)
			door:SetNWFloat("rentLength", 1)
			door:SetNWFloat("rentMaxPeriods", 1)
		end
	end
end)

hook.Add("canKeysLock", "AdvancedDoorSystem_CanLock", function(ply, door)
	if door:GetNWEntity("tenant", false) == ply then
		return true
	end
end)

hook.Add("canKeysUnlock", "AdvancedDoorSystem_CanLock", function(ply, door)
	if door:GetNWEntity("tenant", false) == ply then
		return true
	end
end)