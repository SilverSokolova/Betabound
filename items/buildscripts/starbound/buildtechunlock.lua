require("/scripts/sb_assetmissing.lua")

function build(_, config, parameters); sb_techType()
  parameters.techModule = isTech(parameters.techModule or randomTech())
  local tech = root.techConfig(parameters.techModule)

  local inheritedParameters = config.inheritedParameters
  for i = 1, #inheritedParameters do
    if tech[inheritedParameters[i]] then
      config[inheritedParameters[i]] = tech[inheritedParameters[i]]
    end
  end
  if tech.shortDescription then
    config.shortdescription = tech.shortDescription --My beautiful loop, RUINED by this if statement, all because of this game's inconsistency!
  end

  config.inventoryIcon = jarray()
  config.tooltipFields.subtitle = string.format(config.subtitle, root.techType(tech.name))
  table.insert(config.inventoryIcon, {image = config.backingImage})
  table.insert(config.inventoryIcon, {image = sb_assetmissing(tech.icon, "/interface/sb_tooltips/assetmissing.png")})
  return config, parameters
end

function isTech(a)
  return root.hasTech(a) and a or isTech(randomTech(a))
end

function randomTech(a)
  local tech = root.assetJson("/treasure/sb_tech.config")
  return root.assetJson("/versioning/sb_tech.config")[a] or tech[math.random(#tech)]
end