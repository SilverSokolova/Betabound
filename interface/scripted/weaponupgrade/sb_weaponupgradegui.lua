--[[
This file exists to let players ancient-upgrade weapons
that they brought to level 6 by using other means,
since the ancient upgrades have special effects.
]]

local originalInit = init or function() end
local originalPopulateItemList = populateItemList or function() end

function populateItemList() end --Kill this so it doesn't run in originalInit before we override self.upgradeLevel

function init() originalInit()
  self.upgradeLevel = self.upgradeLevel + 0.0001
  populateItemList = originalPopulateItemList
end