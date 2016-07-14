if CLIENT then
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

    AdvDoors.isLocked = function(door)
        return door:GetNWBool("AdvDoors_isLocked", false)
    end

    AdvDoors.getOwnerName = function(door)
        if door:getDoorOwner() and door:getDoorOwner() != nil and IsValid(door:getDoorOwner()) then
            return door:getDoorOwner():Nick()
        end
        return false
    end
end