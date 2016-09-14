if CLIENT then
	AdvDoors.MenuTabs = AdvDoors.MenuTabs or {}
    AdvDoors.DownloadMaterial = function(url, callback)
        local crc = util.CRC(url)
        
        if file.Exists("advdoors/materials/" .. crc .. ".png", "DATA") then
            local mat = Material("../data/advdoors/materials/" .. crc .. ".png", "smooth")
            callback(mat)
        end

        http.Fetch(url, function(body)
            file.Write("advdoors/materials/" .. crc .. ".png", body)
            
            local mat = Material("../data/advdoors/materials/" .. crc .. ".png", "smooth")
            callback(mat)
        end)
    end 
	
	AdvDoors.AddMenuTab = function(tab, id)
		if !id then
			table.insert(AdvDoors.MenuTabs, tab)
		else
			AdvDoors.MenuTabs[id] = tab
		end
	end
end

AdvDoors.isLocked = function(door)
	return door:GetNWBool("AdvDoors_isLocked", false)
end

AdvDoors.getOwner = function(door)
	if door:getDoorOwner() and door:getDoorOwner() != nil and IsValid(door:getDoorOwner()) then
		return door:getDoorOwner()
	end
	return false
end
	
AdvDoors.getOwnerName = function(door)
	if door:getDoorOwner() and door:getDoorOwner() != nil and IsValid(door:getDoorOwner()) then
		return door:getDoorOwner():Nick()
	end
	return false
end
	
AdvDoors.getOwnerSteamID64 = function(door)
	if door:getDoorOwner() and door:getDoorOwner() != nil and IsValid(door:getDoorOwner()) then
		return door:getDoorOwner():SteamID64()
	end
	return false
end

AdvDoors.getByUserID = function(userid)
	for k,v in ipairs(player.GetAll()) do
		if v:UserID() == userid then
			return v
		end
	end
	return false
end

AdvDoors.hasValidCoowner = function(coOwners)
	for k,v in pairs(coOwners) do
		local ply = AdvDoors.getByUserID(k)
		if IsValid(ply) and ply:IsPlayer() then 
			return true 
		end
	end
	return false
end

AdvDoors.getEntIndex = function(ent)
	return ent:EntIndex() - game.MaxPlayers()
end

AdvDoors.hasJobRestriction = function(door)
	if AdvDoors.Configuration.getMapConfig().DoorJobs[AdvDoors.getEntIndex(door)] then
		for k,v in pairs(AdvDoors.Configuration.getMapConfig().DoorJobs[AdvDoors.getEntIndex(door)]) do
			if v then
				return true
			end
		end
	end
	return false
end

AdvDoors.getDoorList = function(door)
	local temp = 0
	if AdvDoors.Configuration.getMapConfig().DoorJobs[AdvDoors.getEntIndex(door)] then
		for k,v in pairs(AdvDoors.Configuration.getMapConfig().DoorJobs[AdvDoors.getEntIndex(door)]) do
			if v then
				temp = temp + 1
			end
		end
		return temp
	end
	return false
end

AdvDoors.jobList = function(jobs)
	local temp = 0
	if jobs then
		for k,v in pairs(jobs) do
			if v then
				temp = temp + 1
			end
		end
		return temp
	end
	return false
end

AdvDoors.isTeamAllowedToBuyDoor = function(door, team)
	if AdvDoors.Configuration.getMapConfig().DoorJobs[AdvDoors.getEntIndex(door)] and #AdvDoors.Configuration.getMapConfig().DoorJobs[AdvDoors.getEntIndex(door)] > 0 and AdvDoors.hasJobRestriction(door) then
		for k,v in pairs(AdvDoors.Configuration.getMapConfig().DoorJobs[AdvDoors.getEntIndex(door)]) do
			if k == team and v then
				return true
			end
		end
		return false
	end
	return true
end