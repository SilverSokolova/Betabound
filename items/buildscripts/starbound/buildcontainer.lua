function build(directory, config, parameters)
  local a = root.assetJson("/objects/biome/scorchedcity/scorchedcityfridge/scorchedcityfridge.object").scripts
  if a and a[1] == "/scripts/enhancedstorage.lua" then
    config.tooltipKind = "container"
    config.tooltipFields = {}
  end
  return config, parameters
end