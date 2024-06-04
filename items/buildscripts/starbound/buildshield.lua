function build(directory, config, parameters, level, seed)
  require("/items/buildscripts/starbound/buildvweapon.lua")
  build(directory, config, parameters, level, seed)
  local rotate = parameters.allowRotate or root.assetJson("/items/active/shields/startershield.activeitem").stances.raised.allowRotate or false
  config.stances.idle.allowRotate = rotate
  config.stances.raised.allowRotate = rotate

  return config, parameters
end