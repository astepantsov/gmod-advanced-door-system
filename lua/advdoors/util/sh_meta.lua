local meta = FindMetaTable("Entity")

function meta:getDoorPrice()
	if self:isDoor() and self:isKeysOwnable() then
		return AdvDoors.Configuration.getMapConfig().DoorPrices[AdvDoors.getEntIndex(self)] or false
	end
	return false
end

function meta:getDoorSellPrice()
	if self:isDoor() and self:isKeysOwnable() then
		return AdvDoors.Configuration.getMapConfig().DoorPrices[AdvDoors.getEntIndex(self)] and math.Round(AdvDoors.Configuration.getMapConfig().DoorPrices[AdvDoors.getEntIndex(self)] * 2/3) or false
	end
	return false
end

function meta:isDoorBlacklisted()
	if AdvDoors.Configuration.getMapConfig().blacklistedDoors[AdvDoors.getEntIndex(self)] then
		return true
	end
	return false
end

function meta:isDoorTypeBlacklisted()
	if AdvDoors.Configuration.getGeneralConfig().doorPropBlacklist[self:GetClass()] then
		return true
	end
	return false
end