function build(directory, config, parameters, level, seed)
  local configParameter = function(keyName, defaultValue) return parameters[keyName] or config[keyName] or defaultValue end
  if parameters.sb_crafted then
    require "/scripts/util.lua"
    parameters = util.mergeTable(configParameter("sb_craftedParameters", {}), parameters)
    parameters.sb_crafted = nil
  end
  local sb_tooltipFields = config.tooltipFields or {}
  if config.sb_builder then
    require(config.sb_builder)
    config, parameters = build(directory, config, parameters, level, seed)
  end

  config.tooltipFields = sb.jsonMerge(config.tooltipFields or {}, sb_tooltipFields)
  local level = string.format("%.0f",configParameter("level", 1))
  config.tooltipFields.sb_levelLabel = "^shadow;Lvl "..level
  config.tooltipFields.sb_level2Label = "Lvl "..level

  if not config.fixedRarity then
    local rarities = {"common","uncommon","rare","legendary","essential"}
    config.rarity = rarities[root.evalFunction("sb_rarity", math.floor(configParameter("level", 1)))] or config.rarity or "legendary"
  end
  if config.rarity == "essential" and not config.tooltipFields.rarityLabel then config.tooltipFields.rarityLabel = "Epic" end
  if config.sb_subtitle and not config.tooltipFields.subtitle then config.tooltipFields.subtitle = config.sb_subtitle end

  return config, parameters
end