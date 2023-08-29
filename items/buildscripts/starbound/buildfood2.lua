function build(directory, config, parameters)
  build = nil
  require("/items/buildscripts/buildfood.lua")
  config, parameters = build(directory, config, parameters)
  config.tooltipFields = config.tooltipFields or {}
  config.tooltipFields["rotTimeLabel"] = ""
  return config, parameters
end