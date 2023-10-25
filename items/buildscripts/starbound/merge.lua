function build(directory, config, parameters, level, seed)
  local configParameter = function(keyName, defaultValue) return parameters[keyName] or config[keyName] or defaultValue end
  build = nil
  if config.sb_builder then
    require(config.sb_builder)
    config, parameters = build(directory, config, parameters, level, seed)
  end
  config = util.mergeTable(config, configParameter("sb_merge", {}))
  return config, parameters
end