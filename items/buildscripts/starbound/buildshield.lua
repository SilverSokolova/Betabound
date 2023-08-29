function build(directory, config, parameters, level, seed)
  local configParameter = function(keyName, defaultValue) return parameters[keyName] or config[keyName] or defaultValue end
  if config.sb_builder then
    require(config.sb_builder)
    config, parameters = build(directory, config, parameters, level, seed)
  end

  local rotate = parameters.allowRotate or root.assetJson("/items/active/shields/startershield.activeitem").stances.raised.allowRotate or false
  config.stances.idle.allowRotate = rotate
  config.stances.raised.allowRotate = rotate

  config.sb_builder = nil
  require("/items/buildscripts/starbound/buildvweapon.lua")
  build(directory, config, parameters, level, seed)
  config.tooltipFields.levelLabel = config.tooltipFields.sb_levelLabel
  config.tooltipFields.level2Label = config.tooltipFields.sb_level2Label

  return config, parameters
end