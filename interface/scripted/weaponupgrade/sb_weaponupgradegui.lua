--[[
This file exists to let players ancient-upgrade weapons
that they brought to level 6 via other means, to get
upgradeParameters applied.
]]

local originalInit = init or function() end
local originalPopulateItemList = populateItemList or function() end

function populateItemList() end --Kill this so it doesn't run in originalInit before we override self.upgradeLevel

function init() originalInit()
  self.upgradeLevel = self.upgradeLevel + 0.0001
  populateItemList = originalPopulateItemList
end