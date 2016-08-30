local meta = FindMetaTable("Entity")

function meta:getDoorPrice()
	if self:isDoor() and self:isKeysOwnable() then
		return AdvDoors.Configuration.getMapConfig().DoorPrices[self:EntIndex()] or false
	end
	return false
end