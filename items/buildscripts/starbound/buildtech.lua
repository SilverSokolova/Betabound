require("/scripts/sb_assetmissing.lua")
function build(directory, config, parameters); sb_techType()
  config.techModule = isTech(parameters.techModule or randomTech())
  parameters.techModule = config.techModule
  local tech = root.techConfig(isTech(parameters.techModule))
  config.shortdescription = tech.shortDescription or config.shortdescription
  config.description = tech.description or config.description
  config.rarity = tech.rarity or "rare"
  config.tooltipKind = tech.tooltipKind or config.tooltipKind
  config.inventoryIcon = jarray(); config.tooltipFields = tech.tooltipFields or config.tooltipFields
  config.tooltipFields.subtitle = string.format(config.subtitle, root.techType(tech.name))
  table.insert(config.inventoryIcon, {image = "/tech/starbound/banana.png"})
  table.insert(config.inventoryIcon, {image = sb_assetmissing(tech.icon, "/interface/sb_tooltips/assetmissing.png")})
  return config, parameters
end

function isTech(a)
  return root.hasTech(a) and a or isTech(randomTech(a))
end

function randomTech(a)
  local tech = root.assetJson("/tech/starbound/tech.config")
  return root.assetJson("/versioning/sb_tech.config")[a] or tech[math.random(#tech)]
end