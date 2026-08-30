require("/scripts/sb_assetmissing.lua")

function build(directory, config, parameters)
  local item = root.itemConfig(sb_itemExists(parameters.originalItemName) and parameters.originalItemName or "cannedfood")
  local data = root.itemConfig("sb_flashfreeze").config.persistentParameters

  for i = 1, #data do
    if item.config[data[i]] then
      config[data[i]] = item.config[data[i]]
    end
  end

  require("/items/buildscripts/starbound/buildfood.lua")
  config, parameters = build(directory, config, parameters)

  return config, parameters
end