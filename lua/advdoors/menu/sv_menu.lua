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
util.AddNetworkString("advdoors_addblacklist")
util.AddNetworkString("advdoors_removeblacklist")
util.AddNetworkString("advdoors_addjob")
util.AddNetworkString("advdoors_setgroup")
util.AddNetworkString("advdoors_jobremove")
util.AddNetworkString("advdoors_anyplayer")
util.AddNetworkString("advdoors_addjobplayer")
util.AddNetworkString("advdoors_jobremoveplayer")
util.AddNetworkString("advdoors_changeprice")
util.AddNetworkString("advdoors_otheractions")

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
		AdvDoors.RemoveAllModifications(door)
		net.Start("advdoors_sold")
		net.Send(ply)
	end
end

hook.Add("playerKeysSold", "AdvancedDoorSystem_DoorSold", soldDoor)

local function resetJobRestriction(door)
	AdvDoors.Configuration.getMapConfig().DoorJobs[AdvDoors.getEntIndex(door)] = {}
	AdvDoors.Configuration.Save(AdvDoors.Configuration.Loaded)
	AdvDoors.Configuration.Broadcast()
end

local function resetRent(door)
	door:SetNWBool("canRent", false)
	door:SetNWEntity("tenant", false)
	door:SetNWFloat("rentPrice", 1)
	door:SetNWFloat("rentLength", 1)
	door:SetNWFloat("rentMaxPeriods", 1)
end

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
				net.WriteString(AdvDoors.LANG.GetString("rent_updated"))
				net.Send(ply)
			end)
		else
			net.Start("advdoors_updaterent")
			net.WriteString(AdvDoors.LANG.GetString("rent_not_updated"))
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
			AdvDoors.RemoveAllModifications(data.door)
			if AdvDoors.getOwner(data.door) then
				data.door:keysUnOwn(AdvDoors.getOwner(data.door))
			end
			resetRent(data.door)
		end
		data.door:setKeysNonOwnable(!data.state)
		net.Start("advdoors_toggleownership")
		net.Send(ply)
	end
end)

net.Receive("advdoors_addblacklist", function(len, ply)
	local data = net.ReadTable()
	if IsValid(data.door) and data.door:isDoor() and IsValid(ply) and ply:IsPlayer() and ply:IsSuperAdmin() and data.option == 1 or data.option == 2 then
		if data.option == 1 then
			AdvDoors.Configuration.getMapConfig().blacklistedDoors[AdvDoors.getEntIndex(data.door)] = true
		elseif data.option == 2 then
			AdvDoors.Configuration.getGeneralConfig().doorPropBlacklist[data.door:GetClass()] = true
		end
		AdvDoors.Configuration.Save(AdvDoors.Configuration.Loaded)
		AdvDoors.Configuration.Broadcast()
		net.Start("advdoors_addblacklist")
		net.Send(ply)
	end
end)

net.Receive("advdoors_removeblacklist", function(len, ply)
	local ent = net.ReadEntity()
	if IsValid(ent) and ent:isDoor() and IsValid(ply) and ply:IsPlayer() and ply:IsSuperAdmin() then
		AdvDoors.Configuration.getMapConfig().blacklistedDoors[AdvDoors.getEntIndex(ent)] = false
		AdvDoors.Configuration.getGeneralConfig().doorPropBlacklist[ent:GetClass()] = false
		AdvDoors.Configuration.Save(AdvDoors.Configuration.Loaded)
		AdvDoors.Configuration.Broadcast()
		net.Start("advdoors_removeblacklist")
		net.Send(ply)
	end
end)

net.Receive("advdoors_addjob", function(len, ply)
	local data = net.ReadTable()
	if IsValid(data.door) and data.door:isDoor() and IsValid(ply) and ply:IsPlayer() and ply:IsSuperAdmin() and team.GetName(data.job) != "" then
		data.door:removeAllKeysAllowedToOwn()
		data.door:removeAllKeysExtraOwners()
		AdvDoors.RemoveAllModifications(data.door)
		resetJobRestriction(data.door)
		data.door:setDoorGroup(nil)
		if AdvDoors.getOwner(data.door) then
			data.door:keysUnOwn(AdvDoors.getOwner(data.door))
		end
		resetRent(data.door)
		data.door:addKeysDoorTeam(data.job)
		DarkRP.storeTeamDoorOwnability(data.door)
		DarkRP.storeDoorGroup(data.door, nil)
		net.Start("advdoors_addjob")
		net.Send(ply)
	end
end)

net.Receive("advdoors_setgroup", function(len, ply)
	local data = net.ReadTable()
	if IsValid(data.door) and data.door:isDoor() and IsValid(ply) and ply:IsPlayer() and ply:IsSuperAdmin() then
		data.door:removeAllKeysAllowedToOwn()
		data.door:removeAllKeysDoorTeams()
		AdvDoors.RemoveAllModifications(data.door)
		data.door:removeAllKeysExtraOwners()
		resetJobRestriction(data.door)
		if AdvDoors.getOwner(data.door) then
			data.door:keysUnOwn(AdvDoors.getOwner(data.door))
		end
		resetRent(data.door)
		data.door:setDoorGroup(data.group)
		DarkRP.storeDoorGroup(data.door, data.group)
		DarkRP.storeTeamDoorOwnability(data.door)
		net.Start("advdoors_setgroup")
		net.Send(ply)
	end
end)

net.Receive("advdoors_jobremove", function(len, ply)
	local data = net.ReadTable()
	if IsValid(data.door) and data.door:isDoor() and IsValid(ply) and ply:IsPlayer() and ply:IsSuperAdmin() then
		data.door:removeKeysDoorTeam(data.job)
		DarkRP.storeTeamDoorOwnability(data.door)
		net.Start("advdoors_jobremove")
		net.Send(ply)
	end
end)

net.Receive("advdoors_anyplayer", function(len, ply)
	local data = net.ReadEntity()
	if IsValid(data) and data:isDoor() and IsValid(ply) and ply:IsPlayer() and ply:IsSuperAdmin() then
		data:removeAllKeysAllowedToOwn()
		data:removeAllKeysDoorTeams()
		AdvDoors.RemoveAllModifications(data)
		data:removeAllKeysExtraOwners()
		resetJobRestriction(data)
		if AdvDoors.getOwner(data) then
			data:keysUnOwn(AdvDoors.getOwner(data))
		end
		resetRent(data)
		data:setDoorGroup(nil)
		DarkRP.storeDoorGroup(data, nil)
		DarkRP.storeTeamDoorOwnability(data)
		net.Start("advdoors_anyplayer")
		net.Send(ply)
	end
end)

net.Receive("advdoors_addjobplayer", function(len, ply)
	local data = net.ReadTable()
	if IsValid(data.door) and data.door:isDoor() and IsValid(ply) and ply:IsPlayer() and ply:IsSuperAdmin() and team.GetName(data.job) != "" then
		if not AdvDoors.Configuration.getMapConfig().DoorJobs[AdvDoors.getEntIndex(data.door)] then AdvDoors.Configuration.getMapConfig().DoorJobs[AdvDoors.getEntIndex(data.door)] = {} end
		AdvDoors.Configuration.getMapConfig().DoorJobs[AdvDoors.getEntIndex(data.door)][data.job] = true
		AdvDoors.Configuration.Save(AdvDoors.Configuration.Loaded)
		AdvDoors.Configuration.Broadcast()
		net.Start("advdoors_addjobplayer")
		net.Send(ply)
	end
end)

net.Receive("advdoors_jobremoveplayer", function(len, ply)
	local data = net.ReadTable()
	if IsValid(data.door) and data.door:isDoor() and IsValid(ply) and ply:IsPlayer() and ply:IsSuperAdmin() then
		if not AdvDoors.Configuration.getMapConfig().DoorJobs[AdvDoors.getEntIndex(data.door)] then AdvDoors.Configuration.getMapConfig().DoorJobs[AdvDoors.getEntIndex(data.door)] = {} end
		AdvDoors.Configuration.getMapConfig().DoorJobs[AdvDoors.getEntIndex(data.door)][data.job] = false
		AdvDoors.Configuration.Save(AdvDoors.Configuration.Loaded)
		AdvDoors.Configuration.Broadcast()
		net.Start("advdoors_jobremoveplayer")
		net.Send(ply)
	end
end)

net.Receive("advdoors_changeprice", function(len, ply)
	local data = net.ReadTable()
	if IsValid(data.door) and data.door:isDoor() and IsValid(ply) and ply:IsPlayer() and ply:IsSuperAdmin() and tonumber(data.price) and math.Round(tonumber(data.price)) >= 1 then
		AdvDoors.Configuration.getMapConfig().DoorPrices[AdvDoors.getEntIndex(data.door)] = math.Round(tonumber(data.price))
		AdvDoors.Configuration.Save(AdvDoors.Configuration.Loaded)
		AdvDoors.Configuration.Broadcast()
		net.Start("advdoors_changeprice")
		net.Send(ply)
	end
end)

net.Receive("advdoors_otheractions", function(len, ply)
	local data = net.ReadTable()
	if IsValid(data.door) and data.door:isDoor() and IsValid(ply) and ply:IsPlayer() and ply:IsSuperAdmin() and data.actionID == 1 or data.actionID == 2 or data.actionID == 3 or data.actionID == 4 then
		if data.actionID == 1 or data.actionID == 4 then
			if AdvDoors.getOwner(data.door) then
				data.door:keysUnOwn(AdvDoors.getOwner(data.door))
				resetRent(data.door)
				AdvDoors.RemoveAllModifications(data.door)
			end
		end
		if data.actionID == 2 or data.actionID == 4 then
			data.door:removeAllKeysAllowedToOwn()
			data.door:removeAllKeysExtraOwners()
		end
		if data.actionID == 3 or data.actionID == 4 then
			data.door:SetNWEntity("tenant", false)
			data.door:SetNWFloat("tenantExpire", CurTime())
		end
		net.Start("advdoors_otheractions")
		net.Send(ply)
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
			AdvDoors.RemoveAllModifications(door)
		end
	end
end)

hook.Add("canKeysLock", "AdvancedDoorSystem_CanLock", function(ply, door)
	if door:GetNWEntity("tenant", false) == ply then
		return true
	end
end)

hook.Add("canKeysUnlock", "AdvancedDoorSystem_CanUnlock", function(ply, door)
	if door:GetNWEntity("tenant", false) == ply then
		return true
	end
end)

hook.Add("playerBuyDoor", "AdvancedDoorSystem_CanBuy", function(ply, door)
	if IsValid(ply) and ply:IsPlayer() and IsValid(door) and door:isDoor() and door:isKeysOwnable() then
		if AdvDoors.hasJobRestriction(door) then
			if AdvDoors.isTeamAllowedToBuyDoor(door, ply:Team()) then
				return true
			else
				return false, AdvDoors.LANG.GetString("has_job_restr"), false
			end
		else
			return true
		end
	end
	return false, AdvDoors.LANG.GetString("cannot_buy"), false
end)