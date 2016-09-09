if CLIENT then
	AdvDoors.MenuTabs = {}
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