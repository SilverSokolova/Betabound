function build(directory, config, parameters)
  config.builder = nil
  config = sb.jsonMerge(root.assetJson(config.originalItemName:sub(1, 1) == "/" and config.originalItemName or (directory .. config.originalItemName)), config)

  if config.builder then
    require(config.builder)
    config, parameters = build(directory,config,parameters)
  end

  --Sucks that this doesn't grab itemTags according to root.itemHasTag but oh well
  return config, parameters
end