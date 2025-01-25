function build(directory, config, parameters, level, seed)
  local configParameter = function(keyName, defaultValue) return parameters[keyName] or config[keyName] or defaultValue end
  build = nil
  if config.sb_builder then
    require(config.sb_builder)
    config, parameters = build(directory, config, parameters, level, seed)
  end
  config.tooltipFields = config.tooltipFields or {}
  local level = string.format("%.0f", configParameter("level", 1))
  config.tooltipFields.sb_levelLabel = "^shadow;Lvl "..level
  config.tooltipFields.sb_level2Label = "Lvl "..level
  return config, parameters
end