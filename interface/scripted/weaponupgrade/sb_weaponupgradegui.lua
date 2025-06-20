--[[
This file exists to let players ancient-upgrade weapons
that they brought to level 6 by using other means,
since the ancient upgrades have special effects.
]]

local originalInit = init or function() end
local originalPopulateItemList = populateItemList or function() end

function init() originalInit()
  self.upgradeLevel = self.upgradeLevel + 0.0001
  populateItemList = originalPopulateItemList
end

function populateItemList() end