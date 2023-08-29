function build(directory, config, parameters)
  config.builder = nil
  config = sb.jsonMerge(root.assetJson(config.sb_itemName:sub(1,1) == "/" and config.sb_itemName or (directory..config.sb_itemName)),config)

  if config.builder then
    require(config.builder)
    config, parameters = build(directory,config,parameters)
  end

  --Sucks that this doesn't grab itemTags according to root.itemHasTag but oh well
  return config, parameters
end