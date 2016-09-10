local meta = FindMetaTable("Entity")

function meta:getDoorPrice()
	if self:isDoor() and self:isKeysOwnable() then
		return AdvDoors.Configuration.getMapConfig().DoorPrices[self:EntIndex()] and AdvDoors.Configuration.getMapConfig().DoorPrices[self:EntIndex()].Buy or false
	end
	return false
end

function meta:getDoorSellPrice()
	if self:isDoor() and self:isKeysOwnable() then
		return AdvDoors.Configuration.getMapConfig().DoorPrices[self:EntIndex()] and AdvDoors.Configuration.getMapConfig().DoorPrices[self:EntIndex()].Sell or false
	end
	return false
end