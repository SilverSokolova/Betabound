require "/scripts/util.lua"
require "/items/buildscripts/starbound/definition.lua"

function build(directory, config, parameters)
  local configParameter = function(keyName, defaultValue) return parameters[keyName] or config[keyName] or defaultValue end
  local definition = configParameter("definition",configParameter("sb_definition"))
  if not configParameter("doLeveledStatusEffects") then config.leveledStatusEffects = nil end
  if definition then
    config = applyDefinition(config, definition, configParameter("configOverrides"))
  end

  if configParameter("acceptsAugmentType") or configParameter("currentAugment") or root.assetJson("/items/armors/biome/copperarmor/copperarmor.head").acceptsAugmentType then
    config.tooltipKind = "sb_armoraugment"
    parameters.acceptsAugmentType = configParameter("acceptsAugmentType","back")
  else
    config.tooltipKind = "sb_armor"
  end

  if parameters.tooltipKind == "sb_armoraugment" then parameters.tooltipKind = nil end --fix for uninstalls :(

  config.tooltipFields = config.tooltipFields or {}
  local level = configParameter("level")
  config.price = (config.price or 10) * root.evalFunction("itemLevelPriceMultiplier", level or 1)
  if level and configParameter("leveledStatusEffects", configParameter("statusEffects")) then --check for status effects to prevent merchants from assigning a level to cosmetics
    level = "Lvl "..string.format("%.0f",level)
    config.tooltipFields.levelLabel = "^shadow;"..level
    config.tooltipFields.level2Label = level
  end
  return config, parameters
end