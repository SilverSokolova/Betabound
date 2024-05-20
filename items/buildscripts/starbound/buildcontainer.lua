function build(directory, config, parameters)
  local a = root.assetJson("/objects/biome/scorchedcity/scorchedcityfridge/scorchedcityfridge.object").scripts
  if a and a[1] == "/scripts/enhancedstorage.lua" then
    config.tooltipKind = "container"
    config.tooltipFields = {}
  else
    local slotCount = parameters.slotCount or config.slotCount
    if slotCount then
      config.tooltipFields = config.tooltipFields or {}
      config.tooltipFields.slotCountLabel = string.format(root.assetJson("/interface/tooltips/sb_container.tooltip").slotCountLabel.value, ""..slotCount)
    end
  end
  return config, parameters
end