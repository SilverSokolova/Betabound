function applyDefinition(config, definition, configOverrides)
  if definition then
    if type(definition) == "string" then
      definition = {definition}
    end
    for i = 1, #definition do
      util.mergeTable(config, root.assetJson("/sb_definitions/"..definition[i]..".config"))
    end
  end
  if configOverrides then util.mergeTable(config, configOverrides) end
  return config
end