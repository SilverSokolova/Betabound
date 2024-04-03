function build(directory, config, parameters, level, seed)
  if config.sb_builder then
    require(config.sb_builder)
    config, parameters = build(directory, config, parameters, level, seed)
  end

  --Make stunmines stack ಠ_ಠ
  if config.retainScriptStorageInItem then
    if not parameters.scriptStorage then
      parameters.scriptStorage = {}
      parameters.inventoryIcon = config.icons.full --Don't check for an existing icon because they should be the same
    end
  end
  return config, parameters
end