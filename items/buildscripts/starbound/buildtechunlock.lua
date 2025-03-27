require("/scripts/sb_assetmissing.lua")

function build(_, config, parameters, level); 
  sb_techType()
  parameters.techModule = isTech(parameters.techModule or randomTech(nil, math.max(math.floor(level or 1), 1)))
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
  table.insert(config.inventoryIcon, {image = sb_assetmissing(tech.icon)})
  return config, parameters
end

function isTech(tech)
  return root.hasTech(tech) and tech or isTech(randomTech(tech))
end


function randomTech(tech, level)
  local techs = root.assetJson("/treasure/sb_tech.config")
  techs = level and techs[tostring(level)] or techs["1"] --techs[tostring(math.random(2) == 1 and math.random(math.max(level - 1, 1)) or level)] or techs["1"]
  return root.assetJson("/versioning/sb_tech.config")[tech] or techs[math.random(#techs)]
end