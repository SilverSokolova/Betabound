function build(directory, config, parameters)
  local configParameter = function(keyName, defaultValue) return parameters[keyName] or config[keyName] or defaultValue end
  build = nil
  require("/items/buildscripts/buildfist.lua")
  config, parameters = build(directory, config, parameters)
  config.tooltipFields = config.tooltipFields or {}
  local level = string.format("%.0f",configParameter("level", 1))
  config.tooltipFields.levelLabel = "^shadow;Lvl "..level
  config.tooltipFields.level2Label = "Lvl "..level
  return config, parameters
end