-- Uncomment the next line to disable modifications system
-- AdvDoors.SetModificationsDisabled()

AdvDoors.OpenButton = MOUSE_RIGHT -- Button for opening a door menu (when using a door display)
-- List of all available buttons: https://wiki.garrysmod.com/page/Enums/KEY

AdvDoors.Language = "English" -- Language of your addon
-- If you want to translate an addon, go to advanced-door-system/lua/advdoors/lang and create a file called your_language.lua. Then copy contents of the english.lua file and paste it into a new file.
-- Modify the first line:
-- local L = AdvDoors.LANG.RegisterLanguage("English")
-- Instead of "English", write your language's name and translate everything
-- At the end, replace a value of the variable that is written above this comment block with your language's name.

-- You can change modification prices below
AdvDoors.SetModificationPrice(ADVDOORS_MODIFICATION_DOORBELL, 10) -- Door bell
AdvDoors.SetModificationPrice(ADVDOORS_MODIFICATION_REINFORCE, 10) -- Reinforce
AdvDoors.SetModificationPrice(ADVDOORS_MODIFICATION_ALARM, 10) -- Alarm

-- You can disable certain modifications below by changing true to false
AdvDoors.SetModificationEnabled(ADVDOORS_MODIFICATION_DOORBELL, true) -- Door bell
AdvDoors.SetModificationEnabled(ADVDOORS_MODIFICATION_REINFORCE, true) -- Reinforce
AdvDoors.SetModificationEnabled(ADVDOORS_MODIFICATION_ALARM, true) -- Alarm