for _, door in pairs(ents.GetAll()) do
	if door:isDoor() and door:isKeysOwnable() then
		door:SetNWBool("AdvDoors_isLocked", door:isLocked())
	end
end

local function onLocked(door)
	if door:isDoor() and door:isKeysOwnable() then
		door:SetNWBool("AdvDoors_isLocked", true)
	end
end

hook.Add("onKeysLocked", "AdvancedDoorSystem_DoorLocked", onLocked)

local function onUnlocked(door)
	if door:isDoor() and door:isKeysOwnable() then
		door:SetNWBool("AdvDoors_isLocked", false)
	end
end

hook.Add("onKeysUnlocked", "AdvancedDoorSystem_DoorUnlocked", onUnlocked)